import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Inicializar para Windows/Desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "vitisguard.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE historial (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT,
            diagnostico TEXT,
            severidad TEXT,
            indice TEXT,
            ruta_imagen TEXT,
            area_total INTEGER,
            area_afectada INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertarAnalisis(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('historial', row);
  }

  Future<List<Map<String, dynamic>>> obtenerHistorial() async {
    Database db = await database;
    return await db.query('historial', orderBy: "id DESC");
  }
}
