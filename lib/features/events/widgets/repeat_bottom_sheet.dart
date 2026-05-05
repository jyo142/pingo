// lib/features/events/widgets/repeat_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pingo/features/events/models/repeat_config.dart';

class RepeatBottomSheet extends StatefulWidget {
  final RepeatConfig initial;
  final Color purple;

  const RepeatBottomSheet({
    super.key,
    required this.initial,
    required this.purple,
  });

  @override
  State<RepeatBottomSheet> createState() => _RepeatBottomSheetState();
}

class _RepeatBottomSheetState extends State<RepeatBottomSheet> {
  late RepeatConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initial.enabled
        ? widget.initial
        : RepeatConfig.defaultOn();
    // Keep the enabled state from the initial config
    _config = _config.copyWith(enabled: widget.initial.enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Text(
                "Repeat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _config.enabled,
                activeColor: widget.purple,
                onChanged: (v) => setState(() {
                  _config = v ? RepeatConfig.defaultOn() : RepeatConfig.off();
                }),
                title: const Text("Repeat event"),
              ),

              if (_config.enabled) ...[
                const SizedBox(height: 12),

                // Frequency chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(RepeatFrequency.weekly, "Weekly"),
                    _chip(RepeatFrequency.daily, "Daily"),
                    _chip(RepeatFrequency.biweekly, "Bi-weekly"),
                    _chip(RepeatFrequency.monthly, "Monthly"),
                    _chip(RepeatFrequency.custom, "Custom"),
                  ],
                ),

                // Custom day picker
                if (_config.frequency == RepeatFrequency.custom) ...[
                  const SizedBox(height: 16),
                  _weekdayPicker(),
                ],

                const Divider(height: 32),

                const Text(
                  "Ends",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                _endOption(RepeatEnds.never, "Never"),
                _endOption(
                  RepeatEnds.onDate,
                  "On date",
                  trailing: _datePicker(),
                ),
                _endOption(
                  RepeatEnds.after,
                  "After",
                  trailing: _occurrencePicker(),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final error = _config.validate();
                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                  context.pop(_config);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Frequency chip ─────────────────────────────────────────────────────────

  Widget _chip(RepeatFrequency frequency, String label) {
    final selected = _config.frequency == frequency;

    return GestureDetector(
      onTap: () => setState(() {
        _config = _config.copyWith(frequency: frequency);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? widget.purple : const Color(0xFFF1F1F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Custom weekday picker ──────────────────────────────────────────────────

  Widget _weekdayPicker() {
    const labels = ["S", "M", "T", "W", "T", "F", "S"];
    // Supabase uses 1=Mon…7=Sun (ISO), map index 0=Sun to 7, 1–6 = Mon–Sat → 1–6
    const isoMap = [7, 1, 2, 3, 4, 5, 6];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isoDay = isoMap[i];
        final selected = _config.daysOfWeek?.contains(isoDay) ?? false;

        return GestureDetector(
          onTap: () {
            final current = List<int>.from(_config.daysOfWeek ?? []);
            selected ? current.remove(isoDay) : current.add(isoDay);
            setState(() {
              _config = _config.copyWith(daysOfWeek: current);
            });
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: selected ? widget.purple : const Color(0xFFF1F1F6),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── End option radio row ───────────────────────────────────────────────────

  Widget _endOption(RepeatEnds value, String label, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<RepeatEnds>(
        value: value,
        groupValue: _config.ends,
        activeColor: widget.purple,
        onChanged: (v) => setState(() {
          _config = _config.copyWith(
            ends: v,
            clearEndDate: v != RepeatEnds.onDate,
            clearAfterCount: v != RepeatEnds.after,
          );
        }),
      ),
      title: Text(label),
      trailing: _config.ends == value ? trailing : null,
      onTap: () => setState(() {
        _config = _config.copyWith(
          ends: value,
          clearEndDate: value != RepeatEnds.onDate,
          clearAfterCount: value != RepeatEnds.after,
        );
      }),
    );
  }

  // ── Date picker ────────────────────────────────────────────────────────────

  Widget _datePicker() {
    final date = _config.endDate;

    return TextButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: ColorScheme.light(primary: widget.purple)),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _config = _config.copyWith(endDate: picked);
          });
        }
      },
      child: Text(
        date == null ? "Select" : "${date.month}/${date.day}/${date.year}",
        style: TextStyle(color: widget.purple, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Occurrence counter ─────────────────────────────────────────────────────

  Widget _occurrencePicker() {
    final count = _config.afterCount ?? 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _counterBtn(
          icon: Icons.remove,
          onTap: count > 1
              ? () => setState(() {
                  _config = _config.copyWith(afterCount: count - 1);
                })
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "$count times",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        _counterBtn(
          icon: Icons.add,
          onTap: () => setState(() {
            _config = _config.copyWith(afterCount: count + 1);
          }),
        ),
      ],
    );
  }

  Widget _counterBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFF1F1F6)
              : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? Colors.black87 : Colors.black26,
        ),
      ),
    );
  }
}
