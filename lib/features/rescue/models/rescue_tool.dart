import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Something different to try when breathing alone has not been enough.
class RescueTool {
  const RescueTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

const rescueTools = [
  RescueTool(
    id: 'grounding',
    title: 'Ground yourself',
    subtitle: 'Count what is around you. Pulls your head out of the urge.',
    icon: Symbols.visibility_rounded,
  ),
  RescueTool(
    id: 'delay',
    title: 'Not for ten minutes',
    subtitle: 'Put the decision off. We will check back with you.',
    icon: Symbols.hourglass_top_rounded,
  ),
  RescueTool(
    id: 'water',
    title: 'Drink a glass of water',
    subtitle: 'Gives your hands and mouth something else to do.',
    icon: Symbols.water_drop_rounded,
  ),
  RescueTool(
    id: 'move',
    title: 'Change where you are',
    subtitle: 'Stand up and leave the spot the craving found you in.',
    icon: Symbols.directions_walk_rounded,
  ),
  RescueTool(
    id: 'reason',
    title: 'Read your reason',
    subtitle: 'The words you wrote for exactly this moment.',
    icon: Symbols.favorite_rounded,
  ),
];

RescueTool rescueToolById(String? id) {
  return rescueTools.firstWhere(
    (tool) => tool.id == id,
    orElse: () => rescueTools.first,
  );
}
