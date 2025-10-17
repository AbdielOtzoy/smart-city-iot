# Reporte Semanal N°3 — Fase 3  
**Curso:** Arquitectura y Ensambladores 2  
**Proyecto:** Sistema Inteligente de Seguridad y Gestión de Tráfico Urbano  
  
---

## Objetivo del reporte
Documentar los avances finales y la consolidación del proyecto durante la tercera semana de la Fase 3, reflejando los resultados alcanzados, las pruebas de integración, la presentación del prototipo y las conclusiones del equipo.

---

## Actividades finales
Durante esta semana se realizó la **integración total** del sistema, la **verificación de comunicación entre todos los módulos** y la **demostración del proyecto funcional**.  
Principales acciones:

- Integración completa de **IA, Raspberry, Arduino y Flutter**.  
- Implementación de los endpoints `/api/top_personas` y `/api/top_armas`.  
- Ajuste de la base de datos y depuración de registros.  
- Configuración final de los paneles en Grafana con datos en tiempo real.  
- Pruebas del flujo completo (detección → API → alerta física → notificación → dashboard).  
- Presentación grupal del prototipo funcional y grabación del video demostrativo.

---

## Contribuciones individuales del equipo

| Integrante | Aporte realizado |
|-------------|------------------|
| **Dany** | Ajustó la API para manejar múltiples solicitudes y evitar bloqueos. Configuró la comunicación final entre la Raspberry Pi y el Arduino con comandos seriales optimizados. |
| **Sebas** | Finalizó el tablero de Grafana con métricas en tiempo real y configuró la integración con la base de datos. Apoyó en la presentación final. |
| **Melgar** | Refinó el modelo de IA para detección de armas, mejorando la precisión de identificación. Apoyó en la conexión entre la laptop y la Raspberry. |
| **Abdiel** | Mejoró la IA de reconocimiento facial agregando nuevas imágenes de entrenamiento y ajustando los umbrales de detección. |
| **Engel** | Integró el modelo de detección de placas a la API, validando el envío de datos a la base de datos con éxito. |
| **Christian** | Coordinó la documentación final, elaboró los reportes semanales y participó en la grabación de la demostración funcional. |
| **Bryan** | Implementó los endpoints `/api/top_personas` y `/api/top_armas` y verificó las consultas desde Flutter. |
| **Daniel** | Actualizó los diagramas del sistema y la maqueta digital, asegurando que reflejaran el flujo final de datos. |
| **Jhonatan** | Mejoró la interfaz Flutter, integrando los widgets de notificación y el dashboard analítico con datos reales. |

---

## Resultados finales
- **Sistema IoT e IA completamente integrado** y funcional.  
- **Base de datos actualizada** con registros precisos de detecciones.  
- **Alertas físicas y digitales** operativas en tiempo real.  
- **Aplicación Flutter** mostrando métricas y notificaciones de eventos.  
- **Demostración final exitosa**, validando todos los objetivos de la fase.  

---

## Conclusiones del equipo
- Se consolidaron los conocimientos en **IoT, IA y comunicación de sistemas embebidos**.  
- La arquitectura propuesta demostró ser eficiente y escalable.  
- El trabajo colaborativo fue clave para superar problemas de comunicación y rendimiento.  
- El sistema final refleja una solución innovadora para la seguridad y monitoreo urbano.  

---

## Observaciones finales
El proyecto se entregó con todos los módulos funcionando correctamente, documentación completa y repositorio GitHub actualizado.  
La maqueta logró representar una ciudad inteligente a escala, combinando hardware, software y análisis de datos en tiempo real.

