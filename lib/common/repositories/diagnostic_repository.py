import json
import sqlite3
from datetime import datetime

class DiagnosticRepository:
    """
    Gestiona el almacenamiento y recuperación de diagnósticos en la base de datos.
    Asegura la integridad referencial entre imágenes, diagnósticos y hallazgos.
    """
    def __init__(self, db_manager):
        self.db = db_manager

    def save_full_diagnosis(self, image_path, iaa_results):
        """
        Guarda un diagnóstico completo de forma atómica.
        :param image_path: Ruta del archivo analizado.
        :param iaa_results: Diccionario generado por SeverityCalculatorService.
        """
        try:
            cursor = self.db.conn.cursor()
            
            # 1. Registrar la imagen en la tabla 'images'
            cursor.execute(
                "INSERT INTO images (file_path, width, height) VALUES (?, ?, ?)",
                (image_path, 0, 0) # Las dimensiones se pueden actualizar después con OpenCV
            )
            image_id = cursor.lastrowid

            # 2. Registrar el diagnóstico principal
            cursor.execute(
                "INSERT INTO diagnostics (image_id, iaa_index, total_leaf_area) VALUES (?, ?, ?)",
                (image_id, iaa_results['iaa'], iaa_results['leaf_area'])
            )
            diagnostic_id = cursor.lastrowid

            # 3. Registrar cada hallazgo (mancha/patógeno) detectado
            for detail in iaa_results['details']:
                # Convertimos datos adicionales (como polígonos si los hubiera) a JSON
                cursor.execute(
                    """INSERT INTO findings 
                       (diagnostic_id, pathogen_id, confidence, area_px) 
                       VALUES (?, (SELECT id FROM pathogens WHERE name_ru = ?), ?, ?)""",
                    (diagnostic_id, detail['label'], 0.0, detail['pixels'])
                )

            self.db.conn.commit()
            return diagnostic_id

        except Exception as e:
            self.db.conn.rollback()
            print(f"Error al persistir el diagnóstico: {e}")
            return None

    def get_history(self):
        """Recupera el historial de diagnósticos para la capa de Analítica."""
        query = """
            SELECT d.id, d.timestamp, d.iaa_index, i.file_path 
            FROM diagnostics d
            JOIN images i ON d.image_id = i.id
            ORDER BY d.timestamp DESC
        """
        cursor = self.db.conn.cursor()
        cursor.execute(query)
        return cursor.fetchall()