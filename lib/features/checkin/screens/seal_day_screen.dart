import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/streak_calculations.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/number_formatting.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/savings_jar.dart';
import '../../../core/widgets/state_view.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/smoking_window_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../../logging/widgets/slip_form.dart';
import '../../notifications/reminder_refresh.dart';
import '../models/seal_question.dart';
import '../widgets/feeling_icon.dart';

/// Closes the day in one tap.
///
/// The app already knows most of what happened, so it shows that and asks
/// only whether the day was smoke-free. Sealing banks the day; skipping it
/// never costs anything. A couple of optional one-tap questions follow.
class SealDayScreen extends ConsumerStatefulWidget {
  const SealDayScreen({super.key});

  @override
  ConsumerState<SealDayScreen> createState() => _SealDayScreenState();
}

class _SealDayScreenState extends ConsumerState<SealDayScreen> {
  DailyCheckInRecord? _seal;
  final Set<String> _tags = {};
  int? _mood;
  final _noteController = TextEditingController();
  bool _noteOpen = false;

  bool _loading = true;
  Object? _loadError;
  bool _saving = false;

  /// Only a seal made on this visit plays the stamp.
  bool _justSealed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final existing = await ref
          .read(dailyCheckInRepositoryProvider)
          .getToday();
      if (!mounted) {
        return;
      }
      setState(() {
        _seal = existing;
        if (existing != null) {
          _tags
            ..clear()
            ..addAll(existing.tags);
          _mood = existing.mood;
          _noteController.text = existing.note ?? '';
          _noteOpen = (existing.note ?? '').isNotEmpty;
        }
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _loadError = error);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Writes the day as it stands. Returns false if it could not be saved.
  Future<bool> _save({required int cigarettesToday}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final note = _noteController.text.trim();
      final record = await ref
          .read(dailyCheckInRepositoryProvider)
          .saveToday(
            smokeFreeToday: cigarettesToday == 0,
            cigarettesSmoked: cigarettesToday,
            mood: _mood,
            tags: _tags.toList(),
            note: note.isEmpty ? null : note,
          );
      ref.invalidate(todayCheckInProvider);
      ref.invalidate(recentCheckInsProvider);
      if (mounted) {
        setState(() => _seal = record);
      }
      return true;
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(error))));
      return false;
    }
  }

  Future<void> _sealDay({required int cigarettesToday}) async {
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
      // Set before saving, so the stamp animates when it first appears.
      _justSealed = true;
    });
    final saved = await _save(cigarettesToday: cigarettesToday);
    if (saved) {
      HapticService.milestone(
        enabled: ref.read(hapticsEnabledControllerProvider),
      );
      await refreshReminders(ref, todayCheckedIn: true);
    }
    if (mounted) {
      setState(() {
        _saving = false;
        _justSealed = saved;
      });
    }
  }

  Future<void> _finish({required int cigarettesToday}) async {
    // Picks up a note that was typed but not submitted.
    final note = _noteController.text.trim();
    if (note != (_seal?.note ?? '')) {
      await _save(cigarettesToday: cigarettesToday);
    }
    if (mounted) {
      context.pop();
    }
  }

  void _selection() {
    HapticService.selection(
      enabled: ref.read(hapticsEnabledControllerProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(homeDashboardProvider).value;
    final cravings = ref.watch(recentCravingsProvider).value ?? const [];
    final logs = ref.watch(recentSmokingLogsProvider).value ?? const [];
    final rituals = ref.watch(ritualsProvider).value ?? const [];

    final now = DateTime.now();
    final today = StreakCalculations.dateOnly(now);
    bool isToday(DateTime time) => StreakCalculations.dateOnly(time) == today;

    final beaten = cravings
        .where((craving) => craving.resisted && isToday(craving.startedAt))
        .length;
    final cigarettesToday = logs
        .where((log) => isToday(log.smokedAt))
        .fold<int>(0, (sum, log) => sum + log.count);
    final slipped = cigarettesToday > 0;

    final nowMinutes = now.hour * 60 + now.minute;
    final momentsToday = rituals
        .where(
          (ritual) => ritual.enabled && ritual.daysOfWeek.contains(now.weekday),
        )
        .toList();
    final momentsBehind = momentsToday
        .where((ritual) => ritual.startMinutes <= nowMinutes)
        .length;

    final keptToday = dashboard == null || slipped || dashboard.moneyToday < 0.5
        ? null
        : dashboard.moneyToday;

    final sealed = _seal != null;
    final Widget body;
    if (_loading) {
      body = const StateView.loading(label: 'Loading today');
    } else if (_loadError != null) {
      body = StateView.error(error: _loadError!, onRetry: _load);
    } else {
      body = ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sealed) ...[
                  Center(
                    child: _SealStamp(
                      smokeFree: !slipped,
                      animate: _justSealed,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    !sealed
                        ? 'Today, so far'
                        : slipped
                        ? 'Today is closed'
                        : 'Today is sealed',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  !sealed
                      ? 'ZeroPuff filled this in from what you logged. One tap closes the day.'
                      : slipped
                      ? 'Logged honestly. Tomorrow starts clean.'
                      : 'One more smoke-free day in the bank.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                // The day's money dropping into the jar, on the visit it is
                // sealed.
                if (sealed &&
                    _justSealed &&
                    keptToday != null &&
                    dashboard != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 72,
                        child: CoinDropJar(
                          fill: 0.45,
                          drops: 1,
                          hapticsEnabled: ref.watch(
                            hapticsEnabledControllerProvider,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${formatMoney(dashboard.currencySymbol, keptToday)} went into the jar today',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _DayRecap(
                  beaten: beaten,
                  cigarettes: cigarettesToday,
                  keptToday: keptToday == null || dashboard == null
                      ? null
                      : formatMoney(dashboard.currencySymbol, keptToday),
                  momentsBehind: momentsBehind,
                  momentsTotal: momentsToday.length,
                ),
                if (sealed) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  _QuestionChips(
                    question: SealQuestion.forDay(
                      beaten: beaten,
                      slipped: slipped,
                    ),
                    selected: _tags,
                    onToggle: (value) {
                      _selection();
                      setState(() {
                        if (!_tags.remove(value)) {
                          _tags.add(value);
                        }
                      });
                      _save(cigarettesToday: cigarettesToday);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _FeelingRow(
                    selected: _mood,
                    onSelected: (value) {
                      _selection();
                      setState(() => _mood = _mood == value ? null : value);
                      _save(cigarettesToday: cigarettesToday);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_noteOpen)
                    TextField(
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 300,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'A note for later',
                        hintText: 'Anything you want to remember about today.',
                        alignLabelWithHint: true,
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => setState(() => _noteOpen = true),
                      icon: const Icon(Symbols.edit_note_rounded),
                      label: const Text('Add a note'),
                    ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Seal the day')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (!_loading && _loadError == null)
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  child: sealed
                      ? FilledButton(
                          onPressed: () =>
                              _finish(cigarettesToday: cigarettesToday),
                          child: const Text('Done'),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () => _sealDay(
                                      cigarettesToday: cigarettesToday,
                                    ),
                              icon: const Icon(Symbols.verified_rounded),
                              label: Text(
                                slipped ? 'Close the day' : 'Smoke-free today',
                              ),
                            ),
                            if (!slipped) ...[
                              const SizedBox(height: AppSpacing.xs),
                              TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => showSlipSheet(context),
                                child: const Text('I slipped today'),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// What the app already knows about today.
class _DayRecap extends StatelessWidget {
  const _DayRecap({
    required this.beaten,
    required this.cigarettes,
    required this.keptToday,
    required this.momentsBehind,
    required this.momentsTotal,
  });

  final int beaten;
  final int cigarettes;
  final String? keptToday;
  final int momentsBehind;
  final int momentsTotal;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String)>[
      (
        cigarettes == 0
            ? Symbols.smoke_free_rounded
            : Symbols.edit_note_rounded,
        cigarettes == 0
            ? 'No cigarettes logged'
            : cigarettes == 1
            ? '1 cigarette logged'
            : '$cigarettes cigarettes logged',
      ),
      (
        Symbols.bolt_rounded,
        beaten == 0
            ? 'No cravings logged'
            : beaten == 1
            ? '1 craving beaten'
            : '$beaten cravings beaten',
      ),
      if (keptToday != null)
        (Symbols.savings_rounded, '$keptToday kept so far today'),
      if (momentsTotal > 0)
        (
          Symbols.schedule_rounded,
          '$momentsBehind of $momentsTotal smoking moments behind you',
        ),
    ];

    return AppCard(
      style: AppCardStyle.tonal,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.componentGap),
            _RecapRow(icon: rows[index].$1, text: rows[index].$2),
          ],
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;

    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _QuestionChips extends StatelessWidget {
  const _QuestionChips({
    required this.question,
    required this.selected,
    required this.onToggle,
  });

  final SealQuestion question;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Optional. Pick any that fit.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final option in question.options)
              FilterChip(
                label: Text(option.label),
                selected: selected.contains(option.value),
                onSelected: (_) => onToggle(option.value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Five faces of the day, from hard to clear. One tap, or none.
class _FeelingRow extends StatelessWidget {
  const _FeelingRow({required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How did today feel?', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final feeling in DayFeeling.all)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: selected == feeling.value,
                  label: feeling.label,
                  excludeSemantics: true,
                  onTap: () => onSelected(feeling.value),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelected(feeling.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected == feeling.value
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerLow,
                              border: Border.all(
                                color: selected == feeling.value
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                                width: selected == feeling.value ? 2 : 1,
                              ),
                            ),
                            child: SizedBox.square(
                              dimension: 48,
                              child: Icon(
                                feelingIcon(feeling.value),
                                color: selected == feeling.value
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            feeling.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: selected == feeling.value
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The mark a sealed day gets. It lands with a small bounce when the day has
/// just been sealed.
class _SealStamp extends StatefulWidget {
  const _SealStamp({required this.smokeFree, required this.animate});

  final bool smokeFree;
  final bool animate;

  @override
  State<_SealStamp> createState() => _SealStampState();
}

class _SealStampState extends State<_SealStamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (!widget.animate || AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.smokeFree
                ? scheme.primaryContainer
                : scheme.surfaceContainerHigh,
            border: Border.all(
              color: widget.smokeFree ? scheme.primary : scheme.outline,
              width: 3,
            ),
          ),
          child: SizedBox.square(
            dimension: 104,
            child: Icon(
              widget.smokeFree
                  ? Symbols.verified_rounded
                  : Symbols.check_rounded,
              size: 52,
              color: widget.smokeFree
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
