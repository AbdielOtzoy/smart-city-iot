// ================================================================ //
//            VISTA 3: AMBIENTAL (Vista_Ambiental.pde)              //
// ================================================================ //

void drawAmbientalView() {
  drawTitledPanel("Monitoreo Ambiental", 50, 100, width - 100, height - 150);

  // --- Valores MQ ---
  println(mq1L);
  println(mq2L);
  println(mq3L);

  int maxLevel = 300;

  // Panel fondo
  fill(panelBg);
  rect(80, 160, width - 160, 500, 30);

  fill(textPrimary);
  textFont(titleFont);
  textAlign(LEFT, TOP);
  text("Monitoreo Ambiental", 100, 180);

  // --- Indicadores de cada sensor (más pequeños y centrados) ---
  drawIndicadorCircular("MQ-01", mq1L, maxLevel, 330, 350, 160);
  drawIndicadorCircular("MQ-02", mq2L, maxLevel, width/2, 350, 160);
  drawIndicadorCircular("MQ-03", mq3L, maxLevel, width - 330, 350, 160);

  // --- Banner de sismo (reubicado abajo, centrado) ---
  fill(isSismoActivo() ? accentRed : accentGreen);
  rect(width/2 - 300, 500, 600, 140, 25);

  fill(255);
  textFont(titleFont);
  textAlign(CENTER, TOP);
  if (isSismoActivo()) {
    text("¡ALERTA SÍSMICA!", width/2, 520);
    stroke(255);
    strokeWeight(6);
    noFill();
    beginShape();
    vertex(width/2 - 200, 580); 
    vertex(width/2 - 150, 540); 
    vertex(width/2 - 100, 580); 
    vertex(width/2 - 50, 540); 
    vertex(width/2, 580); 
    vertex(width/2 + 50, 540);
    endShape();
    noStroke();
  } else {
    text("Estado Sísmico: NORMAL", width/2, 520);
    stroke(255);
    strokeWeight(6);
    noFill();
    beginShape();
    vertex(width/2 - 100, 580); 
    vertex(width/2, 580); 
    vertex(width/2 + 50, 540);
    endShape();
    noStroke();
  }
}

// ================================================================ //
//   FUNCIÓN AUXILIAR PARA DIBUJAR INDICADOR CIRCULAR               //
// ================================================================ //
void drawIndicadorCircular(String label, float valor, int maxLevel, float x, float y, float size) {
  float porcentaje = constrain((valor / maxLevel) * 100, 0, 100);

  // arco de progreso
  strokeWeight(14);
  noFill();
  stroke(accentGreen);
  arc(x, y, size, size, PI + QUARTER_PI, PI + QUARTER_PI + TWO_PI * porcentaje / 100);

  // texto porcentaje
  noStroke();
  fill(textPrimary);
  textFont(titleFont);
  textAlign(CENTER, CENTER);
  text(nf(porcentaje, 0, 1) + "%", x, y);

  // etiqueta debajo
  textFont(mainFont);
  text(label, x, y + size/2 + 20);
}
