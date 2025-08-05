// ================================================================ //
//           VISTA 2: TRANSPORTE (Vista_Transporte.pde)             //
// ================================================================ //

void drawBusView() {
  drawTitledPanel("Mapa de Ruta de Transporte Público", 50, 100, width - 100, height - 150);

  // RUTA 1 - TRANSMETRO (Línea horizontal superior)
  strokeWeight(6);
  noFill();
  stroke(accentBlue);
  line(150, 160, 1100, 160);
  noStroke();

  // RUTA 2 - TRANSURBANO 1 (Línea horizontal media-superior)  
  strokeWeight(4);
  noFill();
  stroke(okGreen);
  line(150, 250, 1100, 250);
  noStroke();

  // RUTA 3 - TRANSURBANO 2 (Línea horizontal media-inferior)
  strokeWeight(4);
  noFill();
  stroke(okGreen);
  line(150, 340, 1100, 340);
  noStroke();

  // RUTA 4 - TRANSMETRO 2 (Línea horizontal inferior)
  strokeWeight(6);
  noFill();
  stroke(accentBlue);
  line(150, 430, 1100, 430);
  noStroke();

  // Paradas para TRANSMETRO 1 (Ruta superior)
  drawBusStop(300, 160, "Metro A1");
  drawBusStop(500, 160, "Metro A2");
  drawBusStop(700, 160, "Metro A3");
  drawBusStop(900, 160, "Metro A4");

  // Paradas para TRANSURBANO 1 (Ruta media-superior)
  drawBusStop(250, 250, "Urbano C1");
  drawBusStop(450, 250, "Urbano C2");
  drawBusStop(650, 250, "Urbano C3");
  drawBusStop(850, 250, "Urbano C4");

  // Paradas para TRANSURBANO 2 (Ruta media-inferior)
  drawBusStop(400, 340, "Urbano D1");
  drawBusStop(600, 340, "Urbano D2");
  drawBusStop(800, 340, "Urbano D3");
  drawBusStop(1000, 340, "Urbano D4");

  // Paradas para TRANSMETRO 2 (Ruta inferior)
  drawBusStop(350, 430, "Metro B1");
  drawBusStop(550, 430, "Metro B2");
  drawBusStop(750, 430, "Metro B3");
  drawBusStop(950, 430, "Metro B4");

  // TRANSMETRO 1 (Bus azul en ruta superior)
  float transmetro1X = 620, transmetro1Y = 150;
  fill(accentBlue);
  rect(transmetro1X, transmetro1Y, 50, 20, 8);
  fill(255);
  rect(transmetro1X + 5, transmetro1Y + 3, 12, 14, 2);
  rect(transmetro1X + 20, transmetro1Y + 3, 12, 14, 2);
  rect(transmetro1X + 35, transmetro1Y + 3, 12, 14, 2);
  
  // Información TRANSMETRO 1 - Posicionada arriba para evitar solapamiento
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  textFont(mainFont);
  text("Transmetro 105 - Línea Norte", transmetro1X, transmetro1Y - 30);
  fill(textSecondary);
  text("Próxima parada: Metro A3 - 150m", transmetro1X, transmetro1Y - 15);

  // TRANSURBANO 1 (Bus verde en ruta media-superior)
  float transurbano1X = 320, transurbano1Y = 240;
  fill(okGreen);
  rect(transurbano1X, transurbano1Y, 40, 20, 5);
  fill(255);
  rect(transurbano1X + 5, transurbano1Y + 3, 10, 14, 2);
  rect(transurbano1X + 18, transurbano1Y + 3, 10, 14, 2);
  rect(transurbano1X + 28, transurbano1Y + 3, 10, 14, 2);
  
  // Información TRANSURBANO 1 - Posicionada arriba
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  text("Transurbano 32", transurbano1X, transurbano1Y - 30);
  fill(textSecondary);
  text("Próxima: Urbano C2 - 200m", transurbano1X, transurbano1Y - 15);

  // TRANSURBANO 2 (Bus verde en ruta media-inferior)
  float transurbano2X = 750, transurbano2Y = 330;
  fill(okGreen);
  rect(transurbano2X, transurbano2Y, 40, 20, 5);
  fill(255);
  rect(transurbano2X + 5, transurbano2Y + 3, 10, 14, 2);
  rect(transurbano2X + 18, transurbano2Y + 3, 10, 14, 2);
  rect(transurbano2X + 28, transurbano2Y + 3, 10, 14, 2);
  
  // Información TRANSURBANO 2 - Posicionada arriba para evitar conflicto con Transmetro 2
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  text("Transurbano 45", transurbano2X, transurbano2Y - 30);
  fill(textSecondary);
  text("Próxima: Urbano D3 - 320m", transurbano2X, transurbano2Y - 15);

  // TRANSMETRO 2 (Bus azul en ruta inferior)
  float transmetro2X = 470, transmetro2Y = 420;
  fill(accentBlue);
  rect(transmetro2X, transmetro2Y, 50, 20, 8);
  fill(255);
  rect(transmetro2X + 5, transmetro2Y + 3, 12, 14, 2);
  rect(transmetro2X + 20, transmetro2Y + 3, 12, 14, 2);
  rect(transmetro2X + 35, transmetro2Y + 3, 12, 14, 2);
  
  // Información TRANSMETRO 2 - Posicionada abajo
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  text("Transmetro 208 - Línea Sur", transmetro2X, transmetro2Y + 35);
  fill(textSecondary);
  text("Próxima parada: Metro B2 - 280m", transmetro2X, transmetro2Y + 50);

  // Leyenda
  float legendX = 150;
  float legendY = height - 120;
  
  fill(panelBg);
  rect(legendX - 10, legendY - 25, 400, 80, 10);
  
  fill(textPrimary);
  textAlign(LEFT, CENTER);
  textFont(titleFont);
  text("Leyenda", legendX, legendY - 5);
  
  // Línea Transmetro
  stroke(accentBlue);
  strokeWeight(6);
  line(legendX, legendY + 15, legendX + 30, legendY + 15);
  noStroke();
  fill(textSecondary);
  textFont(mainFont);
  text("Rutas Transmetro", legendX + 40, legendY + 15);
  
  // Línea Transurbano
  stroke(okGreen);
  strokeWeight(4);
  line(legendX + 200, legendY + 15, legendX + 230, legendY + 15);
  noStroke();
  fill(textSecondary);
  text("Rutas Transurbano", legendX + 240, legendY + 15);
  
  // Paradas
  fill(accentBlue);
  ellipse(legendX + 15, legendY + 35, 12, 12);
  fill(textPrimary);
  ellipse(legendX + 15, legendY + 35, 6, 6);
  fill(textSecondary);
  text("Paradas", legendX + 40, legendY + 35);
}
