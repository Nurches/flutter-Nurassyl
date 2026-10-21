import 'package:flutter/material.dart';

import 'models/event.dart';
import 'screens/detail_screen.dart';
import 'screens/event_form_screen.dart';

/// Every route name in one place — no '/...' literal anywhere else.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';

  /// Builds the pushed screens from typed argument classes. Returning null
  /// (wrong name or wrong argument type) hands over to [onUnknownRoute].
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch ((settings.name, settings.arguments)) {
      (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      ),
      (Routes.form, final FormArgs args) => MaterialPageRoute<Event>(
        settings: settings,
        builder: (_) => EventFormScreen(event: args.event),
      ),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _NotFoundScreen(name: settings.name),
    );
  }
}

/// What the detail screen needs: the event, who "you" are, and callbacks
/// that send changes back up to the shell.
class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onGoToProfile,
  });

  final Event event;
  final String userName;
  final ValueChanged<Event> onChanged;
  final ValueChanged<Event> onDelete;
  final VoidCallback onGoToProfile;
}

/// null for a new event, the event itself for editing.
class FormArgs {
  const FormArgs({this.event});

  final Event? event;
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('No screen called "${name ?? ''}"')),
    );
  }
}
