import cv2
import time
import threading
from detector_local import detectar_placa

# Configuración de la cámara
cap = cv2.VideoCapture("http://192.168.1.70:8080/video")  # o 0 para webcam

print("[INFO] Iniciando detección de placas (offline)...")

# Variables globales
ultimo_resultado = None
procesando = False

def procesar_frame(frame):
    """Hilo que procesa un frame sin bloquear el video"""
    global procesando, ultimo_resultado
    procesando = True
    try:
        resultado = detectar_placa(frame)
        ultimo_resultado = resultado
    finally:
        procesando = False

while True:
    ret, frame = cap.read()
    if not ret:
        print("[ERROR] No se pudo acceder a la cámara.")
        break

    
    if not procesando:
        threading.Thread(target=procesar_frame, args=(frame.copy(),), daemon=True).start()
        time.sleep(0.3) 

    # Dibujar resultados en pantalla
    if ultimo_resultado and "predictions" in ultimo_resultado:
        for pred in ultimo_resultado["predictions"]:
            x, y, w, h = pred["x"], pred["y"], pred["width"], pred["height"]
            conf, clase = pred["confidence"], pred["class"]
            if clase.lower() == "placas" and conf > 0.7:
                cv2.rectangle(frame, (x - w // 2, y - h // 2), (x + w // 2, y + h // 2), (0, 255, 0), 2)
                cv2.putText(frame, f"{clase} ({conf:.2f})", (x - w // 2, y - h // 2 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

    cv2.imshow("Detección de Placas (Offline)", frame)

    # Salir con 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
