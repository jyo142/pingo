// lib/features/events/services/event_service.dart

import 'package:flutter/material.dart';
import 'package:pingo/features/events/models/attendee.dart';
import 'package:pingo/features/events/models/event.dart';
import 'package:pingo/features/events/models/event_exception.dart';
import 'package:pingo/features/events/models/event_occurance.dart';
import 'package:pingo/features/events/models/repeat_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Service ───────────────────────────────────────────────────────────────────

class EventService {
  static final _db = Supabase.instance.client;

  static String get _userId {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  // ── Create ──────────────────────────────────────────────────────────────────

  static Future<Event> createEvent({
    required String name,
    String? description,
    String? location,
    required DateTime startsAt,
    required DateTime endsAt,
    RepeatConfig? repeat,
    String attendanceType = 'qr_code',
  }) async {
    final eventData = await _db.rpc(
      'create_event_with_owner',
      params: {
        'p_owner_id': _userId,
        'p_name': name,
        'p_description': description,
        'p_location': location,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_ends_at': endsAt.toUtc().toIso8601String(),
        'p_attendance_type': attendanceType,
        'p_repeat_enabled': repeat?.enabled ?? false,
        'p_frequency': repeat?.frequency?.name,
        'p_interval': repeat?.interval ?? 1,
        'p_ends': repeat?.ends?.name ?? 'never',
        'p_end_date': repeat?.endDate?.toIso8601String(),
        'p_after_count': repeat?.afterCount,
        'p_days_of_week': repeat?.daysOfWeek,
      },
    );

    return Event.fromJson(eventData);
  }

  // ── Read ────────────────────────────────────────────────────────────────────

  /// Fetch all events for the current user (with repeat config joined)
  static Future<List<Event>> getMyEvents() async {
    final data = await _db
        .from('events_with_repeat')
        .select()
        .eq('owner_id', _userId)
        .order('starts_at');

    return (data as List).map((e) => Event.fromJson(e)).toList();
  }

  /// Fetch a single event by ID
  static Future<Event> getEvent(String eventId) async {
    final data = await _db
        .from('events_with_repeat')
        .select()
        .eq('id', eventId)
        .single();

    return Event.fromJson(data);
  }

  /// Fetch events within a date range (for calendar view)
  static Future<List<Event>> getEventsInRange(
    DateTime from,
    DateTime to,
  ) async {
    final data = await _db
        .from('events_with_repeat')
        .select()
        .eq('owner_id', _userId)
        .lte('starts_at', to.toUtc().toIso8601String())
        .gte('ends_at', from.toUtc().toIso8601String())
        .order('starts_at');

    return (data as List).map((e) => Event.fromJson(e)).toList();
  }

  /// Fetch all exceptions for an event
  static Future<List<EventException>> getExceptions(String eventId) async {
    final data = await _db
        .from('event_exceptions')
        .select()
        .eq('event_id', eventId)
        .order('original_date');

    return (data as List).map((e) => EventException.fromJson(e)).toList();
  }

  /// Expand a repeating event into individual occurrences for a date range.
  /// Applies exceptions (modifications + cancellations) automatically.
  static List<EventOccurrence> expandOccurrences({
    required Event event,
    required List<EventException> exceptions,
    required DateTime from,
    required DateTime to,
  }) {
    final occurrences = <EventOccurrence>[];
    final exceptionMap = {for (final e in exceptions) e.originalDate: e};
    final repeat = event.repeat;

    if (repeat == null || !repeat.enabled) {
      // Non-repeating — just return the single occurrence if in range
      if (!event.startsAt.isBefore(from) && !event.startsAt.isAfter(to)) {
        occurrences.add(EventOccurrence.fromMaster(event, event.startsAt));
      }
      return occurrences;
    }

    // Generate all scheduled dates and apply exceptions
    final dates = _generateDates(
      event: event,
      repeat: repeat,
      from: from,
      to: to,
    );

    for (final date in dates) {
      // Normalise to UTC for map lookup
      final key = date.toUtc();
      final exception = exceptionMap[key];

      if (exception == null) {
        occurrences.add(EventOccurrence.fromMaster(event, date));
      } else if (exception.type == ExceptionType.cancelled) {
        continue; // skip cancelled occurrences
      } else {
        occurrences.add(EventOccurrence.fromException(event, exception));
      }
    }

    return occurrences;
  }

  // ── Update ──────────────────────────────────────────────────────────────────

  /// Update all occurrences (edits the master event)
  static Future<void> updateAllOccurrences({
    required String eventId,
    required Map<String, dynamic> changes,
    RepeatConfig? repeat,
  }) async {
    // Convert DateTime fields to UTC strings
    final payload = _serializeChanges(changes);

    await _db.from('events').update(payload).eq('id', eventId);

    // Update repeat config if provided
    if (repeat != null) {
      await _db.from('repeat_configs').upsert({
        'event_id': eventId,
        'frequency': repeat.enabled ? repeat.frequency?.name : null,
        'interval': repeat.interval ?? 1,
        'ends': repeat.ends?.name ?? 'never',
        'end_date': repeat.endDate?.toIso8601String(),
        'after_count': repeat.afterCount,
        'days_of_week': repeat.daysOfWeek,
      });
    }
  }

  /// Modify a single occurrence only
  static Future<void> updateThisOccurrence({
    required String eventId,
    required DateTime originalDate,
    required Map<String, dynamic> changes,
  }) async {
    final payload = _serializeChanges(changes);

    await _db.from('event_exceptions').upsert({
      'event_id': eventId,
      'original_date': originalDate.toUtc().toIso8601String(),
      'exception_type': 'modified',
      ...payload,
    });
  }

  /// Modify this and all future occurrences.
  /// Cuts off the old repeat rule and creates a new master event from this date.
  static Future<void> updateThisAndFuture({
    required Event originalEvent,
    required DateTime fromDate,
    required Map<String, dynamic> changes,
    RepeatConfig? repeat,
  }) async {
    // 1. Cap the existing repeat rule just before this occurrence
    await _db
        .from('repeat_configs')
        .update({
          'ends': 'on_date',
          'end_date': fromDate
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        })
        .eq('event_id', originalEvent.id);

    // 2. Cancel any existing exceptions from this date forward
    //    (they belong to the old rule — the new event starts fresh)
    final exceptions = await getExceptions(originalEvent.id);
    final futureExceptionIds = exceptions
        .where((e) => !e.originalDate.isBefore(fromDate))
        .map((e) => e.id)
        .toList();

    if (futureExceptionIds.isNotEmpty) {
      await _db
          .from('event_exceptions')
          .delete()
          .inFilter('id', futureExceptionIds);
    }

    // 3. Create a new master event with the changes applied
    final merged = {
      'name': originalEvent.name,
      'description': originalEvent.description,
      'location': originalEvent.location,
      ...changes,
    };

    final duration = originalEvent.endsAt.difference(originalEvent.startsAt);
    final newStartsAt = changes['starts_at'] as DateTime? ?? fromDate;
    final newEndsAt =
        changes['ends_at'] as DateTime? ?? newStartsAt.add(duration);

    await createEvent(
      name: merged['name'] as String,
      description: merged['description'] as String?,
      location: merged['location'] as String?,
      startsAt: newStartsAt,
      endsAt: newEndsAt,
      repeat: repeat ?? originalEvent.repeat,
      attendanceType: originalEvent.attendanceType,
    );
  }

  // ── Cancel / Delete ─────────────────────────────────────────────────────────

  /// Cancel a single occurrence (keeps event, skips this date)
  static Future<void> cancelOccurrence({
    required String eventId,
    required DateTime originalDate,
  }) async {
    await _db.from('event_exceptions').upsert({
      'event_id': eventId,
      'original_date': originalDate.toUtc().toIso8601String(),
      'exception_type': 'cancelled',
    });
  }

  /// Delete the entire event and all related data (cascade handles the rest)
  static Future<void> deleteEvent(String eventId) async {
    await _db.from('events').delete().eq('id', eventId);
  }

  // ── Attendees ───────────────────────────────────────────────────────────────

  static Future<List<Attendee>> getAttendees(String eventId) async {
    final data = await _db
        .from('attendees')
        .select()
        .eq('event_id', eventId)
        .order('created_at');

    return (data as List).map((e) => Attendee.fromJson(e)).toList();
  }

  static Future<void> inviteAttendee({
    required String eventId,
    required String userId,
  }) async {
    await _db.from('attendees').insert({
      'event_id': eventId,
      'user_id': userId,
      'status': 'invited',
    });
  }

  static Future<void> updateAttendeeStatus({
    required String eventId,
    required String userId,
    required AttendeeStatus status,
  }) async {
    await _db
        .from('attendees')
        .update({'status': status.name})
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  static Future<void> removeAttendee({
    required String eventId,
    required String userId,
  }) async {
    await _db
        .from('attendees')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Generate all scheduled dates for a repeating event within a range
  static List<DateTime> _generateDates({
    required Event event,
    required RepeatConfig repeat,
    required DateTime from,
    required DateTime to,
  }) {
    final dates = <DateTime>[];
    var current = event.startsAt;
    final interval = repeat.interval ?? 1;

    // Determine hard end from repeat config
    DateTime? hardEnd;
    if (repeat.ends?.name == 'on_date' && repeat.endDate != null) {
      hardEnd = repeat.endDate;
    }

    int count = 0;

    while (!current.isAfter(to)) {
      // Stop if past the repeat end date
      if (hardEnd != null && current.isAfter(hardEnd)) break;

      // Stop if after_count limit reached
      if (repeat.ends?.name == 'after' && repeat.afterCount != null) {
        if (count >= repeat.afterCount!) break;
      }

      // Only include dates within the requested range
      if (!current.isBefore(from)) {
        // For custom frequency, check if this day of week is allowed
        if (repeat.frequency?.name == 'custom') {
          if (repeat.daysOfWeek?.contains(current.weekday) ?? false) {
            dates.add(current);
            count++;
          }
        } else {
          dates.add(current);
          count++;
        }
      }

      // Advance to next occurrence
      current = _advance(current, repeat.frequency?.name, interval);
    }

    return dates;
  }

  static DateTime _advance(DateTime date, String? frequency, int interval) {
    switch (frequency) {
      case 'daily':
        return date.add(Duration(days: interval));
      case 'weekly':
        return date.add(Duration(days: 7 * interval));
      case 'biweekly':
        return date.add(const Duration(days: 14));
      case 'monthly':
        return DateTime(
          date.year,
          date.month + interval,
          date.day,
          date.hour,
          date.minute,
        );
      case 'custom':
        return date.add(const Duration(days: 1)); // check each day
      default:
        return date.add(Duration(days: interval));
    }
  }

  /// Serialize a changes map — converts DateTime to UTC ISO string
  static Map<String, dynamic> _serializeChanges(Map<String, dynamic> changes) {
    return changes.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toUtc().toIso8601String());
      }
      return MapEntry(key, value);
    });
  }
}
