import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/friendly_error.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/number_stepper.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/smoking_log_repository.dart';
import '../../../services/haptics/haptic_service.dart';

const _maxCount = 60;

const _triggers = {
  'stress': 'Stressed',
  'bored': 'Bored',
  'social': 'Social',
  'after food': 'After food',
  'coffee': 'Coffee',
  'routine': 'Routine',
  'other': 'Something else',
};

class SmokingLogScreen extends ConsumerStatefulWidget {
  const SmokingLogScreen({this.logId, super.key});

  final String? logId;

  @override
  ConsumerState<SmokingLogScreen> createState() => _SmokingLogScreenState();
}

class _SmokingLogScreenState extends ConsumerState<SmokingLogScreen> {
  int _count = 1;
  String _trigger = 'stress';
  DateTime _smokedAt = DateTime.now();
  final _noteController = TextEditingController();

  bool _loadingExisting = false;
  bool _isSaving = false;
  Object? _loadError;

  bool get _isEditing => widget.logId != null;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    _mediumHaptic();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repository = ref.read(smokingLogRepositoryProvider);
      final eventRepository = ref.read(appEventRepositoryProvider);
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();
      final logId = widget.logId;

      final String savedLogId;
      if (logId == null) {
        savedLogId = await repository.addLog(
          count: _count,
          trigger: _trigger,
          smokedAt: _smokedAt,
          note: note,
        );
      } else {
        await repository.updateLog(
          logId: logId,
          count: _count,
          trigger: _trigger,
          smokedAt: _smokedAt,
          note: note,
        );
        savedLogId = logId;
      }

      await eventRepository.track(
        AppEvent(
          eventName: logId == null ? 'smoke_logged' : 'smoke_log_updated',
          properties: {
            'count': _count,
            'trigger': _trigger,
            'smoked_at': _smokedAt.toIso8601String(),
          },
        ),
      );
      ref.invalidate(latestSmokeAtProvider);
      ref.invalidate(recentSmokingLogsProvider);
      ref.invalidate(homeBaselineProvider);

      if (!mounted) {
        return;
      }
      if (logId == null) {
        context.go('${AppRoutes.recovery}?logId=$savedLogId');
        return;
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Log updated. Your timeline is clearer now.'),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(error))));
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _loadExisting() async {
    final logId = widget.logId;
    if (logId == null) {
      return;
    }
    setState(() {
      _loadingExisting = true;
      _loadError = null;
    });
    try {
      final log = await ref.read(smokingLogRepositoryProvider).getById(logId);
      if (log == null || !mounted) {
        return;
      }
      setState(() {
        _count = log.count.clamp(1, _maxCount);
        _trigger = _triggers.containsKey(log.trigger) ? log.trigger : 'other';
        _smokedAt = log.smokedAt;
        _noteController.text = log.note ?? '';
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _loadError = error);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingExisting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Widget body;
    if (_loadingExisting) {
      body = const StateView.loading(label: 'Loading log');
    } else if (_loadError != null) {
      body = StateView.error(error: _loadError!, onRetry: _loadExisting);
    } else {
      body = ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: scheme.secondaryContainer,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppShapes.extraLarge,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Private correction' : 'Private log',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Semantics(
                          header: true,
                          child: Text(
                            _isEditing
                                ? 'Make the timeline accurate.'
                                : 'This is not a failure screen.',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _isEditing
                              ? 'Small corrections matter. Your progress should reflect what really happened.'
                              : 'Honest logs protect the bigger pattern and help tomorrow feel less random.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                NumberStepper(
                  label: 'How many?',
                  value: _count,
                  min: 1,
                  max: _maxCount,
                  onChanged: (value) {
                    _selectionHaptic();
                    setState(() => _count = value);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('What triggered it?', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final entry in _triggers.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: _trigger == entry.key,
                        onSelected: (selected) {
                          if (selected) {
                            _selectionHaptic();
                            setState(() => _trigger = entry.key);
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'When did this happen?',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _TimeSelector(
                  smokedAt: _smokedAt,
                  onChanged: (value) {
                    _selectionHaptic();
                    setState(() => _smokedAt = value);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _noteController,
                  maxLength: 300,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Optional note',
                    hintText: 'What was happening right before?',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _submitLog,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            semanticsLabel: 'Saving',
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isEditing ? 'Update log' : 'Save log'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit log' : 'Log cigarette')),
      body: SafeArea(child: body),
    );
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() {
    HapticService.selection(enabled: _hapticsEnabled);
  }

  void _mediumHaptic() {
    HapticService.medium(enabled: _hapticsEnabled);
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({required this.smokedAt, required this.onChanged});

  final DateTime smokedAt;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final presets = <(String, DateTime)>[
      ('Just now', now),
      ('15 min ago', now.subtract(const Duration(minutes: 15))),
      ('30 min ago', now.subtract(const Duration(minutes: 30))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        AppCard(
          style: AppCardStyle.outlined,
          onTap: () => _pickTime(context),
          semanticLabel: 'Time smoked: ${_label(smokedAt, now)}. Double tap to change.',
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _label(smokedAt, now),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your smoke-free timer starts from this time.',
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
    final now = DateTime.now();
    // Assume today; if that lands in the future, the user means yesterday.
    var value = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
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
