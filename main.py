import sys
from PyQt6.QtWidgets import QApplication

# Importaciones de Clean Architecture
from lib.common.database.db_manager import DBManager
from lib.services.ai_inference_service import AIInferenceService
from lib.services.severity_calculator_service import SeverityCalculatorService
from lib.features.detection.domain.detection_controller import DetectionController

# Importamos la UI que acabamos de crear
from lib.features.detection.presentation.main_window import VitisGuardMainWindow

def main():
    # 1. Iniciamos la aplicación de PyQt6
    app = QApplication(sys.argv)
    
    # Estilo global opcional para que se vea más moderna
    app.setStyle("Fusion")

    # 2. Inicializamos la Base de Datos
    print("Conectando base de datos...")
    db = DBManager()

    # 3. Inicializamos los Servicios (Backend)
    print("Cargando servicios de IA...")
    ai_service = AIInferenceService('assets/models/best.pt')
    calculator = SeverityCalculatorService()

    # 4. Inicializamos el Controlador (Orquestador)
    controller = DetectionController(db, ai_service, calculator)

    # 5. Inicializamos y mostramos la Interfaz Gráfica (Frontend)
    print("Abriendo Interfaz VitisGuard...")
    window = VitisGuardMainWindow(controller)
    window.show()

    # 6. Mantenemos la aplicación corriendo
    exit_code = app.exec()
    
    # 7. Al cerrar la ventana, cerramos la base de datos limpiamente
    db.close()
    sys.exit(exit_code)

if __name__ == "__main__":
    main()