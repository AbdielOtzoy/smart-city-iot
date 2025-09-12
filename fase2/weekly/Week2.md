

## **Reporte Semanal – Semana 2**

### **Objetivo de la semana**

El objetivo principal de esta segunda semana fue avanzar en la integracion de los diferentes modulos del sistema conectando el backend con la base de datos estableciendo la comunicacion fluida entre Arduino y Raspberry Pi a traves de MQTT y realizando las primeras pruebas de transmision de datos hacia la aplicacion movil en Flutter, ademas se busco consolidar el montaje fisico del prototipo integrando la pieza 3D en la maqueta y reforzando detalles esteticos.



### **Resumen general de avances**

Durante esta semana nuestro equipo termino la fase de preparacion y tambien se sento las bases de una integracion  entre hardware y software, los principales logros fueron:

* **Integracion de la API con la base de datos**
  Se implemento la conexion entre la API REST y el gestor de base de datos definido esto permitio que los eventos generados por los sensores comenzaran a registrarse de manera persistente creando asi los primeros registros historicos en el sistema.

* **Pruebas de comunicacion Arduino + Raspberry Pi + MQTT**
  Los datos obtenidos de los sensores conectados al Arduino fueron transmitidos por puerto serial a la Raspberry Pi donde un script de servicio proceso la informacion y la publico en topicos especificos dentro del broker MQTT esto valido el flujo de datos en tiempo real desde el hardware hacia la red de comunicacion aunque hacen falta mejoras.

* **Consumo de datos desde Flutter**
  La aplicacion movil comenzo a conectarse con la API logrando mostrar datos simulados y algunos obtenidos de pruebas reales se avanzo tambien en el Mapa Interactivo  el Feed de Notificaciones y el Dashboard de Control asegurando que la interfaz fuera capaz de recibir y representar informacion en tiempo real.

* **Avances en el prototipo fisico y pieza 3D**
  Una de las piezas impresas en 3D fue ajustada y montada en la maqueta esto permitio organizar mejor los componentes internos y mejorar la presentacion general tambien se trabajo en reforzar la estructura de la maqueta y en detalles esteticos que la hicieron mas representativa.

* **Documentacion y diagramas actualizados**
  Se actualizaron los diagramas de flujo de datos y arquitectura incluyendo ya la interaccion real entre API, base de datos y aplicacion movil asimismo se documentaron los avances de cada integrante en esta etapa de integracion.



### **Aportes individuales**

#### **DANIEL ANDREE HERNANDEZ FLORES**

* Continuo con la configuracion de la comunicacion Arduino–Raspberry Pi.
* Valido el funcionamiento del script en Python para lectura del puerto serial y publicacion en MQTT.
* Realizo pruebas de envio de datos reales de sensores logrando que la Raspberry Pi los procesara y publicara en topicos organizados.

#### **EDUARDO SEBASTIAN GUTIERREZ FELIPE**

* Dio seguimiento a la administracion del repositorio en GitHub manteniendo actualizado el avance de Flutter y backend.
* Integro el Mapa Interactivo en Flutter con la API logrando mostrar posiciones simuladas y pruebas iniciales de datos en tiempo real.
* Aporto en la verificacion de endpoints desde la aplicacion movil.

#### **ABDIEL FERNANDO JOSe OTZOY OTZiN**

* Conecto la API con la base de datos creando endpoints que permitieron registrar eventos de sensores.
* Realizo pruebas de insercion y consulta de datos en la base de datos asegurando la persistencia de informacion.
* Comenzo a implementar endpoints mas complejos para consultas de alertas y metricas.

#### **GABRIEL ANDReS MELGAR ARAGON**

* Continuo con el desarrollo del Feed de Notificaciones en Flutter mostrando alertas generadas en las pruebas de MQTT y API.
* Colaboro en pruebas de integracion con la aplicacion movil verificando la correcta recepcion de datos.
* Participo en el montaje fisico de la pieza 3D dentro de la maqueta.

#### **CHRISTIAN DAVID CHINCHILLA SANTOS**

* Monto de manera definitiva la pieza 3D en la maqueta asegurando su funcionalidad y estetica.
* Apoyo en la organizacion interna del cableado y en la disposicion de los componentes fisicos.
* Realizo pruebas de estabilidad del prototipo fisico despues de la integracion de una pieza.

#### **ENGEL EMILIO COC RAXJAL**

* Documento los aportes semanales de cada integrante y elaboro un registro mas detallado del proceso de integracion.
* Propuso mejoras visuales y esteticas en la maqueta como señalizacion y texturas que comenzaron a aplicarse durante la semana.
* Coordino con el resto del equipo para planificar los ajustes de presentacion final.

#### **JHONATAN IVAN GUOZ TUBAC**

* Avanzo en la implementacion del Dashboard de Control en Flutter incorporando metricas basicas obtenidas de la API.
* Realizo pruebas de visualizacion de graficos y tablas dinamicas preparando la base para la visualizacion final en la Semana 3.
* Apoyo en la estetica de la maqueta con sugerencias y ajustes menores.

#### **DANIEL ABRAHAM ORTIZ CHINCHILLA**

* Actualizo el documento del Smart Connected Design Framework incluyendo las mejoras logradas en la integracion.
* Redibujo los diagramas de flujo de datos mostrando ahora el recorrido real de la informacion desde los sensores hasta la aplicacion movil.
* Trabajo en la documentacion de arquitectura para incluir en la entrega final.

#### **BRYAN JOSUe CORONADO LAINEZ**

* Colaboro en la instalacion fisica de la pieza 3D en la maqueta .
* Apoyo en la verificacion de las conexiones internas tras el montaje asegurando que no se afectara la transmision de datos.
* Contribuyo a reforzar y mejorar la presentacion visual de la maqueta.

---

### **Dificultades encontradas**

* Durante las pruebas de comunicacion MQTT se presentaron problemas de latencia y perdida de algunos mensajes.
* La integracion de la API con Flutter requirio ajustes adicionales, ya que los datos en JSON no siempre llegaban en el formato esperado.
* La pieza 3D necesito varias correcciones antes de montarse de forma estable en la maqueta.
* El tiempo de coordinacion entre los equipos de backend y frontend fue limitado debido a la carga de otros cursos.
* Se produjo un retraso en la entrega final de la maqueta porque las impresiones 3D se demoraron varios días debido a problemas con el proveedor.

---

### **Tareas pendientes para la semana 3**

1. Realizar pruebas completas de extremo a extremo (sensores + Arduino + Raspberry Pi + MQTT + API + Base de Datos + Flutter).
2. Optimizar la API y la base de datos para mejorar la velocidad de consulta y reducir errores en la integracion.
3. Completar las vistas de Flutter (Mapa, Feed y Dashboard) con datos reales en tiempo real.
4. Refinar los detalles esteticos y estructurales de la maqueta.
5. Documentar los resultados de las pruebas finales y preparar la entrega completa de la Fase 2.
6. Terminar la integracion de las piezas 3D en al maqueta.

---

