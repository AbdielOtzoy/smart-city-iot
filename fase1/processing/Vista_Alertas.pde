// ================================================================ //
//             VISTA 4: ALERTAS (Vista_Alertas.pde)                 //
// ================================================================ //

void drawAlertsView() {
  drawTitledPanel("Panel de Alertas del Sistema", 50, 100, width - 100, height - 150);

  // Fondo de la consola
  fill(bgDark);
  rect(80, 160, width - 160, height - 240, 10);

  // Alertas de ejemplo
  String[] alerts = {
    "[PÁNICO] Botón de pánico activado en Zona 4.",
    "[INCENDIO] Alarma de incendios en Edificio Municipal.",
    "[INFO] Mantenimiento programado del sistema de semáforos.",
    "[INFRACCIÓN] Vehículo con placas P-123ABC excede límite de velocidad.",
    "[SISMO] Actividad sísmica leve detectada.",
    "[INFO] Sistema de transporte operando con normalidad."
  };

  textAlign(LEFT, TOP);
  textFont(mainFont);
  float yPos = 180;
  for (String alert : alerts) {
    if (alert.startsWith("[PÁNICO]") || alert.startsWith("[INCENDIO]") || alert.startsWith("[SISMO]")) fill(alertRed);
    else if (alert.startsWith("[INFRACCIÓN]")) fill(warnYellow);
    else fill(okGreen);
    text(alert, 100, yPos);
    yPos += 35;
  }
}
