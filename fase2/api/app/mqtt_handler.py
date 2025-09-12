import json
import paho.mqtt.client as mqtt
from datetime import datetime, timezone
from app.database import alertasCollection, traficoCollection, ambienteCollection

def on_connect(client, _, __, rc):
    if rc == 0:
        print("Conectado a MQTT Broker")
        # Tópicos a los que se suscribe
        client.subscribe("Data/Grupo2/ACE2/2S2025/Trafico")
        client.subscribe("Data/Grupo2/ACE2/2S2025/Ambiente")
        client.subscribe("Data/Grupo2/ACE2/2S2025/Incendio")
        client.subscribe("Data/Grupo2/ACE2/2S2025/Sismo")
        client.subscribe("Data/Grupo2/ACE2/2S2025/Panico")
        client.subscribe("Data/Grupo2/ACE2/2S2025/Infraccion")
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
        elif msg.topic == "Data/Grupo2/ACE2/2S2025/Incendio":
            datos = data.get("data")
            datos = datos if len(datos) <= 3 else datos[:3]
            for dato in datos:
                print(dato)
                if dato['estado'] == "ALTO" or dato['estado'] == "ALERTA":
                    print(f"Alerta de incendio en {dato['estado']} en {dato['id']}")
                    alertasCollection.insert_one({
                        "tipo": "incendio",
                        "data": str(dato["id"]),
                        "timestamp": timestamp
                    })
        elif msg.topic == "Data/Grupo2/ACE2/2S2025/Trafico":
            semaforos = data.get("semaforos")
            traficoCollection.insert_one({
                "semaforos": semaforos,
                "timestamp": timestamp
            })
        elif msg.topic == "Data/Grupo2/ACE2/2S2025/Sismo":
            nivel = data.get("nivel")
            if nivel == "ALTO" or nivel == "ALERTA":
                print(f"Alerta de sismo en {nivel}")
                alertasCollection.insert_one({
                    "tipo": "sismo",
                    "data": nivel,
                    "timestamp": timestamp
                })
        elif msg.topic == "Data/Grupo2/ACE2/2S2025/Panico":
            datos = data.get("data")
            if datos:
                unique_datos = set()
                for dato in datos:
                    unique_datos.add(dato['zona'])
                for zona in unique_datos:
                    print(f"Alerta de pánico en {zona}")
                    alertasCollection.insert_one({
                        "tipo": "panico",
                        "data": str(zona),
                        "timestamp": timestamp
                    })
        elif msg.topic == "Data/Grupo2/ACE2/2S2025/Infraccion":
            datos = data.get("data")
            if datos:
                unique_datos = set()
                for dato in datos:
                    unique_datos.add(dato['zona'])
                for zona in unique_datos:
                    print(f"Alerta de infracción en {zona}")
                    alertasCollection.insert_one({
                        "tipo": "infraccion",
                        "data": str(zona),
                        "timestamp": timestamp
                    })
        elif msg.topic == "Data/Grupo2/ACE2/2S2025/Ambiente":
            # recolectar solamente los primeros 3 datos del arreglo
            mq_sensors = data.get("mq_sensors", [])
            mq_sensors = mq_sensors if len(mq_sensors) <= 3 else mq_sensors[:3]
            ambienteCollection.insert_one({
                "mq_sensors": mq_sensors,
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

