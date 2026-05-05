import 'package:pingo/features/events/models/repeat_config.dart';

enum EditScope { thisOnly, thisAndFuture, allEvents }

class Event {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? location;
  final DateTime startsAt;
  final DateTime endsAt;
  final String attendanceType;
  final DateTime createdAt;

  // Joined from repeat_configs (via events_with_repeat view)
  final RepeatConfig? repeat;

  const Event({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.location,
    required this.startsAt,
    required this.endsAt,
    required this.attendanceType,
    required this.createdAt,
    this.repeat,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    RepeatConfig? repeat;
    if (json['frequency'] != null) {
      repeat = RepeatConfig.fromJson(json);
    }

    return Event(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
      attendanceType: json['attendance_type'] as String? ?? 'qr_code',
      createdAt: DateTime.parse(json['created_at'] as String),
      repeat: repeat,
    );
  }
}
