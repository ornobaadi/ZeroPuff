import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The icon for how a day felt, from hardest (1) to clearest (5).
IconData feelingIcon(int value) {
  return switch (value) {
    1 => Symbols.thunderstorm_rounded,
    2 => Symbols.waves_rounded,
    3 => Symbols.balance_rounded,
    4 => Symbols.spa_rounded,
    _ => Symbols.wb_sunny_rounded,
  };
}
