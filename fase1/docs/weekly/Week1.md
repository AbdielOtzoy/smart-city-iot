



##  **Reporte Semanal  – Semana 1**


**Objetivo de la semana:** Avanzar en la implementacion fisica del sistema en la maqueta con el objetivo de  trasladarlo al prototipo previamente probado en protoboard y en simulacion integrando el cableado, ubicacion de sensores y preparacion para pruebas finales.

---

### **Resumen general de avances**

Durante esta semana el equipo se enfoco en la transicion de un sistema funcional en protoboard hacia su montaje definitivo en la maqueta fisica pero antes de eso ya contabamos con lo siguiente:

* **Codigo Arduino finalizado**: incluyendo la programacion de sensores (HC-SR04, MQ-02, piezoelectrico), logica de control para semaforos, deteccion de infracciones, sismos, incendios y alertas de boton de panico.
* **Aplicacion en Processing** : Ya  con panel de alertas, visualización de semaforos, rutas de transporte y monitoreo en tiempo real de datos de sensores (actualmente solo se probo con simulacion de datos ).
* **Pruebas exitosas** tanto en simulación como en protoboard validando la comunicación I2C entre Arduinos y la conexión serial con Processing.

En la maqueta ya teniamos finalizada la construccion de todos los elementos fisicos tales como :edificios, paradas de autobús, monumentos, calles y buses en miniatura pero aun no estaban integrados los componentes electronicos ya que necesitabamos hacer perforaciones para el cableado.

---
Las actividades de esta semana se centraron en:

1. **Preparación de la maqueta para integración electronica**: Se realizaron perforaciones estrategicas para la instalacion de sensores y ocultamiento de cableado tambien se hicieron pequeños cambios en el tamaño de los edificios y las paradas de autobus ya que las calles son pequeñas y se necesitaba  espacio para que los sensores funcionaran correctamente.

2. **Construir la maqueta**: Se construyo por separado cada una de las partes que la conforman incluyendo edificios, paradas de transporte, monumentos, calles y demas elementos decorativos esto permitio trabajar de manera individual en cada componente antes de su integracion final de esta forma optimizamos el tiempo de construcion solo quedando el ensamblaje.

3. **Ubicación preliminar**: Se determino la posicion preliminar de LEDs, sensores y actuadores verificando su compatibilidad con el diseño fisico y asegurando que las perforaciones y soportes fueran adecuados para su montaje definitivo.

4. **Pruebas iniciales**: Se realizaron pruebas de conexion en la maqueta para comprobar que los sensores mantuvieran su precision al ser integrados en su posicion de trabajo aunque aun no se montaron de forma definitiva se logro confirmar su correcto funcionamiento y alcance en el entorno fisico.

5. **Desarrollo del panel de alertas y visualización**: Se implemento el panel de alertas en Processing integrando el calculo de distancias hacia las paradas de transporte y mejorando la visualizacion de datos de deteccin de humo y alertas sismicas tambien se desarrollo un sistema de representacion visual clara para estos eventos.

6. **Conexiones electrónicas en protoboard**: Se completo toda la interconexión electronica en protoboard conectando todos los sensores (HC-SR04, MQ-02, piezoeléctrico) y actuadores (LEDs, zumbadores y botones) logrando un sistema totalmente funcional previo a la transición a la maqueta.



---


### **Aportes individuales**

#### **DANIEL ANDREE HERNANDEZ FLORES** 

* Conecto fisicamente los sensores HC-SR04 y MQ-02 en la maqueta asegurando correcta orientacion para la deteccion.
* Probo la comunicacion I2C en una protoboar para  verificando envio y recepcion de datos.
* Ejecuto pruebas rapidas de lectura de cada sensor para confirmar que no hubo fallos por manipulación fisica.

#### **EDUARDO SEBASTIAN GUTIERREZ FELIPE** 

* Ajusto la logica de control para coordinar el cambio de luces de semaforo con los eventos detectados por sensores de trafico.
* Valido la logica de deteccion de infracciones (vehiculos detectados con semaforo en rojo).
* Refino el calculo de distancias y estimación de tiempo de llegada de buses adaptandolo a la longitud real de las rutas en la maqueta.


#### **ABDIEL FERNANDO JOSÉ OTZOY OTZÍN** 

* Configuro el puerto serial en Processing para recibir datos desde el Arduino Master.
* Adapto la visualizacion de semaforos a las dimensiones reales del mapa en la maqueta.
* Implemento indicadores visuales y animaciones para alertas de infracción y deteccion de humo.


#### **GABRIEL ANDRES MELGAR ARAGÓN** 

* Programo el panel de alertas en Processing, clasificando visualmente los tipos de evento (panico, sismo, incendio, infraccion).
* Implemento la visualización dinámica de rutas de transporte en el dashboard.
* Añadio indicadores de posicion en tiempo real para los buses actualizados con los datos del HC-SR04.


#### **CHRISTIAN DAVID CHINCHILLA SANTOS** 

* Coordino el diseño final de la maqueta, validando que todas las ubicaciones de sensores y actuadores fueran accesibles.
* Construyo la base principal de la maqueta incluyendo calles, avenidas e intersecciones para semáforos.
* Marco las ubicaciones de perforaciones para sensores y cableado.
* Preparo el terreno para el montaje de elementos decorativos y señalizacion vial.

#### **ENGEL EMILIO COC RAXJAL** 

* Construyo y coloco las paradas de Transmetro y Transurbano junto a los buses.
* Realizo la señalizacion correspondiente a rutas y paradas en la maqueta.
* Apoyo en las tareas de cableado y en la colocacion de semaforos y sensores asegurando su correcta conexion y funcionamiento.
* Registró las decisiones técnicas sobre ubicación de sensores y rutas de cableado.

#### **JHONATAN IVAN GUOZ TUBAC** 

* Elaboro replicas de edificios y monumentos historicos.
* Señalizo los lugares de interes con base en el diseño original.
* Integro espacios reservados para colocar sensores MQ-02 dentro de las estructuras.
* Preparo material visual para la documentacion final (fotografías y diseños).

#### **DANIEL ABRAHAM ORTIZ CHINCHILLA** 

* Instalo los semaforos LED en intersecciones según el diseño del circuito.
* Coloco sensores ultrasónicos en posiciones estratégicas de la ruta de buses.
* Organizo el cableado interno siguiendo rutas ocultas para mantener la estetica.
* Inicio la colocación de elementos decorativos como arboles y señales.

#### **BRYAN JOSUÉ CORONADO LAINEZ** 

* Elaboro el esquema electrico final del sistema.
* Documento el proceso de conexión de todos los componentes en la maqueta.
* Valido que la distribución del cableado coincidiera con el diseño tecnico y el plano de la maqueta.
* Apoyo en las tareas de cableado y en la colocacion de semaforos y sensores asegurando su correcta conexion y funcionamiento.

---

### **Dificultades encontradas**

* Necesidad de abrir perforaciones adicionales debido a la posición de algunos componentes electrónicos ademas se detecto que algunas de las perforaciones tendrian que cambiar de ubicación por problemas de espacio y accesibilidad.
* Ajuste de longitudes de cable para evitar tension cruces innecesarios o desconexiones accidentales durante el montaje.
* Alineacion precisa de los sensores HC-SR04 para evitar falsos positivos causados por obstaculos cercanos o variaciones en la superficie de la maqueta.
* Limitacion en las pruebas de algunos modulos de software debido a que el Arduino estaba ocupado en la instalación de la electronica lo que obligo a validar ciertos procesos onicamente con datos simulados.
* Necesidad de reorganizar parte del cableado para facilitar el encapsulamiento y evitar que interfiera con el diseño estetico de la maqueta.
* Requerimiento de reforzar la fijacion de algunos componentes para que no se desplacen durante las pruebas o manipulacion de la maqueta.



---

### **Tareas pendientes para la próxima semana**

1. Finalizar el pegado definitivo de todos los elementos de la maqueta.
2. Completar la instalación de cableado interno y encapsulamiento de componentes.
3. Realizar pruebas completas de integración Arduino + Processing directamente en la maqueta.
4. Documentar los resultados de las pruebas y preparar material visual para la entrega de Fase 1.



