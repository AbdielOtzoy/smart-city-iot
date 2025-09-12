import serial
import time
from datetime import datetime
import json
import paho.mqtt.client as mqtt

class ArduinoRawReader:
    def __init__(self, port='/dev/ttyACM0', baudrate=9600, timeout=1, mqtt_broker='broker.emqx.io', mqtt_port=1883):
        """
        Inicializa el lector de datos crudos del Arduino y cliente MQTT
        """
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.serial_connection = None
        self.mqtt_client = mqtt.Client()  # Usa API por defecto
        self.mqtt_broker = mqtt_broker
        self.mqtt_port = mqtt_port
        self.mqtt_topics = {
            "trafico": "Data/Grupo2/ACE2/2S2025/Trafico",
            "bus": "Data/Grupo2/ACE2/2S2025/Bus",
            "distancias": "Data/Grupo2/ACE2/2S2025/Distancias",
            "incendio": "Data/Grupo2/ACE2/2S2025/Incendio",
            "ambiente": "Data/Grupo2/ACE2/2S2025/Ambiente",
            "sismo": "Data/Grupo2/ACE2/2S2025/Sismo",
            "panico": "Data/Grupo2/ACE2/2S2025/Panico",
            "infraccion": "Data/Grupo2/ACE2/2S2025/Infraccion"
        }

    def connect(self):
        """Establece conexión con el puerto serial y el broker MQTT"""
        try:
            self.serial_connection = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout
            )
            print(f"Conectado al puerto {self.port} a {self.baudrate} baudios")
            time.sleep(2)  # Esperar a que la conexión serial se estabilice
        except serial.SerialException as e:
            print(f"Error conectando al puerto {self.port}: {e}")
            return False

        try:
            self.mqtt_client.connect(self.mqtt_broker, self.mqtt_port, 60)
            print(f"Conectado al broker MQTT {self.mqtt_broker}:{self.mqtt_port}")
        except Exception as e:
            print(f"Error conectando al broker MQTT: {e}")
            return False

        return True
    
    def disconnect(self):
        """Cierra la conexión serial y el cliente MQTT"""
        if self.serial_connection and self.serial_connection.is_open:
            self.serial_connection.close()
            print("Conexión serial cerrada")
        self.mqtt_client.disconnect()
        print("Conexión MQTT cerrada")
    
    def _hora_actual_iso(self):
        # Hora en formato ISO 8601 para claridad
        return datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    
    def parse_raw_data(self, lines):
        """Convierte datos crudos en objetos JSON separados por categoría"""
        if not lines:
            return None

        # Inicializar estructuras JSON
        data = {
            "trafico": {"semaforos": {}},
            "bus": {},
            "distancias": {},
            "incendio": [],
            "ambiente": {"mq_sensors": []},
            "sismo": {},
            "panico": [],
            "infraccion": []
        }

        for line in lines:
            parts = line.strip().split()
            if not parts:
                continue

            try:
                # Parsear SEMAFORO (corrige errores tipográficos como EMAFORO)
                if parts[0].startswith("SEMAFORO") or parts[0].startswith("EMAFORO"):
                    sem_id = parts[1]
                    estado = parts[2]
                    data["trafico"]["semaforos"][sem_id] = estado

                # Parsear BUS
                elif parts[0] == "BUS":
                    bus_type = parts[1].lower()
                    distancia = float(parts[2])  # Usar float para manejar decimales
                    data["bus"][bus_type] = distancia

                # Parsear DISTANCIA
                elif parts[0] == "Distancia" and parts[1] == "Zona":
                    zona_id = parts[2]
                    distancia = float(parts[3])  # Usar float para manejar decimales
                    data["distancias"]["zona" + zona_id] = distancia

                # Parsear INCENDIO
                elif parts[0].startswith("INCENDIO"):
                    incendio_parts = parts[0].split(":")[1:] + parts[1:]
                    if len(incendio_parts) >= 3:
                        incendio_id = int(incendio_parts[0])
                        nivel = float(incendio_parts[1])  # Usar float para manejar decimales
                        estado = incendio_parts[2]
                        # Corregir errores tipográficos como RILLO
                        estado = "NORMAL" if estado in ["NORMAL", "RILLO"] else estado
                        incendio = {
                            "id": incendio_id,
                            "nivel": nivel,
                            "estado": estado
                        }
                        data["incendio"].append(incendio)

                # Parsear MQ (Ambiente)
                elif parts[0].startswith("MQ"):
                    sensor_id = int(parts[0].replace("MQ", "")) - 1
                    nivel = float(parts[1])  # Usar float para manejar decimales
                    data["ambiente"]["mq_sensors"].append({"id": sensor_id, "nivel": nivel})

                # Parsear SISMO
                elif parts[0].startswith("SISMO"):
                    sismo_parts = parts[0].split(":")[1:] + parts[1:]
                    if len(sismo_parts) >= 2:
                        data["sismo"] = {
                            "nivel": sismo_parts[0],
                            "timestamp": int(sismo_parts[1])
                        }

                # Parsear PANIC
                elif parts[0] == "PANICO":
                    panico = {
                        "zona": int(parts[1].replace(":", "")),
                        "timestamp": int(parts[2])
                    }
                    data["panico"].append(panico)

                # Parsear INFRACCION
                elif parts[0] == "INFRACCION":
                    infraccion = {
                        "zona": int(parts[1]),
                        "timestamp": int(parts[2])
                    }
                    data["infraccion"].append(infraccion)

            except (ValueError, IndexError) as e:
                print(f"Error parseando línea '{line}': {e}")
                continue

        # Solo devolver datos no vacíos
        return {key: value for key, value in data.items() if value and (isinstance(value, list) and len(value) > 0 or isinstance(value, dict) and len(value) > 0)}
    
    def read_raw_data(self):
        """Lee datos crudos del puerto serial"""
        if not self.serial_connection or not self.serial_connection.is_open:
            return None
        
        try:
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
    
    def publish_mqtt(self, data):
        """Publica los datos JSON en los tópicos MQTT correspondientes
        Cada payload se envía con su hora de publicación y se reemplaza cualquier timestamp existente por la hora actual."""
        try:
            hora_envio = self._hora_actual_iso()
            for category, payload in data.items():
                if payload:
                    topic = self.mqtt_topics.get(category)
                    if topic:
                        # Asegurar que el payload tenga su campo de hora
                        # Si ya existe "timestamp" dentro de payload, lo reemplazamos por hora_envio
                        # Dependiendo de la estructura del payload, actualizamos o añadimos.
                        if isinstance(payload, dict):
                            payload_with_time = dict(payload)
                            payload_with_time["timestamp"] = hora_envio
                        else:
                            # Si por alguna razón no es dict (p. ej., lista), envolvemos en dict
                            payload_with_time = {"data": payload, "timestamp": hora_envio}
                        json_data = json.dumps(payload_with_time)
                        self.mqtt_client.publish(topic, json_data)
                        print(f"Datos publicados en {topic}: {json_data}")
                    else:
                        print(f"No se encontró tópico para la categoría {category}")
        except Exception as e:
            print(f"Error publicando en MQTT: {e}")

    def run_continuous(self, interval=1):
        """Ejecuta lectura continua, convierte a JSON y publica en MQTT"""
        print(f"Iniciando lectura continua cada {interval} segundos...")
        
        try:
            while True:
                print(f"\nLeyendo datos... [{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}]")
                
                raw_data = self.read_raw_data()
                if raw_data:
                    print("Datos crudos recibidos:")
                    for line in raw_data:
                        print(line)
                    
                    # Convertir a JSON
                    json_data = self.parse_raw_data(raw_data)
                    if json_data:
                        print("JSONs generados:")
                        for category, payload in json_data.items():
                            print(f"{category}: {json.dumps(payload, indent=2)}")
                        # Publicar en MQTT (con hora)
                        self.publish_mqtt(json_data)
                    else:
                        print("No se pudo parsear los datos a JSON")
                else:
                    print("No se recibieron datos")
                
                print(f"Esperando {interval} segundos")
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print("\nLectura detenida por el usuario")
        except Exception as e:
            print(f"Error durante la lectura continua: {e}")
        finally:
            self.disconnect()

def main():
    reader = ArduinoRawReader(
        port='/dev/ttyACM0',
        baudrate=9600,
        mqtt_broker='broker.emqx.io',
        mqtt_port=1883
    )
    if reader.connect():
        try:
            reader.run_continuous(interval=1)
        finally:
            reader.disconnect()

if __name__ == "__main__":
    main()