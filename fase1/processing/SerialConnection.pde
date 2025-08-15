// ================================================================ //
//          GESTIÓN DE CONEXIÓN SERIAL (SerialConnection.pde)       //
// ---------------------------------------------------------------- //
// Responsabilidades:                                               //
// - Conexión serial con Arduino                                   //
// - Recepción y parsing de datos                                  //
// - Almacenamiento del estado del sistema                         //
// - Funciones getter para acceder a los datos                     //
// ================================================================ //

/*
EMEPLO DE DATOS QUE LE DEBERIA ENVIAR EL ARDUINO A PROCESSING
SEMAFORO:1:ROJO
SEMAFORO:2:VERDE
SEMAFORO:3:ROJO
SEMAFORO:4:ROJO
SEMAFORO:5:VERDE
SEMAFORO:6:ROJO
SEMAFORO:7:VERDE
SEMAFORO:8:ROJO
SEMAFORO:9:AMARILLO
SEMAFORO:10:ROJO
BUS:TRANSMETRO:1:100
BUS:TRANSMETRO:2:300
BUS:TRANSURBANO:3:0
BUS:TRANSURBANO:4:200
INCENDIO:1:850:ALERTA
INCENDIO:2:220:NORMAL
INFRACCION:3:1234567895
PANICO:1:1234567896
SISMO:ALTO:1234567897
SISTEMA:OK:1234567898
-----------
ESTRUCTURA GENERAL:
TIPO_EVENTO:PARAMETRO1:PARAMETRO2:PARAMETRO3\n
*/

import processing.serial.*;

// --- CONFIGURACIÓN SERIAL ---
Serial arduino;
boolean serialConnected = false;
String serialPort = ""; // Se detectará automáticamente
int baudRate = 9600;

// --- MODO DE SIMULACIÓN (NUEVO) ---
boolean modoSimulacion = false;
long ultimoTiempoSimulacion = 0;
final int INTERVALO_SIMULACION = 3000; // 3 segundos

// --- ESTADO DEL SISTEMA (DATOS RECIBIDOS) ---
// Semáforos (10 semáforos)
String[] semaforoEstados = new String[10];
long[] semaforoUltimaActualizacion = new long[10];

// Transporte Público (2 paradas: Transmetro y Transurbano)
int[] busDistancias = new int[2];
String[] busTipos = {"TRANSMETRO", "TRANSURBANO"};
long[] busUltimaActualizacion = new long[2];

// Incendios (2 lugares históricos)
int[] incendioNiveles = new int[2];
String[] incendioEstados = new String[2];
long[] incendioUltimaActualizacion = new long[2];

// Botones de Pánico (6 botones)
boolean[] panicoBotones = new boolean[6];
long[] panicoTimestamps = new long[6];

// Alertas y eventos
ArrayList<String> alertasRecientes = new ArrayList<String>();
ArrayList<String> infraccionesRecientes = new ArrayList<String>();
boolean sismoActivo = false;
long sismoTimestamp = 0;

// Estado de conexión
long ultimaRecepcion = 0;
boolean sistemaActivo = false;

// --- Variables para simulación de movimiento de buses ---
float busVelocidadTransmetro = 5.0; // cm por segundo (más lento)
float busVelocidadTransurbano = 4.0; // cm por segundo (más lento)
float busDistanciaTotal = 100.0; // cm (ancho de la maqueta)
long busUltimoMovimiento = 0;
float[] busPosicionesSimuladas = {0, 0}; // [Transmetro, Transurbano]
int[] busDirecciones = {1, 1}; // 1: hacia final, -1: hacia inicial
long[] busDetenidoTimestamp = {0, 0}; // Tiempos cuando se detuvo cada bus

// --- NUEVO: Variables para monitoreo ambiental MQ-02 ---
int humoNivel = 0; // Valor del sensor MQ-02 (0-1000)
String humoEstado = "NORMAL"; // "NORMAL" o "ALERTA"
long humoUltimaActualizacion = 0;

// ================================================================ //
//        FUNCIONES PRINCIPALES DE PROCESSING (setup y draw)        //
// ================================================================ //


/**
 * Se ejecuta en bucle, es el corazón de la animación y la lógica.
 */

// ================================================================ //
//                     INICIALIZACIÓN Y CONEXIÓN                    //
// ================================================================ //

/**
 * Inicializa la conexión serial con Arduino
 */
void initSerial() {
  // Inicializar arrays con valores por defecto
  for (int i = 0; i < 10; i++) semaforoEstados[i] = "ROJO";
  for (int i = 0; i < 2; i++) busDistancias[i] = 0;
  for (int i = 0; i < 2; i++) {
    incendioNiveles[i] = 200;
    incendioEstados[i] = "NORMAL";
  }
  for (int i = 0; i < 6; i++) panicoBotones[i] = false;

  detectSerialPort();

  if (!serialPort.equals("")) {
    try {
      arduino = new Serial(this, serialPort, baudRate);
      serialConnected = true;
      modoSimulacion = false;
      println("✓ Conexión serial establecida en: " + serialPort);
      arduino.clear();
    } catch (Exception e) {
      println("✗ Error al conectar con Arduino: " + e.getMessage());
      serialConnected = false;
    }
  } else {
    println("✗ No se detectó ningún puerto serial compatible.");
    serialConnected = false;
  }

  // Si la conexión falló, activa el modo de simulación.
  if (!serialConnected) {
    modoSimulacion = true;
    sistemaActivo = true; // Para que la UI lo considere activo
    println("======================================================");
    println("===== MODO SIMULACIÓN ACTIVADO (Sin Arduino) =====");
    println("======================================================");
  }
}

/**
 * Detecta automáticamente el puerto serial de Arduino.
 */
void detectSerialPort() {
  String[] availablePorts = Serial.list();
  println("Puertos seriales disponibles:");
  for (int i = 0; i < availablePorts.length; i++) {
    println("  " + i + ": " + availablePorts[i]);
  }

  for (String port : availablePorts) {
    if (port.startsWith("COM") || port.contains("usbmodem") || port.contains("tty.usb")) {
      serialPort = port;
      println("✓ Puerto compatible detectado: " + port);
      return;
    }
  }

  if (serialPort.equals("") && availablePorts.length > 0) {
    serialPort = availablePorts[0];
    println("⚠ Usando puerto por defecto: " + serialPort);
  }
}

// ================================================================ //
//      PROCESAMIENTO DE DATOS (REAL Y SIMULADO - NUEVO)          //
// ================================================================ //

/**
 * Procesa los datos recibidos del puerto serial
 */
void updateSerialData() {
  if (!serialConnected || arduino == null) return;

  while (arduino.available() > 0) {
    String rawData = arduino.readStringUntil('\n');
    if (rawData != null) {
      rawData = rawData.trim();
      if (!rawData.equals("")) {
        parseArduinoData(rawData);
        ultimaRecepcion = millis();
      }
    }
  }

  sistemaActivo = (millis() - ultimaRecepcion < 5000);
}

/**
 * Parsea una línea de datos recibida del Arduino
 */
void parseArduinoData(String data) {
  println("[DEBUG] Recibiendo dato: " + data); // Mensaje de depuración
  String[] parts = data.split(":");
  if (parts.length < 2) {
    println("[DEBUG] Dato ignorado por formato insuficiente: " + data);
    return;
  }

  String tipo = parts[0];
  long timestamp = millis();

  try {
    switch (tipo) {
      case "SEMAFORO":
        if (parts.length >= 3) {
          int id = Integer.parseInt(parts[1]) - 1;
          String estado = parts[2];
          if (id >= 0 && id < 10) {
            semaforoEstados[id] = estado;
            semaforoUltimaActualizacion[id] = timestamp;
          }
        }
        println("[DEBUG] Semaforo actualizado: id=" + parts[1] + " estado=" + parts[2]);
        break;
      case "BUS":
        // BUS:TIPO:ID:DISTANCIA
        if (parts.length >= 4) {
          String busTipo = parts[1];
          int id = Integer.parseInt(parts[2]) - 1;
          int distancia = Integer.parseInt(parts[3]);
          // Solo dos paradas: id 0 (TRANSMETRO), id 1 (TRANSURBANO)
          if (id >= 0 && id < 2) {
            busDistancias[id] = distancia;
            busTipos[id] = busTipo;
            busUltimaActualizacion[id] = timestamp;
          }
        }
        println("[DEBUG] Bus actualizado: tipo=" + parts[1] + " id=" + parts[2] + " distancia=" + parts[3]);
        break;
      case "HUMO":
        // HUMO:NIVEL:ESTADO
        if (parts.length >= 3) {
          humoNivel = Integer.parseInt(parts[1]);
          humoEstado = parts[2];
          humoUltimaActualizacion = millis();
          if (humoEstado.equals("ALERTA") || humoNivel > 700) {
            agregarAlerta("🔥 ALERTA DE HUMO/MQ-02: Nivel " + humoNivel);
          }
        }
        println("[DEBUG] Humo procesado: nivel=" + parts[1] + " estado=" + parts[2]);
        break;
      case "SISMO":
        // SISMO:NIVEL:TIMESTAMP
        if (parts.length >= 3) {
          String nivel = parts[1];
          sismoActivo = !nivel.equals("BAJO"); // Solo "BAJO" no activa alerta
          sismoTimestamp = millis();
          if (sismoActivo) {
            agregarAlerta("🌎 SISMO DETECTADO (" + nivel + ")");
          }
        }
        println("[DEBUG] Sismo procesado: nivel=" + parts[1]);
        break;
      case "INCENDIO":
        // INCENDIO:ID:NIVEL:ESTADO
        if (parts.length >= 4) {
          int id = Integer.parseInt(parts[1]) - 1;
          int nivel = Integer.parseInt(parts[2]);
          String estado = parts[3];
          if (id >= 0 && id < 2) {
            incendioNiveles[id] = nivel;
            incendioEstados[id] = estado;
            incendioUltimaActualizacion[id] = timestamp;
            if (nivel > 800 || estado.equals("ALERTA")) {
              agregarAlerta("🔥 INCENDIO en Lugar Histórico " + (id + 1) + " (Nivel: " + nivel + ")");
            }
          }
        }
        println("[DEBUG] Incendio procesado: id=" + parts[1] + " nivel=" + parts[2] + " estado=" + parts[3]);
        break;
     
    }
  } catch (NumberFormatException e) {
    println("Error parsing data: " + data + " -> " + e.getMessage());
  }
}

/**
 * (NUEVO) Genera datos falsos cuando no hay conexión y los imprime.
 */
void generarDatosSimulados() {
  println("\n--- [SIMULACIÓN] Generando nuevos datos (" + nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2) + ") ---");
  long timestamp = millis();
  String[] estadosPosibles = {"ROJO", "VERDE", "AMARILLO"};

  // 1. Simular Semáforos
  for (int i = 0; i < 10; i++) {
    semaforoEstados[i] = estadosPosibles[(int)random(3)];
    semaforoUltimaActualizacion[i] = timestamp;
    println("  SEMAFORO:" + (i + 1) + ":" + semaforoEstados[i]);
    // Simula infracción si el semáforo está en rojo y hay probabilidad alta
    if (semaforoEstados[i].equals("ROJO") && random(1) < 0.5) { // 50% probabilidad
      String infraccion = "INFRACCION:Semáforo en rojo pasado #" + (i + 1) + " [" + nf(hour(),2) + ":" + nf(minute(),2) + "]";
      infraccionesRecientes.add(0, infraccion);
      agregarAlerta("⚠️ INFRACCIÓN: Semáforo en rojo pasado #" + (i + 1));
      println("  " + infraccion);
    }
  }

  // 2. Simular movimiento de buses entre paradas
  float dt = (busUltimoMovimiento == 0) ? 0 : (timestamp - busUltimoMovimiento) / 1000.0; // segundos
  busUltimoMovimiento = timestamp;

  // Transmetro (verde) - bidireccional
  if (busDirecciones[0] == 1 && busPosicionesSimuladas[0] < busDistanciaTotal) {
    // Avanzando hacia parada final
    busPosicionesSimuladas[0] += busVelocidadTransmetro * dt;
    if (busPosicionesSimuladas[0] >= busDistanciaTotal) {
      busPosicionesSimuladas[0] = busDistanciaTotal;
      busDirecciones[0] = 0; // Se detiene en la parada final
      busDetenidoTimestamp[0] = timestamp;
      println("  [SIMULACIÓN] Transmetro llegó a parada final");
    }
  } else if (busDirecciones[0] == -1 && busPosicionesSimuladas[0] > 0) {
    // Avanzando hacia parada inicial
    busPosicionesSimuladas[0] -= busVelocidadTransmetro * dt;
    if (busPosicionesSimuladas[0] <= 0) {
      busPosicionesSimuladas[0] = 0;
      busDirecciones[0] = 0; // Se detiene en la parada inicial
      busDetenidoTimestamp[0] = timestamp;
      println("  [SIMULACIÓN] Transmetro llegó a parada inicial");
    }
  } else if (busDirecciones[0] == 0 && timestamp - busDetenidoTimestamp[0] > 5000) {
    // Detenido por más de 5 segundos - cambiar dirección
    if (busPosicionesSimuladas[0] >= busDistanciaTotal - 1) {
      // Estamos en parada final - iniciar viaje hacia inicial
      busDirecciones[0] = -1;
      println("  [SIMULACIÓN] Transmetro inicia viaje hacia parada inicial");
    } else if (busPosicionesSimuladas[0] <= 1) {
      // Estamos en parada inicial - iniciar viaje hacia final
      busDirecciones[0] = 1;
      println("  [SIMULACIÓN] Transmetro inicia viaje hacia parada final");
    }
  }
  
  busDistancias[0] = int(busDistanciaTotal - busPosicionesSimuladas[0]);
  busUltimaActualizacion[0] = timestamp;
  println("  BUS:TRANSMETRO:1:" + busDistancias[0] + " [Simulación movimiento, pos=" + busPosicionesSimuladas[0] + ", dir=" + busDirecciones[0] + "]");

  // Transurbano (rojo) - bidireccional
  if (busDirecciones[1] == 1 && busPosicionesSimuladas[1] < busDistanciaTotal) {
    // Avanzando hacia parada final
    busPosicionesSimuladas[1] += busVelocidadTransurbano * dt;
    if (busPosicionesSimuladas[1] >= busDistanciaTotal) {
      busPosicionesSimuladas[1] = busDistanciaTotal;
      busDirecciones[1] = 0; // Se detiene en la parada final
      busDetenidoTimestamp[1] = timestamp;
      println("  [SIMULACIÓN] Transurbano llegó a parada final");
    }
  } else if (busDirecciones[1] == -1 && busPosicionesSimuladas[1] > 0) {
    // Avanzando hacia parada inicial
    busPosicionesSimuladas[1] -= busVelocidadTransurbano * dt;
    if (busPosicionesSimuladas[1] <= 0) {
      busPosicionesSimuladas[1] = 0;
      busDirecciones[1] = 0; // Se detiene en la parada inicial
      busDetenidoTimestamp[1] = timestamp;
      println("  [SIMULACIÓN] Transurbano llegó a parada inicial");
    }
  } else if (busDirecciones[1] == 0 && timestamp - busDetenidoTimestamp[1] > 5000) {
    // Detenido por más de 5 segundos - cambiar dirección
    if (busPosicionesSimuladas[1] >= busDistanciaTotal - 1) {
      // Estamos en parada final - iniciar viaje hacia inicial
      busDirecciones[1] = -1;
      println("  [SIMULACIÓN] Transurbano inicia viaje hacia parada inicial");
    } else if (busPosicionesSimuladas[1] <= 1) {
      // Estamos en parada inicial - iniciar viaje hacia final
      busDirecciones[1] = 1;
      println("  [SIMULACIÓN] Transurbano inicia viaje hacia parada final");
    }
  }
  
  busDistancias[1] = int(busDistanciaTotal - busPosicionesSimuladas[1]);
  busUltimaActualizacion[1] = timestamp;
  println("  BUS:TRANSURBANO:2:" + busDistancias[1] + " [Simulación movimiento, pos=" + busPosicionesSimuladas[1] + ", dir=" + busDirecciones[1] + "]");

  // --- Simulación de HUMO/MQ-02 ---
  humoNivel = int(random(100, 1000));
  humoEstado = (humoNivel > 700) ? "ALERTA" : "NORMAL";
  humoUltimaActualizacion = millis();
  println("  HUMO:" + humoNivel + ":" + humoEstado);
  if (humoEstado.equals("ALERTA")) {
    agregarAlerta("🔥 ALERTA DE HUMO/MQ-02 SIMULADA: Nivel " + humoNivel);
  }

  // --- Simulación de Sismo ---
  if (random(1) < 0.2) { // 20% probabilidad de sismo
    sismoActivo = true;
    sismoTimestamp = millis();
    agregarAlerta("🌎 SISMO SIMULADO (ALTO)");
    println("  SISMO:ALTO:" + sismoTimestamp);
  } else {
    sismoActivo = false;
  }

  // 3. Simular Incendios
  for (int i = 0; i < 2; i++) {
    incendioNiveles[i] = (int)random(150, 1000);
    if (incendioNiveles[i] > 800) {
      incendioEstados[i] = "ALERTA";
      agregarAlerta("🔥 INCENDIO SIMULADO en Lugar Histórico " + (i + 1));
      println("  INCENDIO:" + (i + 1) + ":" + incendioNiveles[i] + ":ALERTA");
    } else {
      incendioEstados[i] = "NORMAL";
      println("  INCENDIO:" + (i + 1) + ":" + incendioNiveles[i] + ":NORMAL");
    }
    incendioUltimaActualizacion[i] = timestamp;
  }

  // 4. Simular Pánico (probabilidad baja)
  if (random(1) < 0.1) { // 10% de probabilidad
    int boton = (int)random(6);
    panicoBotones[boton] = true;
    panicoTimestamps[boton] = timestamp;
    agregarAlerta("🚨 BOTÓN DE PÁNICO SIMULADO activado #" + (boton + 1));
    println("  PANICO:" + (boton + 1) + ":" + timestamp);
  }
  
  println("-------------------------------------------------");
}

// ... El resto de tus funciones (agregarAlerta, getters) no necesitan cambios ...

/**
 * Agrega una nueva alerta a la lista
 */
void agregarAlerta(String mensaje) {
  String alertaCompleta = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2) + " - " + mensaje;
  alertasRecientes.add(0, alertaCompleta); // Agregar al inicio
  if (alertasRecientes.size() > 50) {
    alertasRecientes.remove(alertasRecientes.size() - 1);
  }
  println("ALERTA: " + alertaCompleta);
}

// ================================================================ //
//                    FUNCIONES GETTER PÚBLICAS                     //
// ================================================================ //

/**
 * Obtiene el estado de un semáforo específico (1-10)
 */
String getSemaforoEstado(int id) {
  if (id >= 1 && id <= 10) {
    return semaforoEstados[id - 1];
  }
  return "ROJO"; // Estado por defecto
}

/**
 * Obtiene la distancia del bus en una parada específica (1-2)
 */
int getBusDistancia(int parada) {
  if (parada >= 1 && parada <= 2) {
    return busDistancias[parada - 1];
  }
  return 0;
}

/**
 * Obtiene el tipo de bus en una parada (TRANSMETRO/TRANSURBANO)
 */
String getBusTipo(int parada) {
  if (parada >= 1 && parada <= 2) {
    return busTipos[parada - 1];
  }
  return "TRANSMETRO";
}

/**
 * Obtiene el nivel de partículas en un lugar histórico (1-2)
 */
int getIncendioNivel(int lugar) {
  if (lugar >= 1 && lugar <= 2) {
    return incendioNiveles[lugar - 1];
  }
  return 0;
}

/**
 * Obtiene el estado de alerta de incendio (NORMAL/ALERTA)
 */
String getIncendioEstado(int lugar) {
  if (lugar >= 1 && lugar <= 2) {
    return incendioEstados[lugar - 1];
  }
  return "NORMAL";
}

/**
 * Verifica si un botón de pánico específico está activo (1-6)
 */
boolean isPanicoActivo(int boton) {
  if (boton >= 1 && boton <= 6) {
    return panicoBotones[boton - 1];
  }
  return false;
}

/**
 * Obtiene todas las alertas recientes
 */
ArrayList<String> getAlertasRecientes() {
  return alertasRecientes;
}

/**
 * Obtiene todas las infracciones recientes
 */
ArrayList<String> getInfraccionesRecientes() {
  return infraccionesRecientes;
}

/**
 * Verifica si hay un sismo activo
 */
boolean isSismoActivo() {
  return sismoActivo && (millis() - sismoTimestamp < 10000); // Activo por 10 segundos
}

/**
 * Verifica el estado de la conexión serial
 */
boolean isSerialConnected() {
  return serialConnected && sistemaActivo;
}

/**
 * Obtiene información de estado del sistema
 */
String getSystemStatus() {
  if (!serialConnected) {
    return "Arduino Desconectado (SIMULACION)";
  } else if (!sistemaActivo) {
    return "Sin datos";
  } else {
    return "Arduino Conectado";
  }
}

/**
 * Obtiene el tiempo estimado (en segundos) para que el bus llegue a la parada final.
 * Usa la distancia actual y la velocidad simulada.
 */
float getBusTiempoEstimado(int parada) {
  if (parada == 1) {
    return busDistancias[0] / busVelocidadTransmetro;
  } else if (parada == 2) {
    return busDistancias[1] / busVelocidadTransurbano;
  }
  return 0;
}

/**
 * Reinicia la simulación de los buses (para pruebas)
 */
void reiniciarSimulacionBuses() {
  busPosicionesSimuladas[0] = 0;  // Transmetro en inicial
  busPosicionesSimuladas[1] = 0;  // Transurbano en inicial
  busDirecciones[0] = 1;          // Dirección hacia final
  busDirecciones[1] = 1;          // Dirección hacia final
  busDistancias[0] = int(busDistanciaTotal);
  busDistancias[1] = int(busDistanciaTotal);
  busDetenidoTimestamp[0] = 0;
  busDetenidoTimestamp[1] = 0;
  println("Simulación de buses reiniciada manualmente");
}
 
int getBusDireccion(int parada) {
  if (parada == 1) return busDirecciones[0];
  if (parada == 2) return busDirecciones[1];
  return 1;
}

// NUEVO: Getters para el panel ambiental
int getHumoNivel() {
  return humoNivel;
}
String getHumoEstado() {
  return humoEstado;
}
long getHumoUltimaActualizacion() {
  return humoUltimaActualizacion;
}
