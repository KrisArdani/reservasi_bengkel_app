import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/pelanggan_model.dart';
import '../../../core/repositories/auth_repository.dart';

part 'auth_controller.g.dart';

class AuthState {
  final UserModel? user;
  final PelangganModel? pelanggan;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.pelanggan,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    PelangganModel? pelanggan,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      pelanggan: pelanggan ?? this.pelanggan,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null intentionally
    );
  }
}

@riverpod
class AuthController extends _$AuthController {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = AuthRepository();
    return const AuthState();
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        PelangganModel? pelanggan;
        if (user.role == 'Pelanggan') {
          pelanggan = await _authRepository.getPelangganByUserId(user.idUser);
        }
        state = state.copyWith(
          user: user,
          pelanggan: pelanggan,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Username atau password salah',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String nama,
    String? alamat,
    String? noHp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.registerPelanggan(
        username: username,
        password: password,
        nama: nama,
        alamat: alamat,
        noHp: noHp,
      );
      
      final pelanggan = await _authRepository.getPelangganByUserId(user!.idUser);
      
      state = state.copyWith(
        user: user,
        pelanggan: pelanggan,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}
