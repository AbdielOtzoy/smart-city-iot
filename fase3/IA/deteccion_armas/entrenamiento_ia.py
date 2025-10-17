

from ultralytics import YOLO
import os
import yaml

def verificar_dataset():
    """Verifica que el dataset esté correctamente estructurado"""
    print("\n" + "="*60)
    print("VERIFICANDO ESTRUCTURA DEL DATASET")
    print("="*60)
    
    # Mostrar directorio actual
    print(f"\nDirectorio actual: {os.getcwd()}")
    
    # Buscar el archivo data.yaml
    posibles_rutas = [
        'data.yaml',
        'knife.v1i.yolov8/data.yaml',
        'knife.vii.yolov8/data.yaml',
        'train/data.yaml',
        '../knife.v1i.yolov8/data.yaml'
    ]
    
    data_yaml_path = None
    print("\nBuscando data.yaml en:")
    for ruta in posibles_rutas:
        print(f"  Intentando: {ruta} ... ", end="")
        if os.path.exists(ruta):
            data_yaml_path = ruta
            print("ENCONTRADO")
            break
        else:
            print("NO")
    
    if not data_yaml_path:
        print("\nNo se encontró data.yaml en ninguna ubicación")
        print("\nContenido del directorio actual:")
        for item in sorted(os.listdir('.')):
            item_path = os.path.join('.', item)
            if os.path.isdir(item_path):
                print(f"  [DIR]  {item}/")
            else:
                print(f"  [FILE] {item}")
        
        print("\nSOLUCION:")
        print("1. Copia la ruta exacta donde está data.yaml")
        print("2. Ejecutalo manualmente:")
        print("   python entrenamiento_ia.py knife.v1i.yolov8/data.yaml")
        return None
    
    # Leer y mostrar contenido
    with open(data_yaml_path, 'r') as f:
        config = yaml.safe_load(f)
        print(f"\nContenido del dataset:")
        print(f"  - Clases: {config.get('names', 'No especificado')}")
        print(f"  - Train: {config.get('train', 'No especificado')}")
        print(f"  - Val: {config.get('val', 'No especificado')}")
    
    return data_yaml_path

def entrenar_modelo(data_yaml_path, epochs=50, img_size=640):
    """
    Entrena el modelo YOLOv8 con tu dataset
    
    Args:
        data_yaml_path: Ruta al archivo data.yaml
        epochs: Número de épocas de entrenamiento (más = mejor modelo pero más tiempo)
        img_size: Tamaño de imagen para entrenamiento
    """
    print("\n" + "="*60)
    print("INICIANDO ENTRENAMIENTO DEL MODELO")
    print("="*60)
    print(f"Epocas: {epochs}")
    print(f"Tamaño de imagen: {img_size}")
    print("="*60 + "\n")
    
    # Cargar modelo pre-entrenado de YOLOv8
    print("Descargando modelo base YOLOv8n (más pequeño y rápido)...")
    modelo = YOLO('yolov8n.pt')  
    
    # Entrenar
    print("\nIniciando entrenamiento! Esto puede tomar varios minutos u horas...\n")
    resultados = modelo.train(
        data=data_yaml_path,
        epochs=epochs,
        imgsz=img_size,
        device='0',  
        batch=16,  
        patience=10,  
        save=True,
        project='runs/detect',
        name='weapon_detection',
        exist_ok=True,
        pretrained=True,
        optimizer='auto',
        verbose=True,
        seed=42,
        deterministic=True,
        single_cls=False,
        rect=False,
        cos_lr=False,
        close_mosaic=10,
        resume=False,
        amp=True,  
        fraction=1.0,
        profile=False,
        overlap_mask=True,
        mask_ratio=4,
        dropout=0.0,
        val=True,
        plots=True
    )
    
    print("\n" + "="*60)
    print("ENTRENAMIENTO COMPLETADO")
    print("="*60)
    print(f"Modelo guardado en: runs/detect/weapon_detection/weights/best.pt")
    print("="*60 + "\n")
    
    return resultados

def validar_modelo(model_path='runs/detect/weapon_detection/weights/best.pt', 
                   data_yaml_path='data.yaml'):
    """Valida el modelo entrenado"""
    print("\n" + "="*60)
    print("VALIDANDO MODELO")
    print("="*60)
    
    modelo = YOLO(model_path)
    metricas = modelo.val(data=data_yaml_path)
    
    print(f"\nResultados de validación:")
    print(f"  - mAP50: {metricas.box.map50:.3f}")
    print(f"  - mAP50-95: {metricas.box.map:.3f}")
    print(f"  - Precisión: {metricas.box.mp:.3f}")
    print(f"  - Recall: {metricas.box.mr:.3f}")
    
    return metricas

def main():
    """Función principal de entrenamiento"""
    import sys
    
    print("\n" + "="*60)
    print("SISTEMA DE ENTRENAMIENTO YOLOV8 - DETECCION DE ARMAS")
    print("="*60)
    
    # Verificar si se pasó ruta como argumento
    if len(sys.argv) > 1:
        data_yaml_path = sys.argv[1]
        print(f"\nUsando ruta proporcionada: {data_yaml_path}")
        if not os.path.exists(data_yaml_path):
            print(f"ERROR: No existe el archivo: {data_yaml_path}")
            return
    else:
        # Verificar dataset automáticamente
        data_yaml_path = verificar_dataset()
        if not data_yaml_path:
            print("\nERROR: No se pudo encontrar data.yaml")
            print("\nOPCIONES:")
            print("1. Ejecuta el script desde la carpeta deteccion_armas:")
            print("   cd /home/gabriel-melgar/deteccion_armas")
            print("   python entrenamiento_ia.py")
            print("\n2. O pasa la ruta completa como argumento:")
            print("   python entrenamiento_ia.py knife.v1i.yolov8/data.yaml")
            return
    
    # Configuración de entrenamiento
    print("\n" + "="*60)
    print("CONFIGURACION DE ENTRENAMIENTO")
    print("="*60)
    
    # Opciones de entrenamiento
    print("\nOpciones:")
    print("1. Entrenamiento rápido (10 épocas) - Para pruebas")
    print("2. Entrenamiento normal (50 épocas) - Recomendado")
    print("3. Entrenamiento largo (100 épocas) - Mejor precisión")
    print("4. Personalizado")
    
    opcion = input("\nElige una opción (1-4): ").strip()
    
    if opcion == '1':
        epochs = 10
    elif opcion == '2':
        epochs = 50
    elif opcion == '3':
        epochs = 100
    elif opcion == '4':
        try:
            epochs = int(input("Número de épocas: "))
        except:
            epochs = 50
            print("Valor inválido, usando 50 épocas")
    else:
        epochs = 50
        print("Opción inválida, usando 50 épocas")
    
    # Iniciar entrenamiento
    try:
        entrenar_modelo(data_yaml_path, epochs=epochs)
        
        # Validar modelo
        validar_modelo(data_yaml_path=data_yaml_path)
        
        print("\n" + "="*60)
        print("PROCESO COMPLETADO EXITOSAMENTE")
        print("="*60)
        print("\nAhora puedes usar el modelo entrenado con:")
        print("  python detect_tiempo_real.py")
        print("="*60 + "\n")
        
    except Exception as e:
        print(f"\nError durante el entrenamiento: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()