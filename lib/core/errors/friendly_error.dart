import 'package:flutter/foundation.dart';

/// Turns any thrown object into a message that is safe to show to users.
///
/// The raw error is only written to the debug log, so database, network and
/// SDK details never leak into the UI.
String friendlyError(Object error, {String? fallback}) {
  debugPrint('ZeroPuff error: $error');

  final type = error.runtimeType.toString();
  final text = error.toString().toLowerCase();

  final looksOffline =
      type.contains('SocketException') ||
      type.contains('ClientException') ||
      type.contains('TimeoutException') ||
      text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('connection refused') ||
      text.contains('connection closed');
  if (looksOffline) {
    return 'No connection. Check your internet and try again.';
  }

  if (type.contains('GoogleSignIn') || text.contains('sign-in')) {
    return 'Google sign-in did not finish. Please try again.';
  }

  if (type.contains('AuthException') || text.contains('jwt')) {
    return 'Your session has expired. Please sign in again.';
  }

  return fallback ?? 'Something went wrong. Please try again.';
}
