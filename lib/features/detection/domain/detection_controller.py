import os
from datetime import datetime

class DetectionController:
    """
    Controlador de Dominio para el Módulo de Detección.
    Orquesta el flujo de datos entre la Inteligencia Artificial, 
    el motor matemático y el repositorio de persistencia (Base de Datos).
    """
    def __init__(self, repository, ai_service, calculator_service):
        # Inyección de dependencias
        self.repository = repository
        self.ai_service = ai_service
        self.calculator = calculator_service

    def analyze_and_save(self, image_path):
        """
        Ejecuta el pipeline completo de VitisGuard:
        1. Inferencia -> 2. Formateo -> 3. Cálculo -> 4. Guardado
        """
        # 1. Validación de seguridad
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"La imagen no fue encontrada en la ruta: {image_path}")

        # 2. Inferencia con la red neuronal (YOLOv11)
        # Retorna el objeto crudo de Ultralytics
        raw_result = self.ai_service.predict(image_path)
        
        # 3. Formateo de datos (Desacoplamiento de Ultralytics)
        # Convierte los tensores a diccionarios y matrices de Numpy
        formatted_data = self.ai_service.get_formatted_results(raw_result)
        
        # 4. Cálculo del Índice de Área Afectada (IAA)
        if formatted_data is None:
            # Si no hay enfermedad detectada o la hoja está 100% sana sin detecciones claras
            metrics = {"iaa": 0.0, "total_area_px": 0, "affected_area_px": 0, "pathogens": {}}
        else:
            # 🟢 AQUÍ ESTÁ EL CAMBIO: Le pasamos 'image_path' a la calculadora híbrida
            metrics = self.calculator.calculate_metrics(formatted_data, image_path)

        # 5. Guardar registro en la Base de Datos
        iaa_value = metrics.get('iaa', 0.0)
        fecha_actual = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        try:
            # Asumimos que tu clase DBManager o Repository tiene un método así.
            # Si se llama diferente, ajústalo a tu código real (ej. db.insertar_registro)
            self.repository.save_record(
                fecha=fecha_actual, 
                iaa=iaa_value, 
                path=image_path
            )
        except Exception as e:
            print(f"⚠️ Advertencia: Error al guardar en la base de datos. Detalles: {e}")

        # 6. Retorno de empaquetado para la Interfaz Gráfica (PyQt6 o Flutter en tu caso)
        return {
            "status": "success",
            "image_path": image_path,
            "metrics": metrics,
            "formatted_data": formatted_data
        }