import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
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
  const SmokingLogScreen({super.key});

  @override
  ConsumerState<SmokingLogScreen> createState() => _SmokingLogScreenState();
}

class _SmokingLogScreenState extends ConsumerState<SmokingLogScreen> {
  int _count = 1;
  String _trigger = 'stress';
  final _noteController = TextEditingController();

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    final repository = ref.read(smokingLogRepositoryProvider);
    final eventRepository = ref.read(appEventRepositoryProvider);

    await repository.addLog(
      count: _count,
      trigger: _trigger,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    await eventRepository.track(
      AppEvent(
        eventName: 'smoke_logged',
        properties: {'count': _count, 'trigger': _trigger},
      ),
    );

    if (!_isDisposed && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Logged. Let's keep going. You did not lose everything.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Log cigarette')),
      body: SafeArea(
        child: ListView(
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
                  Text('Private log', style: theme.textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'This is not a failure screen.',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Honest logs protect the bigger pattern and help tomorrow feel less random.',
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
                border: Border.all(color: theme.colorScheme.outlineVariant),
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
            Text('What triggered it?', style: theme.textTheme.titleMedium),
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
              label: const Text('Save log'),
            ),
          ],
        ),
      ),
    );
  }
}
