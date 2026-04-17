import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pingo/core/db/supabase_user_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final user = Supabase.instance.client.auth.currentUser;

  String? get userFirstName => user?.firstName;
  String? get avatarUrl => user?.avatarUrl;

  static const _purple = Color(0xFF5B5BD6);
  static const _purpleLight = Color(0xFFEEF0FF);
  static const _amber = Color(0xFFC2620A);
  static const _amberLight = Color(0xFFFFF0E6);
  static const _surface = Color(0xFFF5F5FF);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF888888);
  static const _cardBorder = Color(0x12000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purple,
      body: Column(
        children: [
          // ── Purple hero section ──────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatsStrip(),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── White card panel ─────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Today's Event", onTap: () {}),
                    const SizedBox(height: 12),
                    _buildTodayEventCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Upcoming", onTap: () {}),
                    const SizedBox(height: 12),
                    _buildUpcomingItem(
                      icon: Icons.calendar_today_rounded,
                      iconColor: _purple,
                      iconBg: _purpleLight,
                      title: "Team Meeting",
                      subtitle: "Conference Room A",
                      dateLabel: "Tomorrow",
                    ),
                    const SizedBox(height: 10),
                    _buildUpcomingItem(
                      icon: Icons.star_rounded,
                      iconColor: _amber,
                      iconBg: _amberLight,
                      title: "Hackathon",
                      subtitle: "Innovation Lab",
                      dateLabel: "Friday",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom nav ───────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good morning",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userFirstName ?? "James",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? const Text(
                  "J",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  // ── Stats strip ───────────────────────────────────────────────
  Widget _buildStatsStrip() {
    return Row(
      children: [
        _buildStatTile("Attended", "12"),
        const SizedBox(width: 10),
        _buildStatTile("Pending", "3"),
        const SizedBox(width: 10),
        _buildStatTile("Rate", "80%"),
      ],
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: "Create Event",
            isPrimary: true,
            onTap: () => context.push('/createEvent'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            icon: Icons.article_outlined,
            label: "Join Event",
            isPrimary: false,
            onTap: () => context.push('/createEvent'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : Colors.white.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isPrimary ? _purple : Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? _purple : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textMuted,
            letterSpacing: 0.5,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            "See all",
            style: TextStyle(
              fontSize: 12,
              color: _purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Today's event card ─────────────────────────────────────────
  Widget _buildTodayEventCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AI Workshop",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Room 301  ·  11:00 AM",
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _amberLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Pending",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _amber,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFE24B4A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Starts in 45 min",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code, size: 14),
                label: const Text(
                  "Mark Attendance",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upcoming event row ─────────────────────────────────────────
  Widget _buildUpcomingItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String dateLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dateLabel,
              style: const TextStyle(fontSize: 12, color: _textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom navigation ──────────────────────────────────────────
  Widget _buildBottomNav() {
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
        selectedIndex: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home_rounded, color: _purple),
            icon: Icon(Icons.home_outlined, color: _textMuted),
            label: "Home",
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.notifications_outlined, color: _textMuted),
            ),
            label: "Alerts",
          ),
          NavigationDestination(
            icon: Badge(
              label: Text("2"),
              child: Icon(Icons.chat_bubble_outline_rounded, color: _textMuted),
            ),
            label: "Messages",
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded, color: _textMuted),
            label: "Scan QR",
          ),
        ],
      ),
    );
  }
}
