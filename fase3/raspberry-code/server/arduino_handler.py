import serial
import time
from config import config


class ArduinoHandler:
    """Manejador de comunicación con Arduino"""
    
    # Tipos de alerta disponibles
    ALERT_TYPES = {
        "arma": "ARMA",
        "arma_blanca": "ARMA",
        "arma_fuego": "ARMA",
        "persona": "PERSONA",
        "placa": "PLACA",
        "emergencia": "ARMA"  # Mapear emergencias a alarma de arma
    }
    
    def __init__(self):
        self.port = config.ARDUINO_PORT
        self.baudrate = config.ARDUINO_BAUDRATE
        self.serial_connection = None
        self.enabled = config.ARDUINO_ALERT_ENABLED
        
    def connect(self):
        """Establece conexión con Arduino"""
        if not self.enabled:
            print(" Arduino deshabilitado en configuración")
            return False
            
        try:
            self.serial_connection = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=1
            )
            time.sleep(2)  # Esperar estabilización
            print(f" Conectado a Arduino en {self.port}")
            
            # Verificar estado
            self.send_command("STATUS")
            time.sleep(0.5)
            
            # Leer respuesta de status
            if self.serial_connection.in_waiting > 0:
                response = self.serial_connection.read(self.serial_connection.in_waiting).decode('utf-8', errors='ignore')
                print(f" Respuesta Arduino: {response.strip()}")
            
            return True
        except serial.SerialException as e:
            print(f" Error conectando a Arduino: {e}")
            return False
    
    def disconnect(self):
        """Cierra conexión con Arduino"""
        if self.serial_connection and self.serial_connection.is_open:
            self.serial_connection.close()
            print(" Conexión Arduino cerrada")
    
    def send_alert(self, alert_type: str, zona: int = None):
        """
        Envía una alerta al Arduino
        
        Args:
            alert_type: Tipo de alerta ('arma', 'arma_blanca', 'arma_fuego', 'persona', 'placa')
            zona: Zona específica (0, 1, 2) o None para todas las zonas
        
        Returns:
            bool: True si se envió correctamente
        """
        if not self.enabled:
            print(" Arduino deshabilitado")
            return False
            
        if not self.serial_connection or not self.serial_connection.is_open:
            print(" Arduino no conectado. Intentando conectar...")
            if not self.connect():
                return False
        
        try:
            # Mapear tipo de alerta
            tipo_mapeado = self.ALERT_TYPES.get(alert_type.lower(), "ARMA")
            
            # Determinar zona
            zona_str = "ALL" if zona is None else str(zona)
            
            # Formato: ALERT:TIPO:ZONA\n
            command = f"ALERT:{tipo_mapeado}:{zona_str}\n"
            self.serial_connection.write(command.encode())
            
            # Leer confirmación
            time.sleep(0.1)
            if self.serial_connection.in_waiting > 0:
                response = self.serial_connection.readline().decode('utf-8', errors='ignore').strip()
                print(f" Arduino responde: {response}")
            
            print(f" Alerta enviada: {tipo_mapeado} en zona {zona_str}")
            return True
            
        except Exception as e:
            print(f" Error enviando alerta a Arduino: {e}")
            return False
    
    def send_command(self, command: str):
        """
        Envía un comando personalizado al Arduino
        
        Args:
            command: Comando a enviar (sin \n final, se agrega automáticamente)
        
        Returns:
            str: Respuesta del Arduino o None si hay error
        """
        if not self.enabled or not self.serial_connection:
            return None
            
        try:
            self.serial_connection.write(f"{command}\n".encode())
            time.sleep(0.2)  # Esperar respuesta
            
            # Leer respuesta
            if self.serial_connection.in_waiting > 0:
                response = self.serial_connection.read(self.serial_connection.in_waiting).decode('utf-8', errors='ignore')
                print(f" Comando: {command}")
                print(f" Respuesta: {response.strip()}")
                return response.strip()
            
            return None
        except Exception as e:
            print(f" Error enviando comando: {e}")
            return None
    
    def test_all_alerts(self):
        """
        Prueba todas las alertas en secuencia
        Útil para verificar funcionamiento
        """
        if not self.enabled or not self.serial_connection:
            print(" Arduino no disponible")
            return False
        
        print(" Iniciando test de alertas...")
        
        # Test PLACA
        print("\n Testeando alerta de PLACA...")
        self.send_alert("placa", zona=0)
        time.sleep(3)
        
        # Test PERSONA
        print("\n Testeando alerta de PERSONA...")
        self.send_alert("persona", zona=1)
        time.sleep(3)
        
        # Test ARMA
        print("\n Testeando alerta de ARMA...")
        self.send_alert("arma", zona=2)
        time.sleep(5)
        
        # Test TODAS LAS ZONAS
        print("\n Testeando TODAS las zonas (ARMA)...")
        self.send_alert("arma", zona=None)
        time.sleep(5)
        
        print("\n Test completado")
        return True


# Instancia global del handler Arduino
arduino_handler = ArduinoHandler()