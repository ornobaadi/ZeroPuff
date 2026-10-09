import '../utils/number_formatting.dart';

/// Plain ways of picturing the numbers. Estimates of size and time only;
/// nothing here is a claim about health.
class PerspectiveCalculations {
  const PerspectiveCalculations._();

  /// The length of a king-size cigarette.
  static const cigaretteCentimetres = 8.4;

  /// Roughly how long one takes to smoke.
  static const minutesPerCigarette = 6;

  /// Time that would have gone on [cigarettes], as "40 min", "13 h", "3 days".
  static String timeNotSmoking(int cigarettes) {
    final minutes = cigarettes * minutesPerCigarette;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes / 60;
    if (hours < 48) {
      return '${hours.round()} h';
    }
    return '${(hours / 24).round()} days';
  }

  /// A few sentences that put the totals in perspective, most concrete first.
  /// Empty until there is something to say.
  static List<String> facts({
    required int cigarettesAvoided,
    required int packSize,
    required int cravingsBeaten,
  }) {
    final facts = <String>[];
    if (cigarettesAvoided > 0) {
      final metres = cigarettesAvoided * cigaretteCentimetres / 100;
      final length = metres >= 1000
          ? '${formatDecimal(metres / 1000)} km'
          : metres >= 10
          ? '${metres.round()} m'
          : '${formatDecimal(metres)} m';
      facts.add(
        'Laid end to end, the cigarettes you skipped would stretch $length.',
      );
      facts.add(
        'About ${timeNotSmoking(cigarettesAvoided)} you did not spend smoking, at $minutesPerCigarette minutes each.',
      );
      if (packSize > 0 && cigarettesAvoided >= packSize) {
        final packs = cigarettesAvoided / packSize;
        facts.add(
          '${formatDecimal(packs)} ${packs == 1 ? 'pack' : 'packs'} you never had to buy.',
        );
      }
    }
    if (cravingsBeaten > 0) {
      facts.add(
        cravingsBeaten == 1
            ? 'One craving came and went without a cigarette.'
            : '$cravingsBeaten cravings came and went without a cigarette.',
      );
    }
    return facts;
  }
}
