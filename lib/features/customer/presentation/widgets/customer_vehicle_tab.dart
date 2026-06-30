import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/customer_controller.dart';

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

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kendaraan'),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await ref.read(customerControllerProvider.notifier).addKendaraan(
                          merk: _merkController.text,
                          tipe: _tipeController.text,
                          platNomer: _platController.text,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      _merkController.clear();
                      _tipeController.clear();
                      _platController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kendaraan berhasil ditambahkan')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
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
          ? const Center(child: CircularProgressIndicator())
          : kendaraanList.isEmpty
              ? const Center(child: Text('Belum ada kendaraan. Silakan tambah.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kendaraanList.length,
                  itemBuilder: (context, index) {
                    final k = kendaraanList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, size: 40),
                        title: Text('${k.merk} - ${k.tipe}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(k.platNomer),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        tooltip: 'Tambah Kendaraan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
