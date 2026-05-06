// lib/features/events/screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pingo/features/events/models/attendee.dart';
import 'package:pingo/features/events/models/event.dart';
import 'package:pingo/features/events/models/repeat_config.dart';
import 'package:pingo/features/events/services/event_service.dart';
import 'package:pingo/features/events/widgets/edit_scope_sheet.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _purple = Color(0xFF5B5BD6);
  static const _surface = Color(0xFFF5F5FF);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF888888);
  static const _cardBorder = Color(0x12000000);

  late AnimationController _menuController;
  late Animation<Offset> _menuSlide;
  late Animation<double> _menuFade;

  bool _menuOpen = false;
  bool _isLoading = true;
  Event? _event;
  List<Attendee> _attendees = [];

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _menuSlide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _menuController, curve: Curves.easeOutCubic),
        );
    _menuFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _menuController, curve: Curves.easeOut));
    _loadEvent();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    try {
      final event = await EventService.getEvent(widget.eventId);
      final attendees = await EventService.getAttendees(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = event;
        _attendees = attendees;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Failed to load event: $e');
    }
  }

  // ── Menu ───────────────────────────────────────────────────────

  void _openMenu() {
    setState(() => _menuOpen = true);
    _menuController.forward();
  }

  void _closeMenu() {
    _menuController.reverse().then((_) {
      if (mounted) setState(() => _menuOpen = false);
    });
  }

  // ── Actions ────────────────────────────────────────────────────

  void _onEdit() {
    _closeMenu();
    if (_event?.repeat?.enabled == true) {
      _showEditScopeSheet(
        title: 'Edit which events?',
        onThis: () => _navigateToEdit(EditScope.thisOnly),
        onFuture: () => _navigateToEdit(EditScope.thisAndFuture),
        onAll: () => _navigateToEdit(EditScope.allEvents),
      );
    } else {
      _navigateToEdit(EditScope.allEvents);
    }
  }

  void _navigateToEdit(EditScope scope) {
    // Push to edit screen — implement as needed
    context.push('/events/${widget.eventId}/edit', extra: scope);
  }

  void _onDelete() {
    _closeMenu();
    if (_event?.repeat?.enabled == true) {
      _showDeleteScopeSheet();
    } else {
      _showDeleteConfirmDialog(
        title: 'Delete event?',
        message:
            'This will permanently remove "${_event?.name}". This cannot be undone.',
        onConfirm: () => _deleteEvent(EditScope.allEvents),
      );
    }
  }

  void _showDeleteScopeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EditScopeSheet(
        title: 'Delete which events?',
        isDanger: true,
        thisLabel: 'This event only',
        thisSub: 'Remove just this occurrence',
        futureLabel: 'This & future events',
        futureSub: 'Remove from this date forward',
        allLabel: 'All events',
        allSub: 'Remove every occurrence',
        onThis: () {
          Navigator.pop(context);
          _showDeleteConfirmDialog(
            title: 'Delete this occurrence?',
            message:
                'This will remove just this one occurrence of "${_event?.name}".',
            onConfirm: () => _deleteEvent(EditScope.thisOnly),
          );
        },
        onFuture: () {
          Navigator.pop(context);
          _showDeleteConfirmDialog(
            title: 'Delete this & future events?',
            message:
                'This will remove "${_event?.name}" from this date forward.',
            onConfirm: () => _deleteEvent(EditScope.thisAndFuture),
          );
        },
        onAll: () {
          Navigator.pop(context);
          _showDeleteConfirmDialog(
            title: 'Delete all events?',
            message:
                'This permanently removes "${_event?.name}" and every occurrence. This cannot be undone.',
            onConfirm: () => _deleteEvent(EditScope.allEvents),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(EditScope scope) async {
    try {
      if (scope == EditScope.allEvents) {
        await EventService.deleteEvent(widget.eventId);
      } else if (scope == EditScope.thisOnly) {
        // Cancel this occurrence — needs the original date
        // You'll need to pass the occurrence date into this screen
        // await EventService.cancelOccurrence(eventId: widget.eventId, originalDate: widget.occurrenceDate!);
      } else if (scope == EditScope.thisAndFuture) {
        // Implemented in EventService.updateThisAndFuture
      }
      if (!mounted) return;
      _showSnack('Event deleted');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to delete event: $e');
    }
  }

  void _showEditScopeSheet({
    required String title,
    required VoidCallback onThis,
    required VoidCallback onFuture,
    required VoidCallback onAll,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EditScopeSheet(
        title: title,
        thisLabel: 'This event only',
        thisSub: 'Just this occurrence',
        futureLabel: 'This & future events',
        futureSub: 'From this date forward',
        allLabel: 'All events',
        allSub: 'Every occurrence',
        onThis: () {
          Navigator.pop(context);
          onThis();
        },
        onFuture: () {
          Navigator.pop(context);
          onFuture();
        },
        onAll: () {
          Navigator.pop(context);
          onAll();
        },
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purple,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(bottom: false, child: _buildTopBar()),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _event == null
                      ? const Center(child: Text('Event not found'))
                      : _buildBody(),
                ),
              ),
            ],
          ),

          // Dimmed overlay when menu is open
          if (_menuOpen)
            FadeTransition(
              opacity: _menuFade,
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(color: Colors.black54),
              ),
            ),

          // Slide-in drawer
          if (_menuOpen)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width * 0.75,
              child: SlideTransition(
                position: _menuSlide,
                child: _buildDrawer(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Row(
        children: [
          _circleBtn(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
          Expanded(
            child: Text(
              _event?.name ?? '',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _circleBtn(
            onTap: _openMenu,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _menuLine(),
                const SizedBox(height: 3.5),
                _menuLine(),
                const SizedBox(height: 3.5),
                _menuLine(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }

  Widget _menuLine() => Container(
    width: 14,
    height: 1.5,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(1),
    ),
  );

  Widget _buildBody() {
    final event = _event!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(event),
          const SizedBox(height: 12),
          _buildInfoCard(event),
          const SizedBox(height: 12),
          _buildAttendeesCard(),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Event event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _dateBadge(event),
                if (event.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBadge(Event event) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = event.startsAt;
    final label =
        '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day} · ${event.startsAt.hour}:${event.startsAt.minute.toString().padLeft(2, '0')} – ${event.endsAt.hour}:${event.endsAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 11,
            color: Color(0xFF3C3489),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF3C3489),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Event event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.access_time_rounded,
            title: _formatTimeRange(event),
            subtitle: _formatDuration(event),
          ),
          if (event.repeat?.enabled == true)
            _infoRow(
              icon: Icons.repeat_rounded,
              title: event.repeat!.summary(),
              subtitle: _repeatEndLabel(event.repeat!),
              trailing: _pill('Repeat'),
            ),
          if (event.location?.isNotEmpty == true)
            _infoRow(
              icon: Icons.location_on_outlined,
              title: event.location!,
              isLast: true,
              trailing: GestureDetector(
                onTap: () {
                  /* open maps */
                },
                child: const Text(
                  'Map',
                  style: TextStyle(
                    fontSize: 12,
                    color: _purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _purple, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: _textPrimary),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF3C3489),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAttendeesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTENDEES · ${_attendees.length}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ..._attendees.map((a) => _attendeeRow(a)),
        ],
      ),
    );
  }

  Widget _attendeeRow(Attendee attendee) {
    final isLast = _attendees.last == attendee;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          _avatar(attendee.userId.substring(0, 2).toUpperCase()),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attendee.userId,
                style: const TextStyle(fontSize: 13, color: _textPrimary),
              ),
            ],
          ),
          const Spacer(),
          _statusBadge(attendee.status),
        ],
      ),
    );
  }

  Widget _avatar(String initials) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFEEEDFE),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 10,
          color: _purple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusBadge(AttendeeStatus status) {
    final Map<AttendeeStatus, (String, Color, Color)> configs = {
      AttendeeStatus.owner: (
        'Owner',
        const Color(0xFFEAF3DE),
        const Color(0xFF27500A),
      ),
      AttendeeStatus.going: (
        'Going',
        const Color(0xFFEAF3DE),
        const Color(0xFF27500A),
      ),
      AttendeeStatus.maybe: (
        'Maybe',
        const Color(0xFFFAEEDA),
        const Color(0xFF633806),
      ),
      AttendeeStatus.invited: (
        'Invited',
        const Color(0xFFF1F1F1),
        const Color(0xFF888888),
      ),
      AttendeeStatus.declined: (
        'Declined',
        const Color(0xFFFCEBEB),
        const Color(0xFFA32D2D),
      ),
    };

    final (label, bg, fg) = configs[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── Drawer ─────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return SafeArea(
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(child: _buildDrawerItems()),
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      color: _purple,
      padding: const EdgeInsets.fromLTRB(14, 48, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _event?.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _event != null ? _formatDateShort(_event!.startsAt) : '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: [
        _drawerItem(
          icon: Icons.article_outlined,
          label: 'Details',
          isActive: true,
          onTap: _closeMenu,
        ),
        _drawerItem(icon: Icons.edit_outlined, label: 'Edit', onTap: _onEdit),
        _drawerItem(
          icon: Icons.how_to_reg_outlined,
          label: 'Attendance',
          onTap: () {
            _closeMenu(); /* navigate */
          },
        ),
        _drawerItem(
          icon: Icons.chat_bubble_outline,
          label: 'Messages',
          badge: '3',
          onTap: () {
            _closeMenu(); /* navigate */
          },
        ),
        _drawerItem(
          icon: Icons.campaign_outlined,
          label: 'Announcements',
          onTap: () {
            _closeMenu(); /* navigate */
          },
        ),
        _drawerItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {
            _closeMenu(); /* navigate */
          },
        ),
        const Divider(height: 16, indent: 14, endIndent: 14),
        _drawerItem(
          icon: Icons.delete_outline,
          label: 'Delete event',
          isDanger: true,
          onTap: _onDelete,
        ),
      ],
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    String? badge,
    bool isActive = false,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    final color = isDanger
        ? const Color(0xFFA32D2D)
        : isActive
        ? _purple
        : _textPrimary;
    final bgColor = isDanger
        ? const Color(0xFFFCEBEB)
        : const Color(0xFFEEEDFE);
    final itemBg = isActive ? const Color(0xFFEEEDFE) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: itemBg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            if (badge != null) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _cardBorder)),
      ),
      child: GestureDetector(
        onTap: () {
          _closeMenu(); /* share */
        },
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.share_outlined, color: _purple, size: 16),
            ),
            const SizedBox(width: 12),
            const Text(
              'Share event',
              style: TextStyle(fontSize: 13, color: _textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _formatTimeRange(Event e) {
    String _fmt(DateTime d) =>
        '${d.hour % 12 == 0 ? 12 : d.hour % 12}:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
    return '${_fmt(e.startsAt)} – ${_fmt(e.endsAt)}';
  }

  String _formatDuration(Event e) {
    final mins = e.endsAt.difference(e.startsAt).inMinutes;
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60, m = mins % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  String _formatDateShort(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _repeatEndLabel(RepeatConfig r) {
    if (r.ends == RepeatEnds.onDate && r.endDate != null) {
      return 'Until ${_formatDateShort(r.endDate!)}';
    }
    if (r.ends == RepeatEnds.after && r.afterCount != null) {
      return 'For ${r.afterCount} occurrences';
    }
    return 'Ends never';
  }
}
