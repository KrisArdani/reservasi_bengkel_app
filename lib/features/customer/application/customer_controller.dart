import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/kendaraan_model.dart';
import '../../../core/models/reservasi_model.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../auth/application/auth_controller.dart';

part 'customer_controller.g.dart';

class CustomerState {
  final List<KendaraanModel> kendaraan;
  final List<ReservasiModel> reservasi;
  final bool isLoading;
  final String? error;

  const CustomerState({
    this.kendaraan = const [],
    this.reservasi = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerState copyWith({
    List<KendaraanModel>? kendaraan,
    List<ReservasiModel>? reservasi,
    bool? isLoading,
    String? error,
  }) {
    return CustomerState(
      kendaraan: kendaraan ?? this.kendaraan,
      reservasi: reservasi ?? this.reservasi,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class CustomerController extends _$CustomerController {
  late final CustomerRepository _repository;

  @override
  CustomerState build() {
    _repository = CustomerRepository();
    // Fetch data initially if logged in as Pelanggan
    final pelanggan = ref.read(authControllerProvider).pelanggan;
    if (pelanggan != null) {
      // Defer loading to avoid changing state during build
      Future.microtask(() => loadData());
    }
    return const CustomerState();
  }

  Future<void> loadData() async {
    final pelanggan = ref.read(authControllerProvider).pelanggan;
    if (pelanggan == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final kendaraanList = await _repository.getKendaraan(pelanggan.idPelanggan);
      final reservasiList = await _repository.getReservasi(pelanggan.idPelanggan);
      
      state = state.copyWith(
        kendaraan: kendaraanList,
        reservasi: reservasiList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addKendaraan({
    required String merk,
    required String tipe,
    required String platNomer,
  }) async {
    final pelanggan = ref.read(authControllerProvider).pelanggan;
    if (pelanggan == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addKendaraan(
        idPelanggan: pelanggan.idPelanggan,
        merk: merk,
        tipe: tipe,
        platNomer: platNomer,
      );
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateKendaraan({
    required int idKendaraan,
    required String merk,
    required String tipe,
    required String platNomer,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateKendaraan(
        idKendaraan: idKendaraan,
        merk: merk,
        tipe: tipe,
        platNomer: platNomer,
      );
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteKendaraan(int idKendaraan) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteKendaraan(idKendaraan);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> addReservasi({
    required int idKendaraan,
    required String tanggal,
    required String jam,
    required String keluhan,
  }) async {
    final pelanggan = ref.read(authControllerProvider).pelanggan;
    if (pelanggan == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addReservasi(
        idPelanggan: pelanggan.idPelanggan,
        idKendaraan: idKendaraan,
        tanggal: tanggal,
        jam: jam,
        keluhan: keluhan,
      );
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> actionReschedule(int idReservasi, bool isAccepted) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.actionReschedule(idReservasi, isAccepted);
      await loadData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
