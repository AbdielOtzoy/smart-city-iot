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
}

void draw() {
  background(bgDark);
  drawNavigation(); // Definida en Componentes.pde
  drawMainContent();  // Llama al enrutador de vistas
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
      drawEnvironmentalView(); // En Vista_Ambiental.pde
      break;
    case 4:
      drawAlertsView(); // En Vista_Alertas.pde
      break;
  }
}

void keyPressed() {
  if (key >= '1' && key <= '4') {
    currentScreen = key - '0';
  }
}
