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
  late RepeatConfig config;

  @override
  void initState() {
    super.initState();
    config = RepeatConfig(
      enabled: widget.initial.enabled,
      type: widget.initial.type,
      weekdays: {...widget.initial.weekdays},
      endType: widget.initial.endType,
      endDate: widget.initial.endDate,
      occurrences: widget.initial.occurrences,
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a Material wrapper to ensure the background and shape are consistent
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // This makes the sheet wrap the content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
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
                value: config.enabled,
                activeColor: widget.purple,
                onChanged: (v) => setState(() => config.enabled = v),
                title: const Text("Repeat event"),
              ),

              // Conditional Section
              if (config.enabled) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(RepeatType.weekly, "Weekly"),
                    _chip(RepeatType.daily, "Daily"),
                    _chip(RepeatType.biWeekly, "Bi-weekly"),
                    _chip(RepeatType.monthly, "Monthly"),
                    _chip(RepeatType.custom, "Custom"),
                  ],
                ),
                const SizedBox(height: 16),

                if (config.type == RepeatType.weekly) ...[
                  _weekdays(),
                  const SizedBox(height: 16),
                ],

                const Divider(height: 32),
                const Text(
                  "Ends",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                _endOption(RepeatEndType.never, "Never"),
                _endOption(
                  RepeatEndType.date,
                  "On date",
                  trailing: _datePicker(),
                ),
                _endOption(
                  RepeatEndType.after,
                  "After",
                  trailing: _occurrence(),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(config),
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(RepeatType type, String label) {
    final selected = config.type == type;

    return GestureDetector(
      onTap: () => setState(() => config.type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? widget.purple : const Color(0xFFF1F1F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Colors.black54),
        ),
      ),
    );
  }

  Widget _weekdays() {
    const days = ["S", "M", "T", "W", "T", "F", "S"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final selected = config.weekdays.contains(i);

        return GestureDetector(
          onTap: () {
            setState(() {
              selected ? config.weekdays.remove(i) : config.weekdays.add(i);
            });
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: selected ? widget.purple : const Color(0xFFF1F1F6),
            child: Text(
              days[i],
              style: TextStyle(color: selected ? Colors.white : Colors.black54),
            ),
          ),
        );
      }),
    );
  }

  Widget _endOption(RepeatEndType value, String label, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<RepeatEndType>(
        value: value,
        groupValue: config.endType,
        activeColor: widget.purple,
        onChanged: (v) => setState(() => config.endType = v!),
      ),
      title: Text(label),
      trailing: trailing,
      onTap: () => setState(() => config.endType = value),
    );
  }

  Widget _datePicker() {
    return TextButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: config.endDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => config.endDate = picked);
        }
      },
      child: Text(
        config.endDate == null
            ? "Select"
            : "${config.endDate!.month}/${config.endDate!.day}",
      ),
    );
  }

  Widget _occurrence() {
    return Text("${config.occurrences} times");
  }
}
