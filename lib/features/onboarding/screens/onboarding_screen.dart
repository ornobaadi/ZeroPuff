import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/friendly_error.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../models/app_event.dart';
import '../../../models/profile_data.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/device/device_identity_service.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../models/onboarding_form.dart';
import '../steps/habit_step.dart';
import '../steps/reason_step.dart';
import '../steps/reminders_step.dart';
import '../steps/routine_step.dart';
import '../steps/start_date_step.dart';
import '../steps/welcome_step.dart';

/// Page indices. Step 0 is the welcome page and is not counted in the
/// progress indicator, which covers the five setup steps after it.
const _welcomeStep = 0;
const _reasonStep = 4;
const _remindersStep = 5;
const _lastStep = _remindersStep;
const _setupSteps = _lastStep;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _reasonController = TextEditingController();

  int _step = _welcomeStep;
  OnboardingForm _form = OnboardingForm.initial();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  /// Picks up where the user left off if the app was closed mid-setup.
  Future<void> _restoreDraft() async {
    try {
      final draft = await ref.read(onboardingRepositoryProvider).loadDraft();
      if (draft == null || draft.completed || !mounted) {
        return;
      }
      final restored = OnboardingForm.fromDraft(draft);
      final step = draft.currentStep.clamp(_welcomeStep, _lastStep);
      setState(() {
        _form = restored;
        _step = step;
        _reasonController.text = restored.reason;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(step);
        }
      });
    } on Object {
      // A missing or unreadable draft just means starting from the beginning.
    }
  }

  @override
  Widget build(BuildContext context) {
    final showProgress = _step > _welcomeStep;

    return PopScope(
      canPop: _step == _welcomeStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSaving) {
          _previous();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                visible: showProgress,
                step: _step,
                onBack: _isSaving ? null : _previous,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const WelcomeStep(),
                    StartDateStep(
                      form: _form,
                      onChoiceSelected: _selectDateChoice,
                      onPickDate: _pickQuitDate,
                    ),
                    HabitStep(
                      form: _form,
                      onChanged: _updateForm,
                      onSelection: _selectionHaptic,
                    ),
                    RoutineStep(
                      form: _form,
                      onChanged: _updateForm,
                      onSelection: _selectionHaptic,
                      onPickStart: _pickWindowStart,
                      onPickEnd: _pickWindowEnd,
                    ),
                    ReasonStep(
                      controller: _reasonController,
                      onChanged: (value) =>
                          _form = _form.copyWith(reason: value),
                    ),
                    const RemindersStep(),
                  ],
                ),
              ),
              _BottomBar(
                step: _step,
                isSaving: _isSaving,
                canContinue: _form.canContinueFrom(_step),
                onPrimary: _onPrimary,
                onSecondary: _onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Form updates -------------------------------------------------------

  void _updateForm(OnboardingForm form) => setState(() => _form = form);

  void _selectDateChoice(QuitDateChoice choice) {
    _selectionHaptic();
    final now = DateTime.now();
    setState(() {
      _form = _form.copyWith(
        dateChoice: choice,
        quitDate: switch (choice) {
          QuitDateChoice.today => now,
          QuitDateChoice.yesterday => DateTime(
            now.year,
            now.month,
            now.day - 1,
            now.hour,
            now.minute,
          ),
          QuitDateChoice.custom => _form.quitDate,
        },
      );
    });
  }

  Future<void> _pickQuitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _form.quitDate.isAfter(now) ? now : _form.quitDate,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      helpText: 'Choose your start date',
    );
    if (picked == null || !mounted) {
      return;
    }
    _selectionHaptic();
    setState(() {
      _form = _form.copyWith(
        quitDate: OnboardingForm.dateOnDay(picked, now),
        dateChoice: QuitDateChoice.custom,
      );
    });
  }

  Future<void> _pickWindowStart() async {
    final minutes = await _pickTime(_form.smokeWindowStartMinutes);
    if (minutes == null || !mounted) {
      return;
    }
    final end = _form.smokeWindowEndMinutes;
    setState(() {
      _form = _form.copyWith(
        smokeWindowStartMinutes: minutes,
        smokeWindowEndMinutes: end <= minutes
            ? (minutes + 60).clamp(0, 24 * 60)
            : end,
      );
    });
  }

  Future<void> _pickWindowEnd() async {
    final minutes = await _pickTime(_form.smokeWindowEndMinutes);
    if (minutes == null || !mounted) {
      return;
    }
    final start = _form.smokeWindowStartMinutes;
    setState(() {
      _form = _form.copyWith(
        smokeWindowEndMinutes: minutes,
        smokeWindowStartMinutes: start >= minutes
            ? (minutes - 60).clamp(0, 24 * 60)
            : start,
      );
    });
  }

  Future<int?> _pickTime(int initialMinutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (initialMinutes ~/ 60).clamp(0, 23),
        minute: initialMinutes.remainder(60),
      ),
    );
    if (picked == null) {
      return null;
    }
    _selectionHaptic();
    return picked.hour * 60 + picked.minute;
  }

  // ---- Navigation ---------------------------------------------------------

  Future<void> _goToStep(int step) async {
    setState(() => _step = step);
    if (!_pageController.hasClients) {
      return;
    }
    final duration = AppMotion.of(context, AppMotion.emphasized);
    if (duration == Duration.zero) {
      _pageController.jumpToPage(step);
      return;
    }
    await _pageController.animateToPage(
      step,
      duration: duration,
      curve: AppMotion.enter,
    );
  }

  Future<void> _previous() async {
    if (_step == _welcomeStep) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _selectionHaptic();
    await _goToStep(_step - 1);
  }

  Future<void> _onPrimary() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step == _lastStep) {
      _mediumHaptic();
      await _complete(enableReminders: true);
      return;
    }
    if (!_form.canContinueFrom(_step)) {
      return;
    }
    _lightHaptic();
    await _saveDraft(next: _step + 1);
    await _goToStep(_step + 1);
  }

  /// "Skip" on the reason step, "Not now" on the reminders step.
  Future<void> _onSecondary() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step == _lastStep) {
      _lightHaptic();
      await _complete(enableReminders: false);
      return;
    }
    if (_step == _reasonStep) {
      _lightHaptic();
      _reasonController.clear();
      _form = _form.copyWith(reason: '');
      await _saveDraft(next: _step + 1);
      await _goToStep(_step + 1);
    }
  }

  // ---- Saving -------------------------------------------------------------

  Future<void> _saveDraft({required int next, bool completed = false}) async {
    try {
      await ref
          .read(onboardingRepositoryProvider)
          .saveDraft(_form.toDraft(step: next, completed: completed));
    } on Object {
      // Losing a draft must never block the user from continuing.
    }
  }

  Future<void> _complete({required bool enableReminders}) async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final granted = enableReminders
          ? await NotificationService.requestPermission()
          : false;
      final user = ref.read(currentUserProvider);
      final profile = _form.toProfile(
        userId: user?.id ?? DeviceIdentityService.guestUserId,
        displayName:
            user?.userMetadata?['full_name']?.toString() ??
            user?.email ??
            'Guest',
        avatarUrl: user?.userMetadata?['avatar_url']?.toString(),
      );

      await ref.read(onboardingRepositoryProvider).completeOnboarding(profile);
      if (user != null) {
        await ref.read(profileRepositoryProvider).upsertProfile(profile);
      }
      await ref
          .read(appEventRepositoryProvider)
          .track(const AppEvent(eventName: 'onboarding_completed'));
      await _setupNotifications(profile, granted);

      if (enableReminders && !granted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Reminders are off. You can turn them on in Profile > Reminders.',
            ),
          ),
        );
      }
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(error))));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _setupNotifications(
    ProfileData profile,
    bool notificationsGranted,
  ) async {
    final nextPreferences = NotificationPreferences(
      dailyCheckInEnabled: notificationsGranted,
      milestoneReminderEnabled: notificationsGranted,
      streakProtectionEnabled: notificationsGranted,
    );
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .save(nextPreferences);
    final now = DateTime.now();
    final smokeFreeDuration = now.isBefore(profile.quitDate)
        ? Duration.zero
        : now.difference(profile.quitDate);
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile.quitDate,
      smokingWindow: profile.usualSmokingWindow,
      snapshot: NotificationScheduleSnapshot(
        smokeFreeDuration: smokeFreeDuration,
        currencySymbol: profile.currencySymbol,
      ),
    );
  }

  // ---- Haptics ------------------------------------------------------------

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() => HapticService.selection(enabled: _hapticsEnabled);

  void _lightHaptic() => HapticService.light(enabled: _hapticsEnabled);

  void _mediumHaptic() => HapticService.medium(enabled: _hapticsEnabled);
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.visible,
    required this.step,
    required this.onBack,
  });

  final bool visible;
  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Keep the height constant so the page does not jump between steps.
    return SizedBox(
      height: 64,
      child: visible
          ? ContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.componentGap,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: step / _setupSteps,
                        minHeight: 8,
                        semanticsLabel: 'Setup step $step of $_setupSteps',
                        semanticsValue: '${(step / _setupSteps * 100).round()}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ExcludeSemantics(
                      child: Text(
                        '$step of $_setupSteps',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.isSaving,
    required this.canContinue,
    required this.onPrimary,
    required this.onSecondary,
  });

  final int step;
  final bool isSaving;
  final bool canContinue;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  String get _primaryLabel => switch (step) {
    _welcomeStep => 'Get started',
    _remindersStep => 'Turn on reminders',
    _ => 'Continue',
  };

  String? get _secondaryLabel => switch (step) {
    _reasonStep => 'Skip for now',
    _remindersStep => 'Not now',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final secondary = _secondaryLabel;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: isSaving || !canContinue ? null : onPrimary,
                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          semanticsLabel: 'Saving',
                        ),
                      )
                    : Text(_primaryLabel),
              ),
              if (secondary != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: isSaving ? null : onSecondary,
                  child: Text(secondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
