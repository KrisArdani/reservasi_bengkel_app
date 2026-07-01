import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/reservasi_detail_model.dart';
import '../../../core/models/montir_model.dart';
import '../../../core/repositories/admin_repository.dart';

part 'admin_controller.g.dart';

class AdminState {
  final List<ReservasiDetailModel> reservasi;
  final List<MontirModel> montir;
  final List<Map<String, dynamic>> montirWorkload;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.reservasi = const [],
    this.montir = const [],
    this.montirWorkload = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<ReservasiDetailModel>? reservasi,
    List<MontirModel>? montir,
    List<Map<String, dynamic>>? montirWorkload,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      reservasi: reservasi ?? this.reservasi,
      montir: montir ?? this.montir,
      montirWorkload: montirWorkload ?? this.montirWorkload,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class AdminController extends _$AdminController {
  late final AdminRepository _repository;

  @override
  AdminState build() {
    _repository = AdminRepository();
    Future.microtask(() => loadData());
    return const AdminState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reservasiList = await _repository.getAllReservasi();
      final montirList = await _repository.getAllMontir();
      final workloadList = await _repository.getMontirWorkload();
      
      state = state.copyWith(
        reservasi: reservasiList,
        montir: montirList,
        montirWorkload: workloadList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> assignMontir(int idReservasi, int idMontir) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.assignMontir(idReservasi, idMontir);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> proposeReschedule(int idReservasi, String newTanggal, String newJam) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.proposeReschedule(idReservasi, newTanggal, newJam);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateStatus(int idReservasi, String newStatus) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateStatus(idReservasi, newStatus);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> addMontir(String nama, String keahlian) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addMontir(nama, keahlian);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateMontir(int idMontir, String nama, String keahlian) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateMontir(idMontir, nama, keahlian);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteMontir(int idMontir) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteMontir(idMontir);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> exportCsv(List<ReservasiDetailModel> listToExport) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      List<List<dynamic>> rows = [];
      // Header
      rows.add([
        'No Reservasi', 'Tanggal', 'Jam', 'Pelanggan', 'No HP', 
        'Kendaraan', 'Plat Nomor', 'Montir', 'Status', 'Keluhan'
      ]);

      for (var res in listToExport) {
        rows.add([
          'RSV-${res.idReservasi.toString().padLeft(4, '0')}',
          res.tanggal,
          res.jam,
          res.namaPelanggan,
          res.noHp,
          '${res.merkKendaraan} ${res.tipeKendaraan}',
          res.platNomer,
          res.namaMontir ?? '-',
          res.status,
          res.keluhan ?? '-',
        ]);
      }

      String csvData = Csv().encode(rows);
      
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/laporan_reservasi_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'Laporan Reservasi Bengkel'));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
