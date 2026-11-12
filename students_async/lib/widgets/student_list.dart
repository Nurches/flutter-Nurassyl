import 'package:flutter/material.dart';

import '../api/fake_api.dart';

/// State 4 of 4: the data.
class StudentList extends StatelessWidget {
  const StudentList(this.students, {super.key, this.compact = false});

  final List<Student> students;
  final bool compact;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.only(bottom: 88), // room for a FAB
    itemCount: students.length,
    itemBuilder: (context, i) {
      final s = students[i];
      return ListTile(
        dense: compact,
        visualDensity: compact ? VisualDensity.compact : null,
        leading: compact ? null : CircleAvatar(child: Text(_initials(s.name))),
        title: Text(s.name),
        subtitle: Text(s.group),
        trailing: Text(
          s.gpa?.toStringAsFixed(1) ?? '—',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    },
  );

  static String _initials(String name) =>
      name.split(' ').map((w) => w[0]).take(2).join();
}
