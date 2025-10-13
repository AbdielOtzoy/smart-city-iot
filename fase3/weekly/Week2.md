# Reporte Semanal N°2 — Fase 3  
**Curso:** Arquitectura y Ensambladores 2  
**Proyecto:** Sistema Inteligente de Seguridad y Gestión de Tráfico Urbano    
**Fecha:** Semana 2 – Octubre 2025  

---

## Objetivo del reporte
Registrar los avances técnicos alcanzados por el grupo durante la segunda semana de desarrollo de la Fase 3, con énfasis en la integración de la Inteligencia Artificial, la conexión entre dispositivos IoT y el despliegue de los primeros módulos funcionales.

---

## Actividades realizadas
Durante esta semana el equipo se centró en la **implementación práctica del sistema**, especialmente en los componentes de comunicación e inteligencia artificial.  
Las principales actividades fueron:

- **Integración inicial de los modelos de IA**:
  - Se probaron los modelos de detección de **rostros, placas y armas blancas** en las laptops del grupo.
- **Desarrollo del Backend (Raspberry Pi)**:
  - Se creó el endpoint `POST /api/info` para recibir los datos procesados desde las laptops.
  - Se validó la comunicación con la base de datos.
- **Avances en el Arduino UNO**:
  - Se actualizaron los comandos seriales para nuevas alertas.
  - Se programaron sonidos específicos para cada tipo de evento.
- **Aplicación Flutter (Frontend)**:
  - Se agregó la sección de “Alertas en Tiempo Real”.
  - Se configuró el dashboard básico de eventos.
- **Dashboard en Grafana**:
  - Se conectó correctamente la base de datos y se generaron los primeros paneles de métricas.

---

## Contribuciones individuales del equipo

| Integrante | Aporte realizado |
|-------------|------------------|
| **Dany** | Implementó la lógica de comunicación entre la Raspberry Pi y el Arduino mediante comandos seriales. Configuró la API Flask para recibir los datos desde las laptops. |
| **Sebas** | Configuró el servidor Grafana y creó paneles dinámicos para visualizar los eventos de IA. Colaboró en las pruebas del endpoint principal. |
| **Melgar** | Entrenó y probó el modelo de detección de armas con YOLOv8 y realizó las primeras pruebas con capturas de video reales. |
| **Abdiel** | Desarrolló el modelo de detección facial utilizando MobileNet y conectó el flujo con la API local. |
| **Engel** | Avanzó en el modelo de reconocimiento de placas vehiculares utilizando EasyOCR y mejoró la lectura de texto. |
| **Christian** | Encargado de la documentación y pruebas generales del sistema. Elaboró el reporte técnico semanal. |
| **Bryan** | Diseñó el esquema de base de datos extendido con tablas de detecciones e integró el endpoint `/api/info`. |
| **Daniel** | Realizó los diagramas de arquitectura de la Fase 3 y participó en la configuración del entorno IoT. |
| **Rabit** | Implementó los widgets de “Alertas en Tiempo Real” en Flutter y probó la comunicación con la API. |

---

## Resultados parciales
- Flujo completo **Laptop → API Raspberry → Base de Datos → Arduino** operativo.  
- Recepción correcta de detecciones de prueba.  
- Aplicación Flutter funcional con alertas básicas.  
- Maqueta actualizada con cámaras y zumbadores activos.

---

## Plan de la siguiente semana
- Optimizar los modelos de IA con datasets personalizados.  
- Implementar los endpoints `/api/top_personas` y `/api/top_armas`.  
- Sincronizar Grafana con nuevas métricas.  
- Preparar documentación técnica y pruebas finales.  

---

## Observaciones
El grupo mantiene una comunicación constante y demuestra avances coordinados.  
Se detectó la necesidad de mejorar la latencia entre la Raspberry y las laptops, pero la arquitectura general funciona correctamente.

