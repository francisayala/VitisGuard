import numpy as np
from ultralytics import YOLO

class AIInferenceService:
    """
    Servicio de inferencia YOLOv11 para segmentación de enfermedades.
    """

    def __init__(self, model_path='assets/models/best.pt'):
        try:
            self.model = YOLO(model_path)
            print(f"✅ Modelo cargado correctamente desde {model_path}")
        except Exception as e:
            print(f"⚠️ Error cargando modelo: {e}")
            self.model = None

    def predict(self, image_path):
        if not self.model:
            return None

        results = self.model.predict(
            source=image_path,
            conf=0.50,
            save=False,
            retina_masks=True  # 🔥 IMPORTANTE: máscaras en resolución original
        )

        return results[0]

    def get_formatted_results(self, raw_result):
        if raw_result is None or raw_result.masks is None:
            return None

        formatted = {
            'masks': [],
            'labels': []
        }

        masks_data = raw_result.masks.data.cpu().numpy()
        class_ids = raw_result.boxes.cls.cpu().numpy()
        class_names = raw_result.names

        for i, mask in enumerate(masks_data):
            formatted['masks'].append(mask)
            label_id = int(class_ids[i])
            formatted['labels'].append(class_names[label_id])

        return formatted