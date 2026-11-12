import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// The four states by hand: three fields and one method.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi();

  @override
  void initState() {
    super.initState();
    // Called, not awaited: initState is synchronous and the framework will
    // not wait. unawaited() says so on purpose; _load catches its own errors.
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      // The line after await runs later: the user may have pressed Back.
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _students == null && _error == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students · by hand'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch ((_error, _students)) {
        (Object _, _) => ErrorView(onRetry: _load),
        (null, null) => const LoadingView(),
        (null, final list?) when list.isEmpty => const EmptyView(),
        (null, final list?) => StudentList(list),
      },
    );
  }
}
