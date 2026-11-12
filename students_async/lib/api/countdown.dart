import 'package:flutter/foundation.dart';

/// from, from-1, … 0 — one value per second.
///
/// The generator runs only while somebody listens. After cancel() it is
/// stopped at its next await/yield, so `tick` is how the console shows a leak.
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield i;
    debugPrint('tick $i');
  }
}
