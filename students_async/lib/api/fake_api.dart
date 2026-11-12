import 'package:flutter/foundation.dart';

class Student {
  const Student({
    required this.name,
    required this.group,
    this.gpa,
  });
  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

// Level 1: the API that does not exist yet. It must feel like a
// network: slow, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});
  final bool empty; // true -> the server has no students
  int calls = 0; // how many times fetchStudents() ran

  // Saves are counted on the "server", not per screen: every screen makes
  // its own FakeApi, but a Save that pops the screen must still meet the
  // failing second call the next time the screen is opened.
  static int _saves = 0;

  @visibleForTesting
  static void resetSaves() => _saves = 0;

  Future<List<Student>> fetchStudents() async {
    // The number is taken before the await: three calls in a row would all
    // read calls == 3 after it, and all three would fail instead of the third.
    final call = ++calls;
    debugPrint('fetchStudents #$call');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (call % 3 == 0) throw NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    final save = ++_saves;
    await Future<void>.delayed(const Duration(seconds: 1));
    if (save % 2 == 0) throw StateError('server rejected $value');
  }
}
