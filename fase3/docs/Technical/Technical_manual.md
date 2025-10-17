<!-- ...existing code... -->
# Manual técnico

## Arquitectura del sistema
![Diagrama de arquitectura](Images/diagrama_de_arquitectura.png)

## Tecnologías y dependencias principales
- Backend: Python (Flask o FastAPI) — código en `api/`
- Broker MQTT: configurable (p. ej. Mosquitto)
- Base de datos: PostgreSQL / SQLite (según `api/database.py`)
- Requisitos: `api/requirements.txt`

## Puesta en marcha rápida
1. Crear y activar entorno virtual:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
2. Instalar dependencias:
   ```bash
   pip install -r api/requirements.txt
   ```
3. Configurar variables de entorno (ver sección siguiente).
4. Ejecutar la API:
   - Flask:
     ```bash
     export FLASK_APP=api/main.py
     flask run --host=0.0.0.0 --port=5000
     ```
   - FastAPI:
     ```bash
     uvicorn api.main:app --reload --host 0.0.0.0 --port=8000
     ```

## Variables de entorno recomendadas
- DATABASE_URL (ej. postgresql://user:pass@host:5432/dbname)
- MQTT_BROKER_HOST
- MQTT_BROKER_PORT
- MQTT_USERNAME (opcional)
- MQTT_PASSWORD (opcional)
- SECRET_KEY (para auth/sesiones)

## Especificación REST de la API

Nota: en este documento se han dejado plantillas y ejemplos. Añadir las rutas reales definidas en `api/routes.py`. Para facilitarlo hay instrucciones y scripts (abajo) para extraer automáticamente las rutas según el framework usado (Flask / FastAPI).

Plantilla por endpoint (usar Markdown para bloques JSON / curl):

- Ruta: /ruta/aqui
- Método: GET | POST | PUT | DELETE
- Descripción: breve descripción
- Autenticación: Bearer / API Key / Ninguna
- Request (application/json ejemplo):
  ```json
  {
    "campo": "valor"
  }
  ```
- Response 200 / 201 (ejemplo):
  ```json
  {
    "result": "ok"
  }
  ```
- Códigos de estado esperados: 200, 201, 400, 401, 404, 500
- Ejemplo cURL:
  ```bash
  curl -X POST http://localhost:8000/api/v1/ejemplo -H "Content-Type: application/json" -d '{"campo":"valor"}'
  ```

Ejemplo documentado (adaptar según `api/routes.py`):

- Ruta: `/api/v1/measurements`
- Método: `POST`
- Descripción: Registrar nueva medición desde sensor
- Autenticación: Ninguna / token
- Request (application/json):
  ```json
  {
    "device_id": "device-001",
    "sensor_type": "co2",
    "value": 412.5,
    "timestamp": "2025-10-16T14:23:00Z"
  }
  ```
- Response 201 Created:
  ```json
  {
    "id": 123,
    "device_id": "device-001",
    "sensor_type": "co2",
    "value": 412.5,
    "timestamp": "2025-10-16T14:23:00Z"
  }
  ```
- cURL:
  ```bash
  curl -X POST http://localhost:8000/api/v1/measurements \
    -H "Content-Type: application/json" \
    -d '{"device_id":"device-001","sensor_type":"co2","value":412.5,"timestamp":"2025-10-16T14:23:00Z"}'
  ```

### Cómo obtener las rutas reales desde el proyecto
- Si es Flask (desde el entorno con dependencias instaladas):
  ```bash
  export FLASK_APP=api/main.py
  flask routes
  ```
- Si es FastAPI (arrancar y consultar OpenAPI):
  - Ejecutar:
    ```bash
    uvicorn api.main:app --reload --host=0.0.0.0 --port=8000
    ```
  - Abrir:
    - http://localhost:8000/docs  (Swagger UI)
    - http://localhost:8000/openapi.json  (JSON con todos los endpoints)

- Script Python para listar rutas (Flask):
  ```python
  # listar_routes_flask.py
  from api.main import app
  for rule in app.url_map.iter_rules():
      print(f"{rule.methods} -> {rule.rule}")
  ```

- Script Python para listar rutas (FastAPI):
  ```python
  # listar_routes_fastapi.py
  from api.main import app
  for r in app.routes:
      print(r.path, getattr(r, "methods", "GET"))
  ```

Copiar la salida y pegar en la sección "Especificación REST" rellenando la plantilla por endpoint.

## MQTT
- Topics recomendados:
  - sensors/{device_id}/{sensor_type}/data
  - devices/{device_id}/status
  - commands/{device_id}/control
- Mensaje de ejemplo (JSON):
  ```json
  {
    "sensor": "temperature",
    "value": 23.4,
    "unit": "C",
    "ts": "2025-10-16T14:23:00Z"
  }
  ```
- Documentar en este manual los topics y estructuras que realmente usa `api/mqtt_handler.py`. Para obtener ejemplos en runtime, conectar un cliente MQTT (mosquitto_pub / mosquitto_sub) y publicar/suscribirse a los topics del proyecto.

## Esquemas de la base de datos

Insertar aquí las imágenes exportadas desde el modelador (PNG). Lugares sugeridos en el repo:
- `docs/Technical/Images/db_schema_entidades.png`
- `docs/Technical/Images/db_schema_relaciones.png`

## Imagenes
### trafico
![alt text](Images/trafico1.png "Diagrama de tráfico")

![alt text](Images/trafico2.png "Diagrama de tráfico")

### alertas
![alt text](Images/alertas1.png "Diagrama de alertas")

### ambiente
![alt text](Images/ambiente1.png "Diagrama de ambiente")

![alt text](Images/ambiente2.png "Diagrama de ambiente")

### Esquema lógico (plantilla — ajustar según `api/models.py`)
Tabla: users
- id (PK, integer, serial)
- username (varchar, unique)
- password_hash (varchar)
- email (varchar)
- created_at (timestamp)

Tabla: devices
- id (PK)
- device_id (varchar, unique)
- name (varchar)
- location (varchar)
- owner_id (FK -> users.id)

Tabla: sensors
- id (PK)
- device_id (FK -> devices.id)
- type (varchar)  // e.g., temperature, co2
- unit (varchar)

Tabla: readings
- id (PK)
- sensor_id (FK -> sensors.id)
- value (numeric)
- timestamp (timestamp)

## Migrations / Inicialización de la BD
- Si se usa Alembic / Flask-Migrate:
  ```bash
  alembic init alembic
  alembic revision --autogenerate -m "init"
  alembic upgrade head
  ```
- Si se usa SQL directo: incluir `api/sql/create_tables.sql` con sentencias CREATE TABLE.

## Seguridad y buenas prácticas
- No exponer credenciales en el repositorio.
- Usar HTTPS en producción.
- Validar y sanitizar payloads de entrada.
- Manejar errores con códigos HTTP adecuados y mensajes útiles.
- Limitar tamaño y frecuencia de peticiones (rate limiting).
- Usar autenticación y autorización en endpoints sensibles.