import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reservasi_bengkel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pelanggan (
        id_pelanggan INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        nama TEXT NOT NULL,
        alamat TEXT,
        no_hp TEXT,
        FOREIGN KEY (id_user) REFERENCES user (id_user) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE kendaraan (
        id_kendaraan INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pelanggan INTEGER NOT NULL,
        merk TEXT NOT NULL,
        tipe TEXT NOT NULL,
        plat_nomer TEXT NOT NULL UNIQUE,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id_pelanggan) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE montir (
        id_montir INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        keahlian TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reservasi (
        id_reservasi INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pelanggan INTEGER NOT NULL,
        id_kendaraan INTEGER NOT NULL,
        id_montir INTEGER,
        tanggal TEXT NOT NULL,
        jam TEXT NOT NULL,
        keluhan TEXT,
        status TEXT NOT NULL,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id_pelanggan) ON DELETE CASCADE,
        FOREIGN KEY (id_kendaraan) REFERENCES kendaraan (id_kendaraan) ON DELETE CASCADE,
        FOREIGN KEY (id_montir) REFERENCES montir (id_montir) ON DELETE SET NULL
      )
    ''');

    // Insert initial data for Admin and Owner
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert Admin
    await db.insert('user', {
      'username': 'admin',
      'password': 'password123', // In real app, this should be hashed
      'role': 'Admin',
    });

    // Insert Owner (Kepala Bengkel)
    await db.insert('user', {
      'username': 'owner',
      'password': 'password123',
      'role': 'Kepala Bengkel',
    });

    // Insert sample mechanics
    await db.insert('montir', {'nama': 'Budi Montir', 'keahlian': 'Mesin'});
    await db.insert('montir', {'nama': 'Agus Knalpot', 'keahlian': 'Knalpot & Body'});
  }
}
