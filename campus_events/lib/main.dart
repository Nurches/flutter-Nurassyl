import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/event.dart';
import 'screens/events_tab.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Event> _events = seedEvents();

  void _toggleFavourite(Event event) {
    setState(() {
      _events = [
        for (final e in _events)
          if (e.id == event.id) e.copyWith(isFavourite: !e.isFavourite) else e,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Events',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Campus Events')),
        body: EventsTab(
          events: _events,
          onOpen: (_) {},
          onFavourite: _toggleFavourite,
        ),
      ),
    );
  }
}
