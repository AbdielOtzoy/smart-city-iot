import os


class Config:
    """Configuración de la API"""
    
    # Configuración del servidor
    HOST = "0.0.0.0"  # Escucha en todas las interfaces
    PORT = 3000
    
    # Información de la API
    API_TITLE = "API de Detección - Sistema de Vigilancia"
    API_VERSION = "1.0.0"
    API_DESCRIPTION = """
    API central para recibir y procesar detecciones de:
    - Placas vehiculares
    - Armas (blancas y de fuego)
    - Personas/Rostros
    
    Los datos se validan, almacenan y publican a los tópicos MQTT correspondientes.
    """
    
    # Directorios
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    LOGS_DIR = os.path.join(BASE_DIR, "logs")
    DATA_DIR = os.path.join(BASE_DIR, "data")
    
    # Crear directorios si no existen
    os.makedirs(LOGS_DIR, exist_ok=True)
    os.makedirs(DATA_DIR, exist_ok=True)
    
    # Configuración de almacenamiento
    DB_FILE = os.path.join(DATA_DIR, "detecciones.json")
    
    # Configuración MQTT
    MQTT_BROKER = "broker.emqx.io"
    MQTT_PORT = 1883
    MQTT_TOPICS = {
        "placas": "Data/Grupo2/ACE2/2S2025/alertaPlacas",
        "armas": "Data/Grupo2/ACE2/2S2025/alertaArmas",
        "personas": "Data/Grupo2/ACE2/2S2025/alertaRostros",
        "infraccion": "Data/Grupo2/ACE2/2S2025/Infraccion"
    }
    
    # Configuración de Arduino
    ARDUINO_ALERT_ENABLED = True
    ARDUINO_PORT = "/dev/ttyACM0"
    ARDUINO_BAUDRATE = 9600


config = Config()