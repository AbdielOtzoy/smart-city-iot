import paho.mqtt.client as mqtt
import json
from datetime import datetime
from config import config


class MQTTHandler:
    """Manejador de conexiones y publicaciones MQTT"""
    
    def __init__(self):
        self.client = mqtt.Client()
        self.connected = False
        self.broker = config.MQTT_BROKER
        self.port = config.MQTT_PORT
        self.topics = config.MQTT_TOPICS
        
        # Callbacks
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect
        
    def _on_connect(self, client, userdata, flags, rc):
        """Callback cuando se conecta al broker"""
        if rc == 0:
            self.connected = True
            print(f" Conectado al broker MQTT {self.broker}:{self.port}")
        else:
            self.connected = False
            print(f" Error conectando al broker MQTT. Código: {rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        """Callback cuando se desconecta del broker"""
        self.connected = False
        print(f" Desconectado del broker MQTT. Código: {rc}")
    
    def connect(self):
        """Establece conexión con el broker MQTT"""
        try:
            self.client.connect(self.broker, self.port, 60)
            self.client.loop_start()  # Inicia loop en segundo plano
            return True
        except Exception as e:
            print(f" Error conectando al broker MQTT: {e}")
            return False
    
    def disconnect(self):
        """Cierra la conexión MQTT"""
        try:
            self.client.loop_stop()
            self.client.disconnect()
            print(" Conexión MQTT cerrada")
        except Exception as e:
            print(f"Error cerrando conexión MQTT: {e}")
    
    def publish(self, topic_key: str, payload: dict):
        """
        Publica un mensaje en el tópico especificado
        
        Args:
            topic_key: Clave del tópico en config.MQTT_TOPICS
            payload: Diccionario con los datos a enviar
        """
        if not self.connected:
            print(" No conectado al broker MQTT. Intentando reconectar...")
            self.connect()
            return False
        
        try:
            # Agregar timestamp si no existe
            if "timestamp" not in payload:
                payload["timestamp"] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
            
            topic = self.topics.get(topic_key)
            if not topic:
                print(f" Tópico '{topic_key}' no encontrado en configuración")
                return False
            
            # Convertir a JSON y publicar
            json_data = json.dumps(payload, ensure_ascii=False)
            result = self.client.publish(topic, json_data)
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f" Publicado en {topic}: {json_data}")
                return True
            else:
                print(f" Error publicando en {topic}. Código: {result.rc}")
                return False
                
        except Exception as e:
            print(f" Error en publish: {e}")
            return False


# Instancia global del handler MQTT
mqtt_handler = MQTTHandler()