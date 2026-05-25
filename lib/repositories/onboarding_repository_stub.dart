import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_data.dart';
import '../models/profile_data.dart';
import '../models/smoking_window_data.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository();
});

class OnboardingRepository {
  OnboardingData? _draft;
  ProfileData? _profile;

  Future<OnboardingData?> loadDraft() async => _draft;

  Future<void> saveDraft(OnboardingData data) async {
    _draft = data;
  }

  Future<void> completeOnboarding(ProfileData profile) async {
    _profile = profile;
  }

  Future<void> attachGuestProfileToUser(String userId) async {
    final existing = _profile;
    if (existing == null) {
      return;
    }
    _profile = ProfileData(
      userId: userId,
      displayName: existing.displayName,
      avatarUrl: existing.avatarUrl,
      quitDate: existing.quitDate,
      cigarettesPerDay: existing.cigarettesPerDay,
      packPrice: existing.packPrice,
      packSize: existing.packSize,
      currencyCode: existing.currencyCode,
      currencySymbol: existing.currencySymbol,
      triggers: existing.triggers,
      usualSmokingWindow: existing.usualSmokingWindow.copyWith(
        windowId: SmokingWindowData.primaryWindowId,
      ),
      quitReason: existing.quitReason,
    );
  }

  Future<ProfileData?> loadCompletedProfile() async => _profile;

  ProfileData? get debugProfile => _profile;
}
