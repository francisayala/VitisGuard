#corazon del backend, el controlador de dominio que orquesta todo el flujo de datos entre la IA, la matemática y la base de datos.

import os
import shutil
from fastapi import FastAPI, UploadFile, File, HTTPException, Form
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
async def analyze_leaf(
    file: UploadFile = File(...),
    model_name: str = Form("VitisGuard CNN v1.2") # Por defecto usamos el tuyo si no mandan nada
):
    """
    Endpoint principal. Recibe una imagen desde Flutter y el modelo que se quiere usar.
    """
    try:
        # --- NUEVO: MAGIA DE CAMBIO DE MODELO ---
        # Asumimos que tus modelos están guardados en la carpeta 'assets/models/'
        ruta_modelo = os.path.join('assets/models', model_name)

        # Verificamos si la ruta actual es diferente a la que queremos usar
        if getattr(ai_service, 'model_path', 'assets/models/best.pt') != ruta_modelo:
            print(f"🔄 Cambiando motor de IA. Cargando modelo: {ruta_modelo}")

            # Solo cambiamos el modelo si el archivo existe en el backend
            if os.path.exists(ruta_modelo):
                # Actualizamos el servicio de IA.
                ai_service.__init__(ruta_modelo) 
                # Y volvemos a inyectarlo en el controlador
                controller.ai_service = ai_service 
            else:
                print(f"⚠️ ADVERTENCIA: No se encontró el archivo {ruta_modelo}. Se usará el modelo actual.")
        # ----------------------------------------

        # 1. Guardar la imagen recibida temporalmente
        file_path = os.path.join(TEMP_DIR, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # 2. Pasar la imagen al Controlador (nuestro código existente)
        resultado = controller.analyze_and_save(file_path)

        # 3. Extraemos solo los datos que Flutter necesita para pintar la UI
        metrics = resultado["metrics"]
        
        return {
            "success": True,
            "filename": file.filename,
            "iaa_severity": metrics["iaa"],
            "total_area_px": metrics["total_area_px"],
            "affected_area_px": metrics["affected_area_px"],
            "pathogens": metrics["pathogens"]
        }

    except Exception as e:
        # Si algo falla, este bloque lo atrapa para que el servidor no explote
        raise HTTPException(status_code=500, detail=str(e))