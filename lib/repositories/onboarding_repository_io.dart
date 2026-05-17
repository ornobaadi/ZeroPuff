import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../models/onboarding_data.dart';
import '../models/profile_data.dart';
import '../services/local_database/local_database_service_io.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return OnboardingRepository(database);
});

class OnboardingRepository {
  const OnboardingRepository(this._database);

  final Isar _database;

  Future<OnboardingData?> loadDraft() async {
    final draft = await _database.onboardingDrafts.where().findFirst();
    if (draft == null) {
      return null;
    }

    return OnboardingData(
      quitDate: draft.quitDate,
      cigarettesPerDay: draft.cigarettesPerDay,
      packPrice: draft.packPrice,
      packSize: draft.packSize,
      currencyCode: draft.currencyCode,
      currencySymbol: draft.currencySymbol,
      triggers: draft.triggers,
      quitReason: draft.quitReason,
      currentStep: draft.currentStep,
      completed: draft.completed,
    );
  }

  Future<void> saveDraft(OnboardingData data) async {
    final existing = await _database.onboardingDrafts.where().findFirst();
    final draft = existing ?? OnboardingDraft();
    draft
      ..quitDate = data.quitDate
      ..cigarettesPerDay = data.cigarettesPerDay
      ..packPrice = data.packPrice
      ..packSize = data.packSize
      ..currencyCode = data.currencyCode
      ..currencySymbol = data.currencySymbol
      ..triggers = data.triggers
      ..quitReason = data.quitReason
      ..currentStep = data.currentStep
      ..completed = data.completed
      ..updatedAt = DateTime.now();

    await _database.writeTxn(() => _database.onboardingDrafts.put(draft));
  }

  Future<void> completeOnboarding(ProfileData profile) async {
    final localProfile = LocalProfile()
      ..userId = profile.userId
      ..displayName = profile.displayName
      ..avatarUrl = profile.avatarUrl
      ..quitDate = profile.quitDate
      ..cigarettesPerDay = profile.cigarettesPerDay
      ..packPrice = profile.packPrice
      ..packSize = profile.packSize
      ..currencyCode = profile.currencyCode
      ..currencySymbol = profile.currencySymbol
      ..triggers = profile.triggers
      ..quitReason = profile.quitReason
      ..updatedAt = DateTime.now()
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'profile'
      ..entityId = profile.userId
      ..operation = 'upsert'
      ..createdAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.localProfiles.put(localProfile);
      await _database.syncQueueItems.put(queueItem);
    });
  }

  Future<ProfileData?> loadCompletedProfile() async {
    final profile = await _database.localProfiles.where().findFirst();
    if (profile == null) {
      return null;
    }

    return ProfileData(
      userId: profile.userId,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      quitDate: profile.quitDate,
      cigarettesPerDay: profile.cigarettesPerDay,
      packPrice: profile.packPrice,
      packSize: profile.packSize,
      currencyCode: profile.currencyCode,
      currencySymbol: profile.currencySymbol,
      triggers: profile.triggers,
      quitReason: profile.quitReason,
    );
  }
}
