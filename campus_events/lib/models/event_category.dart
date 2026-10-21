import 'package:flutter/material.dart';

/// Enhanced enum: every value carries its own label and icon.
enum EventCategory {
  tech('Tech', Icons.computer),
  science('Science', Icons.science),
  career('Career', Icons.work),
  sport('Sport', Icons.sports_soccer),
  music('Music', Icons.music_note),
  social('Social', Icons.celebration)
  ;

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Exhaustive switch expression: adding a value without a colour
  /// is a compile error, so the compiler leads you to every place.
  Color colorIn(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primaryContainer,
    EventCategory.science => scheme.tertiaryContainer,
    EventCategory.career => scheme.secondaryContainer,
    EventCategory.sport => scheme.errorContainer,
    EventCategory.music => scheme.inversePrimary,
    EventCategory.social => scheme.surfaceContainerHighest,
  };
}
