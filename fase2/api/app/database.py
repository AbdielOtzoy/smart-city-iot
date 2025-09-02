from pymongo import MongoClient
from app.config import MONGO_URL

client = MongoClient(MONGO_URL)
db = client["iot_db"]   # Nombre de la base
alertasCollection = db["alertas"]
traficoCollection = db["trafico"]
ambienteCollection = db["ambiente"]