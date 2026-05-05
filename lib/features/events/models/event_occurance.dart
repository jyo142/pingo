import 'package:pingo/features/events/models/event.dart';
import 'package:pingo/features/events/models/event_exception.dart';

class EventOccurrence {
  final String eventId;
  final String? exceptionId; // null if this is an unmodified master occurrence
  final DateTime originalDate; // anchor — the originally scheduled date
  final String name;
  final String? description;
  final String? location;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isCancelled;
  final bool isModified;

  const EventOccurrence({
    required this.eventId,
    this.exceptionId,
    required this.originalDate,
    required this.name,
    this.description,
    this.location,
    required this.startsAt,
    required this.endsAt,
    this.isCancelled = false,
    this.isModified = false,
  });

  // Build from master event data (no exception)
  factory EventOccurrence.fromMaster(Event master, DateTime date) {
    final duration = master.endsAt.difference(master.startsAt);
    return EventOccurrence(
      eventId: master.id,
      originalDate: date,
      name: master.name,
      description: master.description,
      location: master.location,
      startsAt: date,
      endsAt: date.add(duration),
    );
  }

  // Build from exception — merges master defaults with exception overrides
  factory EventOccurrence.fromException(Event master, EventException ex) {
    final duration = master.endsAt.difference(master.startsAt);
    final startsAt = ex.startsAt ?? ex.originalDate;

    return EventOccurrence(
      eventId: master.id,
      exceptionId: ex.id,
      originalDate: ex.originalDate,
      name: ex.name ?? master.name,
      description: ex.description ?? master.description,
      location: ex.location ?? master.location,
      startsAt: startsAt,
      endsAt: ex.endsAt ?? startsAt.add(duration),
      isCancelled: ex.type == ExceptionType.cancelled,
      isModified: ex.type == ExceptionType.modified,
    );
  }
}
