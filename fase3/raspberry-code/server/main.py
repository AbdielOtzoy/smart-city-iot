from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import json
import os
from typing import Union
from contextlib import asynccontextmanager

from models import DeteccionPlaca, DeteccionArma, DeteccionPersona, RespuestaAPI
from config import config
from mqtt_handler import mqtt_handler
from arduino_handler import arduino_handler


# Manejador de eventos de inicio/apagado
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Conectar MQTT y Arduino
    print(" Iniciando servicios...")
    mqtt_handler.connect()
    arduino_handler.connect()
    yield
    # Shutdown: Desconectar servicios
    print(" Cerrando servicios...")
    mqtt_handler.disconnect()
    arduino_handler.disconnect()


# Inicializar FastAPI
app = FastAPI(
    title=config.API_TITLE,
    version=config.API_VERSION,
    description=config.API_DESCRIPTION,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==================== FUNCIONES AUXILIARES ====================

def guardar_deteccion(tipo: str, datos: dict):
    """Guarda la detección en un archivo JSON"""
    try:
        registro = {
            "tipo_deteccion": tipo,
            "timestamp_recepcion": datetime.now().isoformat(),
            "datos": datos
        }
        
        if os.path.exists(config.DB_FILE):
            with open(config.DB_FILE, 'r', encoding='utf-8') as f:
                detecciones = json.load(f)
        else:
            detecciones = []
        
        detecciones.append(registro)
        
        with open(config.DB_FILE, 'w', encoding='utf-8') as f:
            json.dump(detecciones, f, ensure_ascii=False, indent=2)
        
        return True
    except Exception as e:
        print(f" Error al guardar detección: {e}")
        return False


# ==================== ENDPOINTS ====================

@app.get("/", tags=["General"])
async def root():
    """Endpoint raíz - Información del sistema"""
    return {
        "sistema": "API de Detección - Raspberry Pi",
        "version": config.API_VERSION,
        "estado": "operativo",
        "mqtt_conectado": mqtt_handler.connected,
        "arduino_habilitado": config.ARDUINO_ALERT_ENABLED,
        "timestamp": datetime.now().isoformat(),
        "documentacion": "/docs"
    }


@app.get("/api/health", tags=["General"])
async def health_check():
    """Verificación de salud del sistema"""
    return {
        "status": "healthy",
        "mqtt_status": "connected" if mqtt_handler.connected else "disconnected",
        "arduino_enabled": config.ARDUINO_ALERT_ENABLED,
        "timestamp": datetime.now().isoformat()
    }


@app.post("/api/info/placa", 
          response_model=RespuestaAPI,
          tags=["Detecciones"],
          summary="Recibir detección de placa vehicular")
async def recibir_placa(deteccion: DeteccionPlaca, zona: int = None):
    """
    Recibe y procesa una detección de placa vehicular.
    
    - **clase**: Debe ser "placas"
    - **timestamp**: Timestamp en formato ISO 8601
    - **placa_texto**: Texto de la placa detectada
    - **zona**: Zona específica (0, 1, 2) o None para activar todas
    """
    try:
        datos = deteccion.model_dump()
        if zona is not None:
            datos["zona"] = zona
        
        # Guardar detección
        if not guardar_deteccion("placa", datos):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al guardar la detección"
            )
        
        # Publicar en MQTT
        mqtt_handler.publish("placas", datos)
        
        # Enviar alerta al Arduino con zona específica
        alerta_enviada = False
        if config.ARDUINO_ALERT_ENABLED:
            alerta_enviada = arduino_handler.send_alert("placa", zona=zona)
        
        # Log
        zona_str = f"Zona {zona}" if zona is not None else "Todas las zonas"
        print(f" Placa detectada: {deteccion.placa_texto} [{zona_str}]")
        
        return RespuestaAPI(
            success=True,
            message=f"Detección de placa procesada - Alerta activada en {zona_str}",
            data={
                "placa": deteccion.placa_texto,
                "zona": zona if zona is not None else "todas",
                "mqtt_publicado": mqtt_handler.connected,
                "arduino_alertado": alerta_enviada
            }
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error procesando detección: {str(e)}"
        )


@app.post("/api/info/arma",
          response_model=RespuestaAPI,
          tags=["Detecciones"],
          summary="Recibir detección de arma")
async def recibir_arma(deteccion: DeteccionArma, zona: int = None):
    """
    Recibe y procesa una detección de arma.
    
    - **tipo**: "arma_blanca" o "arma_fuego"
    - **subtipo**: Tipo específico (opcional)
    - **timestamp**: Timestamp en formato ISO 8601
    - **zona**: Zona específica (0, 1, 2) o None para activar todas
    """
    try:
        datos = deteccion.model_dump()
        if zona is not None:
            datos["zona"] = zona
        
        # Guardar detección
        if not guardar_deteccion("arma", datos):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al guardar la detección"
            )
        
        # Publicar en MQTT
        mqtt_handler.publish("armas", datos)
        
        # Enviar alerta al Arduino con zona específica
        alerta_enviada = False
        if config.ARDUINO_ALERT_ENABLED:
            alerta_enviada = arduino_handler.send_alert("arma", zona=zona)
        
        # También publicar como infracción
        infraccion_payload = {
            "tipo": "arma_detectada",
            "subtipo": deteccion.tipo,
            "zona": zona,
            "timestamp": deteccion.timestamp
        }
        mqtt_handler.publish("infraccion", infraccion_payload)
        
        # Log
        zona_str = f"Zona {zona}" if zona is not None else "Todas las zonas"
        print(f" Arma detectada: {deteccion.tipo} - {deteccion.subtipo} [{zona_str}]")
        
        return RespuestaAPI(
            success=True,
            message=f"ALERTA CRÍTICA: Arma detectada - Buzzer activado en {zona_str}",
            data={
                "tipo": deteccion.tipo,
                "subtipo": deteccion.subtipo,
                "zona": zona if zona is not None else "todas",
                "mqtt_publicado": mqtt_handler.connected,
                "arduino_alertado": alerta_enviada
            }
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error procesando detección: {str(e)}"
        )


@app.post("/api/info/persona",
          response_model=RespuestaAPI,
          tags=["Detecciones"],
          summary="Recibir detección de persona/rostro")
async def recibir_persona(deteccion: DeteccionPersona, zona: int = None):
    """
    Recibe y procesa una detección de persona/rostro.
    
    - **tipo**: Debe ser "persona"
    - **data**: Nombre o ID de la persona
    - **timestamp**: Timestamp en formato ISO 8601
    - **zona**: Zona específica (0, 1, 2) o None para activar todas
    """
    try:
        datos = deteccion.model_dump()
        if zona is not None:
            datos["zona"] = zona
        
        # Guardar detección
        if not guardar_deteccion("persona", datos):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error al guardar la detección"
            )
        
        # Publicar en MQTT
        mqtt_handler.publish("personas", datos)
        
        # Enviar alerta al Arduino con zona específica
        alerta_enviada = False
        if config.ARDUINO_ALERT_ENABLED:
            alerta_enviada = arduino_handler.send_alert("persona", zona=zona)
        
        # Log
        zona_str = f"Zona {zona}" if zona is not None else "Todas las zonas"
        print(f" Persona detectada: {deteccion.data} [{zona_str}]")
        
        return RespuestaAPI(
            success=True,
            message=f"Detección de persona procesada - Alerta activada en {zona_str}",
            data={
                "persona": deteccion.data,
                "zona": zona if zona is not None else "todas",
                "mqtt_publicado": mqtt_handler.connected,
                "arduino_alertado": alerta_enviada
            }
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error procesando detección: {str(e)}"
        )


@app.post("/api/info",
          tags=["Detecciones"],
          summary="Endpoint unificado (detecta tipo automáticamente)")
async def recibir_info_unificado(payload: Union[DeteccionPlaca, DeteccionArma, DeteccionPersona]):
    """
    Endpoint unificado que acepta cualquier tipo de detección.
    Detecta automáticamente el tipo basándose en los campos del payload.
    """
    if isinstance(payload, DeteccionPlaca):
        return await recibir_placa(payload)
    elif isinstance(payload, DeteccionArma):
        return await recibir_arma(payload)
    elif isinstance(payload, DeteccionPersona):
        return await recibir_persona(payload)
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tipo de detección no reconocido"
        )


@app.get("/api/detecciones",
         tags=["Consultas"],
         summary="Obtener todas las detecciones")
async def obtener_detecciones(limite: int = 100):
    """
    Obtiene las últimas detecciones almacenadas.
    
    - **limite**: Número máximo de detecciones a retornar (default: 100)
    """
    try:
        if not os.path.exists(config.DB_FILE):
            return {"detecciones": [], "total": 0}
        
        with open(config.DB_FILE, 'r', encoding='utf-8') as f:
            detecciones = json.load(f)
        
        detecciones_recientes = detecciones[-limite:]
        
        return {
            "detecciones": detecciones_recientes,
            "total": len(detecciones_recientes),
            "total_almacenadas": len(detecciones)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error obteniendo detecciones: {str(e)}"
        )


@app.get("/api/detecciones/{tipo}",
         tags=["Consultas"],
         summary="Obtener detecciones por tipo")
async def obtener_detecciones_por_tipo(tipo: str, limite: int = 50):
    """
    Obtiene las últimas detecciones de un tipo específico.
    
    - **tipo**: 'placa', 'arma' o 'persona'
    - **limite**: Número máximo de detecciones a retornar
    """
    try:
        if not os.path.exists(config.DB_FILE):
            return {"detecciones": [], "total": 0}
        
        with open(config.DB_FILE, 'r', encoding='utf-8') as f:
            detecciones = json.load(f)
        
        # Filtrar por tipo
        detecciones_filtradas = [d for d in detecciones if d.get("tipo_deteccion") == tipo]
        detecciones_recientes = detecciones_filtradas[-limite:]
        
        return {
            "tipo": tipo,
            "detecciones": detecciones_recientes,
            "total": len(detecciones_recientes)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error obteniendo detecciones: {str(e)}"
        )


@app.post("/api/arduino/alert",
          tags=["Arduino"],
          summary="Enviar alerta manual al Arduino")
async def enviar_alerta_arduino(tipo_alerta: str, zona: int = None):
    """
    Envía una alerta manual al Arduino.
    
    - **tipo_alerta**: Tipo de alerta ('arma', 'persona', 'placa')
    - **zona**: Zona específica (0, 1, 2) o None para todas las zonas
    """
    if not config.ARDUINO_ALERT_ENABLED:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Arduino deshabilitado en configuración"
        )
    
    success = arduino_handler.send_alert(tipo_alerta, zona=zona)
    
    if success:
        zona_str = f"zona {zona}" if zona is not None else "todas las zonas"
        return {
            "success": True,
            "message": f"Alerta '{tipo_alerta}' enviada a Arduino en {zona_str}"
        }
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error enviando alerta a Arduino"
        )


@app.get("/api/arduino/test",
         tags=["Arduino"],
         summary="Probar todas las alertas del Arduino")
async def test_alertas_arduino():
    """
    Ejecuta una secuencia de prueba de todas las alertas del Arduino.
    Útil para verificar que el sistema de buzzers funciona correctamente.
    """
    if not config.ARDUINO_ALERT_ENABLED:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Arduino deshabilitado en configuración"
        )
    
    success = arduino_handler.test_all_alerts()
    
    if success:
        return {
            "success": True,
            "message": "Secuencia de test completada. Revisa los buzzers.",
            "secuencia": [
                "1. Placa - Zona 0",
                "2. Persona - Zona 1",
                "3. Arma - Zona 2",
                "4. Arma - Todas las zonas"
            ]
        }
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error ejecutando test de alertas"
        ) 

    if not config.ARDUINO_ALERT_ENABLED:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Arduino deshabilitado en configuración"
        )
    
    success = arduino_handler.send_alert(tipo_alerta)
    
    if success:
        return {"success": True, "message": f"Alerta '{tipo_alerta}' enviada a Arduino"}
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error enviando alerta a Arduino"
        )


# ==================== INICIO DEL SERVIDOR ====================

if __name__ == "__main__":
    import uvicorn
    
    print("=" * 70)
    print(f" Iniciando {config.API_TITLE}")
    print(f" Dirección: http://{config.HOST}:{config.PORT}")
    print(f" Documentación Swagger: http://192.168.0.5:{config.PORT}/docs")
    print(f" Documentación ReDoc: http://192.168.0.5:{config.PORT}/redoc")
    print(f" MQTT Broker: {config.MQTT_BROKER}:{config.MQTT_PORT}")
    print(f" Arduino: {'Habilitado' if config.ARDUINO_ALERT_ENABLED else 'Deshabilitado'}")
    print("=" * 70)
    
    uvicorn.run(
        app,
        host=config.HOST,
        port=config.PORT,
        log_level="info"
    )