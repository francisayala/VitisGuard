import numpy as np
import cv2

class SeverityCalculatorService:
    def __init__(self, healthy_label='Healthy'):
        # En esta nueva arquitectura, la clase Healthy de YOLO ya no se usa 
        # para matemáticas, pero la mantenemos por si quieres mostrarla.
        self.healthy_label = healthy_label

    def calculate_metrics(self, formatted_results, image_path):
        """
        Calcula la severidad híbrida: YOLOv11 (Enfermedad) + OpenCV (Área Total).
        """
        if not formatted_results or not formatted_results['masks']:
            return {"iaa": 0.0, "total_area_px": 0, "affected_area_px": 0, "pathogens": {}}

        # ====================================================================
        # 🟢 FASE 1: OpenCV - Cálculo del área total de la hoja real
        # ====================================================================
        # Leemos la imagen original
        img = cv2.imread(image_path)
        
        # Convertimos a escala de grises
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Aplicamos un filtro Gaussiano para reducir ruido fotográfico
        blur = cv2.GaussianBlur(gray, (5, 5), 0)
        
        # Usamos el algoritmo de Otsu para separar la hoja del fondo automáticamente
        # Invertimos (THRESH_BINARY_INV) para que la hoja sea blanca (píxeles a contar)
        _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
        
        # Contamos los píxeles que pertenecen a la hoja
        total_leaf_pixels = int(np.sum(thresh == 255))

        # ====================================================================
        # 🔴 FASE 2: YOLO - Cálculo del área de la enfermedad
        # ====================================================================
        first_mask = formatted_results['masks'][0]
        height, width = first_mask.shape
        disease_canvas = np.zeros((height, width), dtype=bool)
        disease_pixels_by_class = {}

        for mask, label in zip(formatted_results['masks'], formatted_results['labels']):
            if label != self.healthy_label:
                binary_mask = mask > 0
                
                # Unificamos las máscaras enfermas para evitar contar píxeles duplicados
                disease_canvas = np.logical_or(disease_canvas, binary_mask)
                
                # Registro por patógeno
                count = int(np.sum(binary_mask))
                disease_pixels_by_class[label] = disease_pixels_by_class.get(label, 0) + count

        # Contamos los píxeles reales de enfermedad (sin duplicados)
        affected_pixels = int(np.sum(disease_canvas))

        # ====================================================================
        # 🧠 FASE 3: Matemática Científica
        # ====================================================================
        iaa = 0.0
        if total_leaf_pixels > 0:
            iaa = (affected_pixels / total_leaf_pixels) * 100.0

        # Blindaje matemático natural
        iaa = min(iaa, 100.0)

        # Filtro de ruido visual (Ignorar si es menor a 1%)
        if iaa < 1.0:
            iaa = 0.0
            affected_pixels = 0
            disease_pixels_by_class = {}

        return {
            "iaa": round(iaa, 2),
            "total_area_px": total_leaf_pixels,
            "affected_area_px": affected_pixels,
            "pathogens": disease_pixels_by_class 
        }