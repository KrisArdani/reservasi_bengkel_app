import '../database/database_helper.dart';
import '../models/kendaraan_model.dart';
import '../models/reservasi_model.dart';
import 'package:intl/intl.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- KENDARAAN ---

  Future<List<KendaraanModel>> getKendaraan(int idPelanggan) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kendaraan',
      where: 'id_pelanggan = ?',
      whereArgs: [idPelanggan],
    );

    return List.generate(maps.length, (i) {
      return KendaraanModel.fromMap(maps[i]);
    });
  }

  Future<KendaraanModel> addKendaraan({
    required int idPelanggan,
    required String merk,
    required String tipe,
    required String platNomer,
  }) async {
    final db = await _dbHelper.database;
    
    // Validate unique plat_nomer
    final existing = await db.query(
      'kendaraan',
      where: 'plat_nomer = ?',
      whereArgs: [platNomer],
    );
    if (existing.isNotEmpty) {
      throw Exception('Plat Nomor sudah terdaftar');
    }

    final id = await db.insert('kendaraan', {
      'id_pelanggan': idPelanggan,
      'merk': merk,
      'tipe': tipe,
      'plat_nomer': platNomer,
    });

    return KendaraanModel(
      idKendaraan: id,
      idPelanggan: idPelanggan,
      merk: merk,
      tipe: tipe,
      platNomer: platNomer,
    );
  }

  Future<void> updateKendaraan({
    required int idKendaraan,
    required String merk,
    required String tipe,
    required String platNomer,
  }) async {
    final db = await _dbHelper.database;
    
    // Validate unique plat_nomer excluding current vehicle
    final existing = await db.query(
      'kendaraan',
      where: 'plat_nomer = ? AND id_kendaraan != ?',
      whereArgs: [platNomer, idKendaraan],
    );
    if (existing.isNotEmpty) {
      throw Exception('Plat Nomor sudah terdaftar di kendaraan lain');
    }

    await db.update(
      'kendaraan',
      {
        'merk': merk,
        'tipe': tipe,
        'plat_nomer': platNomer,
      },
      where: 'id_kendaraan = ?',
      whereArgs: [idKendaraan],
    );
  }

  Future<void> deleteKendaraan(int idKendaraan) async {
    final db = await _dbHelper.database;
    
    // Cek apakah ada reservasi aktif
    final reservasi = await db.query(
      'reservasi',
      where: 'id_kendaraan = ? AND status IN (?, ?, ?, ?)',
      whereArgs: [idKendaraan, 'Menunggu Konfirmasi', 'Dikonfirmasi', 'Reschedule Diusulkan', 'Dalam Proses'],
    );
    
    if (reservasi.isNotEmpty) {
      throw Exception('Tidak bisa menghapus kendaraan yang masih memiliki reservasi aktif');
    }

    await db.delete(
      'kendaraan',
      where: 'id_kendaraan = ?',
      whereArgs: [idKendaraan],
    );
  }

  // --- RESERVASI ---

  Future<List<ReservasiModel>> getReservasi(int idPelanggan) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT r.*, m.nama as nama_montir
      FROM reservasi r
      LEFT JOIN montir m ON r.id_montir = m.id_montir
      WHERE r.id_pelanggan = ?
      ORDER BY r.tanggal DESC, r.jam DESC
    ''', [idPelanggan]);

    return List.generate(maps.length, (i) {
      return ReservasiModel.fromMap(maps[i]);
    });
  }

  Future<ReservasiModel> addReservasi({
    required int idPelanggan,
    required int idKendaraan,
    required String tanggal,
    required String jam,
    required String keluhan,
  }) async {
    final db = await _dbHelper.database;

    // Business Rule: Tanggal tidak boleh lampau
    final chosenDate = DateFormat('yyyy-MM-dd').parse(tanggal);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (chosenDate.isBefore(today)) {
      throw Exception('Tidak bisa memilih tanggal di masa lalu');
    }

    // Business Rule: Double booking untuk kendaraan yang sama
    final existingBooking = await db.query(
      'reservasi',
      where: 'id_kendaraan = ? AND status IN (?, ?, ?, ?)',
      whereArgs: [idKendaraan, 'Menunggu Konfirmasi', 'Dikonfirmasi', 'Reschedule Diusulkan', 'Dalam Proses'],
    );
    if (existingBooking.isNotEmpty) {
      throw Exception('Kendaraan ini masih memiliki reservasi aktif');
    }

    final id = await db.insert('reservasi', {
      'id_pelanggan': idPelanggan,
      'id_kendaraan': idKendaraan,
      'tanggal': tanggal,
      'jam': jam,
      'keluhan': keluhan,
      'status': 'Menunggu Konfirmasi',
    });

    return ReservasiModel(
      idReservasi: id,
      idPelanggan: idPelanggan,
      idKendaraan: idKendaraan,
      tanggal: tanggal,
      jam: jam,
      keluhan: keluhan,
      status: 'Menunggu Konfirmasi',
    );
  }
  
  // Reschedule Action by Customer
  Future<void> actionReschedule(int idReservasi, bool isAccepted) async {
    final db = await _dbHelper.database;
    final status = isAccepted ? 'Dikonfirmasi' : 'Dibatalkan';
    await db.update(
      'reservasi',
      {'status': status},
      where: 'id_reservasi = ?',
      whereArgs: [idReservasi],
    );
  }
}
