// lib/features/home/home_data.dart
import 'package:pingo/features/home/models/event_summary.dart';
import 'package:pingo/features/home/models/user_stats.dart';

class HomeData {
  final EventSummary? todayEvent;
  final List<EventSummary> upcoming;
  final UserStats stats;

  HomeData({
    required this.todayEvent,
    required this.upcoming,
    required this.stats,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    todayEvent: json['today'] != null
        ? EventSummary.fromJson((json['today'] as List).first)
        : null,
    upcoming: (json['upcoming'] as List? ?? [])
        .map((e) => EventSummary.fromJson(e))
        .toList(),
    stats: UserStats.fromJson(json['stats']),
  );
}
