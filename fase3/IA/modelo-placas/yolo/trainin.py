from ultralytics import YOLO

# Cargar modelo pre-entrenado o YOLOv11 small
modelo = YOLO("yolov8n.pt")


# Entrenar con tus datos locales
modelo.train(data="data.yaml", epochs=50, imgsz=640)
