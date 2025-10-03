"""
Sistema de Detección de Armas en TIEMPO REAL
Usa este script DESPUÉS de entrenar el modelo
SIN EMOJIS - VERSION LIMPIA
"""

import cv2
from ultralytics import YOLO
import time
import os

def encontrar_modelo():
    """Busca el modelo entrenado"""
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
    """Inicializa la cámara web"""
    print(f"\nIntentando abrir cámara {camara_id}...")
    cap = cv2.VideoCapture(camara_id)
    
    if not cap.isOpened():
        raise Exception(f"No se pudo abrir la cámara {camara_id}")
    
    # Configurar resolución
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    
    # Verificar resolución real
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    print(f"Camara inicializada: {width}x{height}")
    
    return cap

def detectar_tiempo_real(ruta_modelo, camara_id=0, confianza=0.5):
    """
    Ejecuta detección en tiempo real
    """
    # Cargar modelo
    print(f"\nCargando modelo desde: {ruta_modelo}")
    modelo = YOLO(ruta_modelo)
    print("Modelo cargado exitosamente\n")
    
    # Mostrar clases del modelo
    print("Clases detectables:")
    for idx, nombre in modelo.names.items():
        print(f"  {idx}: {nombre}")
    
    # Inicializar cámara
    cap = inicializar_camara(camara_id)
    
    print("\n" + "="*60)
    print("SISTEMA DE DETECCION DE ARMAS ACTIVO")
    print("="*60)
    print("Controles:")
    print("  'q' o ESC - Salir")
    print("  's' - Guardar captura")
    print("  '+' - Aumentar confianza")
    print("  '-' - Disminuir confianza")
    print("="*60 + "\n")
    
    frame_count = 0
    fps_tiempo = time.time()
    fps = 0
    detecciones_totales = 0
    ultima_deteccion = ""
    
    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Error al capturar frame")
                break
            
            # Realizar detección
            resultados = modelo(frame, conf=confianza, verbose=False)
            
            # Frame anotado
            frame_anotado = resultados[0].plot()
            
            # Calcular FPS
            frame_count += 1
            if frame_count % 30 == 0:
                fps = 30 / (time.time() - fps_tiempo)
                fps_tiempo = time.time()
            
            # Información en pantalla
            h, w = frame_anotado.shape[:2]
            
            # Panel de información superior
            cv2.rectangle(frame_anotado, (0, 0), (450, 120), (0, 0, 0), -1)
            cv2.rectangle(frame_anotado, (0, 0), (450, 120), (0, 255, 0), 2)
            
            cv2.putText(frame_anotado, f'FPS: {fps:.1f}', (10, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(frame_anotado, f'Confianza: {confianza:.2f}', (10, 60),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(frame_anotado, f'Detecciones totales: {detecciones_totales}', (10, 90),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            
            # Detectar objetos
            detecciones = resultados[0].boxes
            if len(detecciones) > 0:
                detecciones_totales += 1
                
                # Alerta visual en la parte inferior
                cv2.rectangle(frame_anotado, (0, h-100), (w, h), (0, 0, 255), -1)
                cv2.putText(frame_anotado, 'ALERTA: ARMA DETECTADA', 
                           (int(w/2) - 250, h - 50),
                           cv2.FONT_HERSHEY_SIMPLEX, 1.2, (255, 255, 255), 3)
                
                # Mostrar detalles en consola
                for det in detecciones:
                    conf = float(det.conf[0])
                    clase = int(det.cls[0])
                    nombre_clase = modelo.names[clase]
                    coordenadas = det.xyxy[0].tolist()
                    
                    mensaje = f"DETECTADO: {nombre_clase} | Confianza: {conf:.2%} | Pos: [{coordenadas[0]:.0f}, {coordenadas[1]:.0f}]"
                    
                    # Solo imprimir si es diferente a la última detección
                    if mensaje != ultima_deteccion:
                        print(mensaje)
                        ultima_deteccion = mensaje
            
            # Mostrar ventana
            cv2.imshow('Deteccion de Armas - YOLOv8', frame_anotado)
            
            # Controles
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q') or key == 27:  # 27 = ESC
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
    
    except KeyboardInterrupt:
        print("\n\nInterrumpido por el usuario")
    
    except Exception as e:
        print(f"\nError durante la detección: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        cap.release()
        cv2.destroyAllWindows()
        print("\n" + "="*60)
        print("Sistema cerrado")
        print(f"Total de detecciones: {detecciones_totales}")
        print("="*60 + "\n")

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("SISTEMA DE DETECCION DE ARMAS EN TIEMPO REAL")
    print("="*60)
    
    # Buscar modelo
    ruta_modelo = encontrar_modelo()
    
    if not ruta_modelo:
        print("\nERROR: No se encontró el modelo entrenado")
        print("\nDebes entrenar el modelo primero:")
        print("  python entrenamiento_ia.py knife.v1i.yolov8/data.yaml")
        print("\nO asegúrate de que best.pt esté en alguna de estas rutas:")
        print("  - runs/detect/weapon_detection/weights/best.pt")
        print("  - knife.v1i.yolov8/train/weights/best.pt")
        print("  - best.pt")
        return
    
    print(f"\nModelo encontrado: {ruta_modelo}")
    
    # Configuración de cámara
    print("\n" + "="*60)
    print("CONFIGURACION DE CAMARA")
    print("="*60)
    print("\nCamaras disponibles:")
    print("  0 - Camara integrada (predeterminada)")
    print("  1 - Camara externa USB")
    
    try:
        opcion = input("\nElige camara (0-1, Enter=0): ").strip()
        camara_id = int(opcion) if opcion else 0
    except:
        camara_id = 0
        print("Usando camara predeterminada: 0")
    
    # Configuración de confianza
    try:
        conf_input = input("Umbral de confianza (0.1-0.9, Enter=0.5): ").strip()
        confianza = float(conf_input) if conf_input else 0.5
        confianza = max(0.1, min(0.9, confianza))
    except:
        confianza = 0.5
        print("Usando confianza predeterminada: 0.5")
    
    print(f"\nConfiguracion final:")
    print(f"  - Camara ID: {camara_id}")
    print(f"  - Confianza: {confianza}")
    print(f"  - Modelo: {ruta_modelo}")
    
    # Iniciar detección
    print("\nPresiona Enter para iniciar...")
    input()
    
    detectar_tiempo_real(ruta_modelo, camara_id, confianza)

if __name__ == "__main__":
    main()
