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
    mq_sensors: list[dict[str, float]]
    timestamp: datetime

    class Config:
        json_schema_extra = {
            "example": {
                "mq_sensors": [
                    {"id": 0, "nivel": 248},
                    {"id": 1, "nivel": 278},
                    {"id": 2, "nivel": 19}
                ],
                "timestamp": "2025-09-02T14:44:50.553Z"
            }
        }
