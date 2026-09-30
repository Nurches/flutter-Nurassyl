import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int _seconds = 0;
  Timer? _timer;
  
  String get _formatted {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _start(){
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_){
      setState(() => _seconds++);
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _reset() {
    _stop();
    setState(() => _seconds = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _formatted,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                FilledButton(onPressed: _start, child: const Text('Start')),
                const SizedBox(width: 8,),
                OutlinedButton(onPressed: _stop, child: const Text('Stop')),
                const SizedBox(width: 8,),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            )
          ],
        ),
      ),
    );
  }
}