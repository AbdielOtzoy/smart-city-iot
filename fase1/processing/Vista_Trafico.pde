// ================================================================ //
//              VISTA 1: TRÁFICO (Vista_Trafico.pde)                //
// ================================================================ //

void drawTrafficView() {
  drawTitledPanel("Panel de Tráfico y Semáforos", 50, 100, width - 100, height - 150);

  // Dibuja 3 semáforos
  drawSemaphore(150, 250, true, false, false);
  drawSemaphore(350, 250, false, false, true);
  drawSemaphore(550, 250, false, true, false);

  // Indicador de infracción
  stroke(alertRed);
  strokeWeight(4);
  noFill();
  rect(140, 210, 80, 180, 15);
  noStroke();

  fill(alertRed);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  text("!", 180, 200);
  textFont(mainFont);
  text("INFRACCIÓN", 180, 410);
}
