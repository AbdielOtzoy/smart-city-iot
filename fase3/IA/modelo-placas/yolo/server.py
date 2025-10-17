# server.py  (OCR + detección + envío)
import time
import threading
import requests
import cv2
import numpy as np
import pytesseract
from PIL import Image
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

# ---------------- CONFIG ----------------
CAMERA_SOURCE = "http://10.102.200.166:8080/video"
RASPBERRY_URL = "http://10.102.200.171:3000/api/info"
#RASPBERRY_URL = "https://webhook.site/08a0abac-e6ee-4300-a631-2fb0f0704cf9"
MAX_CAPTURE_SECONDS = 8        # segundos que captura tras trigger
SAMPLE_INTERVAL = 0.25         # cada cuanto se analiza un frame 
CONF_THRESHOLD = 0.5
COOLDOWN_SECONDS = 6

TESSERACT_PATH = r"C:\Program Files\Tesseract-OCR\tesseract.exe"


pytesseract.pytesseract.tesseract_cmd = TESSERACT_PATH


from detector_local import detectar_placa

app = FastAPI()
_last_sent_time = 0



class DataItem(BaseModel):
    zona: int
    timestamp: int

class TriggerPayload(BaseModel):
    data: List[DataItem]
    timestamp: Optional[str] = None


def send_to_raspberry(payload: dict):
    """Envía los datos a la Raspberry (o webhook) sin romper el servidor."""
    try:
        r = requests.post(RASPBERRY_URL, json=payload, timeout=6)
        print(f"[INFO] Enviado a Raspberry ({r.status_code}) -> {payload}")
    except requests.exceptions.RequestException as e:
        print("[ERROR] No se pudo enviar a Raspberry:", e)


def preprocess_for_ocr(roi_bgr: np.ndarray) -> Image.Image:
    """
    Preprocesa ROI (BGR) para mejorar OCR y devuelve PIL Image.
    - Convierte a gris
    - Aumenta contraste/resolución si muy pequeño
    - Aplica umbral adaptativo y morfología ligera
    """
    gray = cv2.cvtColor(roi_bgr, cv2.COLOR_BGR2GRAY)

   
    h, w = gray.shape
    if max(h, w) < 200:
        scale = int(200 / max(h, w)) + 1
        gray = cv2.resize(gray, (w * scale, h * scale), interpolation=cv2.INTER_LINEAR)

    # Filtro para reducir ruido
    gray = cv2.bilateralFilter(gray, 9, 75, 75)

    # Umbral adaptativo 
    th = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                               cv2.THRESH_BINARY, 11, 2)

    # Operaciones 
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
    th = cv2.morphologyEx(th, cv2.MORPH_CLOSE, kernel, iterations=1)

    # Convertir a PIL
    pil = Image.fromarray(th)
    cv2.imwrite("placa_procesada.jpg", th)
    return pil

def ocr_read_plate(roi_bgr: np.ndarray) -> str:
    """
    Ejecuta OCR sobre ROI (BGR). Prueba varios modos (psm) y devuelve el mejor texto.
    """
    try:
        pil_img = preprocess_for_ocr(roi_bgr)
        best_text = ""
        best_len = 0

        # Probar varios modos de segmentacion
        for psm in [7, 8, 11]:
            config = f'--psm {psm} -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
            raw = pytesseract.image_to_string(pil_img, config=config)
            text = "".join(ch for ch in raw if ch.isalnum()).upper()
            if len(text) > best_len:
                best_text = text
                best_len = len(text)

        return best_text.strip()
    except Exception as e:
        print("[OCR ERROR]", e)
        return ""



def process_capture_and_detect(event_info: dict | None = None):
    """Captura frames durante MAX_CAPTURE_SECONDS y busca placas; al detectarla hace OCR."""
    global _last_sent_time

    if time.time() - _last_sent_time < COOLDOWN_SECONDS:
        print("[INFO] En cooldown. Ignorando trigger.")
        return

    cap = cv2.VideoCapture(CAMERA_SOURCE)
    if not cap.isOpened():
        print("[ERROR] No se pudo abrir la cámara:", CAMERA_SOURCE)
        return

    print("[INFO] Capturando frames y buscando placas (con OCR)...")
    deadline = time.time() + MAX_CAPTURE_SECONDS
    detected_any = False

    while time.time() < deadline and not detected_any:
        ret, frame = cap.read()
        if not ret:
            time.sleep(0.05)
            continue

        # Ejecutar deteccion YOLO
        try:
            res = detectar_placa(frame)
        except Exception as e:
            print("[ERROR] detectar_placa:", e)
            res = None

        if res and "predictions" in res:
            for pred in res["predictions"]:
                clase = pred.get("class", "").lower()
                conf = float(pred.get("confidence", 0))
                if "placa" in clase and conf >= CONF_THRESHOLD:
                    # Coordenadas xywh centradas segun tu detector
                    x, y = int(pred["x"]), int(pred["y"])
                    w, h = int(pred["width"]), int(pred["height"])
                    x1, y1 = max(0, x - w // 2), max(0, y - h // 2)
                    x2, y2 = min(frame.shape[1], x + w // 2), min(frame.shape[0], y + h // 2)
                    roi = frame[y1:y2, x1:x2]
                    if roi.size == 0:
                        continue

                    # OCR
                    cv2.imwrite("ultima_placa.jpg", roi)
                    print("[DEBUG] ROI guardado -> ultima_placa.jpg")

                    placa_texto = ocr_read_plate(roi)
                    timestamp = datetime.now().isoformat()
                    print(f"[DETECCIÓN] bbox={x1,y1,x2,y2} conf={conf:.2f} ocr='{placa_texto}'")

                    payload = {
                        "clase": clase,
                        "placa_texto": placa_texto if placa_texto else None,
                        "timestamp": timestamp
                        
                    }


                    send_to_raspberry(payload)
                    detected_any = True
                    _last_sent_time = time.time()
                    break

        time.sleep(SAMPLE_INTERVAL)

    cap.release()
    if not detected_any:
        print("[INFO] No se detectó placa durante el periodo de captura.")
        send_to_raspberry({
            "evento": event_info,
            "mensaje": "no_plate_detected",
            "timestamp": datetime.now().isoformat()
        })


@app.post("/trigger")
async def trigger(payload: TriggerPayload, background_tasks: BackgroundTasks):
    print("[ALERTA] Trigger recibido:", payload.dict())
    background_tasks.add_task(process_capture_and_detect, payload.dict())
    return {"status": "ok", "message": "Procesando detección con OCR..."}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server:app", host="0.0.0.0", port=3000)

