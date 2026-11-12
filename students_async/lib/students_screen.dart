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

  bool _saving = false; // Level 5: a Save is in flight

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

  // Takes the button's context: a callback guards its own context with
  // context.mounted after every await (a State would check mounted).
  Future<void> _save(BuildContext context) async {
    setState(() => _saving = true);
    try {
      await _api.save(_students!.length);
      if (!context.mounted) return;
      Navigator.pop(context); // pop only on success
    } on StateError catch (e) {
      if (!context.mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
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
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              tooltip: 'Save',
              // null while saving: a second fast tap is not a second request.
              onPressed: _saving ? null : () => _save(context),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.save),
            ),
    );
  }
}
