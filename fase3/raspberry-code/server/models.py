from pydantic import BaseModel, Field
from typing import Literal, Optional
from datetime import datetime


class DeteccionPlaca(BaseModel):
    """Modelo para detección de placas vehiculares"""
    clase: Literal["placas"] = "placas"
    timestamp: str = Field(..., description="Timestamp en formato ISO 8601")
    placa_texto: str = Field(..., min_length=1, max_length=20, description="Texto de la placa detectada")

    class Config:
        json_schema_extra = {
            "example": {
                "clase": "placas",
                "timestamp": "2025-10-14T16:54:15.717834",
                "placa_texto": "VAT428"
            }
        }


class DeteccionArma(BaseModel):
    """Modelo para detección de armas"""
    tipo: Literal["arma_blanca", "arma_fuego"]
    subtipo: Optional[str] = Field(None, description="Subtipo específico del arma (ej: cuchillo, pistola)")
    timestamp: str = Field(..., description="Timestamp en formato ISO 8601")

    class Config:
        json_schema_extra = {
            "example": {
                "tipo": "arma_blanca",
                "subtipo": "cuchillo",
                "timestamp": "2025-10-14T10:30:45.123456"
            }
        }


class DeteccionPersona(BaseModel):
    """Modelo para detección de rostros/personas"""
    tipo: Literal["persona"] = "persona"
    data: str = Field(..., description="Nombre o identificador de la persona")
    timestamp: str = Field(..., description="Timestamp en formato ISO 8601")

    class Config:
        json_schema_extra = {
            "example": {
                "tipo": "persona",
                "data": "Juan Perez",
                "timestamp": "2025-09-02T05:22:03Z"
            }
        }


class RespuestaAPI(BaseModel):
    """Modelo de respuesta estándar de la API"""
    success: bool
    message: str
    data: Optional[dict] = None