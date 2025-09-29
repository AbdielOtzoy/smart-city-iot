from fastapi import APIRouter
from pydantic import BaseModel
from app.database import alertasCollection, traficoCollection, ambienteCollection
from datetime import datetime
from app.models import Alerta, Trafico, Ambiente

router = APIRouter()

@router.get("/")
async def hello_world():
    return {"message": "Hello, World!"}

@router.get("/alertas", response_model=list[Alerta])
async def get_alertas():
    # retornar las últimas 50 alertas
    alertas = list(alertasCollection.find().sort("timestamp", -1).limit(50))
    return [
        Alerta(
            id=str(alerta["_id"]),
            tipo=alerta["tipo"],
            data=str(alerta["data"]),
            timestamp=alerta["timestamp"]
        )
        for alerta in alertas
    ]

#obtener alertas limitadas, se pasa por parámetro
@router.get("/alertas/{limit}", response_model=list[Alerta])
async def get_alertas_limit(limit: int):
    # retornar las últimas 'limit' alertas
    alertas = list(alertasCollection.find().sort("timestamp", -1).limit(limit))
    return [
        Alerta(
            id=str(alerta["_id"]),
            tipo=alerta["tipo"],
            data=str(alerta["data"]),
            timestamp=alerta["timestamp"]
        )
        for alerta in alertas
    ]

@router.get("/trafico", response_model=list[Trafico])
async def get_trafico():
    # retornar el estado actual
    trafico = list(traficoCollection.find().sort("timestamp", -1).limit(1))
    if trafico:
        return [
            Trafico(
                semaforos=list(estado["semaforos"].values()),
                timestamp=estado["timestamp"]
            )
            for estado in trafico
        ]
    return []

@router.get("/ambiente", response_model=list[Ambiente])
async def get_ambiente():
    # retornar el estado actual
    ambiente = list(ambienteCollection.find().sort("timestamp", -1).limit(1))
    if ambiente:
        return [
            Ambiente(
                mq_sensors=estado["mq_sensors"],
                timestamp=estado["timestamp"]
            )
            for estado in ambiente
        ]

