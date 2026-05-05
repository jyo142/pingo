class EventException {
  final String id;
  final String eventId;
  final DateTime originalDate;
  final ExceptionType type;

  // Override fields — null means "use master event value"
  final String? name;
  final String? description;
  final String? location;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime createdAt;

  const EventException({
    required this.id,
    required this.eventId,
    required this.originalDate,
    required this.type,
    this.name,
    this.description,
    this.location,
    this.startsAt,
    this.endsAt,
    required this.createdAt,
  });

  factory EventException.fromJson(Map<String, dynamic> json) => EventException(
    id: json['id'] as String,
    eventId: json['event_id'] as String,
    originalDate: DateTime.parse(json['original_date'] as String),
    type: ExceptionType.values.byName(json['exception_type'] as String),
    name: json['name'] as String?,
    description: json['description'] as String?,
    location: json['location'] as String?,
    startsAt: json['starts_at'] != null
        ? DateTime.parse(json['starts_at'] as String)
        : null,
    endsAt: json['ends_at'] != null
        ? DateTime.parse(json['ends_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

enum ExceptionType { modified, cancelled }
