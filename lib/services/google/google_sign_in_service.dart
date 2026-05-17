import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/env/app_config.dart';

class GoogleSignInService {
  const GoogleSignInService._();

  static bool _initialized = false;

  static Future<void> initialize(AppConfig config) async {
    if (_initialized) {
      return;
    }

    final webClientId = config.googleWebClientId.isEmpty ? null : config.googleWebClientId;

    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : webClientId,
    );
    _initialized = true;
  }
}
