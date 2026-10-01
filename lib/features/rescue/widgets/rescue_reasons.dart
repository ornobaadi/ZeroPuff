import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// What might be pulling the user toward a cigarette right now.
class RescueReason {
  const RescueReason({
    required this.value,
    required this.title,
    required this.icon,
  });

  final String value;
  final String title;
  final IconData icon;
}

const rescueReasons = [
  RescueReason(value: 'stress', title: 'Stressed', icon: Symbols.bolt_rounded),
  RescueReason(
    value: 'bored',
    title: 'Bored',
    icon: Symbols.hourglass_empty_rounded,
  ),
  RescueReason(
    value: 'after food',
    title: 'After food',
    icon: Symbols.restaurant_rounded,
  ),
  RescueReason(
    value: 'coffee',
    title: 'Coffee',
    icon: Symbols.local_cafe_rounded,
  ),
  RescueReason(
    value: 'social',
    title: 'Social pressure',
    icon: Symbols.groups_rounded,
  ),
  RescueReason(
    value: 'routine',
    title: 'Routine',
    icon: Symbols.repeat_rounded,
  ),
  RescueReason(value: 'tired', title: 'Tired', icon: Symbols.bedtime_rounded),
  RescueReason(
    value: 'other',
    title: 'Something else',
    icon: Symbols.more_horiz_rounded,
  ),
];

const rescueFallbackReason = 'I am choosing the next clean breath.';
