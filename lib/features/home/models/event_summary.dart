class EventSummary {
  final String id, name, location, status;
  final DateTime startsAt;

  EventSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.startsAt,
  });

  factory EventSummary.fromJson(Map<String, dynamic> j) => EventSummary(
    id: j['id'],
    name: j['name'],
    location: j['location'] ?? '',
    status: j['status'],
    startsAt: DateTime.parse(j['starts_at']),
  );
}
