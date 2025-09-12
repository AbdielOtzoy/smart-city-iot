from pydantic import BaseModel
from datetime import datetime

class Lectura(BaseModel):
    topico: str
    mensaje: str
    timestamp: datetime

class Alerta(BaseModel):
    id: str
    tipo: str
    data: str
    timestamp: datetime

    class Config:
        json_schema_extra = {
            "example": {
                "id": "68b5b2b8fcf957ee3368fa75",
                "tipo": "panico",
                "data": "2",
                "timestamp": "2023-01-01T00:00:00Z"
            }
        }

class Trafico(BaseModel):
    semaforos: list[str]
    timestamp: datetime

    class Config:
        json_schema_extra = {
            "example": {
                "semaforos": ["rojo", "verde", "amarillo"],
                "timestamp": "2023-01-01T00:00:00Z"
            }
        }

class Ambiente(BaseModel):
    mq1: float
    mq2: float
    mq3: float
    timestamp: datetime

    class Config:
        json_schema_extra = {
            "example": {
                "mq1": 120,
                "mq2": 200,
                "mq3": 250,
                "timestamp": "2023-01-01T00:00:00Z"
            }
        }
