import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/craving_analysis_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../notifications/reminder_refresh.dart';
import '../../share/share_card.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/craving_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../models/rescue_flow.dart';
import '../models/rescue_tool.dart';
import '../widgets/rescue_breathe_view.dart';
import '../widgets/rescue_check_view.dart';
import '../widgets/rescue_reasons.dart';
import '../widgets/rescue_tool_view.dart';
import '../widgets/rescue_tools_view.dart';
import '../widgets/rescue_win_view.dart';

/// Help for a craving. Opens straight into breathing, then checks the urge;
/// if it is still strong it offers a different tool, and getting through ends
/// on a win. Nothing here needs a connection, and saving never gets in the way.
class RescueScreen extends ConsumerStatefulWidget {
  const RescueScreen({super.key});

  @override
  ConsumerState<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends ConsumerState<RescueScreen> {
  RescueFlow _flow = const RescueFlow();
  final Set<String> _triggers = {};
  bool _triggersTouched = false;
  bool _pocketMode = false;
  String _quitReason = rescueFallbackReason;
  Future<String?>? _session;
  int? _beatenCount;
  int _streakBefore = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  /// Reads what personalises the rescue. Breathing never waits for it.
  Future<void> _loadContext() async {
    try {
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .loadCompletedProfile();
      final cravings = await ref
          .read(cravingRepositoryProvider)
          .recent(limit: 90);
      final known = rescueReasons.map((reason) => reason.value).toSet();
      final likely = CravingAnalysisCalculations.likelyTriggers(
        cravings: cravings,
        now: DateTime.now(),
      ).where(known.contains).toSet();
      if (!mounted) {
        return;
      }
      setState(() {
        final reason = profile?.quitReason?.trim();
        if (reason != null && reason.isNotEmpty) {
          _quitReason = reason;
        }
        if (!_triggersTouched) {
          _triggers.addAll(likely);
        }
        _streakBefore =
            ref.read(homeDashboardProvider).value?.resistanceStreak ?? 0;
      });
    } on Object {
      // The rescue works without any of this.
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(homeDashboardProvider).value;
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);
    final pocket = _pocketMode && _flow.stage == RescueStage.breathe;

    final Widget body = switch (_flow.stage) {
      RescueStage.breathe => RescueBreatheView(
        key: const ValueKey('rescue-breathe'),
        breathsThisRound: _flow.breathsThisRound,
        hapticsEnabled: hapticsEnabled,
        pocketMode: _pocketMode,
        onBreath: _onBreath,
        onPocketModeChanged: (value) => setState(() => _pocketMode = value),
        onSkip: () => _advance(_flow.skipToCheck()),
      ),
      RescueStage.check => RescueCheckView(
        key: const ValueKey('rescue-check'),
        startStrength: _flow.startStrength,
        triggers: _triggers,
        onStartStrengthChanged: (strength) {
          _selectionHaptic();
          setState(() => _flow = _flow.withStartStrength(strength));
        },
        onTriggerToggled: _toggleTrigger,
        onAnswer: _answer,
        onSmoked: _smoked,
      ),
      RescueStage.tools => RescueToolsView(
        key: const ValueKey('rescue-tools'),
        toolsUsed: _flow.toolsUsed,
        onPick: (toolId) => _advance(_flow.pickTool(toolId)),
        onBreatheAgain: () => _advance(_flow.breatheAgain()),
      ),
      RescueStage.tool => RescueToolView(
        key: ValueKey('rescue-tool-${_flow.activeToolId}'),
        tool: rescueToolById(_flow.activeToolId),
        quitReason: _quitReason,
        hapticsEnabled: hapticsEnabled,
        onDone: () => _advance(_flow.finishTool()),
        onBack: () => _advance(_flow.backToTools()),
        onStartDelay: _startDelay,
      ),
      RescueStage.win => RescueWinView(
        key: const ValueKey('rescue-win'),
        intensityBefore: _flow.intensityBefore,
        intensityAfter: _flow.intensityAfter ?? _flow.intensityBefore,
        currencySymbol: dashboard?.currencySymbol ?? '',
        hapticsEnabled: hapticsEnabled,
        beatenCount: _beatenCount,
        moneyKept: dashboard == null || dashboard.packSize <= 0
            ? null
            : dashboard.packPrice / dashboard.packSize,
        streak: _streakBefore + 1,
        onDone: _close,
        onShare: () => showShareCard(
          context,
          ShareCardData(
            headline: _beatenCount == null
                ? 'A craving'
                : 'Craving #$_beatenCount',
            caption: 'beaten',
            lines: [
              'It came, I breathed, it passed.',
              if (_streakBefore + 1 >= 2) '${_streakBefore + 1} in a row',
            ],
          ),
        ),
      ),
    };

    return PopScope(
      // Leaving is free before anything has happened and after the win.
      canPop: !_flow.hasStarted || _flow.stage == RescueStage.win,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          if (_flow.stage == RescueStage.win) {
            _restoreReminders();
          }
          return;
        }
        if (pocket) {
          setState(() => _pocketMode = false);
          return;
        }
        final navigator = Navigator.of(context);
        if (await _confirmLeave() && mounted) {
          await _save(_flow.outcomeIfLeft);
          _restoreReminders();
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: pocket ? Colors.black : null,
        appBar: pocket ? null : AppBar(title: const Text('Craving rescue')),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.standard),
            child: body,
          ),
        ),
      ),
    );
  }

  // ---- Moving through the rescue ------------------------------------------

  void _advance(RescueFlow next) {
    if (identical(next, _flow)) {
      return;
    }
    _selectionHaptic();
    _ensureSession();
    setState(() => _flow = next);
  }

  void _onBreath() {
    _ensureSession();
    final next = _flow.addBreath();
    setState(() {
      _flow = next;
      if (next.stage != RescueStage.breathe) {
        _pocketMode = false;
      }
    });
    if (next.stage == RescueStage.check) {
      _mediumHaptic();
    }
  }

  void _toggleTrigger(String trigger) {
    _selectionHaptic();
    setState(() {
      _triggersTouched = true;
      if (!_triggers.remove(trigger)) {
        _triggers.add(trigger);
      }
    });
  }

  Future<void> _answer(UrgeNow now) async {
    if (_finishing) {
      return;
    }
    final next = _flow.answerNow(now);
    if (now == UrgeNow.stillStrong) {
      _selectionHaptic();
      setState(() => _flow = next);
      // Saved now so the craving is on record even if the app is closed here.
      await _save('still_craving', flow: next);
      return;
    }

    _finishing = true;
    await _save('resisted', flow: next);
    await _track('craving_outcome_resisted', flow: next);
    int? beaten;
    try {
      beaten = await ref.read(cravingRepositoryProvider).resistedCount();
    } on Object {
      // The win still shows, just without its number.
    }
    ref.invalidate(recentCravingsProvider);
    if (!mounted) {
      return;
    }
    setState(() {
      _flow = next;
      _beatenCount = beaten == null || beaten == 0 ? null : beaten;
    });
  }

  Future<void> _smoked() async {
    if (_finishing) {
      return;
    }
    _finishing = true;
    _selectionHaptic();
    await _save('smoked');
    await _track('craving_outcome_smoked');
    ref.invalidate(recentCravingsProvider);
    _restoreReminders();
    if (!mounted) {
      return;
    }
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(AppRoutes.logging);
  }

  /// Reminders are restored by the pop handler.
  void _close() => Navigator.of(context).pop();

  Future<bool> _startDelay() async {
    try {
      return await NotificationService.scheduleDelayCheck();
    } on Object {
      return false;
    }
  }

  // ---- Saving -------------------------------------------------------------

  /// Opens the session on the first real interaction, so an accidental tap on
  /// "I'm craving" leaves nothing behind.
  Future<String?> _ensureSession() {
    return _session ??= _openSession();
  }

  Future<String?> _openSession() async {
    try {
      await NotificationService.cancelScheduledReminders();
    } on Object {
      // Reminders are a nicety; the rescue carries on.
    }
    try {
      final sessionId = await ref.read(cravingRepositoryProvider).startRescue();
      await _track('craving_rescue_started');
      return sessionId;
    } on Object {
      return null;
    }
  }

  Future<void> _save(String outcome, {RescueFlow? flow}) async {
    final state = flow ?? _flow;
    try {
      final sessionId = await _ensureSession();
      if (sessionId == null) {
        return;
      }
      await ref
          .read(cravingRepositoryProvider)
          .completeRescue(
            sessionId: sessionId,
            outcome: outcome,
            intensity: state.intensityBefore,
            intensityAfter: state.intensityAfter,
            triggers: _triggers.toList(),
            toolsUsed: state.toolsUsed,
            breaths: state.breaths,
          );
    } on Object {
      // Never let a failed save stand between the user and the next step.
    }
  }

  Future<void> _track(String eventName, {RescueFlow? flow}) async {
    final state = flow ?? _flow;
    try {
      await ref
          .read(appEventRepositoryProvider)
          .track(
            AppEvent(
              eventName: eventName,
              properties: {
                'breaths': state.breaths,
                'tools': state.toolsUsed,
                'urge_before': state.intensityBefore,
                'urge_after': ?state.intensityAfter,
              },
            ),
          );
    } on Object {
      // Analytics must never block the rescue.
    }
  }

  Future<void> _restoreReminders() async {
    if (_session != null) {
      await refreshReminders(ref);
    }
  }

  Future<bool> _confirmLeave() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AppDialog(
            title: 'Leave the rescue?',
            message:
                'The urge will pass whether or not you smoke. Stay for one more breath if you can.',
            secondaryLabel: 'Leave',
            onSecondary: () => Navigator.of(context).pop(true),
            primaryLabel: 'Stay',
            onPrimary: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() => HapticService.selection(enabled: _hapticsEnabled);

  void _mediumHaptic() => HapticService.medium(enabled: _hapticsEnabled);
}
