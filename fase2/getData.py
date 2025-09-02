"""
Script para leer y parsear datos del Arduino via puerto serial
Lee datos cada 20 segundos y los parsea según formato específico
"""

import serial
import time
import re
from datetime import datetime


class ArduinoDataReader:
    def __init__(self, port='/dev/ttyACM0', baudrate=9600, timeout=1):
        """
        Inicializa el lector de datos del Arduino
        """
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.serial_connection = None

    """
    FUNCIONES PRINCIPALES
    - connect(): Establece conexión con el puerto serial
    - disconnect(): Cierra la conexión serial
    - read_raw_data(): Lee datos crudos del puerto serial
    - parse_all_data(raw_lines): Parsea todas las líneas de datos recibidas
    """    
    def connect(self):
        """Establece conexión con el puerto serial"""
        try:
            self.serial_connection = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout
            )
            print(f"Conectado al puerto {self.port} a {self.baudrate} baudios")
            time.sleep(2) 
            return True
        except serial.SerialException as e:
            print(f"Error conectando al puerto {self.port}: {e}")
            return False
    
    def disconnect(self):
        """Cierra la conexión serial"""
        if self.serial_connection and self.serial_connection.is_open:
            self.serial_connection.close()
            print("Conexión serial cerrada")
    
    def read_raw_data(self):
        """Lee datos crudos del puerto serial"""
        if not self.serial_connection or not self.serial_connection.is_open:
            return None
        
        try:
            # Leer todas las líneas disponibles
            lines = []
            start_time = time.time()
            
            while time.time() - start_time < 5:  # Timeout de 5 segundos
                if self.serial_connection.in_waiting > 0:
                    line = self.serial_connection.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        lines.append(line)
                time.sleep(0.1)
            
            return lines
        except Exception as e:
            print(f"Error leyendo datos: {e}")
            return None
    
    def parse_mqa_data(self, line):
        """Parsea datos MQA"""
        if line.startswith('MQA:'):
            parts = line.split(':')
            if len(parts) >= 4:
                return {
                    'tipo': 'MQA',
                    'mq1': float(parts[1]),
                    'mq2': float(parts[2]),
                    'mq3': float(parts[3])
                }
        return None
    
    def parse_distance_data(self, line):
        """Parsea datos de distancia"""
        if re.match(r'^D\d+:', line) or line.startswith('D'):
            distances = {}
            pattern = r'D(\d+):\s*([\d.]+)\s*cm'
            matches = re.findall(pattern, line)
            
            for sensor_num, distance in matches:
                distances[int(sensor_num)] = float(distance)
            
            if distances:
                return {
                    'tipo': 'DISTANCIA',
                    'sensores': distances
                }
        return None
    
    def parse_semaforo_data(self, line):
        """Parsea datos de semáforos"""
        if line.startswith('SEMAFORO:'):
            parts = line.split(':')
            if len(parts) >= 3:
                return {
                    'tipo': 'SEMAFORO',
                    'numero': int(parts[1]),
                    'estado': parts[2]
                }
        return None
    
    def parse_bus_data(self, line):
        """Parsea datos de autobuses"""
        if line.startswith('BUS:'):
            parts = line.split(':')
            if len(parts) >= 4:
                return {
                    'tipo': 'BUS',
                    'sistema': parts[1],
                    'linea': int(parts[2]),
                    'valor': int(parts[3])
                }
        return None
    
    def parse_incendio_data(self, line):
        """Parsea datos de sensores de incendio"""
        if line.startswith('INCENDIO:'):
            parts = line.split(':')
            if len(parts) >= 4:
                return {
                    'tipo': 'INCENDIO',
                    'sensor': int(parts[1]),
                    'valor': int(parts[2]),
                    'estado': parts[3]
                }
        return None
    
    def parse_sismo_data(self, line):
        """Parsea datos de sensor sísmico"""
        if line.startswith('SISMO:'):
            parts = line.split(':')
            if len(parts) >= 3:
                return {
                    'tipo': 'SISMO',
                    'intensidad': parts[1],
                    'valor': int(parts[2])
                }
        return None
    
    def parse_sistema_data(self, line):
        """Parsea estado del sistema"""
        if line.startswith('SISTEMA:'):
            parts = line.split(':')
            if len(parts) >= 3:
                return {
                    'tipo': 'SISTEMA',
                    'estado': parts[1],
                    'timestamp': int(parts[2])
                }
        return None
    
    def parse_panico_data(self, line):
        """Parsea alertas de pánico"""
        if line.startswith('PANICO:'):
            parts = line.split(':')
            if len(parts) >= 3:
                return {
                    'tipo': 'PANICO',
                    'zona': int(parts[1]),
                    'timestamp': int(parts[2])
                }
        return None
    
    def parse_infraccion_data(self, line):
        """Parsea alertas de infracción"""
        if line.startswith('INFRACCION:'):
            parts = line.split(':')
            if len(parts) >= 3:
                return {
                    'tipo': 'INFRACCION',
                    'sensor': int(parts[1]),
                    'timestamp': int(parts[2])
                }
        return None
    
    # VAMOS A HACER EL PARSER DE LAS ALERTAS
    
    def parse_all_data(self, raw_lines):
        """Parsea todas las líneas de datos recibidas y organiza por tipo"""
        current_timestamp = datetime.now().isoformat()
        parsed_data = {
            'timestamp': current_timestamp,
            'datos': {},
            'alertas': []
        }
        
        for line in raw_lines:
            try:
                # Intentar parsear cada tipo de dato
                parsers = [
                    self.parse_mqa_data,
                    self.parse_distance_data,
                    self.parse_semaforo_data,
                    self.parse_bus_data,
                    self.parse_incendio_data,
                    self.parse_sismo_data,
                    self.parse_sistema_data,
                    self.parse_panico_data,
                    self.parse_infraccion_data
                ]
                
                for parser in parsers:
                    result = parser(line)
                    if result:
                        tipo = result['tipo']
                        if tipo not in parsed_data['datos']:
                            parsed_data['datos'][tipo] = []
                        parsed_data['datos'][tipo].append(result)
                        
                        # Clasificar como alerta si es PANICO, INFRACCION, o tipos con estado de alerta
                        if tipo in ['PANICO', 'INFRACCION']:
                            result['timestamp_registrado'] = current_timestamp
                            parsed_data['alertas'].append(result)
                        elif tipo == 'INCENDIO' and result.get('estado') == 'ALERTA':
                            result['timestamp_registrado'] = current_timestamp
                            parsed_data['alertas'].append(result)
                        elif tipo == 'SISMO' and result.get('intensidad') == 'ALTO':
                            result['timestamp_registrado'] = current_timestamp
                            parsed_data['alertas'].append(result)
                        break
                else:
                    # Si no se pudo parsear, guardar como dato crudo
                    if line.strip():
                        if 'DESCONOCIDO' not in parsed_data['datos']:
                            parsed_data['datos']['DESCONOCIDO'] = []
                        parsed_data['datos']['DESCONOCIDO'].append({
                            'tipo': 'DESCONOCIDO',
                            'data_cruda': line.strip()
                        })
            except Exception as e:
                print(f"Error parseando línea '{line}': {e}")
                if 'DESCONOCIDO' not in parsed_data['datos']:
                    parsed_data['datos']['DESCONOCIDO'] = []
                parsed_data['datos']['DESCONOCIDO'].append({
                    'tipo': 'DESCONOCIDO',
                    'data_cruda': line.strip(),
                    'error': str(e)
                })
        
        return parsed_data
    
    
    def run_continuous(self, interval=20):
        """Ejecuta lectura continua cada X segundos"""
        print(f"Iniciando lectura continua cada {interval} segundos...")
        
        
        try:
            while True:
                print(f"\n Leyendo datos... [{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}]")
                
                raw_data = self.read_raw_data()
                if raw_data:
                    parsed_data = self.parse_all_data(raw_data)
                    
                    hora = parsed_data['timestamp']
                    
                    # Imprimir en el formato solicitado
                    
                    # Semáforos
                    if 'SEMAFORO' in parsed_data['datos']:
                        print("Semáforos:")
                        for item in sorted(parsed_data['datos']['SEMAFORO'], key=lambda x: x['numero']):
                            print(f"Semaforo{item['numero']}  {item['estado']}  {hora}")
                    
                    # HC04 (Distancias)
                    if 'DISTANCIA' in parsed_data['datos']:
                        print("HC04:")
                        for dist_item in parsed_data['datos']['DISTANCIA']:
                            sensores = dist_item['sensores']
                            for num in sorted(sensores.keys()):
                                print(f"HC04{num}  {sensores[num]}  {hora}")
                    
                    # BUS
                    if 'BUS' in parsed_data['datos']:
                        print("BUS:")
                        for item in parsed_data['datos']['BUS']:
                            if item['sistema'] == 'TRANSMETRO':
                                print(f"Transmetro  {item['valor']}  {hora}")
                            elif item['sistema'] == 'TRANSURBANO':
                                print(f"Transurbano  {item['valor']}  {hora}")
                    
                    # MQ (desde MQA, cada valor corresponde a un MQ)
                    if 'MQA' in parsed_data['datos']:
                        print("MQ:")
                        for item in parsed_data['datos']['MQA']:
                            print(f"MQ1  {item['mq1']}  {hora}")
                            print(f"MQ2  {item['mq2']}  {hora}")
                            print(f"MQ3  {item['mq3']}  {hora}")
                    
                    # Alertas
                    if parsed_data['alertas']:
                        for alerta in parsed_data['alertas']:
                            if alerta['tipo'] == 'PANICO':
                                print(f"ALERTA PANICO(Zona {alerta['zona']}) {alerta['timestamp_registrado']}")
                            elif alerta['tipo'] == 'INFRACCION':
                                print(f"ALERTA INFRACCION(Sensor {alerta['sensor']}) {alerta['timestamp_registrado']}")
                            elif alerta['tipo'] == 'INCENDIO':
                                print(f"ALERTA INCENDIO(Sensor {alerta['sensor']}, Valor: {alerta['valor']}) {alerta['timestamp_registrado']}")
                            elif alerta['tipo'] == 'SISMO':
                                print(f"ALERTA SISMO {alerta['timestamp_registrado']}")
                
                else:
                    print(" No se recibieron datos")
                
                print(f" Esperando {interval} segundos")
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print("\n Lectura detenida por el usuario")
        except Exception as e:
            print(f" Error durante la lectura continua: {e}")
        finally:
            self.disconnect()


def main():
    reader = ArduinoDataReader(port='/dev/ttyACM0', baudrate=9600)
    
    if reader.connect():
        try:
            reader.run_continuous(interval=1)
            
        finally:
            reader.disconnect()


if __name__ == "__main__":
    main()