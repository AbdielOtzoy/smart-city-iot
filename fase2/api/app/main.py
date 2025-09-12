from fastapi import FastAPI
from app.routes import router
from app.mqtt_handler import start_mqtt

app = FastAPI(
    title="API IoT con FastAPI + MQTT + MongoDB",
    description="Suscripción a tópicos MQTT, almacenamiento en MongoDB Atlas y consulta vía REST",
    version="1.0.0"
)

app.include_router(router)

@app.on_event("startup")
def startup_event():
    start_mqtt()

