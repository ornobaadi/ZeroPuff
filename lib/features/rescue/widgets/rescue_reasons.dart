import 'package:flutter/material.dart';

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
  RescueReason(value: 'stress', title: 'Stressed', icon: Icons.bolt_rounded),
  RescueReason(
    value: 'bored',
    title: 'Bored',
    icon: Icons.hourglass_empty_rounded,
  ),
  RescueReason(
    value: 'after food',
    title: 'After food',
    icon: Icons.restaurant_rounded,
  ),
  RescueReason(
    value: 'coffee',
    title: 'Coffee',
    icon: Icons.local_cafe_rounded,
  ),
  RescueReason(
    value: 'social',
    title: 'Social pressure',
    icon: Icons.groups_rounded,
  ),
  RescueReason(value: 'routine', title: 'Routine', icon: Icons.repeat_rounded),
  RescueReason(value: 'tired', title: 'Tired', icon: Icons.bedtime_rounded),
  RescueReason(
    value: 'other',
    title: 'Something else',
    icon: Icons.more_horiz_rounded,
  ),
];

const rescueFallbackReason = 'I am choosing the next clean breath.';
