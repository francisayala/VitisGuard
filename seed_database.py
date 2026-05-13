from lib.common.database.db_manager import DBManager

def seed_pathogens():
    db = DBManager()
    cursor = db.conn.cursor()
    
    # Lista de patógenos según las clases de tu modelo YOLOv11
    # Formato: (Nombre en Ruso, Nombre Científico/Latín, Color HEX para la UI)
    pathogens = [
        ('Милдью', 'Plasmopara viticola', '#FF0000'),
        ('Оидиум', 'Uncinula necator', '#00FF00'),
        ('Черная гниль', 'Guignardia bidwellii', '#0000FF'),
        ('Здоровая лист', 'Healthy Leaf', '#FFFF00')
    ]
    
    try:
        cursor.executemany(
            "INSERT INTO pathogens (name_ru, name_lat, color_hex) VALUES (?, ?, ?)",
            pathogens
        )
        db.conn.commit()
        print("✅ Catálogo de patógenos inicializado correctamente.")
    except Exception as e:
        print(f"❌ Error al inicializar patógenos: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_pathogens()