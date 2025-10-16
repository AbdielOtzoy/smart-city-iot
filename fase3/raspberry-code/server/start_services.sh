#!/bin/bash

# Script para iniciar ambos servicios en la Raspberry Pi
# Sistema de Vigilancia Integrado

echo "=========================================="
echo " Sistema de Vigilancia - Raspberry Pi"
echo "=========================================="
echo ""

# Directorio base
BASE_DIR="$HOME/Desktop/ACE2"

# Verificar que existe el directorio
if [ ! -d "$BASE_DIR" ]; then
    echo " Error: Directorio $BASE_DIR no encontrado"
    exit 1
fi

cd "$BASE_DIR"

# Activar entorno virtual
if [ -d "myEnvACE2" ]; then
    echo " Activando entorno virtual..."
    source myEnvACE2/bin/activate
else
    echo " Error: No se encontró el entorno virtual"
    exit 1
fi

# Función para matar procesos al salir
cleanup() {
    echo ""
    echo " Deteniendo servicios..."
    kill $API_PID 2>/dev/null
    kill $ARDUINO_PID 2>/dev/null
    echo " Servicios detenidos"
    exit 0
}

# Capturar señales de interrupción
trap cleanup SIGINT SIGTERM

# Iniciar el lector de Arduino en segundo plano
echo " Iniciando lector de Arduino..."
python3 arduino_Reader.py &
ARDUINO_PID=$!
echo "   PID: $ARDUINO_PID"

# Esperar un momento
sleep 2

# Iniciar la API en segundo plano
echo " Iniciando API FastAPI..."
python3 main.py &
API_PID=$!
echo "   PID: $API_PID"

echo ""
echo "=========================================="
echo " Servicios iniciados correctamente"
echo "=========================================="
echo " Lector Arduino: PID $ARDUINO_PID"
echo " API FastAPI: PID $API_PID"
echo " Documentación: http://192.168.0.5:3000/docs"
echo ""
echo "Presiona Ctrl+C para detener los servicios"
echo "=========================================="

# Esperar indefinidamente
wait