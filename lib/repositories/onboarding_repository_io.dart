import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../models/onboarding_data.dart';
import '../models/profile_data.dart';
import '../services/local_database/local_database_service_io.dart';
import '../services/device/device_identity_service.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  return OnboardingRepository(database);
});

class OnboardingRepository {
  const OnboardingRepository(this._database);

  final Isar? _database;

  Future<OnboardingData?> loadDraft() async {
    final database = _database;
    if (database == null) {
      return null;
    }

    final draft = await database.onboardingDrafts.where().findFirst();
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
    final database = _database;
    if (database == null) {
      return;
    }

    final existing = await database.onboardingDrafts.where().findFirst();
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

    await database.writeTxn(() => database.onboardingDrafts.put(draft));
  }

  Future<void> completeOnboarding(ProfileData profile) async {
    final database = _database;
    if (database == null) {
      return;
    }

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

    await database.writeTxn(() async {
      await database.localProfiles.put(localProfile);
      await database.syncQueueItems.put(queueItem);
    });
  }

  Future<void> attachGuestProfileToUser(String userId) async {
    final database = _database;
    if (database == null) {
      return;
    }

    final guestUserId = DeviceIdentityService.guestUserId;

    await database.writeTxn(() async {
      final guestProfile = await database.localProfiles.getByUserId(
        guestUserId,
      );
      if (guestProfile == null) {
        return;
      }

      final existingUserProfile = await database.localProfiles.getByUserId(
        userId,
      );
      if (existingUserProfile != null &&
          existingUserProfile.id != guestProfile.id) {
        existingUserProfile
          ..displayName = guestProfile.displayName
          ..avatarUrl = guestProfile.avatarUrl
          ..quitDate = guestProfile.quitDate
          ..cigarettesPerDay = guestProfile.cigarettesPerDay
          ..packPrice = guestProfile.packPrice
          ..packSize = guestProfile.packSize
          ..currencyCode = guestProfile.currencyCode
          ..currencySymbol = guestProfile.currencySymbol
          ..triggers = guestProfile.triggers
          ..quitReason = guestProfile.quitReason
          ..updatedAt = DateTime.now()
          ..synced = false;

        await database.localProfiles.put(existingUserProfile);
        await database.localProfiles.delete(guestProfile.id);
      } else {
        guestProfile
          ..userId = userId
          ..updatedAt = DateTime.now()
          ..synced = false;

        await database.localProfiles.put(guestProfile);
      }

      final staleQueueItems = await database.syncQueueItems
          .filter()
          .entityTypeEqualTo('profile')
          .entityIdEqualTo(guestUserId)
          .findAll();
      for (final item in staleQueueItems) {
        item.entityId = userId;
      }
      if (staleQueueItems.isNotEmpty) {
        await database.syncQueueItems.putAll(staleQueueItems);
      }

      final queueItem = SyncQueueItem()
        ..entityType = 'profile'
        ..entityId = userId
        ..operation = 'upsert'
        ..createdAt = DateTime.now();
      await database.syncQueueItems.put(queueItem);
    });
  }

  Future<ProfileData?> loadCompletedProfile() async {
    final database = _database;
    if (database == null) {
      return null;
    }

    final profile = await database.localProfiles
        .where()
        .sortByUpdatedAtDesc()
        .findFirst();
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
