import 'package:equatable/equatable.dart';

class ReservasiDetailModel extends Equatable {
  final int idReservasi;
  final String namaPelanggan;
  final String noHp;
  final String merkKendaraan;
  final String tipeKendaraan;
  final String platNomer;
  final int? idMontir;
  final String? namaMontir;
  final String tanggal;
  final String jam;
  final String? keluhan;
  final String status;

  const ReservasiDetailModel({
    required this.idReservasi,
    required this.namaPelanggan,
    required this.noHp,
    required this.merkKendaraan,
    required this.tipeKendaraan,
    required this.platNomer,
    this.idMontir,
    this.namaMontir,
    required this.tanggal,
    required this.jam,
    this.keluhan,
    required this.status,
  });

  factory ReservasiDetailModel.fromMap(Map<String, dynamic> map) {
    return ReservasiDetailModel(
      idReservasi: map['id_reservasi'] as int,
      namaPelanggan: map['nama_pelanggan'] as String,
      noHp: map['no_hp'] as String? ?? '-',
      merkKendaraan: map['merk'] as String,
      tipeKendaraan: map['tipe'] as String,
      platNomer: map['plat_nomer'] as String,
      idMontir: map['id_montir'] as int?,
      namaMontir: map['nama_montir'] as String?,
      tanggal: map['tanggal'] as String,
      jam: map['jam'] as String,
      keluhan: map['keluhan'] as String?,
      status: map['status'] as String,
    );
  }

  @override
  List<Object?> get props => [
        idReservasi,
        namaPelanggan,
        noHp,
        merkKendaraan,
        tipeKendaraan,
        platNomer,
        idMontir,
        namaMontir,
        tanggal,
        jam,
        keluhan,
        status,
      ];
}
