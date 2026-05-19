import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/smoking_log_repository.dart';

const _triggers = [
  'stress',
  'bored',
  'social',
  'after food',
  'coffee',
  'routine',
  'other',
];

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

  bool _isDisposed = false;
  bool _loadingExisting = false;

  bool get _isEditing => widget.logId != null;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    final repository = ref.read(smokingLogRepositoryProvider);
    final eventRepository = ref.read(appEventRepositoryProvider);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final logId = widget.logId;

    if (logId == null) {
      await repository.addLog(
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

    if (!_isDisposed && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            logId == null
                ? "Logged. Let's keep going. You did not lose everything."
                : 'Log updated. Your timeline is clearer now.',
          ),
        ),
      );
    }
  }

  Future<void> _loadExisting() async {
    final logId = widget.logId;
    if (logId == null) {
      return;
    }
    setState(() => _loadingExisting = true);
    try {
      final log = await ref.read(smokingLogRepositoryProvider).getById(logId);
      if (log == null || !mounted) {
        return;
      }
      setState(() {
        _count = log.count;
        _trigger = log.trigger;
        _smokedAt = log.smokedAt;
        _noteController.text = log.note ?? '';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingExisting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit log' : 'Log cigarette')),
      body: SafeArea(
        child: _loadingExisting
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.relapse.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.relapse.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Private correction' : 'Private log',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _isEditing
                              ? 'Make the timeline accurate.'
                              : 'This is not a failure screen.',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _isEditing
                              ? 'Small corrections matter. Your progress should reflect what really happened.'
                              : 'Honest logs protect the bigger pattern and help tomorrow feel less random.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text('How many?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          onPressed: _count > 1
                              ? () => setState(() => _count--)
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$_count',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displayMedium,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () => setState(() => _count++),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'What triggered it?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _triggers.map((trigger) {
                      return ChoiceChip(
                        label: Text(trigger),
                        selected: _trigger == trigger,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _trigger = trigger);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'When did this happen?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TimeSelector(
                    smokedAt: _smokedAt,
                    onChanged: (value) => setState(() => _smokedAt = value),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Optional note',
                      hintText: 'What was happening right before?',
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.relapse,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submitLog,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_isEditing ? 'Update log' : 'Save log'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({required this.smokedAt, required this.onChanged});

  final DateTime smokedAt;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final presets = <_TimePreset>[
      _TimePreset('Just now', now),
      _TimePreset('15 min ago', now.subtract(const Duration(minutes: 15))),
      _TimePreset('30 min ago', now.subtract(const Duration(minutes: 30))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: presets.map((preset) {
            final selected =
                smokedAt.difference(preset.value).inMinutes.abs() < 2;
            return ChoiceChip(
              label: Text(preset.label),
              selected: selected,
              onSelected: (_) => onChanged(preset.value),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.componentGap),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _pickTime(context),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _timeLabel(smokedAt),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your smoke-free timer starts from this time.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
    var value = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );
    if (value.isAfter(now)) {
      value = value.subtract(const Duration(days: 1));
    }
    onChanged(value);
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour == 0
        ? 12
        : value.hour > 12
        ? value.hour - 12
        : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _TimePreset {
  const _TimePreset(this.label, this.value);

  final String label;
  final DateTime value;
}
