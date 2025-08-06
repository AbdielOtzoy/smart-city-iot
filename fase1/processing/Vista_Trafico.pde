// ================================================================ //
//           VISTA 1: TRÁFICO (Vista_Trafico.pde)                 //
// ================================================================ //

/**
 * Dibuja el panel de tráfico, mostrando el estado de todos los semáforos
 * en una cuadrícula que se adapta al tamaño de la ventana.
 */
void drawTrafficView() {
  drawTitledPanel("Panel de Tráfico y Semáforos", 50, 100, width - 100, height - 150);

  // --- CONFIGURACIÓN DE LA CUADRÍCULA DINÁMICA ---
  int totalSemaforos = 10; // El sistema gestiona 10 semáforos
  
  // Dimensiones para cada elemento en la cuadrícula
  int itemWidth = 160;   // Ancho reservado para cada semáforo (incluye espaciado)
  int itemHeight = 210;  // Alto reservado para cada semáforo (incluye espaciado)
  
  // Márgenes internos del panel
  int panelMarginX = 120;
  int panelMarginY = 200;

  // Calcula cuántos semáforos caben en una fila, asegurando al menos 1
  int semaphoresPerRow = max(1, (width - panelMarginX * 2) / itemWidth);

  // --- DIBUJO DINÁMICO DE SEMÁFOROS EN CUADRÍCULA ---
  for (int i = 0; i < totalSemaforos; i++) {
    // 1. Calcular posición en la cuadrícula
    int col = i % semaphoresPerRow;
    int row = i / semaphoresPerRow; // La división de enteros se encarga de esto
    
    int currentX = panelMarginX + col * itemWidth;
    int currentY = panelMarginY + row * itemHeight;
    
    int semaforoId = i + 1;

    // 2. Obtener estado y definir colores (lógica sin cambios)
    String estado = getSemaforoEstado(semaforoId);
    boolean rojo = estado.equals("ROJO");
    boolean amarillo = estado.equals("AMARILLO");
    boolean verde = estado.equals("VERDE");

    // 3. Dibujar el semáforo y su etiqueta
    drawSemaphore(currentX, currentY, rojo, amarillo, verde);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textFont(mainFont);
    text("ID: " + semaforoId, currentX, currentY + 145);
    
    // 4. (MEJORADO) Dibujar alerta si hay infracción para este semáforo
    if (hayInfraccionReciente(semaforoId)) {
        drawAlertaInfraccion(currentX, currentY);
    }
  }
}

/**
 * Dibuja el recuadro de alerta de infracción en una posición específica.
 * @param x Coordenada X del centro del semáforo.
 * @param y Coordenada Y del centro del semáforo.
 */
void drawAlertaInfraccion(int x, int y) {
  stroke(alertRed);
  strokeWeight(4);
  noFill();
  // Dibuja el rectángulo relativo a la posición del semáforo
  rect(x - 40, y - 40, 80, 180, 15);
  noStroke();

  fill(alertRed);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  text("!", x, y - 55); // Posiciona el "!" arriba
}

/**
 * Verifica si existe una infracción reciente para un ID de semáforo específico.
 * @param semaforoId El ID del semáforo a verificar.
 * @return true si hay una infracción, false en caso contrario.
 */
boolean hayInfraccionReciente(int semaforoId) {
  String searchString = "Semáforo #" + semaforoId;
  for (String infraccion : getInfraccionesRecientes()) {
    if (infraccion.contains(searchString)) {
      return true;
    }
  }
  return false;
}
