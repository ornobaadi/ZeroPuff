import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/friendly_error.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/craving_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../models/rescue_phase.dart';
import '../widgets/rescue_active_view.dart';
import '../widgets/rescue_outcome_view.dart';
import '../widgets/rescue_reasons.dart';
import '../widgets/rescue_setup_view.dart';

enum _RescueStage { setup, active, outcome }

/// A guided two-minute pause for a craving: set up, follow the steps, then
/// record how it went.
class RescueScreen extends ConsumerStatefulWidget {
  const RescueScreen({super.key});

  @override
  ConsumerState<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends ConsumerState<RescueScreen> {
  int _intensity = 5;
  int _urgeAfter = 5;
  final Set<String> _triggers = {'stress'};
  _RescueStage _stage = _RescueStage.setup;
  RescueProgressState _progress = const RescueProgressState();
  Timer? _timer;
  String? _sessionId;
  String _quitReason = rescueFallbackReason;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _preselectTriggers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Starts with the triggers the user named during setup, when known.
  Future<void> _preselectTriggers() async {
    try {
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .loadCompletedProfile();
      final known = rescueReasons.map((reason) => reason.value).toSet();
      final saved = profile?.triggers.where(known.contains).toSet() ?? {};
      if (saved.isNotEmpty && mounted && _stage == _RescueStage.setup) {
        setState(() {
          _triggers
            ..clear()
            ..addAll(saved);
        });
      }
    } on Object {
      // The default selection is fine if the profile cannot be read.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage != _RescueStage.active,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _stage == _RescueStage.active) {
          final navigator = Navigator.of(context);
          final leave = await _confirmLeave();
          if (leave && mounted) {
            _timer?.cancel();
            await _restoreReminders();
            if (mounted) {
              navigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Two-minute rescue')),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.standard),
            child: switch (_stage) {
              _RescueStage.setup => RescueSetupView(
                key: const ValueKey('rescue-setup'),
                intensity: _intensity,
                triggers: _triggers,
                onIntensityChanged: (value) {
                  _selectionHaptic();
                  setState(() => _intensity = value.round());
                },
                onTriggerToggled: _toggleTrigger,
                onStart: _startRescue,
              ),
              _RescueStage.active => RescueActiveView(
                key: const ValueKey('rescue-active'),
                intensity: _intensity,
                progress: _progress,
                quitReason: _quitReason,
                onCompletePhase: _completeCurrentPhase,
              ),
              _RescueStage.outcome => RescueOutcomeView(
                key: const ValueKey('rescue-outcome'),
                completedPhaseIds: _progress.completedPhaseIds,
                urgeAfter: _urgeAfter,
                onUrgeChanged: (value) {
                  _selectionHaptic();
                  setState(() => _urgeAfter = value);
                },
                onOutcome: _completeRescue,
              ),
            },
          ),
        ),
      ),
    );
  }

  void _toggleTrigger(String trigger) {
    _selectionHaptic();
    setState(() {
      if (!_triggers.remove(trigger)) {
        _triggers.add(trigger);
      }
    });
  }

  Future<void> _startRescue() async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    _timer?.cancel();
    _lightHaptic();
    try {
      final repository = ref.read(cravingRepositoryProvider);
      final eventRepository = ref.read(appEventRepositoryProvider);
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .loadCompletedProfile();
      await NotificationService.cancelScheduledReminders();
      final sessionId = await repository.startRescue(
        intensity: _intensity,
        triggers: _triggers.toList(),
      );
      await eventRepository.track(
        AppEvent(
          eventName: 'craving_rescue_started',
          properties: {
            'intensity': _intensity,
            'triggers': _triggers.toList(),
          },
        ),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _sessionId = sessionId;
        _urgeAfter = _intensity;
        _quitReason = _cleanQuitReason(profile?.quitReason);
        _progress = const RescueProgressState();
        _stage = _RescueStage.active;
      });

      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _tickRescue(),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      _isBusy = false;
    }
  }

  void _tickRescue() {
    if (!mounted) {
      return;
    }
    final next = _progress.tick(intensity: _intensity);
    if (identical(next, _progress)) {
      return;
    }

    final phaseChanged = next.phaseIndex != _progress.phaseIndex;
    final justPaused =
        next.waitingForConfirmation && !_progress.waitingForConfirmation;

    setState(() => _progress = next);

    if (phaseChanged || justPaused) {
      _selectionHaptic();
    }
    if (next.finished) {
      _timer?.cancel();
      _mediumHaptic();
      setState(() => _stage = _RescueStage.outcome);
    }
  }

  Future<void> _completeCurrentPhase() async {
    final phase = _progress.currentPhase;
    _mediumHaptic();
    await ref
        .read(appEventRepositoryProvider)
        .track(
          AppEvent(
            eventName: 'craving_rescue_phase_completed',
            properties: {
              'phase': phase.id,
              'intensity': _intensity,
              'seconds_remaining': _progress.remainingSeconds,
            },
          ),
        );
    if (!mounted) {
      return;
    }

    final next = _progress.completeCurrent(intensity: _intensity);
    final phaseChanged = next.phaseIndex != _progress.phaseIndex;
    setState(() => _progress = next);
    if (phaseChanged) {
      _selectionHaptic();
    }
    if (next.finished) {
      _timer?.cancel();
      setState(() => _stage = _RescueStage.outcome);
    }
  }

  Future<void> _completeRescue(String outcome) async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    if (outcome == 'resisted') {
      _successHaptic();
    } else {
      _selectionHaptic();
    }

    try {
      final sessionId = _sessionId;
      if (sessionId != null) {
        await ref
            .read(cravingRepositoryProvider)
            .completeRescue(sessionId: sessionId, outcome: outcome);
        ref.invalidate(recentCravingsProvider);
      }
      await ref
          .read(appEventRepositoryProvider)
          .track(
            AppEvent(
              eventName: 'craving_outcome_$outcome',
              properties: {
                'urge_after': _urgeAfter,
                'completed_phases': _progress.completedPhaseIds.toList(),
              },
            ),
          );
    } on Object catch (error) {
      _isBusy = false;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
      return;
    }

    if (outcome == 'still_craving') {
      _isBusy = false;
      if (mounted) {
        await _startRescue();
      }
      return;
    }

    await _restoreReminders();
    _isBusy = false;

    if (!mounted) {
      return;
    }
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (outcome == 'smoked') {
      router.push(AppRoutes.logging);
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(_outcomeMessage(outcome))));
  }

  Future<void> _restoreReminders() async {
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .load();
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
    final dashboard = ref.read(homeDashboardProvider).value;
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile?.quitDate,
      smokingWindow: profile?.usualSmokingWindow,
      snapshot: dashboard == null
          ? const NotificationScheduleSnapshot()
          : NotificationScheduleSnapshot(
              todayCheckedIn: dashboard.todayCheckIn != null,
              smokeFreeDuration: dashboard.smokeFreeDuration,
              smokeFreeStreakDays: dashboard.smokeFreeStreakDays,
              checkInStreakDays: dashboard.checkInStreakDays,
              cigarettesAvoided: dashboard.cigarettesAvoided,
              moneySaved: dashboard.moneySaved,
              currencySymbol: dashboard.currencySymbol,
            ),
    );
  }

  Future<bool> _confirmLeave() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave rescue?'),
            content: const Text(
              'You are in the two-minute window. Stay if you can.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _cleanQuitReason(String? value) {
    final reason = value?.trim();
    if (reason == null || reason.isEmpty) {
      return rescueFallbackReason;
    }
    return reason;
  }

  String _outcomeMessage(String outcome) {
    return switch (outcome) {
      'resisted' => 'Logged. You got through this one.',
      'smoked' => "Logged. Let's keep going.",
      _ => 'Logged. You can restart anytime.',
    };
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() {
    HapticService.selection(enabled: _hapticsEnabled);
  }

  void _lightHaptic() {
    HapticService.light(enabled: _hapticsEnabled);
  }

  void _mediumHaptic() {
    HapticService.medium(enabled: _hapticsEnabled);
  }

  void _successHaptic() {
    HapticService.success(enabled: _hapticsEnabled);
  }
}
