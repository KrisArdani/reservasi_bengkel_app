import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/application/auth_controller.dart';
import '../../admin/application/admin_controller.dart';
import '../../../core/widgets/diagonal_sidebar.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/utils/app_feedback.dart';

class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  int _selectedMenuIndex = 0;
  String _selectedPeriod = 'Semua';
  String _selectedStatus = 'Semua Status';
  DateTime _startDate = DateTime(2025, 1, 1);
  DateTime _endDate = DateTime(2030, 12, 31);

  final List<SidebarItem> _sidebarItems = const [
    SidebarItem(title: 'Dashboard', icon: Icons.dashboard, route: '/owner'),
    SidebarItem(title: 'Laporan', icon: Icons.assignment, route: '/owner/laporan'),
  ];

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isDesktop = isDesktopLayout(context);

    final sidebar = DiagonalSidebar(
      avatarInitials: 'K',
      roleTitle: user?.username ?? 'Kepala Bengkel',
      roleSubtitle: 'Kepala Bengkel',
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
      child: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(adminState),
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

  Widget _buildMainContent(AdminState state) {
    if (_selectedMenuIndex == 0) {
      return _buildDashboardSection(state);
    } else {
      return _buildLaporanSection(state);
    }
  }

  // --- SECTION 1: DASHBOARD MONITORING ---
  Widget _buildDashboardSection(AdminState state) {
    final int totalReservasi = state.reservasi.length;
    final int servisSelesai = state.reservasi.where((r) => r.status == 'Selesai').length;
    final int montirAktif = state.montir.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monitoring Kepala Bengkel',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ringkasan performa dan metrik operasional bengkel saat ini.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 40),

          // Metrik Cards Grid
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildMetricCard(
                title: 'Total Reservasi',
                value: totalReservasi.toString(),
                icon: Icons.calendar_month,
                color: Colors.blue,
                delay: Duration.zero,
              ),
              _buildMetricCard(
                title: 'Servis Selesai',
                value: servisSelesai.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
                delay: const Duration(milliseconds: 100),
              ),
              _buildMetricCard(
                title: 'Montir Aktif',
                value: montirAktif.toString(),
                icon: Icons.engineering,
                color: Colors.orange,
                delay: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Duration delay,
  }) {
    return FadeInSlide(
      delay: delay,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF1A1A2E), // Subtle dark blue tone
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.04),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SECTION 2: LAPORAN RESERVASI ---
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Reservasi',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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

        const SizedBox(height: 32),

        // Laporan Table - unified horizontal scroll
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

        // Export Excel Button
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton.icon(
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
            icon: const Icon(Icons.file_download),
            label: const Text('Export Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
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
}
