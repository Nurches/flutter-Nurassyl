import '../models/event.dart';
import '../models/event_category.dart';

/// Twelve events with dates relative to today, so the app never goes stale.
/// Mandatory ones: e1 (60-char title), e2 (full), e3 (past), e4 (online),
/// e5 (no description).
List<Event> seedEvents() {
  final now = DateTime.now();
  // DateTime normalises overflow: day 32 becomes the 1st of the next month.
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Event(
      id: 'e1',
      title: "KBTU Spring Research Symposium: Applied Machine Learning '26",
      category: EventCategory.science,
      starts: at(5, 10),
      location: 'Main building, Assembly Hall',
      capacity: 120,
      attendees: const ['Aruzhan', 'Dias', 'Madina', 'Timur'],
      description:
          'Students and faculty present their applied ML projects. '
          'Posters from 10:00, talks from 11:30.',
    ),
    Event(
      id: 'e2',
      title: 'iOS & Flutter Hackathon',
      category: EventCategory.tech,
      starts: at(2, 9),
      location: 'Room 404, Tole bi 59',
      capacity: 6,
      attendees: const ['Aruzhan', 'Dias', 'Madina', 'Timur', 'Aigerim', 'Ali'],
      description: 'Teams of two, 24 hours, pizza included.',
      isFavourite: true,
    ),
    Event(
      id: 'e3',
      title: 'Freshers Welcome Party',
      category: EventCategory.social,
      starts: at(-3, 18),
      location: 'Student Center',
      capacity: 200,
      attendees: const ['Dias', 'Aigerim', 'Nursultan'],
      description: 'Music, games and the first meeting with your curators.',
    ),
    Event(
      id: 'e4',
      title: 'Online Career Talk: Mobile at Kaspi',
      category: EventCategory.career,
      starts: at(1, 19),
      location: 'https://meet.google.com/kbtu-mobile-talk',
      capacity: 300,
      attendees: const ['Timur', 'Ali'],
      isOnline: true,
      description: 'How a mobile team ships to millions of users every week.',
      isFavourite: true,
    ),
    Event(
      id: 'e5',
      title: 'Futsal Cup: IS vs CSSE',
      category: EventCategory.sport,
      starts: at(3, 17, 30),
      location: 'KBTU Sports Hall',
      capacity: 40,
      attendees: const ['Nursultan', 'Ali', 'Yerlan'],
    ),
    Event(
      id: 'e6',
      title: 'Jazz Evening',
      category: EventCategory.music,
      starts: at(6, 20),
      location: 'Library courtyard',
      capacity: 25,
      attendees: const [
        'Aruzhan', 'Madina', 'Aigerim', 'Zhanna', 'Yerlan', //
        'Dana', 'Saule', 'Arman', 'Bekzat', 'Alina', //
        'Kamila', 'Miras', 'Askar', 'Togzhan', 'Daniyar', //
        'Asel', 'Erzhan', 'Aliya', 'Nurlan', 'Gulnaz', 'Ilyas',
      ],
      description: 'A student band plays standards. Bring a blanket.',
    ),
    Event(
      id: 'e7',
      title: 'Git for Beginners Workshop',
      category: EventCategory.tech,
      starts: at(0, 16),
      location: 'Room 310',
      capacity: 30,
      attendees: const ['Dana', 'Saule'],
      description: 'Branches, commits and pull requests on real projects.',
    ),
    Event(
      id: 'e8',
      title: 'Physics Olympiad Prep',
      category: EventCategory.science,
      starts: at(8, 15),
      location: 'Room 215',
      capacity: 15,
      attendees: const ['Miras', 'Askar'],
      description: 'Problem-solving session with last year\'s winners.',
    ),
    Event(
      id: 'e9',
      title: 'CV Review with HR from Big Four',
      category: EventCategory.career,
      starts: at(-1, 14),
      location: 'Career Center, room 120',
      capacity: 20,
      attendees: const ['Kamila', 'Arman', 'Bekzat'],
      description: 'Bring a printed CV and get feedback in ten minutes.',
    ),
    Event(
      id: 'e10',
      title: 'Morning Run Club',
      category: EventCategory.sport,
      starts: at(1, 7),
      location: 'Main entrance',
      capacity: 50,
      attendees: const ['Yerlan', 'Togzhan'],
      description: '5 km around the campus at an easy pace.',
    ),
    Event(
      id: 'e11',
      title: 'Open Mic Night',
      category: EventCategory.music,
      starts: at(10, 19),
      location: 'Student Center, stage',
      capacity: 80,
      attendees: const ['Alina', 'Daniyar'],
      description: 'Sing, read poetry or play — five minutes each.',
    ),
    Event(
      id: 'e12',
      title: 'Board Games Night',
      category: EventCategory.social,
      starts: at(4, 18),
      location: 'Dormitory lounge',
      capacity: 12,
      attendees: const [
        'Asel',
        'Erzhan',
        'Aliya',
        'Nurlan',
        'Gulnaz',
        'Ilyas',
        'Dias',
        'Ali',
      ],
      description: 'Catan, Codenames and Mafia. Snacks welcome.',
    ),
  ];
}
