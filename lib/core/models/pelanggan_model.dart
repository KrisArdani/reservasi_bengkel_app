import 'package:equatable/equatable.dart';

class PelangganModel extends Equatable {
  final int idPelanggan;
  final int idUser;
  final String nama;
  final String? alamat;
  final String? noHp;

  const PelangganModel({
    required this.idPelanggan,
    required this.idUser,
    required this.nama,
    this.alamat,
    this.noHp,
  });

  factory PelangganModel.fromMap(Map<String, dynamic> map) {
    return PelangganModel(
      idPelanggan: map['id_pelanggan'] as int,
      idUser: map['id_user'] as int,
      nama: map['nama'] as String,
      alamat: map['alamat'] as String?,
      noHp: map['no_hp'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pelanggan': idPelanggan,
      'id_user': idUser,
      'nama': nama,
      'alamat': alamat,
      'no_hp': noHp,
    };
  }

  @override
  List<Object?> get props => [idPelanggan, idUser, nama, alamat, noHp];
}
