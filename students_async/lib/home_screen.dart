import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

/// Three ways in. Every screen is pushed, so Back disposes it — which is
/// exactly what the mounted / cancel() experiments need.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The Data Arrives Later')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Entry(
          icon: Icons.handyman_outlined,
          title: 'By hand',
          subtitle: 'Three fields, try / catch, mounted, Save',
          builder: (_) => const StudentsScreen(),
        ),
        _Entry(
          icon: Icons.hourglass_bottom,
          title: 'FutureBuilder',
          subtitle: 'A stored Future and a Switch that must not reload',
          builder: (_) => const StudentsFutureScreen(),
        ),
        _Entry(
          icon: Icons.timer_outlined,
          title: 'Countdown',
          subtitle: 'async* — StreamBuilder vs listen + cancel()',
          builder: (_) => const CountdownScreen(),
        ),
      ],
    ),
  );
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: builder)),
    ),
  );
}
