// ================================================================ //
//      ARCHIVO PRINCIPAL: MONITOR URBANO (MonitorUrbano.pde)       //
// ---------------------------------------------------------------- //
// Responsabilidades:                                               //
// - Variables globales (estado, colores, fuentes)                  //
// - Función setup() para inicialización                            //
// - Función draw() para el ciclo principal de renderizado          //
// - Lógica de navegación (keyPressed)                              //
// - Enrutador de vistas (drawMainContent)                          //
// ================================================================ //

// --- CONFIGURACIÓN GLOBAL Y ESTADO DE LA APLICACIÓN ---
int currentScreen = 1; // 1: Tráfico, 2: Transporte, 3: Ambiental, 4: Alertas

// --- PALETA DE COLORES (DARK MODE) ---
color bgDark       = color(24, 26, 31);
color panelBg      = color(35, 38, 46);
color textPrimary  = color(230, 235, 245);
color textSecondary= color(150, 160, 175);
color accentBlue   = color(66, 135, 245);
color alertRed     = color(255, 80, 80);
color warnYellow   = color(255, 193, 7);
color okGreen      = color(40, 167, 69);

// --- TIPOGRAFÍA ---
PFont mainFont;
PFont titleFont;

void setup() {
  size(1280, 720);
  smooth(8);
  mainFont = createFont("Arial", 16, true);
  titleFont = createFont("Arial Bold", 20, true);
  
  // Inicializar conexión serial con Arduino
  initSerial();
  
  // Mostrar estado de conexión en consola
  println("=== MONITOR URBANO INICIADO ===");
  println("Estado de conexión: " + getSystemStatus());
  println("Navegación: Usa las teclas 1-4 para cambiar de vista");
  println("================================");
}

void draw() {
  background(bgDark);
  
  // Dibujar interfaz
  drawNavigation(); // Definida en Componentes.pde
  drawConnectionStatus(); // Mostrar estado de conexión
  drawMainContent();  // Llama al enrutador de vistas
  
  if (serialConnected) {
    updateSerialData(); // Si hay conexión, procesa los datos reales.
  } else if (modoSimulacion) {
    // Si no hay conexión, activa la simulación.
    if (millis() - ultimoTiempoSimulacion > INTERVALO_SIMULACION) {
      generarDatosSimulados();
      ultimoTiempoSimulacion = millis();
    }
  }
}

/**
 * Dibuja el indicador de estado de conexión en la esquina superior derecha
 */
void drawConnectionStatus() {
  // Posición en esquina superior derecha
  float x = width - 800;
  float y = 10;
   
  // Indicador visual y texto de estado
  String status = getSystemStatus();
  color statusColor;
  
  switch(status) {
    case "Conectado":
      statusColor = okGreen;
      break;
    case "Sin datos":
      statusColor = warnYellow;
      break;
    default:
      statusColor = alertRed;
  }
  
  // Círculo indicador
  fill(statusColor);
  noStroke();
  circle(x + 65, y + 17, 8);
  
  // Texto de estado
  fill(statusColor);
  text(status, x + 75, y + 25);
  
  // Mostrar número de alertas activas      
  int alertasCount = getAlertasRecientes().size();
  if (alertasCount > 0) {
    fill(alertRed);
    text("(" + alertasCount + " alertas)", x + 75, y + 40);
  }
}

/**
 * Llama a la función de dibujo correspondiente a la pantalla activa.
 * Cada función de vista está en su propio archivo .pde
 */
void drawMainContent() {
  switch (currentScreen) {
    case 1:
      drawTrafficView(); // En Vista_Trafico.pde
      break;
    case 2:
      drawBusView(); // En Vista_Transporte.pde
      break;
    case 3:
      drawAmbientalView(); // En Vista_Ambiental.pde
      break;
    case 4:
      drawAlertsView(); // En Vista_Alertas.pde
      break;
  }
}

void keyPressed() {
  if (key == 'i') {
      viajeActivo = true;
      regresoActivo = false;
      inicioViajeMillis = millis();
      transmetroX = 300;
      transurbanoX = 300;
      println("Viaje iniciado");
  }
  if (key == 'o') {
      regresoActivo = true;
      viajeActivo = false;
      inicioViajeMillis = millis();
      println("Regreso iniciado");
  }
  if (key >= '1' && key <= '4') {
    currentScreen = key - '0';
  }
  
  // Funciones de debug/testing
  if (key == 'r' || key == 'R') {
    // Reiniciar conexión serial
    println("Reiniciando conexión serial...");
    if (arduino != null) {
      arduino.stop();
    }
    initSerial();
  }
  
  if (key == 'd' || key == 'D') {
    // Mostrar datos de debug en consola
    println("\n=== DEBUG INFO ===");
    println("Sistema activo: " + isSerialConnected());
    println("Semáforos estado:");
    for (int i = 1; i <= 10; i++) {
      println("  Semáforo " + i + ": " + getSemaforoEstado(i));
    }
    println("Buses distancia:");
    for (int i = 1; i <= 4; i++) {
      println("  Parada " + i + " (" + getBusTipo(i) + "): " + getBusDistancia(i) + "cm");
    }
    println("Incendios:");
    for (int i = 1; i <= 2; i++) {
      println("  Lugar " + i + ": " + getIncendioNivel(i) + " - " + getIncendioEstado(i));
    }
    println("Alertas recientes: " + getAlertasRecientes().size());
    println("==================\n");
  }
}

/**
 * Se ejecuta cuando se cierra la aplicación
 */
void exit() {
  // Cerrar conexión serial limpiamente
  if (arduino != null) {
    arduino.stop();
    println("Conexión serial cerrada.");
  }
  super.exit();
}
