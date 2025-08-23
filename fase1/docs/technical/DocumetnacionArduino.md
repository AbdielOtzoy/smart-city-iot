


## **Documentación Técnica del Sistema de Monitoreo y Control**

### **1. Introducción**

Este documento describe el funcionamiento de un sistema de monitoreo y control implementado en una placa Arduino. El sistema está diseñado para gestionar un cruce de dos semáforos, monitorear el tráfico mediante sensores ultrasónicos, detectar condiciones ambientales anómalas como la presencia de gases y sismos, y permitir la activación de alertas de pánico manuales. Toda la información y las alertas generadas son comunicadas a un sistema externo a través del puerto serie para su visualización y registro.

----------

### **2. Configuración de Hardware y Definición de Pines**

El sistema integra diversos sensores y actuadores conectados a pines específicos de la placa Arduino. A continuación, se detalla la configuración del hardware.

-   **Semáforos**: Se controlan dos semáforos de tres luces (rojo, amarillo y verde).
    
    -   **Semáforo 1**: Conectado a los pines digitales 6 (rojo), 5 (amarillo) y 4 (verde)1.
        
    -   **Semáforo 2**: Conectado a los pines digitales 9 (rojo), 8 (amarillo) y 7 (verde)2.
        
-   **Sensores Ultrasónicos HC-SR04**: Se utilizan siete sensores para medir distancias y detectar vehículos o peatones.
    
    -   **Pines `Trig` (Disparo)**: Conectados a los pines 22, 24, 26, 28, 30, 32 y 343.
        
    -   **Pines `Echo` (Eco)**: Conectados a los pines 23, 25, 27, 29, 31, 33 y 354.
        
-   **Botones de Pánico**: Tres botones pulsadores, configurados como `INPUT_PULLUP`, permiten la activación manual de alarmas por zona5.
    
    -   Están conectados a los pines 2, 3 y 186.
        
-   **Buzzers (Zumbadores)**: Tres buzzers actúan como alarmas sonoras, uno por cada zona de monitoreo.
    
    -   Conectados a los pines 10, 11 y 12, correspondientes a las Zonas 1, 2 y 3 respectivamente7.
        
-   **Sensores de Gas MQ**: Se emplean tres sensores de gas para detectar la calidad del aire o la presencia de humo.
    
    -   Conectados a los pines analógicos A0, A1 y A28. Se activa una alerta si la lectura es inferior a un umbral de
        
        `95.0`9.
        
-   **Sensor Sísmico (Piezoeléctrico)**: Un sensor piezoeléctrico detecta vibraciones, como las de un sismo.
    
    -   Está conectado al pin digital 2010.
        

----------

### **3. Lógica de Funcionamiento**

El código se estructura en torno a una lógica de estados para los semáforos, lectura constante de sensores y un sistema de gestión de alarmas basado en eventos.

#### **3.1. Control de Semáforos**

El control de los semáforos se basa en una máquina de estados predefinida en el arreglo

`estados`11. Este arreglo contiene cuatro combinaciones posibles que dictan qué luz está encendida para cada semáforo (0 para rojo, 1 para amarillo y 2 para verde)12.

El programa cicla a través de estos estados, cambiando cada 5 segundos (

`tiempoEstado`)13. La función

`loop()` actualiza el estado actual de los semáforos 14141414y la función

`mostrarEstado()` se encarga de encender y apagar los LEDs correspondientes15.

#### **3.2. Lectura de Sensores**

-   **`leerHC_SR04()`**: Esta función mide la distancia con los siete sensores ultrasónicos. Emite un pulso desde el pin
    
    `Trig`, mide el tiempo que tarda en regresar el eco al pin `Echo` 16y convierte ese tiempo en centímetros17.
    
-   **`leerMQSensors()`**: Lee los valores analógicos de los tres sensores de gas y los almacena en el arreglo `mqReadings` para su posterior análisis18.
    

#### **3.3. Sistema de Alertas y Gestión de Buzzers**

El sistema puede activar diferentes tipos de alarmas sonoras según el evento detectado. La gestión de los buzzers se realiza de forma asíncrona mediante la función

`gestionarBuzzers()`19, que permite reproducir patrones de sonido sin detener el resto del programa.

Las alarmas se definen por un tipo (

`buzzerType`), que determina el patrón de sonido20:

-   **Tipo 1 (Botón de Pánico)**: Se activa cuando se presiona uno de los botones de pánico21. Genera 3 pitidos cortos22. La activación se realiza mediante interrupciones para una respuesta inmediata23.
    
-   **Tipo 2 (Infracción de Tráfico)**: Se activa si un sensor HC-SR04 detecta un objeto a menos de 3 cm cuando el semáforo correspondiente está en rojo24242424. Genera 2 pitidos largos25.
    
-   **Tipo 3 (Alarma Sísmica)**: Se activa cuando el sensor piezoeléctrico detecta una vibración26. Activa todos los buzzers con 5 pitidos rápidos27.
    
-   **Tipo 4 (Alerta de Gas/Humo)**: Se activa si la lectura de un sensor MQ cae por debajo del umbral establecido (`mqThreshold`)2828. Genera un pitido continuo y largo29.
    

----------

### **4. Protocolo de Comunicación Serial**

El sistema envía constantemente datos a través del puerto serie a una velocidad de 9600 baudios30. Este mecanismo permite que una aplicación externa (por ejemplo, una interfaz en Processing) visualice el estado del sistema en tiempo real. Los mensajes tienen un formato estandarizado

`CLAVE:VALOR`.

-   **Estado de Semáforos**: `SEMAFORO:<ID>:<ESTADO>`31.
    
-   **Posición de Autobuses**: `BUS:<TIPO>:<ID>:<DISTANCIA>`32.
    
-   **Alerta de Incendio**: `INCENDIO:<ID>:<NIVEL>:<ESTADO>`33.
    
-   **Alerta de Humo**: `HUMO:<NIVEL>:<ESTADO>`34.
    
-   **Alerta Sísmica**: `SISMO:<NIVEL>:<TIMESTAMP>`35.
    
-   **Alerta de Pánico**: `PANICO:<ZONA>:<TIMESTAMP>`36.
    
-   **Alerta de Infracción**: `INFRACCION:<ZONA>:<TIMESTAMP>`37.
    
-   **Mensaje de Sistema (Keep-alive)**: `SISTEMA:OK:<TIMESTAMP>`38.
    

----------

### **5. Flujo del Programa**

1.  **`setup()`**:
    
    -   Configura los pines de los semáforos, buzzers y sensores como entradas o salidas393939.
        
    -   Inicializa la comunicación serie40.
        
    -   Configura las interrupciones para los botones de pánico y el sensor sísmico41.
        
    -   Establece el estado inicial de los semáforos42.
        
2.  **`loop()`**:
    
    -   Lee continuamente los valores de los sensores MQ y HC-SR0443434343.
        
    -   Verifica si las lecturas de los sensores MQ o HC-SR04 ameritan la activación de una alarma44444444.
        
    -   Gestiona los patrones de sonido de los buzzers si hay una alarma activa45.
        
    -   Actualiza el estado de los semáforos cada 5 segundos46.
        
    -   Envía el estado completo del sistema a través del puerto serie47.
        
    -   Introduce un retardo de 1 segundo (
        
        `delay(1000)`) para regular la velocidad del ciclo48.