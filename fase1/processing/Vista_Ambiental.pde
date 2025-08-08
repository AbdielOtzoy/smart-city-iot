// ================================================================ //
//            VISTA 3: AMBIENTAL (Vista_Ambiental.pde)              //
// ================================================================ //

void drawAmbientalView() {
  drawTitledPanel("Monitoreo Ambiental", 50, 100, width - 100, height - 150);

  // --- Panel de humo MQ-02 ---
  int humo = getHumoNivel();
  String estadoHumo = getHumoEstado();
  float porcentaje = constrain(humo / 10.0, 0, 100);

  fill(panelBg);
  rect(80, 160, 400, 400, 30);

  fill(textPrimary);
  textFont(titleFont);
  textAlign(LEFT, TOP);
  text("Monitoreo Ambiental", 100, 180);

  // Elimina texto encima del gráfico circular
  // textFont(mainFont);
  // textAlign(CENTER, CENTER);
  // text("Nivel de Humo", 280, 230);

  // Gráfico circular
  strokeWeight(18);
  stroke(estadoHumo.equals("ALERTA") ? accentOrange : accentGreen);
  noFill();
  arc(280, 370, 260, 260, PI + QUARTER_PI, PI + QUARTER_PI + TWO_PI * porcentaje / 100);

  noStroke();
  fill(textPrimary);
  textFont(titleFont);
  textAlign(CENTER, CENTER);
  text(nf(porcentaje, 0, 1) + "%", 280, 370);

  // Estado
  textFont(mainFont);
  fill(estadoHumo.equals("ALERTA") ? accentOrange : accentGreen);
  textAlign(CENTER, CENTER);
  text(estadoHumo, 280, 410);

  // --- Banner de sismo ---
  fill(isSismoActivo() ? accentRed : accentGreen);
  rect(540, 220, 400, 260, 25);

  fill(255);
  textFont(titleFont);
  textAlign(CENTER, TOP);
  if (isSismoActivo()) {
    text("¡ALERTA SÍSMICA!", 740, 240);
    stroke(255);
    strokeWeight(7);
    noFill();
    beginShape();
    vertex(600, 370); vertex(650, 320); vertex(700, 370); vertex(750, 320); vertex(800, 370); vertex(870, 320);
    endShape();
    noStroke();
  } else {
    text("Estado Sísmico: NORMAL", 740, 240);
    stroke(255);
    strokeWeight(7);
    noFill();
    beginShape();
    vertex(650, 370); vertex(720, 370); vertex(770, 320);
    endShape();
    noStroke();
  }
}
