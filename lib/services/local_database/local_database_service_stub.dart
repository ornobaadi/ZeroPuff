import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDatabaseProvider = Provider<Object?>((ref) => null);

class LocalDatabaseService {
  const LocalDatabaseService._();

  static Object? get instanceOrNull => null;

  static Future<void> initialize() async {
    // Browser preview runs without Isar. Android uses the IO implementation.
  }
}
