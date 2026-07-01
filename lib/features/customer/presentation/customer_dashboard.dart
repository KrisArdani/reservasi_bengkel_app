import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';
import '../application/customer_controller.dart';
import 'widgets/customer_vehicle_tab.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/utils/app_feedback.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final pelanggan = authState.pelanggan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi Bengkel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppFeedback.playClick();
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: _buildBody(pelanggan?.nama ?? 'Pelanggan'),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          AppFeedback.playClick();
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Kendaraan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String nama) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(nama);
      case 1:
        return const CustomerVehicleTab();
      case 2:
        return _buildHistoryTab();
      default:
        return const Center(child: Text('Error'));
    }
  }

  Widget _buildHistoryTab() {
    final customerState = ref.watch(customerControllerProvider);
    
    // Filter history reservations (Selesai, Dibatalkan, Ditolak)
    final historyReservasi = customerState.reservasi.where((r) => 
      ['Selesai', 'Dibatalkan', 'Ditolak'].contains(r.status)
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Riwayat Servis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          if (customerState.isLoading && historyReservasi.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (historyReservasi.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Belum ada riwayat servis'),
                subtitle: Text('Reservasi yang telah selesai atau dibatalkan akan muncul di sini'),
              ),
            )
          else
            ...historyReservasi.map((res) {
              final vehicleMatches = customerState.kendaraan.where((k) => k.idKendaraan == res.idKendaraan);
              final merk = vehicleMatches.isNotEmpty ? vehicleMatches.first.merk : 'Tidak Diketahui';
              final tipe = vehicleMatches.isNotEmpty ? vehicleMatches.first.tipe : '';
              final platNomer = vehicleMatches.isNotEmpty ? vehicleMatches.first.platNomer : '-';
              
              Color statusColor;
              IconData statusIcon;
              if (res.status == 'Selesai') {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle_outline;
              } else {
                statusColor = Colors.red;
                statusIcon = Icons.cancel_outlined;
              }

              final index = historyReservasi.indexOf(res);
              final delayMs = (index * 40).clamp(0, 400);

              return FadeInSlide(
                delay: Duration(milliseconds: delayMs),
                offset: const Offset(0, 15),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFF2D2D2D),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Res-${res.idReservasi}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  res.status, 
                                  style: TextStyle(
                                    color: statusColor, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Kendaraan: $merk $tipe ($platNomer)'),
                        Text('Jadwal: ${res.tanggal} | ${res.jam}'),
                        if (res.namaMontir != null) ...[
                          const SizedBox(height: 4),
                          Text('Montir: ${res.namaMontir}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                        if (res.keluhan != null && res.keluhan!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Keluhan: ${res.keluhan}'),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHomeTab(String nama) {
    final customerState = ref.watch(customerControllerProvider);
    
    // Filter active reservations
    final activeReservasi = customerState.reservasi.where((r) => 
      ['Menunggu Konfirmasi', 'Dikonfirmasi', 'Reschedule Diusulkan', 'Dalam Proses', 'Proses'].contains(r.status)
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Selamat Datang, $nama!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.build_circle, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Servis Sekarang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      AppFeedback.playClick();
                      _showBookingDialog(context);
                    },
                    child: const Text('Buat Reservasi'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Antrean Aktif',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          if (customerState.isLoading && activeReservasi.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (activeReservasi.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.pending_actions),
                title: Text('Belum ada reservasi aktif'),
                subtitle: Text('Silakan buat reservasi servis baru'),
              ),
            )
          else
            ...activeReservasi.map((res) {
              final k = customerState.kendaraan.firstWhere((k) => k.idKendaraan == res.idKendaraan, orElse: () => throw Exception('Kendaraan tidak ditemukan'));
              final index = activeReservasi.indexOf(res);
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Res-${res.idReservasi}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Chip(
                                    label: Text(res.status, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: res.status == 'Reschedule Diusulkan' ? Colors.orange : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Kendaraan: ${k.merk} ${k.tipe} (${k.platNomer})'),
                              Text('Jadwal: ${res.tanggal} | ${res.jam}'),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  AppFeedback.playClick();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            const Text('Detail Reservasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            const Divider(),
                                            const SizedBox(height: 12),
                                            Text('No Reservasi: Res-${res.idReservasi}'),
                                            Text('Status: ${res.status}'),
                                            const SizedBox(height: 12),
                                            Text('Kendaraan: ${k.merk} ${k.tipe} (${k.platNomer})'),
                                            Text('Jadwal: ${res.tanggal} | ${res.jam}'),
                                            const SizedBox(height: 12),
                                            Text('Keluhan: ${res.keluhan ?? "-"}'),
                                            const SizedBox(height: 12),
                                            if (res.namaMontir != null)
                                              Text('Montir: ${res.namaMontir}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 24),
                                            ElevatedButton(
                                              onPressed: () {
                                                AppFeedback.playClick();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Tutup'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text('Lihat Detail'),
                              ),
                              if (res.status == 'Reschedule Diusulkan') ...[
                                  const Divider(),
                                  const Text('Admin mengusulkan jadwal di atas. Apakah Anda setuju?'),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          AppFeedback.playClick();
                                          ref.read(customerControllerProvider.notifier).actionReschedule(res.idReservasi, false);
                                        },
                                        child: const Text('Tolak & Batalkan', style: TextStyle(color: Colors.red)),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: () {
                                          AppFeedback.playClick();
                                          ref.read(customerControllerProvider.notifier).actionReschedule(res.idReservasi, true);
                                        },
                                        child: const Text('Setujui'),
                                      ),
                                    ],
                                  )
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    final customerState = ref.read(customerControllerProvider);
    if (customerState.kendaraan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tambahkan kendaraan terlebih dahulu di menu Kendaraan')),
      );
      setState(() {
        _currentIndex = 1;
      });
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const _BookingBottomSheet();
      },
    );
  }
}

class _BookingBottomSheet extends ConsumerStatefulWidget {
  const _BookingBottomSheet();

  @override
  ConsumerState<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends ConsumerState<_BookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedKendaraanId;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _keluhanController = TextEditingController();
  
  final List<String> _timeSlots = ['08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'];

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerControllerProvider);
    final kendaraanList = customerState.kendaraan;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Buat Reservasi Servis', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Kendaraan'),
                initialValue: _selectedKendaraanId,
                items: kendaraanList.map((k) {
                  return DropdownMenuItem(
                    value: k.idKendaraan,
                    child: Text('${k.merk} ${k.tipe} - ${k.platNomer}'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedKendaraanId = val;
                  });
                },
                validator: (val) => val == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          if (picked.weekday == DateTime.sunday) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bengkel tutup pada hari Minggu')));
                            }
                            return;
                          }
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tanggal Servis'),
                        child: Text(_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Pilih Tanggal'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Jam'),
                      initialValue: _selectedTime,
                      items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTime = val;
                        });
                      },
                      validator: (val) => val == null ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keluhanController,
                decoration: const InputDecoration(labelText: 'Keluhan / Detail Servis'),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  AppFeedback.playClick();
                  if (_formKey.currentState!.validate() && _selectedDate != null) {
                    try {
                      await ref.read(customerControllerProvider.notifier).addReservasi(
                        idKendaraan: _selectedKendaraanId!,
                        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        jam: _selectedTime!,
                        keluhan: _keluhanController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        AppFeedback.playSuccess();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservasi berhasil dibuat')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppFeedback.playError();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  } else if (_selectedDate == null) {
                    AppFeedback.playError();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal servis wajib dipilih')));
                  }
                },
                child: const Text('Simpan Reservasi'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
