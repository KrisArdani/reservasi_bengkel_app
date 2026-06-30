import 'package:equatable/equatable.dart';

class ReservasiModel extends Equatable {
  final int idReservasi;
  final int idPelanggan;
  final int idKendaraan;
  final int? idMontir;
  final String tanggal;
  final String jam;
  final String? keluhan;
  final String status;

  const ReservasiModel({
    required this.idReservasi,
    required this.idPelanggan,
    required this.idKendaraan,
    this.idMontir,
    required this.tanggal,
    required this.jam,
    this.keluhan,
    required this.status,
  });

  factory ReservasiModel.fromMap(Map<String, dynamic> map) {
    return ReservasiModel(
      idReservasi: map['id_reservasi'] as int,
      idPelanggan: map['id_pelanggan'] as int,
      idKendaraan: map['id_kendaraan'] as int,
      idMontir: map['id_montir'] as int?,
      tanggal: map['tanggal'] as String,
      jam: map['jam'] as String,
      keluhan: map['keluhan'] as String?,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_reservasi': idReservasi,
      'id_pelanggan': idPelanggan,
      'id_kendaraan': idKendaraan,
      'id_montir': idMontir,
      'tanggal': tanggal,
      'jam': jam,
      'keluhan': keluhan,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        idReservasi,
        idPelanggan,
        idKendaraan,
        idMontir,
        tanggal,
        jam,
        keluhan,
        status,
      ];
}
