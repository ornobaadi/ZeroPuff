import 'package:flutter/material.dart';

/// Semantic accent colors that Material's color scheme has no role for.
///
/// Each accent has a strong color for icons/graphics and a container pair for
/// tinted surfaces, in both brightnesses, so screens never hard-code colors.
@immutable
class AppAccents extends ThemeExtension<AppAccents> {
  const AppAccents({
    required this.money,
    required this.moneyContainer,
    required this.onMoneyContainer,
    required this.streak,
    required this.streakContainer,
    required this.onStreakContainer,
    required this.craving,
    required this.cravingContainer,
    required this.onCravingContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  static const light = AppAccents(
    money: Color(0xFF9A5F48),
    moneyContainer: Color(0xFFF3DED4),
    onMoneyContainer: Color(0xFF3B1E12),
    streak: Color(0xFF2F6B4A),
    streakContainer: Color(0xFFD5E8DA),
    onStreakContainer: Color(0xFF123222),
    craving: Color(0xFF8C6A2E),
    cravingContainer: Color(0xFFEFE3C8),
    onCravingContainer: Color(0xFF2E2208),
    warning: Color(0xFF9A5F48),
    warningContainer: Color(0xFFF3DED4),
    onWarningContainer: Color(0xFF3B1E12),
  );

  static const dark = AppAccents(
    money: Color(0xFFD4A28B),
    moneyContainer: Color(0xFF3D2A22),
    onMoneyContainer: Color(0xFFF2D5C7),
    streak: Color(0xFF58A879),
    streakContainer: Color(0xFF1E3A2B),
    onStreakContainer: Color(0xFFBFE3CC),
    craving: Color(0xFFD9B77A),
    cravingContainer: Color(0xFF3A3020),
    onCravingContainer: Color(0xFFF0E1C2),
    warning: Color(0xFFD4A28B),
    warningContainer: Color(0xFF3D2A22),
    onWarningContainer: Color(0xFFF2D5C7),
  );

  final Color money;
  final Color moneyContainer;
  final Color onMoneyContainer;
  final Color streak;
  final Color streakContainer;
  final Color onStreakContainer;
  final Color craving;
  final Color cravingContainer;
  final Color onCravingContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  static AppAccents of(BuildContext context) {
    return Theme.of(context).extension<AppAccents>() ?? light;
  }

  @override
  AppAccents copyWith({
    Color? money,
    Color? moneyContainer,
    Color? onMoneyContainer,
    Color? streak,
    Color? streakContainer,
    Color? onStreakContainer,
    Color? craving,
    Color? cravingContainer,
    Color? onCravingContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return AppAccents(
      money: money ?? this.money,
      moneyContainer: moneyContainer ?? this.moneyContainer,
      onMoneyContainer: onMoneyContainer ?? this.onMoneyContainer,
      streak: streak ?? this.streak,
      streakContainer: streakContainer ?? this.streakContainer,
      onStreakContainer: onStreakContainer ?? this.onStreakContainer,
      craving: craving ?? this.craving,
      cravingContainer: cravingContainer ?? this.cravingContainer,
      onCravingContainer: onCravingContainer ?? this.onCravingContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  AppAccents lerp(ThemeExtension<AppAccents>? other, double t) {
    if (other is! AppAccents) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppAccents(
      money: mix(money, other.money),
      moneyContainer: mix(moneyContainer, other.moneyContainer),
      onMoneyContainer: mix(onMoneyContainer, other.onMoneyContainer),
      streak: mix(streak, other.streak),
      streakContainer: mix(streakContainer, other.streakContainer),
      onStreakContainer: mix(onStreakContainer, other.onStreakContainer),
      craving: mix(craving, other.craving),
      cravingContainer: mix(cravingContainer, other.cravingContainer),
      onCravingContainer: mix(onCravingContainer, other.onCravingContainer),
      warning: mix(warning, other.warning),
      warningContainer: mix(warningContainer, other.warningContainer),
      onWarningContainer: mix(onWarningContainer, other.onWarningContainer),
    );
  }
}
