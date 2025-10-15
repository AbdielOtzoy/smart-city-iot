from ultralytics import YOLO
import cv2

# Cargar el modelo entrenado
MODELO_PATH = r"C:\Users\Engel\Desktop\yolo\runs\detect\train\weights\best.pt"
modelo = YOLO(MODELO_PATH)

def detectar_placa(imagen):
    """
    Recibe una imagen (numpy array) y retorna un diccionario
    con las predicciones: x, y, width, height, confidence, class
    """
    try:
        resultado = modelo.predict(imagen, verbose=False)[0]  
        predicciones = []
        for box in resultado.boxes:
            predicciones.append({
                "x": int(box.xywh[0][0]),
                "y": int(box.xywh[0][1]),
                "width": int(box.xywh[0][2]),
                "height": int(box.xywh[0][3]),
                "confidence": float(box.conf[0]),
                "class": modelo.names[int(box.cls[0])]
            })
        return {"predictions": predicciones}
    except Exception as e:
        return {"error": str(e)}

# --- Prueba manual ---
if __name__ == "__main__":
    ruta_imagen = "ejemplo.jpg"
    img = cv2.imread(ruta_imagen)
    if img is None:
        print(f"[ERROR] No se encontró la imagen {ruta_imagen}")
    else:
        resultado = detectar_placa(img)
        print("[RESULTADO]")
        print(resultado)
