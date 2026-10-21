import 'event.dart';

/// Where an event is in time. Sealed: a switch over it must handle
/// all three subclasses, or it does not compile.
sealed class Countdown {
  const Countdown();

  factory Countdown.of(Event event, DateTime now) {
    if (now.isBefore(event.starts)) {
      return Upcoming(event.starts.difference(now));
    }
    if (now.isBefore(event.ends)) {
      return Started(now.difference(event.starts));
    }
    return const Ended();
  }
}

/// Not started yet; [left] is the time until the start.
final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

/// Going on right now; [elapsed] is the time since the start.
final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}
