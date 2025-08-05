// ================================================================ //
//      ARCHIVO DE COMPONENTES REUTILIZABLES (Componentes.pde)      //
// ---------------------------------------------------------------- //
// Responsabilidades:                                               //
// - Contener funciones de dibujo de bajo nivel (helpers).          //
// - Fomentar la reutilización de código para elementos comunes.    //
// ================================================================ //

void drawNavigation() {
  fill(panelBg);
  noStroke();
  rect(0, 0, width, 60);
  textFont(titleFont);
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  text("Monitor Urbano Local", 20, 30);
  String[] labels = {"Tráfico", "Transporte", "Ambiental", "Alertas"};
  for (int i = 0; i < labels.length; i++) {
    float x = width - 500 + (i * 120);
    if (currentScreen == i + 1) {
      fill(accentBlue);
      rect(x - 10, 15, 110, 30, 15);
      fill(textPrimary);
    } else {
      fill(textSecondary);
    }
    textAlign(CENTER, CENTER);
    textFont(mainFont);
    text(labels[i], x + 45, 30);
  }
}

void drawTitledPanel(String title, float x, float y, float w, float h) {
  fill(panelBg);
  noStroke();
  rect(x, y, w, h, 15);
  fill(textPrimary);
  textAlign(LEFT, TOP);
  textFont(titleFont);
  text(title, x + 20, y + 20);
}

void drawSemaphore(float x, float y, boolean redOn, boolean yellowOn, boolean greenOn) {
  fill(80);
  rect(x + 20, y, 20, 150, 5);
  fill(50);
  rect(x, y - 40, 60, 130, 10);
  fill(redOn ? color(255, 0, 0) : color(80, 0, 0));
  ellipse(x + 30, y - 15, 30, 30);
  fill(yellowOn ? color(255, 220, 0) : color(80, 60, 0));
  ellipse(x + 30, y + 25, 30, 30);
  fill(greenOn ? color(0, 255, 0) : color(0, 80, 0));
  ellipse(x + 30, y + 65, 30, 30);
}

void drawBusStop(float x, float y, String label) {
  fill(accentBlue);
  ellipse(x, y, 20, 20);
  fill(textPrimary);
  ellipse(x, y, 8, 8);
  textAlign(CENTER, TOP);
  text(label, x, y + 15);
}

void drawCircularMeter(String label, float value, float x, float y, float radius) {
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  fill(textPrimary);
  text(label, x, y - radius - 30);
  float angle = map(value, 0, 1, 0, TWO_PI);
  color arcColor = lerpColor(okGreen, alertRed, value);
  noFill();
  strokeWeight(20);
  stroke(panelBg);
  arc(x, y, radius * 2, radius * 2, 0, TWO_PI);
  stroke(arcColor);
  arc(x, y, radius * 2, radius * 2, -HALF_PI, -HALF_PI + angle);
  noStroke();
  textFont(titleFont);
  fill(textPrimary);
  text(nf(value * 100, 0, 0) + "%", x, y);
}
