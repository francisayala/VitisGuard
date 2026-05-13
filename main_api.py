#corazon del backend, el controlador de dominio que orquesta todo el flujo de datos entre la IA, la matemática y la base de datos.

import os
import shutil
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Importamos tu Clean Architecture
from lib.common.database.db_manager import DBManager
from lib.services.ai_inference_service import AIInferenceService
from lib.services.severity_calculator_service import SeverityCalculatorService
from lib.features.detection.domain.detection_controller import DetectionController

# Inicializamos el servidor FastAPI
app = FastAPI(title="VitisGuard API", version="1.0")

# Configuramos CORS (Vital para que Flutter pueda comunicarse sin bloqueos)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # En producción se restringe, aquí permitimos todo
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializamos los servicios globalmente al arrancar el servidor
print("🚀 Levantando Backend de VitisGuard...")
db = DBManager()
ai_service = AIInferenceService('assets/models/best.pt')
calculator = SeverityCalculatorService()
controller = DetectionController(db, ai_service, calculator)

# Creamos una carpeta temporal para guardar las imágenes que envíe Flutter
TEMP_DIR = "data/temp_uploads"
os.makedirs(TEMP_DIR, exist_ok=True)

@app.get("/")
def read_root():
    return {"status": "VitisGuard Backend Operativo", "ia_ready": ai_service.model is not None}

@app.post("/api/analyze")
async def analyze_leaf(file: UploadFile = File(...)):
    """
    Endpoint principal. Recibe una imagen desde Flutter, la analiza con YOLO
    y devuelve los resultados clínicos.
    """
    try:
        # 1. Guardar la imagen recibida temporalmente
        file_path = os.path.join(TEMP_DIR, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # 2. Pasar la imagen al Controlador (nuestro código existente)
        resultado = controller.analyze_and_save(file_path)

        # 3. Extraemos solo los datos que Flutter necesita para pintar la UI
        metrics = resultado["metrics"]
        
        # Opcional: Podrías procesar las máscaras aquí si Flutter necesita pintar la imagen superpuesta,
        # pero por ahora enviaremos los datos clínicos numéricos.
        
        return {
            "success": True,
            "filename": file.filename,
            "iaa_severity": metrics["iaa"],
            "total_area_px": metrics["total_area_px"],
            "affected_area_px": metrics["affected_area_px"],
            "pathogens": metrics["pathogens"]
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))