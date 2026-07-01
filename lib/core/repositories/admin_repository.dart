import '../database/database_helper.dart';
import '../models/reservasi_detail_model.dart';
import '../models/montir_model.dart';

class AdminRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ReservasiDetailModel>> getAllReservasi() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        r.id_reservasi, r.tanggal, r.jam, r.keluhan, r.status, r.id_montir,
        p.nama as nama_pelanggan, p.no_hp,
        k.merk, k.tipe, k.plat_nomer,
        m.nama as nama_montir
      FROM reservasi r
      JOIN pelanggan p ON r.id_pelanggan = p.id_pelanggan
      JOIN kendaraan k ON r.id_kendaraan = k.id_kendaraan
      LEFT JOIN montir m ON r.id_montir = m.id_montir
      ORDER BY r.tanggal DESC, r.jam DESC
    ''');

    return List.generate(maps.length, (i) {
      return ReservasiDetailModel.fromMap(maps[i]);
    });
  }

  Future<List<MontirModel>> getAllMontir() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('montir');
    
    return List.generate(maps.length, (i) {
      return MontirModel.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getMontirWorkload() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.id_montir, m.nama, m.keahlian, 
             COUNT(r.id_reservasi) as jumlah_tugas
      FROM montir m
      LEFT JOIN reservasi r ON m.id_montir = r.id_montir 
        AND r.status IN ('Dikonfirmasi', 'Proses', 'Dalam Proses')
      GROUP BY m.id_montir, m.nama, m.keahlian
      ORDER BY jumlah_tugas DESC
    ''');
    return maps;
  }

  Future<void> addMontir(String nama, String keahlian) async {
    final db = await _dbHelper.database;
    await db.insert('montir', {
      'nama': nama,
      'keahlian': keahlian,
    });
  }

  Future<void> updateMontir(int idMontir, String nama, String keahlian) async {
    final db = await _dbHelper.database;
    await db.update(
      'montir',
      {'nama': nama, 'keahlian': keahlian},
      where: 'id_montir = ?',
      whereArgs: [idMontir],
    );
  }

  Future<void> deleteMontir(int idMontir) async {
    final db = await _dbHelper.database;
    
    // Check for active reservations
    final reservasi = await db.query(
      'reservasi',
      where: 'id_montir = ? AND status IN (?, ?, ?, ?)',
      whereArgs: [idMontir, 'Menunggu Konfirmasi', 'Dikonfirmasi', 'Reschedule Diusulkan', 'Dalam Proses'],
    );
    
    if (reservasi.isNotEmpty) {
      throw Exception('Tidak bisa menghapus montir yang memiliki reservasi aktif');
    }
    
    await db.delete('montir', where: 'id_montir = ?', whereArgs: [idMontir]);
  }

  Future<void> assignMontir(int idReservasi, int idMontir) async {
    final db = await _dbHelper.database;
    
    // Validate if montir is available
    final reservasi = await db.query('reservasi', where: 'id_reservasi = ?', whereArgs: [idReservasi]);
    if (reservasi.isEmpty) return;
    
    final tanggal = reservasi.first['tanggal'];
    final jam = reservasi.first['jam'];

    final bentrok = await db.query(
      'reservasi',
      where: 'id_montir = ? AND tanggal = ? AND jam = ? AND status IN (?, ?, ?)',
      whereArgs: [idMontir, tanggal, jam, 'Dikonfirmasi', 'Proses', 'Dalam Proses'],
    );

    if (bentrok.isNotEmpty) {
      throw Exception('Montir sudah ditugaskan pada reservasi lain di jadwal ini');
    }

    await db.update(
      'reservasi',
      {'id_montir': idMontir, 'status': 'Dikonfirmasi'},
      where: 'id_reservasi = ?',
      whereArgs: [idReservasi],
    );
  }

  Future<void> proposeReschedule(int idReservasi, String newTanggal, String newJam) async {
    final db = await _dbHelper.database;
    await db.update(
      'reservasi',
      {
        'tanggal': newTanggal,
        'jam': newJam,
        'status': 'Reschedule Diusulkan'
      },
      where: 'id_reservasi = ?',
      whereArgs: [idReservasi],
    );
  }

  Future<void> updateStatus(int idReservasi, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'reservasi',
      {'status': status},
      where: 'id_reservasi = ?',
      whereArgs: [idReservasi],
    );
  }
}
