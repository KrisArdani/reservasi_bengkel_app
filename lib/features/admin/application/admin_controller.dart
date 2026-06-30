import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/reservasi_detail_model.dart';
import '../../../core/models/montir_model.dart';
import '../../../core/repositories/admin_repository.dart';

part 'admin_controller.g.dart';

class AdminState {
  final List<ReservasiDetailModel> reservasi;
  final List<MontirModel> montir;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.reservasi = const [],
    this.montir = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<ReservasiDetailModel>? reservasi,
    List<MontirModel>? montir,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      reservasi: reservasi ?? this.reservasi,
      montir: montir ?? this.montir,
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
      
      state = state.copyWith(
        reservasi: reservasiList,
        montir: montirList,
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
}
