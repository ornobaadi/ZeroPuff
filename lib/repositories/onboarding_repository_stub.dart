import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_data.dart';
import '../models/profile_data.dart';

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

  Future<ProfileData?> loadCompletedProfile() async => _profile;

  ProfileData? get debugProfile => _profile;
}
