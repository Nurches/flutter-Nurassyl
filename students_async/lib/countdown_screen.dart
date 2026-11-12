import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum _Version { builder, listen }

/// The same countdown(10), two ways. Switching the segment disposes the
/// other version, exactly like pressing Back.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  _Version _version = _Version.builder;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<_Version>(
            segments: const [
              ButtonSegment(
                value: _Version.builder,
                label: Text('A · StreamBuilder'),
              ),
              ButtonSegment(
                value: _Version.listen,
                label: Text('B · listen'),
              ),
            ],
            selected: {_version},
            onSelectionChanged: (s) => setState(() => _version = s.first),
          ),
        ),
        Expanded(
          child: switch (_version) {
            _Version.builder => const _BuilderCountdown(),
            _Version.listen => const _ListenCountdown(),
          },
        ),
      ],
    ),
  );
}

/// Version A: StreamBuilder subscribes and cancels for us.
class _BuilderCountdown extends StatefulWidget {
  const _BuilderCountdown();

  @override
  State<_BuilderCountdown> createState() => _BuilderCountdownState();
}

class _BuilderCountdownState extends State<_BuilderCountdown> {
  // A field, like the Future in Level 3: a rebuild must not restart it.
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) => _Big(
      value: snapshot.data ?? 10,
      caption: 'StreamBuilder — no cancel() in my code',
    ),
  );
}

/// Version B: we subscribe ourselves, so we must cancel ourselves.
class _ListenCountdown extends StatefulWidget {
  const _ListenCountdown();

  @override
  State<_ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<_ListenCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    // Without this line the generator keeps ticking for a dead screen and
    // every tick calls setState() after dispose().
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Big(
    value: _left,
    caption: 'listen() + cancel() in dispose',
  );
}

class _Big extends StatelessWidget {
  const _Big({required this.value, required this.caption});

  final int value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 120,
              fontWeight: FontWeight.w300,
              color: value == 0 ? theme.colorScheme.primary : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value == 0 ? 'Done' : caption,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
