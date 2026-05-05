class Attendee {
  final String id;
  final String eventId;
  final String userId;
  final AttendeeStatus status;
  final DateTime createdAt;

  const Attendee({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
    id: json['id'] as String,
    eventId: json['event_id'] as String,
    userId: json['user_id'] as String,
    status: AttendeeStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

enum AttendeeStatus { owner, invited, going, maybe, declined }
