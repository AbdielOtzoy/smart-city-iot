// ================================================================ //
//           VISTA 2: TRANSPORTE (Vista_Transporte.pde)             //
// ================================================================ //

// --- Variables globales para el viaje ---
boolean viajeActivo = false;
boolean regresoActivo = false;

float transmetroX = 300;
float transurbanoX = 300;
int inicioViajeMillis;

// ================================================================ //
void drawBusView() {
  drawTitledPanel("Mapa de Ruta de Transporte Público", 50, 100, width - 100, height - 150);

  // --- Gradiente para rutas ---
  for (int i = 0; i < 60; i++) {
    stroke(lerpColor(okGreen, color(200,255,200), i/60.0));
    strokeWeight(6);
    line(300, 200+i*0.5, 900, 200+i*0.5);
    stroke(lerpColor(alertRed, color(255,200,200), i/60.0));
    strokeWeight(6);
    line(300, 300+i*0.5, 900, 300+i*0.5);
  }
  noStroke();

  // --- Paradas con iconos y destino resaltado ---
  drawBusStop(300, 200, "🏁 Parada Inicial");
  drawBusStop(900, 200, "🏁 Parada Final");
  drawBusStop(900, 300, "🚏 Parada Final");
  drawBusStop(300, 300, "🚏 Parada Inicial");

  // --- Movimiento automático ---
  if (viajeActivo) {
    int elapsed = millis() - inicioViajeMillis;

    // Transmetro → 10 segundos
    float t1 = constrain(map(elapsed, 0, 10000, 300, 900), 300, 900);
    transmetroX = t1;

    // Transurbano → 20 segundos
    float t2 = constrain(map(elapsed, 0, 20000, 300, 900), 300, 900);
    transurbanoX = t2;
  }

  // --- Movimiento de regreso ---
  if (regresoActivo) {
    int elapsed = millis() - inicioViajeMillis;

    // Transmetro → 10 segundos (de 900 → 300)
    float t1 = constrain(map(elapsed, 0, 10000, 900, 300), 300, 900);
    transmetroX = t1;

    // Transurbano → 20 segundos (de 900 → 300)
    float t2 = constrain(map(elapsed, 0, 20000, 900, 300), 300, 900);
    transurbanoX = t2;
  }

  // --- Dibujar Transmetro (verde) ---
  float transmetroY = 190;
  drawBus(transmetroX, transmetroY, alerRed, "Transurbano");

  // --- Dibujar Transurbano (rojo) ---
  float transurbanoY = 290;
  drawBus(transurbanoX, transurbanoY, okGreen, "Transmetro");

  // --- Leyenda ---
  drawLegend();
}

// ================================================================ //
//   Dibujo de buses (compartido por ambos transportes)
// ================================================================ //
void drawBus(float x, float y, color baseColor, String label) {
  // sombra
  fill(red(baseColor), green(baseColor), blue(baseColor), 60);
  ellipse(x+25, y+30, 60, 18);

  // bus gradiente
  for (int i = 0; i < 10; i++) {
    fill(lerpColor(baseColor, color(255), i/10.0));
    rect(x-2+i*0.4, y-2+i*0.2, 50-i*0.8, 20-i*0.4, 8);
  }
  stroke(baseColor, 80);
  strokeWeight(2);
  rect(x, y, 50, 20, 8);
  noStroke();
  fill(255);
  rect(x + 5, y + 3, 12, 14, 2);
  rect(x + 20, y + 3, 12, 14, 2);
  rect(x + 35, y + 3, 12, 14, 2);

  // etiqueta
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  textFont(mainFont);
  text(label, x, y - 20);
}

// ================================================================ //
//   Leyenda
// ================================================================ //
void drawLegend() {
  float legendX = 300;
  float legendY = height - 120;
  fill(panelBg);
  rect(legendX - 10, legendY - 25, 320, 70, 10);
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  textFont(titleFont);
  text("Leyenda", legendX, legendY - 5);

  // Línea Transmetro
  for (int i = 0; i < 10; i++) {
    stroke(lerpColor(okGreen, color(200,255,200), i/10.0));
    strokeWeight(6);
    line(legendX, legendY + 15 + i*0.5, legendX + 30, legendY + 15 + i*0.5);
  }
  noStroke();
  fill(textSecondary);
  text("Transmetro", legendX + 40, legendY + 15);

  // Línea Transurbano
  for (int i = 0; i < 10; i++) {
    stroke(lerpColor(alertRed, color(255,200,200), i/10.0));
    strokeWeight(6);
    line(legendX + 120, legendY + 15 + i*0.5, legendX + 150, legendY + 15 + i*0.5);
  }
  noStroke();
  fill(textSecondary);
  text("Transurbano", legendX + 160, legendY + 15);

  // Paradas
  fill(okGreen);
  ellipse(legendX + 15, legendY + 35, 12, 12);
  fill(textPrimary);
  ellipse(legendX + 15, legendY + 35, 6, 6);
  text("Paradas", legendX + 40, legendY + 35);
  text("🏁 = Inicio/Final", legendX + 160, legendY + 35);
  text("🚏 = Parada", legendX + 260, legendY + 35);
}
