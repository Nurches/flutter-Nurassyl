import 'dart:collection';

import 'event_category.dart';

/// One campus event. Immutable: every change goes through [copyWith].
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.starts,
    required this.location,
    required this.capacity,
    List<String> attendees = const [],
    this.isOnline = false,
    this.description,
    this.isFavourite = false,
  }) : _attendees = attendees;

  /// Defaults for a brand-new event. Category and date have no sensible
  /// default, so the form leaves them empty for a new event.
  Event.empty()
    : id = '',
      title = '',
      category = EventCategory.tech,
      starts = DateTime.now(),
      location = '',
      capacity = 30,
      _attendees = const [],
      isOnline = false,
      description = null,
      isFavourite = false;

  /// How long every event lasts; used by [isPast] and the countdown.
  static const length = Duration(hours: 2);

  final String id;
  final String title;
  final EventCategory category;
  final DateTime starts;

  /// A room when offline, a link (contains "://") when [isOnline].
  final String location;
  final int capacity;
  final List<String> _attendees;
  final bool isOnline;
  final String? description;
  final bool isFavourite;

  /// Read-only view: `event.attendees.add(...)` throws instead of
  /// silently changing state behind the shell's back.
  List<String> get attendees => UnmodifiableListView(_attendees);

  // Derived values are getters, never stored fields.
  int get count => _attendees.length;
  int get free => capacity - count;
  bool get isFull => count >= capacity;
  DateTime get ends => starts.add(length);
  bool get isPast => DateTime.now().isAfter(ends);
  bool contains(String name) => _attendees.contains(name);

  /// Record getter, destructured where shown: `final (:taken, :free) = e.places;`
  ({int taken, int free}) get places => (taken: count, free: free);

  /// Display order: upcoming first, past last; inside each group by date.
  /// Used on a copy (`toList()..sort(...)`), never on the shell's list.
  static int compareForDisplay(Event a, Event b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.starts.compareTo(b.starts);
  }

  /// Returns a copy with [name] added — the original stays untouched.
  Event register(String name) => copyWith(attendees: [..._attendees, name]);

  /// Returns a copy without [name].
  Event unregister(String name) =>
      copyWith(attendees: _attendees.where((n) => n != name).toList());

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? starts,
    String? location,
    int? capacity,
    List<String>? attendees,
    bool? isOnline,
    String? description,
    bool clearDescription = false,
    bool? isFavourite,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      starts: starts ?? this.starts,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      attendees: List.unmodifiable(attendees ?? _attendees),
      isOnline: isOnline ?? this.isOnline,
      // `description ?? this.description` could never set it back to null,
      // hence the explicit flag.
      description: clearDescription ? null : description ?? this.description,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}
