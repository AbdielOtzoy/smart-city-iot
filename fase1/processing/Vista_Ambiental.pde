// ================================================================ //
//            VISTA 3: AMBIENTAL (Vista_Ambiental.pde)              //
// ================================================================ //

void drawEnvironmentalView() {
  drawTitledPanel("Monitoreo Ambiental", 50, 100, width - 100, height - 150);

  // Medidor de humo
  drawCircularMeter("Nivel de Humo", 0.65, 300, 350, 150);

  // Alerta sísmica
  fill(alertRed);
  rect(width/2 + 100, 200, 400, 300, 15);
  fill(textPrimary);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  text("¡ALERTA SÍSMICA!", width/2 + 300, 240);

  // Ícono de sismo
  noFill();
  stroke(textPrimary);
  strokeWeight(8);
  beginShape();
  vertex(width/2 + 180, 370); vertex(width/2 + 230, 330); vertex(width/2 + 280, 370);
  vertex(width/2 + 330, 330); vertex(width/2 + 380, 370); vertex(width/2 + 430, 330);
  endShape();
  noStroke();
}
