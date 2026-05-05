// lib/features/events/models/repeat_config.dart

enum RepeatFrequency { daily, weekly, biweekly, monthly, custom, never }

enum RepeatEnds { never, onDate, after }

class RepeatConfig {
  final bool enabled;
  final RepeatFrequency? frequency;
  final int? interval; // every N days/weeks/months
  final RepeatEnds? ends;
  final DateTime? endDate; // used when ends = onDate
  final int? afterCount; // used when ends = after
  final List<int>? daysOfWeek; // used when frequency = custom (1=Mon … 7=Sun)

  const RepeatConfig({
    this.enabled = false,
    this.frequency,
    this.interval,
    this.ends,
    this.endDate,
    this.afterCount,
    this.daysOfWeek,
  });

  // ── Defaults ───────────────────────────────────────────────────────────────

  /// Sensible starting state when the user first toggles repeat on
  factory RepeatConfig.defaultOn() => const RepeatConfig(
    enabled: true,
    frequency: RepeatFrequency.weekly,
    interval: 1,
    ends: RepeatEnds.never,
  );

  factory RepeatConfig.off() => const RepeatConfig(enabled: false);

  // ── Serialization ──────────────────────────────────────────────────────────

  factory RepeatConfig.fromJson(Map<String, dynamic> json) {
    final frequencyRaw = json['frequency'] as String?;
    final endsRaw = json['ends'] as String?;

    return RepeatConfig(
      enabled: frequencyRaw != null,
      frequency: frequencyRaw != null
          ? RepeatFrequency.values.byName(frequencyRaw)
          : null,
      interval: json['interval'] as int?,
      ends: endsRaw != null ? _parseEnds(endsRaw) : RepeatEnds.never,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      afterCount: json['after_count'] as int?,
      daysOfWeek: (json['days_of_week'] as List?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'frequency': frequency?.name,
    'interval': interval,
    'ends': _endsToString(ends),
    'end_date': endDate?.toIso8601String(),
    'after_count': afterCount,
    'days_of_week': daysOfWeek,
  };

  // ── CopyWith ───────────────────────────────────────────────────────────────

  RepeatConfig copyWith({
    bool? enabled,
    RepeatFrequency? frequency,
    int? interval,
    RepeatEnds? ends,
    DateTime? endDate,
    int? afterCount,
    List<int>? daysOfWeek,
    bool clearEndDate = false,
    bool clearAfterCount = false,
    bool clearDaysOfWeek = false,
  }) {
    return RepeatConfig(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      ends: ends ?? this.ends,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      afterCount: clearAfterCount ? null : afterCount ?? this.afterCount,
      daysOfWeek: clearDaysOfWeek ? null : daysOfWeek ?? this.daysOfWeek,
    );
  }

  // ── Summary string (shown in the Create Event row) ─────────────────────────

  String summary() {
    if (!enabled) return 'Never';

    final freqLabel = _frequencyLabel();
    final endsLabel = _endsLabel();

    if (endsLabel.isEmpty) return freqLabel;
    return '$freqLabel · $endsLabel';
  }

  String _frequencyLabel() {
    switch (frequency) {
      case RepeatFrequency.daily:
        return interval == 1 ? 'Every day' : 'Every $interval days';
      case RepeatFrequency.weekly:
        return interval == 1 ? 'Every week' : 'Every $interval weeks';
      case RepeatFrequency.biweekly:
        return 'Every 2 weeks';
      case RepeatFrequency.monthly:
        return interval == 1 ? 'Every month' : 'Every $interval months';
      case RepeatFrequency.custom:
        return _customDaysLabel();
      default:
        return 'Repeats';
    }
  }

  String _endsLabel() {
    switch (ends) {
      case RepeatEnds.never:
        return '';
      case RepeatEnds.onDate:
        if (endDate == null) return '';
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
        return 'until ${months[endDate!.month - 1]} ${endDate!.day}';
      case RepeatEnds.after:
        return 'for ${afterCount ?? 0} times';
      default:
        return '';
    }
  }

  String _customDaysLabel() {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) return 'Custom';

    const dayNames = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    final sorted = [...daysOfWeek!]..sort();

    // Shorthand for common patterns
    if (sorted.length == 7) return 'Every day';
    if (sorted.length == 5 && !sorted.contains(6) && !sorted.contains(7)) {
      return 'Weekdays';
    }
    if (sorted.length == 2 && sorted.contains(6) && sorted.contains(7)) {
      return 'Weekends';
    }

    return sorted.map((d) => dayNames[d] ?? '').join(', ');
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  String? validate() {
    if (!enabled) return null;
    if (frequency == null) return 'Please select a frequency';
    if (ends == RepeatEnds.onDate && endDate == null) {
      return 'Please select an end date';
    }
    if (ends == RepeatEnds.after && (afterCount == null || afterCount! < 1)) {
      return 'Please enter a valid number of occurrences';
    }
    if (frequency == RepeatFrequency.custom &&
        (daysOfWeek == null || daysOfWeek!.isEmpty)) {
      return 'Please select at least one day';
    }
    return null;
  }

  bool get isValid => validate() == null;

  // ── Equality ───────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RepeatConfig) return false;
    return enabled == other.enabled &&
        frequency == other.frequency &&
        interval == other.interval &&
        ends == other.ends &&
        endDate == other.endDate &&
        afterCount == other.afterCount &&
        _listEquals(daysOfWeek, other.daysOfWeek);
  }

  @override
  int get hashCode => Object.hash(
    enabled,
    frequency,
    interval,
    ends,
    endDate,
    afterCount,
    Object.hashAll(daysOfWeek ?? []),
  );

  @override
  String toString() => 'RepeatConfig(${summary()})';

  // ── Private helpers ────────────────────────────────────────────────────────

  static RepeatEnds _parseEnds(String value) {
    switch (value) {
      case 'on_date':
        return RepeatEnds.onDate;
      case 'after':
        return RepeatEnds.after;
      default:
        return RepeatEnds.never;
    }
  }

  static String? _endsToString(RepeatEnds? ends) {
    switch (ends) {
      case RepeatEnds.onDate:
        return 'on_date';
      case RepeatEnds.after:
        return 'after';
      case RepeatEnds.never:
        return 'never';
      default:
        return null;
    }
  }

  static bool _listEquals(List<int>? a, List<int>? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
