import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/local_models.dart';

final localDatabaseProvider = Provider<Isar?>((ref) {
  return LocalDatabaseService.instanceOrNull;
});

class LocalDatabaseService {
  const LocalDatabaseService._();

  static Isar? _instance;

  static Isar? get instanceOrNull => _instance;

  static Future<void> initialize() async {
    if (_instance != null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        LocalProfileSchema,
        LocalSmokingWindowSchema,
        OnboardingDraftSchema,
        CravingRescueSessionSchema,
        SmokingLogSchema,
        DailyCheckInSchema,
        AchievementStateSchema,
        NotificationPreferenceSchema,
        SyncQueueItemSchema,
        LocalAppEventSchema,
      ],
      directory: directory.path,
      name: 'zeropuff',
    );
  }
}
