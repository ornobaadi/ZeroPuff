import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Keeps the Android home-screen widget in step with the app.
///
/// The widget is given when the smoke-free period began and the old daily
/// spend, and works out days and money itself, so it stays right on days the
/// app is not opened.
class HomeWidgetService {
  const HomeWidgetService._();

  static const _provider = 'com.zeropuff.app.ZeroPuffWidgetProvider';

  static Future<void> update({
    required DateTime smokeFreeSince,
    required double dailySpend,
    required String currencySymbol,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      // Saved as text: the plugin stores doubles in a form the widget would
      // have to decode.
      await HomeWidget.saveWidgetData<String>(
        'smoke_free_since_ms',
        smokeFreeSince.millisecondsSinceEpoch.toString(),
      );
      await HomeWidget.saveWidgetData<String>(
        'daily_spend',
        dailySpend.toStringAsFixed(4),
      );
      await HomeWidget.saveWidgetData<String>('currency_symbol', currencySymbol);
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
    } on Object {
      // The widget is optional; the app carries on without it.
    }
  }
}
