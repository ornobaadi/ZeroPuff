import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/profile_data.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../../../services/sync/sync_service.dart';

final googleSignInControllerProvider = Provider<GoogleSignInController>((ref) {
  return GoogleSignInController(ref);
});

class GoogleSignInController {
  GoogleSignInController(this._ref);

  final Ref _ref;

  /// Opens the Google sign-in dialog, then (if a local guest profile exists)
  /// attaches it to the signed-in Supabase user and upserts it to Supabase.
  Future<GoogleSignInOutcome> signInAndLinkGuestProfile() async {
    await _ref.read(authRepositoryProvider).signInWithGoogle();

    final user =
        _ref.read(currentUserProvider) ??
        _ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      return const GoogleSignInOutcome(signedIn: false, hasLocalProfile: false);
    }

    await _ref
        .read(onboardingRepositoryProvider)
        .attachGuestProfileToUser(user.id);

    final localProfile = await _ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();

    if (localProfile != null) {
      final linkedProfile = ProfileData(
        userId: user.id,
        displayName:
            user.userMetadata?['full_name']?.toString() ??
            user.email ??
            localProfile.displayName,
        avatarUrl: user.userMetadata?['avatar_url']?.toString(),
        quitDate: localProfile.quitDate,
        cigarettesPerDay: localProfile.cigarettesPerDay,
        packPrice: localProfile.packPrice,
        packSize: localProfile.packSize,
        currencyCode: localProfile.currencyCode,
        currencySymbol: localProfile.currencySymbol,
        triggers: localProfile.triggers,
        usualSmokingWindow: localProfile.usualSmokingWindow,
        quitReason: localProfile.quitReason,
      );

      await _ref
          .read(onboardingRepositoryProvider)
          .completeOnboarding(linkedProfile);
      await _ref.read(profileRepositoryProvider).upsertProfile(linkedProfile);
    }

    final syncResult = await _ref
        .read(syncServiceProvider)
        .syncPending(limit: 100);
    final restoreResult = await _ref
        .read(syncServiceProvider)
        .restoreRemoteSnapshot(replaceLocal: syncResult.remaining == 0);

    _refreshLocalViews();

    return GoogleSignInOutcome(
      signedIn: true,
      hasLocalProfile: localProfile != null,
      restoredRows: restoreResult.restoredRows,
    );
  }

  void _refreshLocalViews() {
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(homeBaselineProvider);
    _ref.invalidate(homeDashboardProvider);
    _ref.invalidate(todayCheckInProvider);
    _ref.invalidate(recentCheckInsProvider);
    _ref.invalidate(recentSmokingLogsProvider);
    _ref.invalidate(recentCravingsProvider);
    _ref.invalidate(latestSmokeAtProvider);
    _ref.invalidate(pendingSyncCountProvider);
  }
}

class GoogleSignInOutcome {
  const GoogleSignInOutcome({
    required this.signedIn,
    required this.hasLocalProfile,
    this.restoredRows = 0,
  });

  final bool signedIn;
  final bool hasLocalProfile;
  final int restoredRows;
}
