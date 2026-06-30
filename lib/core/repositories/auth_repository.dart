import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../models/pelanggan_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<UserModel?> login(String username, String password) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<PelangganModel?> getPelangganByUserId(int idUser) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'id_user = ?',
      whereArgs: [idUser],
    );

    if (maps.isNotEmpty) {
      return PelangganModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> registerPelanggan({
    required String username,
    required String password,
    required String nama,
    String? alamat,
    String? noHp,
  }) async {
    final db = await _dbHelper.database;
    
    // Check if username already exists
    final List<Map<String, dynamic>> existing = await db.query(
      'user',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) {
      throw Exception('Username sudah digunakan');
    }

    // Use transaction to ensure both user and pelanggan are created
    UserModel? newUser;
    await db.transaction((txn) async {
      final idUser = await txn.insert('user', {
        'username': username,
        'password': password, // Note: Should be hashed in production
        'role': 'Pelanggan',
      });

      await txn.insert('pelanggan', {
        'id_user': idUser,
        'nama': nama,
        'alamat': alamat,
        'no_hp': noHp,
      });

      newUser = UserModel(
        idUser: idUser,
        username: username,
        role: 'Pelanggan',
      );
    });

    return newUser;
  }
}
