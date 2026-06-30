import 'package:equatable/equatable.dart';

class KendaraanModel extends Equatable {
  final int idKendaraan;
  final int idPelanggan;
  final String merk;
  final String tipe;
  final String platNomer;

  const KendaraanModel({
    required this.idKendaraan,
    required this.idPelanggan,
    required this.merk,
    required this.tipe,
    required this.platNomer,
  });

  factory KendaraanModel.fromMap(Map<String, dynamic> map) {
    return KendaraanModel(
      idKendaraan: map['id_kendaraan'] as int,
      idPelanggan: map['id_pelanggan'] as int,
      merk: map['merk'] as String,
      tipe: map['tipe'] as String,
      platNomer: map['plat_nomer'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_kendaraan': idKendaraan,
      'id_pelanggan': idPelanggan,
      'merk': merk,
      'tipe': tipe,
      'plat_nomer': platNomer,
    };
  }

  @override
  List<Object?> get props => [idKendaraan, idPelanggan, merk, tipe, platNomer];
}
