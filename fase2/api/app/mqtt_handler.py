import json
import paho.mqtt.client as mqtt
from datetime import datetime, timezone
from app.database import alertasCollection, traficoCollection, ambienteCollection

def on_connect(client, _, __, rc):
    if rc == 0:
        print("Conectado a MQTT Broker")
        # Tópicos a los que se suscribe
        client.subscribe("GRUPO2/arqui2/alertas")
        client.subscribe("GRUPO2/arqui2/trafico")
        client.subscribe("GRUPO2/arqui2/ambiente")
    else:
        print(f"Error: {rc}")

def on_message(_, __, msg):
    timestamp = datetime.now(timezone.utc)
    print(f"Mensaje recibido en {msg.topic}: {msg.payload.decode()} (UTC: {timestamp})")
    try:
        data = json.loads(msg.payload.decode())
        print(f"Datos parseados: {data}")
        if msg.topic == "GRUPO2/arqui2/alertas":
            tipo = data.get("tipo")
            if tipo == "sismo" or tipo == "panico" or tipo == "incendio" or tipo == "infraccion":
                ubicacion = data.get("dato")
                print(f"Alerta de {tipo} en {ubicacion}")
                # Guardar en la base de datos en la colección de alertas
                alertasCollection.insert_one({
                    "tipo": tipo,
                    "data": ubicacion,
                    "timestamp": timestamp
                })
        elif msg.topic == "GRUPO2/arqui2/trafico":
            semaforos = data.get("semaforos", [])
            for estado in semaforos:
                print(f"Semáforo {estado}")
            traficoCollection.insert_one({
                "semaforos": semaforos,
                "timestamp": timestamp
            })
        elif msg.topic == "GRUPO2/arqui2/ambiente":
            mq1 = data.get("mq1")
            mq2 = data.get("mq2")
            mq3 = data.get("mq3")
            ambienteCollection.insert_one({
                "mq1": mq1,
                "mq2": mq2,
                "mq3": mq3,
                "timestamp": timestamp
            })

    except json.JSONDecodeError:
        print("Error al parsear el mensaje JSON")

def start_mqtt():
    print("Iniciando cliente MQTT...")
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect('broker.emqx.io', 1883, 60)
    client.loop_start()
    print("Cliente MQTT iniciado")
    return client
