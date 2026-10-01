import 'package:intl/intl.dart';

final _grouped = NumberFormat('#,##0');
final _oneDecimal = NumberFormat('#,##0.#');
final _cents = NumberFormat('#,##0.00');

/// "$2,190", "$5.50", "$0". Whole amounts drop the cents; small amounts with
/// cents keep them so "$5.50" is not rounded up to "$6".
String formatMoney(String symbol, double amount) {
  final value = amount.isFinite ? amount : 0.0;
  final hasCents = (value - value.roundToDouble()).abs() >= 0.005;
  final body = value.abs() < 100 && hasCents
      ? _cents.format(value)
      : _grouped.format(value.round());
  return '$symbol$body';
}

/// "1,204", "0".
String formatCount(num value) => _grouped.format(value.round());

/// "3.5", "12", "0" with at most one decimal and no trailing ".0".
String formatDecimal(double value) =>
    _oneDecimal.format(value.isFinite ? value : 0);
