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
    money: Color(0xFF7A5A00),
    moneyContainer: Color(0xFFFFE4A3),
    onMoneyContainer: Color(0xFF261A00),
    streak: Color(0xFFB3261E),
    streakContainer: Color(0xFFFFDAD6),
    onStreakContainer: Color(0xFF410002),
    craving: Color(0xFF8A5100),
    cravingContainer: Color(0xFFFFDDB5),
    onCravingContainer: Color(0xFF2C1600),
    warning: Color(0xFF8A5100),
    warningContainer: Color(0xFFFFDDB5),
    onWarningContainer: Color(0xFF2C1600),
  );

  static const dark = AppAccents(
    money: Color(0xFFEDC15A),
    moneyContainer: Color(0xFF5A4300),
    onMoneyContainer: Color(0xFFFFE4A3),
    streak: Color(0xFFFFB4AB),
    streakContainer: Color(0xFF93000A),
    onStreakContainer: Color(0xFFFFDAD6),
    craving: Color(0xFFFFB964),
    cravingContainer: Color(0xFF693C00),
    onCravingContainer: Color(0xFFFFDDB5),
    warning: Color(0xFFFFB964),
    warningContainer: Color(0xFF693C00),
    onWarningContainer: Color(0xFFFFDDB5),
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
