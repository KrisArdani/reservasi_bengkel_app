import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/auth_controller.dart';
import '../../../core/utils/app_feedback.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).register(
        username: _usernameController.text,
        password: _passwordController.text,
        nama: _namaController.text,
        alamat: _alamatController.text,
        noHp: _noHpController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.error != null) {
        AppFeedback.playError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      } else if (next.user != null) {
        AppFeedback.playSuccess();
        context.go('/customer');
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2D2D2D), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Registrasi Pelanggan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan lengkapi data diri Anda di bawah ini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Nama Lengkap
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        hintText: 'Nama Lengkap Anda',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Alamat
                    const Text(
                      'Alamat',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        hintText: 'Alamat Tinggal Anda',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // No. Telepon
                    const Text(
                      'No. Telepon',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noHpController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 081234567890',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Username
                    const Text(
                      'Username',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Pilih Username',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Buat Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi Password
                    const Text(
                      'Konfirmasi Password',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Ulangi Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Buttons (Daftar & Batal)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    AppFeedback.playClick();
                                    _register();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Royal Blue
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Daftar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              AppFeedback.playClick();
                              context.go('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155), // Slate / Batal button color
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
