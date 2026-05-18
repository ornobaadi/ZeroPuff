import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../repositories/daily_checkin_repository.dart';

const _moods = [
  _MoodOption(1, 'Rough', Icons.cloud_rounded),
  _MoodOption(2, 'Tense', Icons.waves_rounded),
  _MoodOption(3, 'Okay', Icons.remove_rounded),
  _MoodOption(4, 'Steady', Icons.spa_rounded),
  _MoodOption(5, 'Clear', Icons.wb_sunny_rounded),
];

class DailyCheckInScreen extends ConsumerStatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  ConsumerState<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends ConsumerState<DailyCheckInScreen> {
  int _mood = 3;
  bool _smokeFreeToday = true;
  int _cigarettesSmoked = 0;
  bool _loadingExisting = true;
  bool _saving = false;
  final _noteController = TextEditingController();

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

  Future<void> _loadExisting() async {
    final existing = await ref.read(dailyCheckInRepositoryProvider).getToday();
    if (!mounted) {
      return;
    }
    if (existing != null) {
      setState(() {
        _mood = existing.mood;
        _smokeFreeToday = existing.smokeFreeToday;
        _cigarettesSmoked = existing.cigarettesSmoked;
        _noteController.text = existing.note ?? '';
      });
    }
    setState(() => _loadingExisting = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(dailyCheckInRepositoryProvider)
          .saveToday(
            mood: _mood,
            smokeFreeToday: _smokeFreeToday,
            cigarettesSmoked: _smokeFreeToday ? 0 : _cigarettesSmoked,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      ref.invalidate(todayCheckInProvider);
      ref.invalidate(recentCheckInsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in saved. Thank you.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily check-in')),
      body: SafeArea(
        child: _loadingExisting
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  Text(
                    'How did today go?',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This is a private honesty check. No streak shaming.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text('Mood', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _moods.map((mood) {
                      final selected = _mood == mood.value;
                      return ChoiceChip(
                        avatar: Icon(mood.icon, size: 16),
                        label: Text(mood.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _mood = mood.value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SmokeFreeSwitch(
                    value: _smokeFreeToday,
                    onChanged: (value) {
                      setState(() {
                        _smokeFreeToday = value;
                        if (value) {
                          _cigarettesSmoked = 0;
                        } else if (_cigarettesSmoked == 0) {
                          _cigarettesSmoked = 1;
                        }
                      });
                    },
                  ),
                  if (!_smokeFreeToday) ...[
                    const SizedBox(height: AppSpacing.md),
                    _CountStepper(
                      value: _cigarettesSmoked,
                      onChanged: (value) {
                        setState(() => _cigarettesSmoked = value);
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _noteController,
                    minLines: 4,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Optional note',
                      hintText: 'What helped or got in the way?',
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: FilledButton.icon(
            onPressed: _saving || _loadingExisting ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Saving' : 'Save check-in'),
          ),
        ),
      ),
    );
  }
}

class _SmokeFreeSwitch extends StatelessWidget {
  const _SmokeFreeSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smoke-free today?', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value
                      ? 'Nice. We will mark today complete.'
                      : 'Still useful. Honesty keeps the pattern clear.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CountStepper extends StatelessWidget {
  const _CountStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.relapse.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.relapse.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Cigarettes today', style: theme.textTheme.titleMedium),
          ),
          IconButton.filledTonal(
            onPressed: value <= 1 ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(this.value, this.label, this.icon);

  final int value;
  final String label;
  final IconData icon;
}
