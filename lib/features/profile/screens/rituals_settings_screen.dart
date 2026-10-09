import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/friendly_error.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/state_view.dart';
import '../../../models/ritual_preset.dart';
import '../../../models/smoking_window_data.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/smoking_window_repository.dart';
import '../../../services/device/device_identity_service.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../../notifications/reminder_refresh.dart';

/// The moments of the day that used to come with a cigarette. Each one gets a
/// heads-up shortly before it, so the user can get ahead of the craving.
class RitualsSettingsScreen extends ConsumerStatefulWidget {
  const RitualsSettingsScreen({super.key});

  @override
  ConsumerState<RitualsSettingsScreen> createState() =>
      _RitualsSettingsScreenState();
}

class _RitualsSettingsScreenState extends ConsumerState<RitualsSettingsScreen> {
  static const _uuid = Uuid();

  String get _userId =>
      ref.read(currentUserProvider)?.id ?? DeviceIdentityService.guestUserId;

  Future<void> _save(SmokingWindowData ritual) async {
    await _change(
      () => ref
          .read(smokingWindowRepositoryProvider)
          .saveRitual(userId: _userId, ritual: ritual),
    );
  }

  Future<void> _delete(SmokingWindowData ritual) async {
    await _change(
      () => ref
          .read(smokingWindowRepositoryProvider)
          .deleteRitual(ritual.windowId),
    );
  }

  Future<void> _change(Future<void> Function() write) async {
    HapticService.selection(
      enabled: ref.read(hapticsEnabledControllerProvider),
    );
    try {
      await write();
      ref.invalidate(ritualsProvider);
      await refreshReminders(ref);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    }
  }

  Future<void> _changeTime(SmokingWindowData ritual) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (ritual.startMinutes ~/ 60).clamp(0, 23),
        minute: ritual.startMinutes.remainder(60),
      ),
      helpText: 'When does "${ritual.label}" usually happen?',
    );
    if (picked == null) {
      return;
    }
    await _save(
      SmokingWindowData.ritual(
        windowId: ritual.windowId,
        label: ritual.label,
        startMinutes: picked.hour * 60 + picked.minute,
        enabled: ritual.enabled,
      ),
    );
  }

  Future<void> _add(List<SmokingWindowData> existing) async {
    final labels = existing.map((ritual) => ritual.label).toSet();
    final choice = await showModalBottomSheet<({String label, int minutes})>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddRitualSheet(taken: labels),
    );
    if (choice == null) {
      return;
    }
    // Asking here, at the moment a nudge is wanted, rather than up front.
    await NotificationService.requestPermission();
    await _save(
      SmokingWindowData.ritual(
        windowId: _uuid.v4(),
        label: choice.label,
        startMinutes: choice.minutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rituals = ref.watch(ritualsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your smoking moments')),
      body: SafeArea(
        child: rituals.when(
          loading: () => const StateView.loading(),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(ritualsProvider),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Most cigarettes are tied to a moment: the coffee, the break, the drive home. '
                      'Add yours and ZeroPuff will check in ${NotificationService.ritualLeadMinutes} minutes before each one.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (data.isEmpty)
                      AppCard(
                        style: AppCardStyle.outlined,
                        child: Text(
                          'No moments added yet. Start with the one that is hardest to skip.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    for (final ritual in data) ...[
                      _RitualCard(
                        ritual: ritual,
                        onToggle: (enabled) =>
                            _save(ritual.copyWith(enabled: enabled)),
                        onChangeTime: () => _changeTime(ritual),
                        onDelete: () => _delete(ritual),
                      ),
                      const SizedBox(height: AppSpacing.componentGap),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () => _add(data),
                      icon: const Icon(Symbols.add_rounded),
                      label: const Text('Add a moment'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RitualCard extends StatelessWidget {
  const _RitualCard({
    required this.ritual,
    required this.onToggle,
    required this.onChangeTime,
    required this.onDelete,
  });

  final SmokingWindowData ritual;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChangeTime;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final time = SmokingWindowData.labelForMinutes(ritual.startMinutes);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                RitualPreset.iconForLabel(ritual.label),
                color: ritual.enabled
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(ritual.label, style: theme.textTheme.titleMedium),
              ),
              Semantics(
                label: 'Heads-up before ${ritual.label}',
                child: Switch(value: ritual.enabled, onChanged: onToggle),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onChangeTime,
                    icon: const Icon(Symbols.schedule_rounded),
                    label: Text('Around $time'),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove ${ritual.label}',
                onPressed: onDelete,
                icon: const Icon(Symbols.delete_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pick a common moment or name one.
class _AddRitualSheet extends StatefulWidget {
  const _AddRitualSheet({required this.taken});

  final Set<String> taken;

  @override
  State<_AddRitualSheet> createState() => _AddRitualSheetState();
}

class _AddRitualSheetState extends State<_AddRitualSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final label = _controller.text.trim();
    if (label.isEmpty) {
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'When does it usually happen?',
    );
    if (picked == null || !mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pop((label: label, minutes: picked.hour * 60 + picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = RitualPreset.all
        .where((preset) => !widget.taken.contains(preset.label))
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          0,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add a moment', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final preset in presets)
                  ActionChip(
                    avatar: Icon(preset.icon, size: 18),
                    label: Text(preset.label),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop((label: preset.label, minutes: preset.startMinutes)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              maxLength: 30,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addCustom(),
              decoration: const InputDecoration(
                labelText: 'Or name your own',
                hintText: 'Tea with colleagues',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonal(
              onPressed: _addCustom,
              child: const Text('Choose a time'),
            ),
          ],
        ),
      ),
    );
  }
}
