import cv2
from ultralytics import YOLO
import time
import os
import requests
import threading
import queue
from datetime import datetime

# ==========================================================
# CONFIGURACIÓN
# ==========================================================
SERVER_URL = "http://10.102.200.171:3000/api/info"
ENVIAR_ALERTAS = True
COOLDOWN_ENVIO = 3  # segundos entre alertas
alert_queue = queue.Queue()  # Cola para enviar alertas sin bloquear

# ==========================================================
# FUNCIONES BASE
# ==========================================================
def encontrar_modelo():
    """Busca el modelo entrenado."""
    posibles_rutas = [
        'runs/detect/weapon_detection/weights/best.pt',
        'runs/detect/weapon_detection2/weights/best.pt',
        'runs/detect/weapon_detection3/weights/best.pt',
        'knife.v1i.yolov8/train/weights/best.pt',
        'knife.vii.yolov8/train/weights/best.pt',
        'best.pt'
    ]
    print("\nBuscando modelo entrenado...")
    for ruta in posibles_rutas:
        if os.path.exists(ruta):
            print(f"  ENCONTRADO: {ruta}")
            return ruta
        else:
            print(f"  NO: {ruta}")
    return None


def inicializar_camara(camara_id=0):
    """Inicializa la cámara web."""
    print(f"\nIntentando abrir cámara {camara_id}...")
    cap = cv2.VideoCapture(camara_id)
    if not cap.isOpened():
        raise Exception(f"No se pudo abrir la cámara {camara_id}")

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    print(f"Cámara inicializada: {width}x{height}")
    return cap



def clasificar_arma(nombre_clase):
    """Clasifica el tipo de arma detectada."""
    nombre_lower = nombre_clase.lower()
    if 'knife' in nombre_lower or 'cuchillo' in nombre_lower or 'blade' in nombre_lower:
        return "arma_blanca", "cuchillo"
    elif 'pistol' in nombre_lower or 'gun' in nombre_lower or 'handgun' in nombre_lower:
        return "arma_fuego", "pistola"
    elif 'rifle' in nombre_lower:
        return "arma_fuego", "rifle"
    elif 'sword' in nombre_lower or 'espada' in nombre_lower:
        return "arma_blanca", "espada"
    elif 'machete' in nombre_lower:
        return "arma_blanca", "machete"
    else:
        return "arma_blanca", nombre_clase


SUBTIPO_MAP = {
    "coldweapon": "cuchillo",
    "firearm": "pistola",
    "rifle": "rifle",
    "sword": "espada",
    "machete": "machete"
}

def enviar_alerta(deteccion_info, modelo):
    """Envía alerta al servidor con los datos de la detección."""
    try:
        clase_id = int(deteccion_info['clase'])
        nombre_clase = modelo.names[clase_id]
        tipo, subtipo = clasificar_arma(nombre_clase)

        # Normalizar y mapear subtipo
        clave = subtipo.lower().replace("-", "").replace(" ", "")
        if clave in SUBTIPO_MAP:
            subtipo = SUBTIPO_MAP[clave]

        payload = {
            "tipo": tipo,
            "subtipo": subtipo,
            "timestamp": datetime.now().isoformat()
        }

        response = requests.post(
            SERVER_URL,
            json=payload,
            timeout=2, 
            headers={'Content-Type': 'application/json'}
        )

        if response.status_code == 200:
            print(f" Alerta enviada: {tipo} - {subtipo}")
            return True
        else:
            print(f" Error al enviar alerta: {response.status_code}")
            return False

    except requests.exceptions.ConnectionError:
        print(f" Error: No se pudo conectar al servidor {SERVER_URL}")
        return False
    except requests.exceptions.Timeout:
        print("Timeout al enviar alerta")
        return False
    except Exception as e:
        print(f" Error al enviar alerta: {e}")
        return False

    

def procesar_alertas(modelo):
    """Hilo dedicado que procesa alertas de la cola sin bloquear la cámara."""
    global alert_queue
    while True:
        try:
            deteccion_info = alert_queue.get()
            enviar_alerta(deteccion_info, modelo)
            alert_queue.task_done()
        except Exception as e:
            print(f"Error en hilo de alertas: {e}")


# ==========================================================
# DETECCIÓN EN TIEMPO REAL
# ==========================================================
def detectar_tiempo_real(ruta_modelo, camara_id=0, confianza=0.5):
    global ENVIAR_ALERTAS

    print(f"\nCargando modelo desde: {ruta_modelo}")
    modelo = YOLO(ruta_modelo)
    print("Modelo cargado exitosamente\n")

    # Clases disponibles
    print("Clases detectables:")
    for idx, nombre in modelo.names.items():
        print(f"  {idx}: {nombre}")

    cap = inicializar_camara(camara_id)

    # Lanzar hilo de alertas
    hilo_alertas = threading.Thread(target=procesar_alertas, args=(modelo,), daemon=True)
    hilo_alertas.start()

    print("\n" + "="*60)
    print("SISTEMA DE DETECCIÓN DE ARMAS ACTIVO")
    print("="*60)
    print(f"Servidor: {SERVER_URL}")
    print(f"Envío de alertas: {'ACTIVADO' if ENVIAR_ALERTAS else 'DESACTIVADO'}")
    print("="*60)
    print("Controles:")
    print("  'q' o ESC - Salir")
    print("  's' - Guardar captura")
    print("  '+' - Aumentar confianza")
    print("  '-' - Disminuir confianza")
    print("  'a' - Activar/desactivar envío de alertas")
    print("="*60 + "\n")

    frame_count = 0
    fps_tiempo = time.time()
    fps = 0
    detecciones_totales = 0
    alertas_enviadas = 0
    ultima_deteccion = ""
    ultimo_envio = 0

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Error al capturar frame")
                break

            resultados = modelo(frame, conf=confianza, verbose=False)
            frame_anotado = resultados[0].plot()

            # Calcular FPS
            frame_count += 1
            if frame_count % 30 == 0:
                fps = 30 / (time.time() - fps_tiempo)
                fps_tiempo = time.time()

            h, w = frame_anotado.shape[:2]

            # Panel superior
            cv2.rectangle(frame_anotado, (0, 0), (500, 150), (0, 0, 0), -1)
            cv2.rectangle(frame_anotado, (0, 0), (500, 150), (0, 255, 0), 2)
            cv2.putText(frame_anotado, f'FPS: {fps:.1f}', (10, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(frame_anotado, f'Confianza: {confianza:.2f}', (10, 60),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(frame_anotado, f'Detecciones: {detecciones_totales}', (10, 90),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(frame_anotado, f'Alertas en cola: {alert_queue.qsize()}', (10, 120),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

            color_alerta = (0, 255, 0) if ENVIAR_ALERTAS else (0, 0, 255)
            estado_texto = "ON" if ENVIAR_ALERTAS else "OFF"
            cv2.putText(frame_anotado, f'Alertas: {estado_texto}', (350, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, color_alerta, 2)

            # Procesar detecciones
            detecciones = resultados[0].boxes
            if len(detecciones) > 0:
                detecciones_totales += 1
                cv2.rectangle(frame_anotado, (0, h-100), (w, h), (0, 0, 255), -1)
                cv2.putText(frame_anotado, 'ALERTA: ARMA DETECTADA',
                           (int(w/2) - 250, h - 50),
                           cv2.FONT_HERSHEY_SIMPLEX, 1.2, (255, 255, 255), 3)

                for det in detecciones:
                    conf = float(det.conf[0])
                    clase = int(det.cls[0])
                    nombre_clase = modelo.names[clase]
                    coordenadas = det.xyxy[0].tolist()

                    mensaje = f"DETECTADO: {nombre_clase} | Confianza: {conf:.2%} | Pos: [{coordenadas[0]:.0f}, {coordenadas[1]:.0f}]"
                    if mensaje != ultima_deteccion:
                        print(mensaje)
                        ultima_deteccion = mensaje

                        tiempo_actual = time.time()
                        if ENVIAR_ALERTAS and (tiempo_actual - ultimo_envio) > COOLDOWN_ENVIO:
                            deteccion_info = {'clase': clase}
                            print(" Encolando alerta...")
                            alert_queue.put(deteccion_info)
                            alertas_enviadas += 1
                            ultimo_envio = tiempo_actual

            cv2.imshow('Detección de Armas - YOLOv8', frame_anotado)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('q') or key == 27:
                print("\nSaliendo del sistema...")
                break
            elif key == ord('s'):
                filename = f'captura_{int(time.time())}.jpg'
                cv2.imwrite(filename, frame_anotado)
                print(f"Captura guardada: {filename}")
            elif key == ord('+') or key == ord('='):
                confianza = min(0.95, confianza + 0.05)
                print(f"Confianza ajustada a: {confianza:.2f}")
            elif key == ord('-') or key == ord('_'):
                confianza = max(0.05, confianza - 0.05)
                print(f"Confianza ajustada a: {confianza:.2f}")
            elif key == ord('a'):
                ENVIAR_ALERTAS = not ENVIAR_ALERTAS
                estado = "ACTIVADO" if ENVIAR_ALERTAS else "DESACTIVADO"
                print(f"Envío de alertas: {estado}")

    except KeyboardInterrupt:
        print("\n\nInterrumpido por el usuario")

    finally:
        cap.release()
        cv2.destroyAllWindows()
        print("\n" + "="*60)
        print("Sistema cerrado")
        print(f"Total de detecciones: {detecciones_totales}")
        print(f"Total de alertas encoladas: {alertas_enviadas}")
        print("="*60 + "\n")


# ==========================================================
# MAIN
# ==========================================================
def main():
    print("\n" + "="*60)
    print("SISTEMA DE DETECCIÓN DE ARMAS EN TIEMPO REAL")
    print("="*60)

    ruta_modelo = encontrar_modelo()
    if not ruta_modelo:
        print("\nERROR: No se encontró el modelo entrenado.")
        return

    print(f"\nModelo encontrado: {ruta_modelo}")
    print(f"\nServidor actual: {SERVER_URL}")

    try:
        opcion = input("Cámara (0 integrada / 1 externa): ").strip()
        camara_id = int(opcion) if opcion else 0
    except:
        camara_id = 0

    try:
        conf_input = input("Umbral de confianza (0.1-0.9, Enter=0.5): ").strip()
        confianza = float(conf_input) if conf_input else 0.5
        confianza = max(0.1, min(0.9, confianza))
    except:
        confianza = 0.5

    input("\nPresiona Enter para iniciar...")
    detectar_tiempo_real(ruta_modelo, camara_id, confianza)


if __name__ == "__main__":
    main()
