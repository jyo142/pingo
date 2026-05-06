import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainBottomNavBar({super.key, required this.shell});

  static const _purple = Color(0xFF5B5BD6);
  static const _purpleLight = Color(0xFFEEF0FF);
  static const _textMuted = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: _purpleLight,
        selectedIndex: shell.currentIndex, // 👈 driven by the shell
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          shell.goBranch(
            index,
            // Re-tapping the current tab pops back to its root route
            initialLocation: index == shell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home_rounded, color: _purple),
            icon: Icon(Icons.home_outlined, color: _textMuted),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.notifications_outlined, color: _textMuted),
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.chat_bubble_outline_rounded, color: _textMuted),
            ),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded, color: _textMuted),
            label: 'Scan QR',
          ),
        ],
      ),
    );
  }
}
