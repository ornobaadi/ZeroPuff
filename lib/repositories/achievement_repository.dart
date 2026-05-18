import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'achievement_repository_stub.dart'
    if (dart.library.io) 'achievement_repository_io.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return getAchievementRepository(ref);
});

abstract class AchievementRepository {
  Future<Set<String>> unlockedKeys();

  Future<void> unlockAll(Set<String> keys);
}
