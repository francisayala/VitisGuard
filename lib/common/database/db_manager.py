import sqlite3
import os

class DBManager:
    """
    Clase encargada de la persistencia de datos. 
    Gestiona la conexión, creación de tablas y operaciones CRUD 
    (Create, Read, Update, Delete) para el historial de VitisGuard.
    """
    def __init__(self, db_name="vitisguard_history.db"):
        # 1. Aseguramos que la carpeta 'data' exista para evitar errores
        self.db_dir = "data"
        if not os.path.exists(self.db_dir):
            os.makedirs(self.db_dir)

        # 2. Definimos la ruta completa de la base de datos
        self.db_path = os.path.join(self.db_dir, db_name)
        
        # 3. Establecemos la conexión
        try:
            self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
            self.cursor = self.conn.cursor()
            self._create_tables()
            print(f"✅ Base de datos conectada en: {self.db_path}")
        except sqlite3.Error as e:
            print(f"❌ Error al conectar a la base de datos: {e}")

    def _create_tables(self):
        """
        Crea la estructura de tablas si no existe.
        Definimos tipos de datos precisos para el rigor académico:
        - fecha: TEXT (Formato ISO8601)
        - iaa: REAL (Para almacenar decimales del porcentaje)
        - image_path: TEXT (Ruta absoluta o relativa del archivo analizado)
        """
        query = '''
        CREATE TABLE IF NOT EXISTS historial (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            iaa REAL NOT NULL,
            image_path TEXT NOT NULL
        )
        '''
        self.cursor.execute(query)
        self.conn.commit()

    def save_record(self, fecha, iaa, path):
        """
        Inserta un nuevo registro de inspección en la tabla historial.
        """
        query = "INSERT INTO historial (fecha, iaa, image_path) VALUES (?, ?, ?)"
        try:
            self.cursor.execute(query, (fecha, iaa, path))
            self.conn.commit()
            print(f"💾 Registro guardado: IAA {iaa}%")
        except sqlite3.Error as e:
            print(f"❌ Error al guardar registro: {e}")

    def get_history(self):
        """
        Recupera todos los registros ordenados del más reciente al más antiguo.
        """
        query = "SELECT * FROM historial ORDER BY id DESC"
        try:
            self.cursor.execute(query)
            return self.cursor.fetchall()
        except sqlite3.Error as e:
            print(f"❌ Error al obtener historial: {e}")
            return []

    def delete_record(self, record_id):
        """
        Permite eliminar un registro específico (útil para la interfaz de usuario).
        """
        query = "DELETE FROM historial WHERE id = ?"
        try:
            self.cursor.execute(query, (record_id,))
            self.conn.commit()
            print(f"🗑️ Registro {record_id} eliminado.")
        except sqlite3.Error as e:
            print(f"❌ Error al eliminar registro: {e}")

    def close(self):
        """Cierra la conexión de forma segura."""
        if self.conn:
            self.conn.close()
            print("🔌 Conexión a la base de datos cerrada.")