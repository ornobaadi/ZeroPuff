import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A common moment of the day that tends to come with a cigarette, offered as
/// a one-tap starting point. The time is only a default and can be changed.
class RitualPreset {
  const RitualPreset({
    required this.id,
    required this.label,
    required this.startMinutes,
    required this.icon,
  });

  final String id;
  final String label;
  final int startMinutes;
  final IconData icon;

  static const all = [
    RitualPreset(
      id: 'wake_up',
      label: 'Waking up',
      startMinutes: 7 * 60,
      icon: Symbols.wb_twilight_rounded,
    ),
    RitualPreset(
      id: 'coffee',
      label: 'Morning coffee',
      startMinutes: 9 * 60,
      icon: Symbols.local_cafe_rounded,
    ),
    RitualPreset(
      id: 'after_lunch',
      label: 'After lunch',
      startMinutes: 13 * 60 + 30,
      icon: Symbols.restaurant_rounded,
    ),
    RitualPreset(
      id: 'work_break',
      label: 'Afternoon break',
      startMinutes: 16 * 60,
      icon: Symbols.work_rounded,
    ),
    RitualPreset(
      id: 'commute',
      label: 'Heading home',
      startMinutes: 18 * 60,
      icon: Symbols.commute_rounded,
    ),
    RitualPreset(
      id: 'after_dinner',
      label: 'After dinner',
      startMinutes: 20 * 60 + 30,
      icon: Symbols.dinner_dining_rounded,
    ),
    RitualPreset(
      id: 'before_bed',
      label: 'Before bed',
      startMinutes: 23 * 60,
      icon: Symbols.bedtime_rounded,
    ),
  ];

  static RitualPreset? byId(String id) {
    for (final preset in all) {
      if (preset.id == id) {
        return preset;
      }
    }
    return null;
  }

  static IconData iconForLabel(String label) {
    for (final preset in all) {
      if (preset.label == label) {
        return preset.icon;
      }
    }
    return Symbols.schedule_rounded;
  }
}
