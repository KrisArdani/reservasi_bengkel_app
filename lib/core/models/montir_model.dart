import 'package:equatable/equatable.dart';

class MontirModel extends Equatable {
  final int idMontir;
  final String nama;
  final String? keahlian;

  const MontirModel({
    required this.idMontir,
    required this.nama,
    this.keahlian,
  });

  factory MontirModel.fromMap(Map<String, dynamic> map) {
    return MontirModel(
      idMontir: map['id_montir'] as int,
      nama: map['nama'] as String,
      keahlian: map['keahlian'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_montir': idMontir,
      'nama': nama,
      'keahlian': keahlian,
    };
  }

  @override
  List<Object?> get props => [idMontir, nama, keahlian];
}
