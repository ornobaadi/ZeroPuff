import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/craving_analysis_calculations.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/number_stepper.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/smoking_log_repository.dart';
import '../../../services/haptics/haptic_service.dart';

const _maxCount = 60;

/// What may have set a cigarette off, as stored on the log.
const slipTriggers = {
  'stress': 'Stressed',
  'bored': 'Bored',
  'social': 'Social',
  'after food': 'After food',
  'coffee': 'Coffee',
  'routine': 'Routine',
  'other': 'Something else',
};

/// Logs a slip from a sheet: how many, what set it off, when. A slip logged
/// for now leads on to the recovery screen; one filled in for a past [day]
/// just closes.
Future<void> showSlipSheet(BuildContext context, {DateTime? day}) async {
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final logId = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            0,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding +
                MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log a slip', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Private, and quick. Knowing when and why is what stops the next one.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SlipForm(
                day: day,
                onSaved: (logId) => Navigator.of(sheetContext).pop(logId),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (logId == null) {
    return;
  }
  if (day == null) {
    router.go('${AppRoutes.recovery}?logId=$logId');
  } else {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Logged. Your record is more accurate now.'),
      ),
    );
  }
}

/// The fields for one slip. Creates a log, or edits [logId].
class SlipForm extends ConsumerStatefulWidget {
  const SlipForm({required this.onSaved, this.logId, this.day, super.key});

  /// The log to edit. Null creates a new one.
  final String? logId;

  /// Log for this past day instead of now.
  final DateTime? day;

  /// Called with the id of the saved log.
  final ValueChanged<String> onSaved;

  @override
  ConsumerState<SlipForm> createState() => _SlipFormState();
}

class _SlipFormState extends ConsumerState<SlipForm> {
  int _count = 1;
  bool _moreThanThree = false;
  String? _trigger;
  late DateTime _smokedAt;
  final _noteController = TextEditingController();

  bool _loading = false;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.logId != null;

  @override
  void initState() {
    super.initState();
    final day = widget.day;
    // Midday is a neutral guess for a past day until the user sets the time.
    _smokedAt = day == null
        ? DateTime.now()
        : DateTime(day.year, day.month, day.day, 12);
    if (_isEditing) {
      _loadExisting();
    } else {
      _trigger = _likelyTrigger();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// The trigger that usually goes with this time of day, when there is one.
  String? _likelyTrigger() {
    final cravings = ref.read(recentCravingsProvider).value ?? const [];
    final likely = CravingAnalysisCalculations.likelyTriggers(
      cravings: cravings,
      now: _smokedAt,
    );
    for (final trigger in likely) {
      if (slipTriggers.containsKey(trigger)) {
        return trigger;
      }
    }
    return null;
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    try {
      final log = await ref
          .read(smokingLogRepositoryProvider)
          .getById(widget.logId!);
      if (log == null || !mounted) {
        return;
      }
      setState(() {
        _count = log.count.clamp(1, _maxCount);
        _moreThanThree = _count > 3;
        _trigger = slipTriggers.containsKey(log.trigger)
            ? log.trigger
            : 'other';
        _smokedAt = log.smokedAt;
        _noteController.text = log.note ?? '';
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = friendlyError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    HapticService.medium(enabled: ref.read(hapticsEnabledControllerProvider));
    try {
      final repository = ref.read(smokingLogRepositoryProvider);
      final note = _noteController.text.trim();
      final trigger = _trigger ?? 'other';
      final existingId = widget.logId;

      final String logId;
      if (existingId == null) {
        logId = await repository.addLog(
          count: _count,
          trigger: trigger,
          smokedAt: _smokedAt,
          note: note.isEmpty ? null : note,
        );
      } else {
        await repository.updateLog(
          logId: existingId,
          count: _count,
          trigger: trigger,
          smokedAt: _smokedAt,
          note: note.isEmpty ? null : note,
        );
        logId = existingId;
      }

      try {
        await ref
            .read(appEventRepositoryProvider)
            .track(
              AppEvent(
                eventName: existingId == null
                    ? 'smoke_logged'
                    : 'smoke_log_updated',
                properties: {
                  'count': _count,
                  'trigger': trigger,
                  'smoked_at': _smokedAt.toIso8601String(),
                },
              ),
            );
      } on Object {
        // Analytics must never block a log from saving.
      }
      ref.invalidate(latestSmokeAtProvider);
      ref.invalidate(recentSmokingLogsProvider);
      ref.invalidate(homeBaselineProvider);
      if (mounted) {
        widget.onSaved(logId);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = friendlyError(error);
          _saving = false;
        });
      }
    }
  }

  void _select(VoidCallback change) {
    HapticService.selection(
      enabled: ref.read(hapticsEnabledControllerProvider),
    );
    setState(change);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading log'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('How many?', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final count in const [1, 2, 3])
              ChoiceChip(
                label: Text('$count'),
                selected: !_moreThanThree && _count == count,
                onSelected: (_) => _select(() {
                  _count = count;
                  _moreThanThree = false;
                }),
              ),
            ChoiceChip(
              label: const Text('More'),
              selected: _moreThanThree,
              onSelected: (_) => _select(() {
                _moreThanThree = true;
                if (_count < 4) {
                  _count = 4;
                }
              }),
            ),
          ],
        ),
        if (_moreThanThree) ...[
          const SizedBox(height: AppSpacing.componentGap),
          NumberStepper(
            label: 'Cigarettes',
            value: _count,
            min: 1,
            max: _maxCount,
            onChanged: (value) => _select(() => _count = value),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('What set it off?', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in slipTriggers.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: _trigger == entry.key,
                onSelected: (_) => _select(() => _trigger = entry.key),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('When?', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        _SlipTime(
          smokedAt: _smokedAt,
          // A past day keeps its date; only the time can change.
          fixedDay: widget.day,
          onChanged: (value) => _select(() => _smokedAt = value),
        ),
        if (_isEditing) ...[
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _noteController,
            maxLength: 300,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Optional note',
              hintText: 'What was happening right before?',
              alignLabelWithHint: true,
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    semanticsLabel: 'Saving',
                  ),
                )
              : const Icon(Symbols.check_rounded),
          label: Text(_isEditing ? 'Update log' : 'Save'),
        ),
      ],
    );
  }
}

class _SlipTime extends StatelessWidget {
  const _SlipTime({
    required this.smokedAt,
    required this.onChanged,
    this.fixedDay,
  });

  final DateTime smokedAt;
  final DateTime? fixedDay;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final presets = <(String, DateTime)>[
      ('Just now', now),
      ('15 min ago', now.subtract(const Duration(minutes: 15))),
      ('An hour ago', now.subtract(const Duration(hours: 1))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fixedDay == null) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (label, value) in presets)
                ChoiceChip(
                  label: Text(label),
                  selected: smokedAt.difference(value).inMinutes.abs() < 2,
                  onSelected: (_) => onChanged(value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.componentGap),
        ],
        AppCard(
          style: AppCardStyle.outlined,
          onTap: () => _pickTime(context),
          semanticLabel:
              'Time smoked: ${_label(smokedAt, now)}. Double tap to change.',
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Symbols.schedule_rounded, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _label(smokedAt, now),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your smoke-free clock restarts from the latest cigarette.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(smokedAt),
    );
    if (picked == null) {
      return;
    }
    final day = fixedDay;
    if (day != null) {
      onChanged(
        DateTime(day.year, day.month, day.day, picked.hour, picked.minute),
      );
      return;
    }
    final now = DateTime.now();
    // Assume today; if that lands in the future, the user means yesterday.
    var value = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );
    if (value.isAfter(now)) {
      value = DateTime(
        now.year,
        now.month,
        now.day - 1,
        picked.hour,
        picked.minute,
      );
    }
    onChanged(value);
  }

  String _label(DateTime value, DateTime now) {
    final time = DateFormat.jm().format(value);
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) {
      return 'Today, $time';
    }
    if (diff == 1) {
      return 'Yesterday, $time';
    }
    return '${DateFormat.MMMd().format(value)}, $time';
  }
}
