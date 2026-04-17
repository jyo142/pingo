enum RepeatType { daily, weekly, biWeekly, monthly, custom }

enum RepeatEndType { never, date, after }

class RepeatConfig {
  bool enabled;
  RepeatType type;
  Set<int> weekdays;
  RepeatEndType endType;
  DateTime? endDate;
  int occurrences;

  RepeatConfig({
    this.enabled = false,
    this.type = RepeatType.weekly,
    Set<int>? weekdays,
    this.endType = RepeatEndType.never,
    this.endDate,
    this.occurrences = 10,
  }) : weekdays = weekdays ?? {1};

  String summary() {
    if (!enabled) return "Never";

    String base = _typeLabel(type);

    if (type == RepeatType.weekly && weekdays.isNotEmpty) {
      const names = ["S", "M", "T", "W", "T", "F", "S"];
      final days = weekdays.map((d) => names[d]).join(", ");
      base += " ($days)";
    }

    if (endType == RepeatEndType.date && endDate != null) {
      base += " • Ends ${endDate!.month}/${endDate!.day}/${endDate!.year}";
    } else if (endType == RepeatEndType.after) {
      base += " • $_occurrencesText";
    }

    return base;
  }

  String get _occurrencesText => "$occurrences times";

  // 👇 Helper for UI labels
  String _typeLabel(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return "Daily";
      case RepeatType.weekly:
        return "Weekly";
      case RepeatType.biWeekly:
        return "Bi-weekly";
      case RepeatType.monthly:
        return "Monthly";
      case RepeatType.custom:
        return "Custom";
    }
  }
}
