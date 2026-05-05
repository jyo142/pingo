// lib/features/events/widgets/edit_scope_sheet.dart

import 'package:flutter/material.dart';

class EditScopeSheet extends StatelessWidget {
  final String title;
  final bool isDanger;
  final String thisLabel, thisSub;
  final String futureLabel, futureSub;
  final String allLabel, allSub;
  final VoidCallback onThis, onFuture, onAll;

  const EditScopeSheet({
    required this.title,
    this.isDanger = false,
    required this.thisLabel,
    required this.thisSub,
    required this.futureLabel,
    required this.futureSub,
    required this.allLabel,
    required this.allSub,
    required this.onThis,
    required this.onFuture,
    required this.onAll,
  });

  static const _purple = Color(0xFF5B5BD6);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(height: 60, color: Colors.transparent),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _option(
                  context,
                  icon: isDanger
                      ? Icons.event_busy_outlined
                      : Icons.event_outlined,
                  iconBg: isDanger
                      ? const Color(0xFFFCEBEB)
                      : const Color(0xFFEEEDFE),
                  iconColor: isDanger ? const Color(0xFFA32D2D) : _purple,
                  label: thisLabel,
                  sub: thisSub,
                  labelColor: isDanger ? const Color(0xFFA32D2D) : null,
                  onTap: onThis,
                ),
                _option(
                  context,
                  icon: isDanger
                      ? Icons.delete_sweep_outlined
                      : Icons.arrow_forward_outlined,
                  iconBg: isDanger
                      ? const Color(0xFFFCEBEB)
                      : const Color(0xFFE1F5EE),
                  iconColor: isDanger
                      ? const Color(0xFFA32D2D)
                      : const Color(0xFF0F6E56),
                  label: futureLabel,
                  sub: futureSub,
                  labelColor: isDanger ? const Color(0xFFA32D2D) : null,
                  onTap: onFuture,
                ),
                _option(
                  context,
                  icon: isDanger
                      ? Icons.delete_forever_outlined
                      : Icons.all_inclusive_outlined,
                  iconBg: isDanger
                      ? const Color(0xFFFCEBEB)
                      : const Color(0xFFFAEEDA),
                  iconColor: isDanger
                      ? const Color(0xFFA32D2D)
                      : const Color(0xFF854F0B),
                  label: allLabel,
                  sub: allSub,
                  labelColor: isDanger ? const Color(0xFFA32D2D) : null,
                  isLast: true,
                  onTap: onAll,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
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

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String sub,
    Color? labelColor,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.07)),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: labelColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}
