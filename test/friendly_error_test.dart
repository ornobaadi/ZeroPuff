import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/errors/friendly_error.dart';

void main() {
  group('friendlyError', () {
    test('never exposes raw exception text', () {
      final message = friendlyError(
        StateError('PostgrestException: relation "profiles" does not exist'),
      );

      expect(message.toLowerCase().contains('postgrest'), isFalse);
      expect(message.contains('profiles'), isFalse);
    });

    test('maps timeouts to a connection message', () {
      expect(
        friendlyError(TimeoutException('slow')),
        contains('No connection'),
      );
    });

    test('uses the fallback for unknown errors when provided', () {
      expect(
        friendlyError(StateError('boom'), fallback: 'Could not save.'),
        'Could not save.',
      );
    });
  });
}
