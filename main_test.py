import cv2
import os
import torch
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QImage, QPixmap

# Respetando tu estructura de carpetas exacta
from lib.common.database.db_manager import DBManager
from lib.features.detection.domain.detection_controller import DetectionController
from lib.services.ai_inference_service import AIInferenceService
from lib.services.severity_calculator_service import SeverityCalculatorService

def run_test():
    print("🚀 Iniciando Test de Integración VitisGuard...")
    
    # 1. Inicializar Base de Datos
    db = DBManager()
    
    # 2. Inicializar Servicios (Los que están en lib/services)
    # Nota: Mañana cuando tengas el best.pt, esto cargará la IA real
    ai_service = AIInferenceService('assets/models/best.pt')
    calculator = SeverityCalculatorService()
    
    # 3. Instanciar controlador
    # El controlador es el "Director de Orquesta"
    controller = DetectionController(db, ai_service, calculator)
    
    # 4. Ruta de imagen de prueba
    test_image = "data/raw_images/test_hoja.jpg"
    
    if not os.path.exists(test_image):
        print(f"❌ Error: No se encuentra la imagen en {test_image}")
        # Creamos una carpeta data/raw_images si no existe para evitar errores futuros
        os.makedirs("data/raw_images", exist_ok=True)
        return

    print(f"📸 Analizando imagen: {test_image}")

    try:
        # 5. Ejecutar pipeline completo (Inferencia -> Cálculo IAA -> Guardar en DB)
        # Este método debe estar dentro de tu DetectionController
        resultado = controller.analyze_and_save(test_image)
        
        print(f"✅ Análisis completado. Resultado: {resultado}")

    except Exception as e:
        print(f"⚠️ Nota: El test fallará hasta que best.pt exista. Error actual: {e}")

    # 6. Verificar historial en DB para asegurar que se guardó
    print("\n--- Historial en Base de Datos (Trazabilidad) ---")
    historial = controller.repository.get_history()
    for row in historial:
        print(f"ID: {row[0]} | Fecha: {row[1]} | IAA: {row[2]}% | Path: {row[3]}")
    
    db.close()

if __name__ == "__main__":
    # Creamos una instancia de QApplication mínima para que PyQt6 no de errores de imagen
    app = QApplication([]) 
    run_test()