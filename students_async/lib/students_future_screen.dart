import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// The same screen with FutureBuilder: no fields for the states.
class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();

  // Late, but not final: _retry is the one place that is allowed to start a
  // new request. build only reads this field and never calls the API itself.
  late Future<List<Student>> _future;

  bool _compact = false; // a local rebuild that must not reload

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  void _retry() => setState(() => _future = _api.fetchStudents());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Students · FutureBuilder'),
      actions: [
        const Text('Compact'),
        Switch(
          value: _compact,
          onChanged: (v) => setState(() => _compact = v),
        ),
        IconButton(
          tooltip: 'Reload',
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<List<Student>>(
      future: _future, // the field, never a call
      builder: (context, snapshot) {
        // hasError first: a failed Future also has no data, and a
        // "no data -> spinner" check above it would spin forever.
        if (snapshot.hasError) return ErrorView(onRetry: _retry);
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final list = snapshot.data ?? const [];
        if (list.isEmpty) return const EmptyView();
        return StudentList(list, compact: _compact);
      },
    ),
  );
}
