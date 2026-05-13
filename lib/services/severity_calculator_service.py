import numpy as np
import cv2

class SeverityCalculatorService:
    def __init__(self, healthy_label='Healthy'):
        self.healthy_label = healthy_label

    def _get_leaf_mask(self, img):
        """
        Segmentación simple pero estable de hoja.
        Mejor que Otsu en muchos casos reales.
        """
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        # rango verde (ajustable según dataset)
        lower_green = np.array([25, 40, 40])
        upper_green = np.array([95, 255, 255])

        mask = cv2.inRange(hsv, lower_green, upper_green)

        # limpieza de ruido
        kernel = np.ones((5, 5), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

        return mask > 0

    def calculate_metrics(self, formatted_results, image_path):
        """
        Severidad correcta: intersección enfermedad ∩ hoja
        """

        if not formatted_results or not formatted_results['masks']:
            return {
                "iaa": 0.0,
                "total_area_px": 0,
                "affected_area_px": 0,
                "pathogens": {}
            }

        # ============================================================
        # 🟢 1. IMAGEN BASE (UN SOLO ESPACIO DE REFERENCIA)
        # ============================================================
        img = cv2.imread(image_path)
        img_h, img_w = img.shape[:2]

        # ============================================================
        # 🟢 2. HOJA (OpenCV robusto)
        # ============================================================
        leaf_mask = self._get_leaf_mask(img)

        # ============================================================
        # 🔴 3. YOLO - ENFERMEDAD (alineada al tamaño real)
        # ============================================================
        disease_canvas = np.zeros((img_h, img_w), dtype=bool)
        disease_by_class = {}

        for mask, label in zip(formatted_results['masks'], formatted_results['labels']):

            if label == self.healthy_label:
                continue

            # resize correcto: máscara → imagen original
            mask_resized = cv2.resize(mask.astype(np.uint8), (img_w, img_h)) > 0

            disease_canvas |= mask_resized

            disease_by_class[label] = disease_by_class.get(label, 0) + int(np.sum(mask_resized))

        # ============================================================
        # 🧠 4. INTERSECCIÓN REAL (CLAVE)
        # ============================================================
        disease_on_leaf = disease_canvas & leaf_mask

        affected_pixels = int(np.sum(disease_on_leaf))
        total_leaf_pixels = int(np.sum(leaf_mask))

        # ============================================================
        # 📊 5. MÉTRICA FINAL
        # ============================================================
        iaa = 0.0
        if total_leaf_pixels > 0:
            iaa = (affected_pixels / total_leaf_pixels) * 100

        iaa = float(np.clip(iaa, 0, 100))

        # ruido mínimo
        if iaa < 1.0:
            iaa = 0.0
            affected_pixels = 0
            disease_by_class = {}

        return {
            "iaa": round(iaa, 2),
            "total_area_px": total_leaf_pixels,
            "affected_area_px": affected_pixels,
            "pathogens": disease_by_class
        }