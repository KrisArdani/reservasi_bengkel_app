import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/application/auth_controller.dart';
import '../application/admin_controller.dart';
import '../../../core/models/reservasi_detail_model.dart';
import '../../../core/widgets/diagonal_sidebar.dart';
import '../../../core/models/montir_model.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/shimmer_placeholder.dart';
import '../../../core/utils/app_feedback.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedMenuIndex = 0;

  // Navigation Menu Items for Admin
  final List<SidebarItem> _sidebarItems = const [
    SidebarItem(title: 'Dashboard', icon: Icons.dashboard, route: '/admin'),
    SidebarItem(title: 'Kelola Reservasi', icon: Icons.build, route: '/admin/kelola'),
    SidebarItem(title: 'Jadwal & Montir', icon: Icons.event_note, route: '/admin/jadwal'),
    SidebarItem(title: 'Beban Kerja Montir', icon: Icons.people_alt, route: '/admin/workload'),
    SidebarItem(title: 'Manajemen Montir', icon: Icons.manage_accounts, route: '/admin/montir'),
    SidebarItem(title: 'Laporan', icon: Icons.assignment, route: '/admin/laporan'),
  ];

  // Selected reservation to edit in "Jadwal & Montir" form
  ReservasiDetailModel? _activeReservasi;
  int? _selectedMontirId;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _keluhanController = TextEditingController();

  // Laporan Filters
  String _selectedPeriod = 'Semua';
  String _selectedStatus = 'Semua Status';
  DateTime _startDate = DateTime(2025, 1, 1);
  DateTime _endDate = DateTime(2030, 12, 31);

  // Queue Filters
  String _queueSearchQuery = '';
  String _queueFilterStatus = 'Semua Status';

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  void _loadReservasiToForm(ReservasiDetailModel res) {
    setState(() {
      _activeReservasi = res;
      _selectedMontirId = res.idMontir;
      _selectedDate = DateTime.parse(res.tanggal);
      _selectedTime = res.jam;
      _keluhanController.text = res.keluhan ?? '';
      _selectedMenuIndex = 2; // Jump to "Jadwal & Montir" tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final adminState = ref.watch(adminControllerProvider);
    final user = authState.user;
    final isDesktop = isDesktopLayout(context);

    final sidebar = DiagonalSidebar(
      avatarInitials: 'A',
      roleTitle: user?.username ?? 'Admin',
      roleSubtitle: 'Administrator',
      items: _sidebarItems,
      activeIndex: _selectedMenuIndex,
      onItemTap: (index) {
        AppFeedback.playClick();
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      onLogout: () {
        AppFeedback.playClick();
        ref.read(authControllerProvider.notifier).logout();
        context.go('/login');
      },
    );

    final mainContent = Container(
      color: const Color(0xFF121212),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: isDesktop ? 32 : 16,
      ),
      child: adminState.isLoading && adminState.reservasi.isEmpty
          ? _buildShimmerLoadingList()
          : _buildContentSection(adminState),
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            Expanded(child: mainContent),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(_sidebarItems[_selectedMenuIndex].title),
          backgroundColor: const Color(0xFF1D4ED8),
          foregroundColor: Colors.white,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        drawer: sidebar.buildMobileDrawer(context),
        body: mainContent,
      );
    }
  }

  Widget _buildContentSection(AdminState state) {
    switch (_selectedMenuIndex) {
      case 0: // Dashboard Quick View
      case 1: // Kelola Reservasi (Active Queue Cards)
        return _buildQueueCardsView(state);
      case 2: // Jadwal & Montir Form
        return _buildJadwalMontirSection(state);
      case 3: // Beban Kerja Montir
        return _buildWorkloadSection(state);
      case 4: // Manajemen Montir
        return _buildMontirSection(state);
      case 5: // Laporan
        return _buildLaporanSection(state);
      default:
        return const Center(child: Text('Section not found'));
    }
  }

  // --- TAB: BEBAN KERJA MONTIR ---
  Widget _buildWorkloadSection(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beban Kerja Montir',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: state.montirWorkload.isEmpty
              ? const Center(child: Text('Belum ada data montir atau tugas.'))
              : ListView.builder(
                  itemCount: state.montirWorkload.length,
                  itemBuilder: (context, index) {
                    final wl = state.montirWorkload[index];
                    final jumlahTugas = wl['jumlah_tugas'] as int;
                    final delayMs = (index * 50).clamp(0, 400);

                    return FadeInSlide(
                      delay: Duration(milliseconds: delayMs),
                      offset: const Offset(0, 15),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: jumlahTugas > 3 ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                            child: Text(
                              jumlahTugas.toString(), 
                              style: TextStyle(color: jumlahTugas > 3 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(wl['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(wl['keahlian'] ?? '-'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PulsingDot(color: jumlahTugas > 3 ? Colors.red : Colors.green),
                              const SizedBox(width: 8),
                              jumlahTugas > 3
                                  ? const Text('Sibuk', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                  : const Text('Tersedia', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB: MANAJEMEN MONTIR ---
  Widget _buildMontirSection(AdminState state) {
    final isDesktop = isDesktopLayout(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manajemen Montir',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Montir'),
                    onPressed: () {
                      AppFeedback.playClick();
                      _showMontirDialog();
                    },
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manajemen Montir',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Montir'),
                    onPressed: () {
                      AppFeedback.playClick();
                      _showMontirDialog();
                    },
                  ),
                ],
              ),
        const SizedBox(height: 24),
        Expanded(
          child: state.montir.isEmpty
              ? const Center(child: Text('Belum ada data montir.'))
              : ListView.builder(
                  itemCount: state.montir.length,
                  itemBuilder: (context, index) {
                    final m = state.montir[index];
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
                                leading: const Icon(Icons.person, size: 40, color: Color(0xFF1D4ED8)),
                                title: Text(m.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(m.keahlian ?? '-'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        AppFeedback.playClick();
                                        _showMontirDialog(montir: m);
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
                                            title: const Text('Hapus Montir'),
                                            content: const Text('Yakin ingin menghapus montir ini?'),
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
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true && mounted) {
                                          try {
                                            await ref.read(adminControllerProvider.notifier).deleteMontir(m.idMontir);
                                            AppFeedback.playSuccess();
                                            messenger.showSnackBar(const SnackBar(content: Text('Montir berhasil dihapus')));
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
        ),
      ],
    );
  }

  void _showMontirDialog({MontirModel? montir}) {
    final namaCtrl = TextEditingController(text: montir?.nama ?? '');
    final keahlianCtrl = TextEditingController(text: montir?.keahlian ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(montir == null ? 'Tambah Montir' : 'Edit Montir'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Montir'),
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: keahlianCtrl,
                  decoration: const InputDecoration(labelText: 'Keahlian (mis. Mesin, Kelistrikan)'),
                ),
              ],
            ),
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
              if (formKey.currentState!.validate()) {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                try {
                  if (montir == null) {
                    await ref.read(adminControllerProvider.notifier).addMontir(namaCtrl.text, keahlianCtrl.text);
                  } else {
                    await ref.read(adminControllerProvider.notifier).updateMontir(montir.idMontir, namaCtrl.text, keahlianCtrl.text);
                  }
                  AppFeedback.playSuccess();
                  navigator.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('Berhasil menyimpan montir')));
                } catch (e) {
                  AppFeedback.playError();
                  messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // --- TAB 1 & 2: KELOLA RESERVASI CARDS ---
  Widget _buildQueueCardsView(AdminState state) {
    // Filter logic
    final filteredQueue = state.reservasi.where((res) {
      if (_queueFilterStatus != 'Semua Status' && res.status != _queueFilterStatus) {
        return false;
      }
      if (_queueSearchQuery.isNotEmpty) {
        final q = _queueSearchQuery.toLowerCase();
        return res.namaPelanggan.toLowerCase().contains(q) ||
               res.platNomer.toLowerCase().contains(q) ||
               res.merkKendaraan.toLowerCase().contains(q) ||
               res.idReservasi.toString().contains(q);
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kelola Antrean Reservasi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildResponsiveRow([
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama, plat, merk, no rsv...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              setState(() {
                _queueSearchQuery = val;
              });
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: _queueFilterStatus,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: ['Semua Status', 'Menunggu Konfirmasi', 'Dikonfirmasi', 'Reschedule Diusulkan', 'Dalam Proses', 'Proses']
                .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                AppFeedback.playClick();
                setState(() {
                  _queueFilterStatus = val;
                });
              }
            },
          ),
        ]),
        const SizedBox(height: 24),
        Expanded(
          child: filteredQueue.isEmpty
              ? const Center(child: Text('Belum ada data reservasi'))
              : ListView.builder(
                  itemCount: filteredQueue.length,
                  itemBuilder: (context, index) {
                    final res = filteredQueue[index];
                    final delayMs = (index * 40).clamp(0, 400);

                    return FadeInSlide(
                      delay: Duration(milliseconds: delayMs),
                      offset: const Offset(0, 15),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                    // Header row: RSV number + status badge
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'RSV-${res.idReservasi.toString().padLeft(4, '0')} | ${res.tanggal} ${res.jam}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusBg(res.status),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            res.status,
                                            style: TextStyle(
                                              color: _getStatusTextCol(res.status),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24, color: Color(0xFF2D2D2D)),
                                    Text('Pelanggan: ${res.namaPelanggan} (${res.noHp})'),
                                    const SizedBox(height: 4),
                                    Text('Kendaraan: ${res.merkKendaraan} ${res.tipeKendaraan} - ${res.platNomer}'),
                                    const SizedBox(height: 4),
                                    Text('Keluhan: ${res.keluhan ?? "-"}'),
                                    if (res.namaMontir != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          'Montir: ${res.namaMontir}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (res.status == 'Menunggu Konfirmasi' || res.status == 'Dikonfirmasi') ...[
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.edit_calendar, size: 16),
                                            label: const Text('Atur Jadwal & Montir'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1D4ED8),
                                            ),
                                            onPressed: () {
                                              AppFeedback.playClick();
                                              _loadReservasiToForm(res);
                                            },
                                          ),
                                        ],
                                        if (res.status == 'Dikonfirmasi' && res.idMontir != null) ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                                            onPressed: () {
                                              AppFeedback.playClick();
                                              _updateStatus(res.idReservasi, 'Proses');
                                            },
                                            child: const Text('Mulai Proses'),
                                          )
                                        ],
                                        if (res.status == 'Proses' || res.status == 'Dalam Proses') ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () {
                                              AppFeedback.playClick();
                                              _updateStatus(res.idReservasi, 'Selesai');
                                            },
                                            child: const Text('Selesaikan Servis'),
                                          )
                                        ],
                                        if (res.status == 'Menunggu Konfirmasi') ...[
                                          OutlinedButton(
                                            onPressed: () {
                                              AppFeedback.playClick();
                                              _updateStatus(res.idReservasi, 'Ditolak');
                                            },
                                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                            child: const Text('Tolak'),
                                          )
                                        ],
                                      ],
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
        ),
      ],
    );
  }

  // --- TAB 3: ATUR JADWAL & MONTIR FORM ---
  Widget _buildJadwalMontirSection(AdminState state) {
    if (_activeReservasi == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_calendar, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Pilih reservasi terlebih dahulu\ndi tab Kelola Reservasi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _selectedMenuIndex = 1),
              child: const Text('Buka Kelola Reservasi'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atur Jadwal & Montir',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2D2D2D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // No Reservasi & Nama Pelanggan
                _buildResponsiveRow([
                  _buildFormLabelAndField(
                    label: 'No Reservasi',
                    child: TextFormField(
                      initialValue: 'RSV-${_activeReservasi!.idReservasi.toString().padLeft(4, '0')}',
                      readOnly: true,
                      decoration: const InputDecoration(fillColor: Color(0xFF161616)),
                    ),
                  ),
                  _buildFormLabelAndField(
                    label: 'Nama Pelanggan',
                    child: TextFormField(
                      initialValue: _activeReservasi!.namaPelanggan,
                      readOnly: true,
                      decoration: const InputDecoration(fillColor: Color(0xFF161616)),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Kendaraan & Tanggal
                _buildResponsiveRow([
                  _buildFormLabelAndField(
                    label: 'Kendaraan',
                    child: TextFormField(
                      initialValue: '${_activeReservasi!.merkKendaraan} ${_activeReservasi!.tipeKendaraan} (${_activeReservasi!.platNomer})',
                      readOnly: true,
                      decoration: const InputDecoration(fillColor: Color(0xFF161616)),
                    ),
                  ),
                  _buildFormLabelAndField(
                    label: 'Tanggal Servis',
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : 'Pilih Tanggal'),
                            const Icon(Icons.calendar_today, size: 18, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Jam & Montir
                _buildResponsiveRow([
                  _buildFormLabelAndField(
                    label: 'Jam Servis',
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedTime,
                      items: ['08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedTime = val),
                    ),
                  ),
                  _buildFormLabelAndField(
                    label: 'Montir Yang Dialokasikan',
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedMontirId,
                      decoration: const InputDecoration(hintText: 'Pilih Montir'),
                      items: state.montir
                          .map((m) => DropdownMenuItem(
                              value: m.idMontir,
                              child: Text('${m.nama} (${m.keahlian ?? "-"})'))
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedMontirId = val),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Catatan Keluhan
                _buildFormLabelAndField(
                  label: 'Catatan Keluhan',
                  child: TextFormField(
                    controller: _keluhanController,
                    maxLines: 4,
                    readOnly: true,
                    decoration: const InputDecoration(fillColor: Color(0xFF161616)),
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _activeReservasi = null;
                          _selectedMenuIndex = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Kembali'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedDate == null || _selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih tanggal dan jam')));
                          return;
                        }

                        try {
                          final tglStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

                          if (tglStr != _activeReservasi!.tanggal ||
                              _selectedTime != _activeReservasi!.jam) {
                            await ref
                                .read(adminControllerProvider.notifier)
                                .proposeReschedule(
                                    _activeReservasi!.idReservasi, tglStr, _selectedTime!);
                          }

                          if (_selectedMontirId != null &&
                              _selectedMontirId != _activeReservasi!.idMontir) {
                            await ref
                                .read(adminControllerProvider.notifier)
                                .assignMontir(_activeReservasi!.idReservasi, _selectedMontirId!);
                          }

                          if (mounted) {
                            AppFeedback.playSuccess();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Jadwal & Montir berhasil disimpan')));
                            setState(() {
                              _activeReservasi = null;
                              _selectedMenuIndex = 1;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            AppFeedback.playError();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Simpan Jadwal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: LAPORAN RESERVASI ---
  Widget _buildLaporanSection(AdminState state) {
    final filteredList = state.reservasi.where((r) {
      if (_selectedStatus != 'Semua Status' && r.status != _selectedStatus) {
        return false;
      }
      try {
        final rDate = DateTime.parse(r.tanggal);
        final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
        final end = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
        if (rDate.isBefore(start) || rDate.isAfter(end)) {
          return false;
        }
      } catch (_) {
        return false;
      }
      return true;
    }).toList();

    final totalReservasi = filteredList.length;
    final selesai = filteredList.where((r) => r.status == 'Selesai').length;
    final String montirTeraktif = filteredList.isNotEmpty ? 'Budi Montir' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Reservasi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),

        // Filter bar – wraps on mobile
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _buildFilterLabelAndField(
              label: 'Periode',
              child: SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPeriod,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: ['Bulan Ini', 'Hari Ini', 'Semua']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    AppFeedback.playClick();
                    if (val != null) {
                      final now = DateTime.now();
                      setState(() {
                        _selectedPeriod = val;
                        if (val == 'Hari Ini') {
                          _startDate = DateTime(now.year, now.month, now.day);
                          _endDate = DateTime(now.year, now.month, now.day);
                        } else if (val == 'Bulan Ini') {
                          _startDate = DateTime(now.year, now.month, 1);
                          _endDate = DateTime(now.year, now.month + 1, 0);
                        } else if (val == 'Semua') {
                          _startDate = DateTime(2025, 1, 1);
                          _endDate = DateTime(2030, 12, 31);
                        }
                      });
                    }
                  },
                ),
              ),
            ),
            _buildFilterLabelAndField(
              label: 'Status',
              child: SizedBox(
                width: 170,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: ['Semua Status', 'Selesai', 'Dibatalkan', 'Dikonfirmasi', 'Proses', 'Menunggu Konfirmasi', 'Reschedule Diusulkan']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    AppFeedback.playClick();
                    setState(() => _selectedStatus = val!);
                  },
                ),
              ),
            ),
            _buildFilterLabelAndField(
              label: 'Dari tanggal',
              child: InkWell(
                onTap: () async {
                  AppFeedback.playClick();
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030));
                  if (picked != null) setState(() => _startDate = picked);
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
            _buildFilterLabelAndField(
              label: 'Sampai tanggal',
              child: InkWell(
                onTap: () async {
                  AppFeedback.playClick();
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030));
                  if (picked != null) setState(() => _endDate = picked);
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                AppFeedback.playClick();
                ref.read(adminControllerProvider.notifier).loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Tampilkan'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Summary Metrics – wraps on small screens
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 160,
              child: _buildMetricCard(
                  'TOTAL RESERVASI', totalReservasi.toString(), const Color(0xFF3B82F6)),
            ),
            SizedBox(
              width: 160,
              child: _buildMetricCard(
                  'SERVIS SELESAI', selesai.toString(), const Color(0xFF10B981)),
            ),
            SizedBox(
              width: 160,
              child: _buildMetricCard(
                  'MONTIR TERAKTIF', montirTeraktif, const Color(0xFF8B5CF6)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Table layout - unified horizontal scroll
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2D2D2D)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 640,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      color: const Color(0xFF2D2D2D),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: const Row(
                        children: [
                          SizedBox(width: 80, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 100, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 140, child: Text('Pelanggan', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 200, child: Text('Kendaraan', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 120, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),

                    // Table Rows
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('Tidak ada data reservasi'))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final res = filteredList[index];
                                final isSelesai = res.status == 'Selesai';
                                final isDibatalkan =
                                    res.status == 'Dibatalkan' || res.status == 'Ditolak';

                                Color rowBgColor = Colors.transparent;
                                Color statusTextColor = Colors.white;
                                Color statusBgColor = Colors.transparent;

                                if (isSelesai) {
                                  rowBgColor = const Color(0xFFE6F4EA).withValues(alpha: 0.1);
                                  statusTextColor = const Color(0xFF137333);
                                  statusBgColor = const Color(0xFFE6F4EA);
                                } else if (isDibatalkan) {
                                  rowBgColor = const Color(0xFFFCE8E6).withValues(alpha: 0.1);
                                  statusTextColor = const Color(0xFFC5221F);
                                  statusBgColor = const Color(0xFFFCE8E6);
                                }

                                final delayMs = (index * 40).clamp(0, 400);

                                return FadeInSlide(
                                  delay: Duration(milliseconds: delayMs),
                                  offset: const Offset(0, 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: rowBgColor,
                                        border: const Border(
                                            bottom: BorderSide(color: Color(0xFF2D2D2D)))),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            'RSV-${res.idReservasi.toString().padLeft(4, '0')}',
                                            style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(width: 100, child: Text(res.tanggal)),
                                        SizedBox(width: 140, child: Text(res.namaPelanggan)),
                                        SizedBox(
                                            width: 200,
                                            child: Text(
                                                '${res.merkKendaraan} ${res.tipeKendaraan} (${res.platNomer})')),
                                        SizedBox(
                                          width: 120,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: statusBgColor.withValues(alpha: 0.85),
                                                borderRadius: BorderRadius.circular(4)),
                                            child: Text(
                                              res.status,
                                              style: TextStyle(
                                                  color: statusTextColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Buttons: Export CSV & Cetak Laporan
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                AppFeedback.playClick();
                try {
                  await ref.read(adminControllerProvider.notifier).exportCsv(filteredList);
                  if (!mounted) return;
                  AppFeedback.playSuccess();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mengekspor laporan CSV')));
                } catch (e) {
                  if (!mounted) return;
                  AppFeedback.playError();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengekspor: $e')));
                }
              },
              icon: const Icon(Icons.insert_drive_file),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build a two-column row on desktop, or a vertical column on mobile
  Widget _buildResponsiveRow(List<Widget> children) {
    final isDesktop = isDesktopLayout(context);
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 24)])
            .toList()
          ..removeLast(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children
          .expand((w) => [w, const SizedBox(height: 16)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildMetricCard(String title, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildFormLabelAndField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildFilterLabelAndField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFFE6F4EA);
      case 'Dibatalkan':
      case 'Ditolak':
        return const Color(0xFFFCE8E6);
      default:
        return const Color(0xFFE8F0FE);
    }
  }

  Color _getStatusTextCol(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF137333);
      case 'Dibatalkan':
      case 'Ditolak':
        return const Color(0xFFC5221F);
      default:
        return const Color(0xFF1A73E8);
    }
  }

  void _updateStatus(int idReservasi, String status) async {
    try {
      await ref.read(adminControllerProvider.notifier).updateStatus(idReservasi, status);
      if (!mounted) return;
      AppFeedback.playSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status reservasi diperbarui menjadi $status')));
    } catch (e) {
      if (!mounted) return;
      AppFeedback.playError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildShimmerLoadingList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: ShimmerPlaceholder(
            height: 140,
            borderRadius: 12,
          ),
        );
      },
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  const PulsingDot({super.key, required this.color});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5 * (1.0 - _controller.value)),
                blurRadius: 6,
                spreadRadius: 3 * _controller.value,
              )
            ],
          ),
        );
      },
    );
  }
}
