// ================================================================ //
//             VISTA 4: ALERTAS (Vista_Alertas.pde)                 //
// ================================================================ //

// Definiciones de color para los tipos de alerta principales
color accentRed = color(220, 40, 40);      // Pánico, Emergencia
color accentYellow = color(255, 220, 40);  // Infracción/Semáforo pasado
color accentOrange = color(255, 140, 20);  // Incendio
color accentPurple = color(160, 80, 200);  // Sismo
color accentGreen = color(60, 200, 60);    // INFO, sistema OK
color accentGray = color(180, 180, 180);   // Otros

void drawAlertsView() {
  drawTitledPanel("Panel de Alertas del Sistema", 50, 100, width - 100, height - 150);

  // Fondo de la consola
  fill(bgDark);
  rect(80, 160, width - 160, height - 240, 10);

  // Encabezado con contador de alertas
  int totalAlertas = getAlertasRecientes().size();
  fill(accentRed);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  text("Alertas recientes (" + totalAlertas + ")", width/2, 140);

  // Mostrar todas las alertas recientes
  ArrayList<String> alertas = getAlertasRecientes();
  int y = 180;
  textFont(mainFont);
  textAlign(LEFT, TOP);

  for (int i = 0; i < alertas.size(); i++) {
    String alerta = alertas.get(i);

    // Colorear según tipo de alerta (solo los tipos que realmente existen en tu sistema)
    if (alerta.contains("PÁNICO") || alerta.contains("🚨")) {
      fill(accentRed); // Pánico
    } else if (alerta.contains("INCENDIO") || alerta.contains("🔥")) {
      fill(accentOrange); // Incendio
    } else if (alerta.contains("SISMO") || alerta.contains("🌎")) {
      fill(accentPurple); // Sismo
    } else if (
      alerta.contains("INFRACCIÓN") || 
      alerta.contains("INFRACCION") || 
      alerta.toLowerCase().contains("semáforo en rojo") || 
      alerta.toLowerCase().contains("semaforo en rojo") ||
      alerta.toLowerCase().contains("semáforo pasado") ||
      alerta.toLowerCase().contains("semaforo pasado")
    ) {
      fill(accentYellow); // Infracción/Semáforo pasado
    } else if (alerta.contains("OK") || alerta.contains("INFO")) {
      fill(accentGreen); // Sistema OK/info
    } else {
      fill(accentGray); // Otros
    }

    text(alerta, 100, y);
    y += 28;
    if (y > height - 100) break; // No sobrepasar el panel
  }

  // Leyenda de colores (opcional)
  drawColorLegend();
}

void drawColorLegend() {
  float legendX = width - 300;
  float legendY = height - 130;
  int legendWidth = 250;
  int legendHeight = 90;

  fill(panelBg);
  strokeWeight(1);
  rect(legendX, legendY, legendWidth, legendHeight, 5);
  noStroke();

  fill(textPrimary);
  textAlign(LEFT, TOP);
  textFont(titleFont);
  text("Tipos de Alertas:", legendX + 10, legendY + 10);

  textFont(mainFont);
  int itemY = int(legendY + 35);
  int lineHeight = 15;

  fill(accentRed);
  ellipse(legendX + 15, itemY, 8, 8);
  fill(textSecondary);
  text("Críticas / Pánico", legendX + 25, itemY - 5);

  itemY += lineHeight;
  fill(accentOrange);
  ellipse(legendX + 15, itemY, 8, 8);
  fill(textSecondary);
  text("Incendio", legendX + 25, itemY - 5);

  itemY += lineHeight;
  fill(accentPurple);
  ellipse(legendX + 15, itemY, 8, 8);
  fill(textSecondary);
  text("Sismo", legendX + 25, itemY - 5);

  itemY += lineHeight;
  fill(accentYellow);
  ellipse(legendX + 15, itemY, 8, 8);
  fill(textSecondary);
  text("Infracción", legendX + 25, itemY - 5);

  itemY += lineHeight;
  fill(accentGreen);
  ellipse(legendX + 15, itemY, 8, 8);
  fill(textSecondary);
  text("Info / OK", legendX + 25, itemY - 5);
}
