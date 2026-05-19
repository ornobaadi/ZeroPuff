import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'achievement_repository.dart';

AchievementRepository getAchievementRepository(Ref ref) {
  return AchievementRepositoryStub();
}

class AchievementRepositoryStub implements AchievementRepository {
  static final Set<String> _unlocked = {};

  @override
  Future<Set<String>> unlockedKeys() async {
    return Set<String>.from(_unlocked);
  }

  @override
  Future<Set<String>> unlockAll(Set<String> keys) async {
    final missing = keys.difference(_unlocked);
    _unlocked.addAll(keys);
    return missing;
  }
}
