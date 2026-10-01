import 'package:flutter/material.dart';

/// Corner scale. Everything the user touches is soft: cards sit at 24,
/// buttons at 20 (soft rectangle), chips and inputs at 16.
class AppShapes {
  const AppShapes._();

  static const double extraSmallRadius = 4;
  static const double smallRadius = 8;
  static const double mediumRadius = 12;
  static const double largeRadius = 16;
  static const double largeIncreasedRadius = 20;
  static const double extraLargeRadius = 24;
  static const double extraLargeIncreasedRadius = 32;

  static const extraSmall = BorderRadius.all(Radius.circular(extraSmallRadius));
  static const small = BorderRadius.all(Radius.circular(smallRadius));
  static const medium = BorderRadius.all(Radius.circular(mediumRadius));
  static const large = BorderRadius.all(Radius.circular(largeRadius));
  static const largeIncreased = BorderRadius.all(
    Radius.circular(largeIncreasedRadius),
  );
  static const extraLarge = BorderRadius.all(Radius.circular(extraLargeRadius));
  static const extraLargeIncreased = BorderRadius.all(
    Radius.circular(extraLargeIncreasedRadius),
  );

  // Semantic aliases used by components and existing screens.
  static const card = extraLarge;
  static const button = largeIncreased;
  static const input = large;
  static const chip = large;
  static const sheet = BorderRadius.vertical(
    top: Radius.circular(extraLargeIncreasedRadius),
  );
}
