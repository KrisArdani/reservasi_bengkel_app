import 'package:flutter/material.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;

  const SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

/// Returns true if the screen is wide enough to show a persistent sidebar
bool isDesktopLayout(BuildContext context) =>
    MediaQuery.of(context).size.width >= 720;

/// A responsive sidebar that renders as a persistent rail on desktop
/// and as a Drawer-compatible panel on mobile (use via [buildMobileDrawer]).
class DiagonalSidebar extends StatelessWidget {
  final String avatarInitials;
  final String roleTitle;
  final String roleSubtitle;
  final List<SidebarItem> items;
  final int activeIndex;
  final Function(int) onItemTap;
  final VoidCallback onLogout;

  const DiagonalSidebar({
    super.key,
    required this.avatarInitials,
    required this.roleTitle,
    required this.roleSubtitle,
    required this.items,
    required this.activeIndex,
    required this.onItemTap,
    required this.onLogout,
  });

  /// Build the inner content (shared between desktop sidebar and mobile drawer)
  Widget _buildContent(BuildContext context, {bool inDrawer = false}) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1D4ED8), // Royal Blue
            Color(0xFF1E3A8A), // Navy Blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    child: Text(
                      avatarInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    roleTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Navigation Items
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isActive = index == activeIndex;

                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Active Pointer Triangle (desktop only)
                      if (isActive && !inDrawer)
                        Positioned(
                          right: 2,
                          child: ClipPath(
                            clipper: TriangleClipper(),
                            child: Container(
                              width: 14,
                              height: 16,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ),

                      // Navigation Button
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 24.0, top: 8.0, bottom: 8.0),
                        child: isActive
                            ? Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                child: Row(
                                  children: [
                                    Icon(item.icon,
                                        color: const Color(0xFF1D4ED8)),
                                    const SizedBox(width: 12),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Color(0xFF1D4ED8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  if (inDrawer) {
                                    Navigator.of(context).pop();
                                  }
                                  onItemTap(index);
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(item.icon, color: Colors.white70),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
              child: InkWell(
                onTap: () {
                  if (inDrawer) Navigator.of(context).pop();
                  onLogout();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 180,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.white70),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Use this as the desktop persistent sidebar (inside a Row)
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: SidebarClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1D4ED8),
                      Color(0xFF1E3A8A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        child: Text(
                          avatarInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        roleTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleSubtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isActive = index == activeIndex;

                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          if (isActive)
                            Positioned(
                              right: 2,
                              child: ClipPath(
                                clipper: TriangleClipper(),
                                child: Container(
                                  width: 14,
                                  height: 16,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 24.0,
                                top: 8.0,
                                bottom: 8.0),
                            child: isActive
                                ? Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    child: Row(
                                      children: [
                                        Icon(item.icon,
                                            color: const Color(0xFF1D4ED8)),
                                        const SizedBox(width: 12),
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Color(0xFF1D4ED8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : InkWell(
                                    onTap: () => onItemTap(index),
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      child: Row(
                                        children: [
                                          Icon(item.icon,
                                              color: Colors.white70),
                                          const SizedBox(width: 12),
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                  child: InkWell(
                    onTap: onLogout,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.white70),
                          SizedBox(width: 12),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a Drawer widget for mobile use
  Widget buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: _buildContent(context, inDrawer: true),
    );
  }
}

class SidebarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 50, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height / 2);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
