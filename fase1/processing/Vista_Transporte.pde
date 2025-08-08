// ================================================================ //
//           VISTA 2: TRANSPORTE (Vista_Transporte.pde)             //
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

  // --- Movimiento de buses usando distancia simulada y dirección ---
  // Transmetro (verde)
  float transmetroY = 190;
  float transmetroDist = getBusDistancia(1);
  int transmetroDir = getBusDireccion(1);
  float transmetroX;
  String transmetroDestino;
  boolean transmetroEnDestino = false;

  if (transmetroDir == 1) {
    transmetroDestino = "Parada Final";
    transmetroX = map(transmetroDist, 100, 0, 300, 900);
    transmetroEnDestino = transmetroDist <= 10;
  } else if (transmetroDir == -1) {
    transmetroDestino = "Parada Inicial";
    transmetroX = map(100 - transmetroDist, 0, 100, 900, 300);
    transmetroEnDestino = transmetroDist >= 90;
  } else {
    if (transmetroDist <= 10) {
      transmetroX = 900;
      transmetroDestino = "Parada Inicial";
      transmetroEnDestino = true;
    } else if (transmetroDist >= 90) {
      transmetroX = 300;
      transmetroDestino = "Parada Final";
      transmetroEnDestino = true;
    } else {
      transmetroX = map(transmetroDist, 100, 0, 300, 900);
      transmetroDestino = "Desconocido";
    }
  }

  // --- Sombra y brillo animado en bus ---
  float glow = 0;
  if (transmetroEnDestino) glow = 30 + 20*sin(millis()/400.0);
  fill(0, 80, 0, 60);
  ellipse(transmetroX+25, transmetroY+30, 60+glow, 18+glow/2);

  // --- Bus con borde y gradiente ---
  for (int i = 0; i < 10; i++) {
    fill(lerpColor(okGreen, color(255), i/10.0));
    rect(transmetroX-2+i*0.4, transmetroY-2+i*0.2, 50-i*0.8, 20-i*0.4, 8);
  }
  stroke(0,80,0,80);
  strokeWeight(2);
  rect(transmetroX, transmetroY, 50, 20, 8);
  noStroke();
  fill(255);
  rect(transmetroX + 5, transmetroY + 3, 12, 14, 2);
  rect(transmetroX + 20, transmetroY + 3, 12, 14, 2);
  rect(transmetroX + 35, transmetroY + 3, 12, 14, 2);

  // --- Texto con sombra y color destino ---
  fill(transmetroEnDestino ? accentBlue : textPrimary);
  textAlign(LEFT, CENTER);
  textFont(mainFont);
  text("Transmetro", transmetroX, transmetroY - 20);
  fill(textSecondary);
  // Elimina las letras que se superponen con el bus y la ruta:
   text("Próxima parada: " + transmetroDestino, transmetroX, transmetroY - 5);
   text("Distancia: " + getBusDistancia(1) + " cm", transmetroX, transmetroY + 25);
   text("Tiempo estimado: " + nf(getBusTiempoEstimado(1), 0, 1) + " s", transmetroX, transmetroY + 40);

  // --- Transurbano (rojo) ---
  float transurbanoY = 290;
  float transurbanoDist = getBusDistancia(2);
  int transurbanoDir = getBusDireccion(2);
  float transurbanoX;
  String transurbanoDestino;
  boolean transurbanoEnDestino = false;

  if (transurbanoDir == 1) {
    transurbanoDestino = "Parada Final";
    transurbanoX = map(transurbanoDist, 100, 0, 300, 900);
    transurbanoEnDestino = transurbanoDist <= 10;
  } else if (transurbanoDir == -1) {
    transurbanoDestino = "Parada Inicial";
    transurbanoX = map(100 - transurbanoDist, 0, 100, 900, 300);
    transurbanoEnDestino = transurbanoDist >= 90;
  } else {
    if (transurbanoDist <= 10) {
      transurbanoX = 900;
      transurbanoDestino = "Parada Inicial";
      transurbanoEnDestino = true;
    } else if (transurbanoDist >= 90) {
      transurbanoX = 300;
      transurbanoDestino = "Parada Final";
      transurbanoEnDestino = true;
    } else {
      transurbanoX = map(transurbanoDist, 100, 0, 300, 900);
      transurbanoDestino = "Desconocido";
    }
  }

  // --- Sombra y brillo animado en bus ---
  glow = 0;
  if (transurbanoEnDestino) glow = 30 + 20*sin(millis()/400.0);
  fill(80, 0, 0, 60);
  ellipse(transurbanoX+25, transurbanoY+30, 60+glow, 18+glow/2);

  // --- Bus con borde y gradiente ---
  for (int i = 0; i < 10; i++) {
    fill(lerpColor(alertRed, color(255), i/10.0));
    rect(transurbanoX-2+i*0.4, transurbanoY-2+i*0.2, 50-i*0.8, 20-i*0.4, 8);
  }
  stroke(120,0,0,80);
  strokeWeight(2);
  rect(transurbanoX, transurbanoY, 50, 20, 8);
  noStroke();
  fill(255);
  rect(transurbanoX + 5, transurbanoY + 3, 12, 14, 2);
  rect(transurbanoX + 20, transurbanoY + 3, 12, 14, 2);
  rect(transurbanoX + 35, transurbanoY + 3, 12, 14, 2);

  // --- Texto con sombra y color destino ---
  fill(transurbanoEnDestino ? accentBlue : textPrimary);
  textAlign(LEFT, CENTER);
  textFont(mainFont);
  text("Transurbano", transurbanoX, transurbanoY - 20);
  fill(textSecondary);
  // Elimina las letras que se superponen con el bus y la ruta:
  text("Próxima parada: " + transurbanoDestino, transurbanoX, transurbanoY - 5);
   text("Distancia: " + getBusDistancia(2) + " cm", transurbanoX, transurbanoY + 25);
   text("Tiempo estimado: " + nf(getBusTiempoEstimado(2), 0, 1) + " s", transurbanoX, transurbanoY + 40);

  // --- Leyenda con iconos ---
  float legendX = 300;
  float legendY = height - 120;
  fill(panelBg);
  rect(legendX - 10, legendY - 25, 320, 70, 10);
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  textFont(titleFont);
  text("Leyenda", legendX, legendY - 5);

  // Línea Transmetro (verde gradiente)
  for (int i = 0; i < 10; i++) {
    stroke(lerpColor(okGreen, color(200,255,200), i/10.0));
    strokeWeight(6);
    line(legendX, legendY + 15 + i*0.5, legendX + 30, legendY + 15 + i*0.5);
  }
  noStroke();
  fill(textSecondary);
  textFont(mainFont);
  text("Transmetro", legendX + 40, legendY + 15);

  // Línea Transurbano (roja gradiente)
  for (int i = 0; i < 10; i++) {
    stroke(lerpColor(alertRed, color(255,200,200), i/10.0));
    strokeWeight(6);
    line(legendX + 120, legendY + 15 + i*0.5, legendX + 150, legendY + 15 + i*0.5);
  }
  noStroke();
  fill(textSecondary);
  text("Transurbano", legendX + 160, legendY + 15);

  // Paradas con icono
  fill(okGreen);
  ellipse(legendX + 15, legendY + 35, 12, 12);
  fill(textPrimary);
  ellipse(legendX + 15, legendY + 35, 6, 6);
  text("Paradas", legendX + 40, legendY + 35);
  text("🏁 = Inicio/Final", legendX + 160, legendY + 35);
  text("🚏 = Parada", legendX + 260, legendY + 35);
}
