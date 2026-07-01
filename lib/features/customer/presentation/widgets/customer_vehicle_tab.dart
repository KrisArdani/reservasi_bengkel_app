import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/customer_controller.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../core/utils/app_feedback.dart';

class CustomerVehicleTab extends ConsumerStatefulWidget {
  const CustomerVehicleTab({super.key});

  @override
  ConsumerState<CustomerVehicleTab> createState() => _CustomerVehicleTabState();
}

class _CustomerVehicleTabState extends ConsumerState<CustomerVehicleTab> {
  final _formKey = GlobalKey<FormState>();
  final _merkController = TextEditingController();
  final _tipeController = TextEditingController();
  final _platController = TextEditingController();

  void _showAddVehicleDialog({int? editId}) {
    final isEdit = editId != null;
    final title = isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _merkController,
                  decoration: const InputDecoration(labelText: 'Merk (mis. Honda, Toyota)'),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tipeController,
                  decoration: const InputDecoration(labelText: 'Tipe (mis. Vario 150, Avanza)'),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _platController,
                  decoration: const InputDecoration(labelText: 'Nomor Polisi (mis. B 1234 CD)'),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppFeedback.playClick();
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                AppFeedback.playClick();
                if (_formKey.currentState!.validate()) {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  try {
                    if (isEdit) {
                      await ref.read(customerControllerProvider.notifier).updateKendaraan(
                            idKendaraan: editId,
                            merk: _merkController.text,
                            tipe: _tipeController.text,
                            platNomer: _platController.text,
                          );
                    } else {
                      await ref.read(customerControllerProvider.notifier).addKendaraan(
                            merk: _merkController.text,
                            tipe: _tipeController.text,
                            platNomer: _platController.text,
                          );
                    }
                    AppFeedback.playSuccess();
                    navigator.pop();
                    _merkController.clear();
                    _tipeController.clear();
                    _platController.clear();
                    messenger.showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Kendaraan berhasil diupdate' : 'Kendaraan berhasil ditambahkan')),
                    );
                  } catch (e) {
                    AppFeedback.playError();
                    messenger.showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerControllerProvider);
    final kendaraanList = customerState.kendaraan;

    return Scaffold(
      body: customerState.isLoading && kendaraanList.isEmpty
          ? _buildShimmerLoadingList()
          : kendaraanList.isEmpty
              ? const Center(child: Text('Belum ada kendaraan. Silakan tambah.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kendaraanList.length,
                  itemBuilder: (context, index) {
                    final k = kendaraanList[index];
                    final delayMs = (index * 40).clamp(0, 400);

                    return FadeInSlide(
                      delay: Duration(milliseconds: delayMs),
                      offset: const Offset(0, 15),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 4,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
                                leading: const Icon(Icons.directions_car, size: 40, color: Color(0xFF1D4ED8)),
                                title: Text('${k.merk} - ${k.tipe}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(k.platNomer),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        AppFeedback.playClick();
                                        _merkController.text = k.merk;
                                        _tipeController.text = k.tipe;
                                        _platController.text = k.platNomer;
                                        _showAddVehicleDialog(editId: k.idKendaraan);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        AppFeedback.playClick();
                                        final messenger = ScaffoldMessenger.of(context);
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Hapus Kendaraan'),
                                            content: const Text('Yakin ingin menghapus kendaraan ini?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  AppFeedback.playClick();
                                                  Navigator.pop(ctx, false);
                                                }, 
                                                child: const Text('Batal')
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () {
                                                  AppFeedback.playClick();
                                                  Navigator.pop(ctx, true);
                                                }, 
                                                child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true && mounted) {
                                          try {
                                            await ref.read(customerControllerProvider.notifier).deleteKendaraan(k.idKendaraan);
                                            AppFeedback.playSuccess();
                                            messenger.showSnackBar(const SnackBar(content: Text('Kendaraan berhasil dihapus')));
                                          } catch (e) {
                                            AppFeedback.playError();
                                            messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppFeedback.playClick();
          _merkController.clear();
          _tipeController.clear();
          _platController.clear();
          _showAddVehicleDialog();
        },
        tooltip: 'Tambah Kendaraan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmerLoadingList() {
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: ShimmerPlaceholder(
            height: 72,
            borderRadius: 12,
          ),
        );
      },
    );
  }
}
