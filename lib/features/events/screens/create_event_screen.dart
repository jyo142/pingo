import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pingo/features/events/models/repeat_config.dart';
import 'package:pingo/features/events/widgets/repeat_bottom_sheet.dart';

enum AttendanceType { qrCode, manual, gps }

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const _purple = Color(0xFF5B5BD6);
  static const _purpleLight = Color(0xFFEEF0FF);
  static const _surface = Color(0xFFF5F5FF);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF888888);
  static const _cardBorder = Color(0x12000000);
  final _createEventFormKey = GlobalKey<FormState>();

  RepeatConfig _repeat = RepeatConfig();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 0, minute: 0);
  String? _dateError;
  String? _startTimeError;
  String? _endTimeError;
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _purple)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(
    TimeOfDay initialTime,
    Function(TimeOfDay) onSelected,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _purple)),
        child: child!,
      ),
    );

    if (picked != null) onSelected(picked);
  }

  String get _formattedDate {
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
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  String get _formattedStartTime => _selectedStartTime.format(context);
  String get _formattedEndTime => _selectedEndTime.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purple,
      bottomNavigationBar: _buildCreateButton(),
      body: Column(
        children: [
          SafeArea(bottom: false, child: _buildTopBar()),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Form(
                  key: _createEventFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(
                        label: "Event Name",
                        child: _buildTextInput(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Event Name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildField(
                        label: "Description",
                        child: _buildTextInput(maxLines: 3),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              label: "Date",
                              child: _buildTappableRow(
                                icon: Icons.calendar_today_rounded,
                                text: _formattedDate,
                                onTap: _pickDate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              label: "Start",
                              child: _buildTappableRow(
                                icon: Icons.access_time_rounded,
                                text: _formattedStartTime,
                                errorText: _startTimeError,
                                onTap: () =>
                                    _pickTime(_selectedStartTime, (picked) {
                                      setState(() {
                                        _selectedStartTime = picked;
                                        _startTimeError = null; // clear on pick
                                      });
                                    }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              label: "End",
                              child: _buildTappableRow(
                                icon: Icons.access_time_rounded,
                                text: _formattedEndTime,
                                errorText: _endTimeError,
                                onTap: () =>
                                    _pickTime(_selectedEndTime, (picked) {
                                      setState(() {
                                        _selectedEndTime = picked;
                                        _endTimeError = null;
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildRepeatRow(),
                      const SizedBox(height: 18),
                      _buildField(
                        label: "Location",
                        child: _buildTextInput(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Location is required";
                            }
                            return null;
                          },
                          prefixIcon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Create Event",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── Field wrapper ──────────────────────────────────────────────
  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // ── Text input ─────────────────────────────────────────────────
  Widget _buildTextInput({
    String? Function(String?)? validator,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _purple, size: 18)
            : null,
        // Match the tappable row border exactly
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purple, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.red.shade400,
          ), // was Color(0x22FF0000)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  // ── Tappable row (date/time) ───────────────────────────────────
  Widget _buildTappableRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    String? errorText, // add this
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            onTap();
            // Clear error on interaction
            setState(() {
              _startTimeError = null;
              _endTimeError = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError ? Colors.red.shade400 : _cardBorder,
                width: hasError ? 1.0 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: hasError ? Colors.red.shade400 : _purple,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: hasError ? Colors.red.shade700 : _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText,
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ),
        ],
      ],
    );
  }

  // ── Create button ──────────────────────────────────────────────
  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleCreate,

        child: const Text(
          "Create Event",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _handleCreate() {
    // TODO: validate & submit to Supabase
    bool tappableValid = true;

    setState(() {
      // Validate date (example: must be in future)
      _dateError = null;

      // Validate times
      final start = _selectedStartTime.hour * 60 + _selectedStartTime.minute;
      final end = _selectedEndTime.hour * 60 + _selectedEndTime.minute;

      if (start == 0 && end == 0) {
        _startTimeError = 'Please set a start time';
        tappableValid = false;
      } else {
        _startTimeError = null;
      }

      if (end <= start) {
        _endTimeError = 'End must be after start';
        tappableValid = false;
      } else {
        _endTimeError = null;
      }
    });
    final formValid = _createEventFormKey.currentState!.validate();
    if (!formValid || !tappableValid) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Event created successfully")));
    context.pop();
  }

  Widget _buildRepeatRow() {
    return _buildField(
      label: "Repeat",
      child: GestureDetector(
        onTap: _openRepeatSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.repeat, color: _purple, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _repeat.summary(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _openRepeatSheet() async {
    final result = await showModalBottomSheet<RepeatConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepeatBottomSheet(initial: _repeat, purple: _purple),
    );

    if (result != null) {
      setState(() => _repeat = result);
    }
  }
}
