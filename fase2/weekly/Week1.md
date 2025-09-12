


##  **Reporte Semanal  – Semana 1**

### **Objetivo de la semana**

Iniciar la transicion  hacia la arquitectura IoT planteada para la Fase 2 del proyecto definiendo la comunicacion entre Arduino y  la Raspberry Pi configurando el broker MQTT y estableciendo la base para la API al igual que la base de datos para comenzar el desarrollo de la aplicacion Flutter junto con el diseño fisico y estetico de la maqueta, tambien se realizaron varios diagramas tecnicos y el Smart Connected Design Framework para documentar la arquitectura del sistema.

---

### **Resumen general de avances**

Durante la primera semana nuestro equipo se concentro en centar las bases tecnologicas y fisicas para esta fase intentnado asegurar de que cada componente quedara bien encaminado para su integración entre las principales actividades que realizamos se incluyen:

* **Configuracion inicial de comunicacion entre Arduino y Raspberry Pi**
  Se establecio la conexion serial mediante USB probando la transmision de datos desde el Arduino hacia la Raspberry Pi la cual recibira y procesara los datos antes de publicarlos en MQTT los resultados fueron buenos aunque falta hacer mejoras.

* **Implementacion del broker MQTT**
  Se instalo y configuro Mosquitto en la Raspberry Pi como servidor MQTT esto nos permitio la comunicacion asincronica entre sensores, backend y aplicacion movil usando topicos bien estructurados.

* **Desarrollo inicial de la API y base de datos**
  Se diseño la estructura de la API y se propuso un esquema de base de datos que soportara la persistencia de datos historicos y tambien permitira consultas en tiempo real.

* **Avances en la aplicacion Flutter**
  Se trabajo en la implementacion inicial de tres modulos clave:

  * **Mapa Interactivo:** para mostrar informacion geoespacial en tiempo real.
  * **Feed de Notificaciones:** para presentar alertas recientes.
  * **Dashboard de Control:** esto mostrara metricas de trafico y seguridad.

* **Diseño y prototipado 3D**
  Se inicio el modelado de la pieza 3D que formara parte del prototipo fisico considerando ergonomia, funcionalidad y principalmente estetica tambien se realizaron pruebas iniciales para verificar medidas.

* **Smart Connected Design Framework y diagramas tecnicos**
  Se elaboro la documentacion conceptual y visual de la arquitectura de esta fase detallando flujo de datos, comunicacion y distribucion de responsabilidades entre hardware, backend y aplicacion.

---

### **Aportes individuales**

#### **DANIEL ANDREE HERNANDEZ FLORES**

* Investigo y configuro la comunicacion entre Arduino y Raspberry Pi mediante puerto serial.
* Instalo y realizo pruebas iniciales del broker MQTT publicando mensajes de prueba en topicos simulados.
* Desarrollo un script en Python para lectura continua de datos desde el puerto serial con capacidad para enviarlos al broker MQTT.

#### **EDUARDO SEBASTIAN GUTIERREZ FELIPE**

* Configuro el repositorio de GitHub para la Fase 2 creando ramas de desarrollo para backend, Flutter y documentacion.
* Implemento la estructura inicial del Mapa Interactivo en Flutte, mostrando posiciones simuladas en un entorno gráfico.
* Integro funciones basicas para consumir datos desde la API mediante endpoints de prueba.

#### **ABDIEL FERNANDO JOSe OTZOY OTZiN**

* Diseño la estructura de la API REST usando un framework moderno definiendo endpoints y metodos de autenticacion basicos.
* Propuso un modelo de base de datos no relacional para almacenar eventos de sensores, alertas y datos de trafico.
* Desarrollo un primer endpoint para validar la conexion entre la aplicacion movil y el backend.

#### **GABRIEL ANDRES MELGAR ARAGON**

* Desarrollo la base del Feed de Notificaciones en Flutter permitiendo mostrar alertas de forma dinamica.
* Colaboro en la definicion del flujo de datos entre la API y la aplicacion planificando el uso de JSON como formato estandar.
* Apoyo en el diseño de la pieza 3D ajustando su forma y dimensiones para la integracion en la maqueta.

#### **CHRISTIAN DAVID CHINCHILLA SANTOS**

* Diseño el modelo 3D del prototipo utilizando software de modelado.
* Realizo una primera impresion de prueba para validar dimensiones y soportes estructurales.
* Apoyo en el montaje fisico y organizacion de los espacios dentro de la maqueta para incorporar la pieza.

#### **ENGEL EMILIO COC RAXJAL**

* Documento los avances semanales incluyendo tareas, aportes y dificultades encontradas por cada integrante.
* Propuso mejoras esteticas para la maqueta como señalizacion, texturas y refuerzos estructurales, presentando bocetos preliminares.
* Coordino con el equipo de montaje para planificar ajustes visuales en la fase final.

#### **JHONATAN IVAN GUOZ TUBAC**

* Desarrollo la base del Dashboard de Control en Flutter incluyendo una vista inicial con metricas simuladas.
* Integro funciones para actualizar la informacion de manera periodica (simulada) preparando la conexion real con la API.
* Ayudo con ideas claves en la planificacion de mejoras visuales para la maqueta.

#### **DANIEL ABRAHAM ORTIZ CHINCHILLA**

* Documento el Smart Connected Design Framework explicando las capas de conexion y flujo de informacion.
* Elaboro diagramas de arquitectura y flujo de datos para la Fase 2 mostrando como se interconectan los distintos modulos.
* Preparo una version preliminar de la documentacion tecnica para futuras entregas.

#### **BRYAN JOSUE CORONADO LAINEZ**

* Apoyo en el montaje fisico de la pieza 3D y en la organizacion interna de la maqueta para alojar los nuevos componentes.
* Colaboro en pruebas de comunicacion entre los modulos iniciales de hardware y software.
* Propuso mejoras adicionales en la estetica de la maqueta especialmente en la distribucion de cables y presentacion visual.

---

### **Dificultades encontradas**

* Configurar el entorno de la Raspberry Pi tomo mas tiempo de lo esperado debido a problemas de dependencias para MQTT y la API.
* El modelo 3D requirio ajustes de medidas para garantizar compatibilidad con la maqueta lo cual atraso el avance.
* Coordinacion entre los equipos de API y Flutter aun en fase de integracion ya que la API estaba en desarrollo inicial.
* Falta de experiencia previa de algunos integrantes en MQTT y comunicacion serial avanzada.

---

### **Tareas pendientes para la semana 2**

1. Completar el montaje y prueba final de la pieza 3D en la maqueta.
2. Integrar la API con la base de datos y conectar la aplicacion Flutter para consumir datos reales.
3. Probar el flujo completo de datos desde Arduino con Raspberry Pi + MQTT + API + Flutter.
4. Refinar la estetica de la maqueta  y darle mantenimiento a las piezas deterioradas.
5. Continuar documentando avances incluyendo evidencia fotográfica y diagramas de progreso.

---

