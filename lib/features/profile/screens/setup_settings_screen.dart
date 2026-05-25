import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/profile_data.dart';
import '../../../models/smoking_window_data.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/device/device_identity_service.dart';
import '../../../services/notifications/notification_service.dart';

const _triggerOptions = [
  'stress',
  'bored',
  'social',
  'after food',
  'coffee',
  'routine',
  'other',
];

const _currencyOptions = [
  _CurrencyOption('USD', r'$', 'US dollar'),
  _CurrencyOption('EUR', 'EUR', 'Euro'),
  _CurrencyOption('GBP', 'GBP', 'British pound'),
  _CurrencyOption('INR', 'INR', 'Indian rupee'),
  _CurrencyOption('BDT', 'BDT', 'Bangladeshi taka'),
];

final editableProfileProvider = FutureProvider<ProfileData?>((ref) async {
  return ref.watch(onboardingRepositoryProvider).loadCompletedProfile();
});

class SetupSettingsScreen extends ConsumerStatefulWidget {
  const SetupSettingsScreen({super.key});

  @override
  ConsumerState<SetupSettingsScreen> createState() =>
      _SetupSettingsScreenState();
}

class _SetupSettingsScreenState extends ConsumerState<SetupSettingsScreen> {
  DateTime _quitDate = DateTime.now();
  int _cigarettesPerDay = 10;
  int _packPrice = 12;
  int _packSize = 20;
  int _smokeWindowStartMinutes = 18 * 60;
  int _smokeWindowEndMinutes = 23 * 60;
  _CurrencyOption _currency = _currencyOptions.first;
  final Set<String> _triggers = {'stress'};
  final _reasonController = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _hydrate(ProfileData profile) {
    if (_loaded) {
      return;
    }
    _loaded = true;
    _quitDate = profile.quitDate;
    _cigarettesPerDay = profile.cigarettesPerDay;
    _packPrice = profile.packPrice.round();
    _packSize = profile.packSize;
    _currency = _currencyOptions.firstWhere(
      (option) => option.code == profile.currencyCode,
      orElse: () => _currencyOptions.first,
    );
    _triggers
      ..clear()
      ..addAll(profile.triggers.isEmpty ? const ['stress'] : profile.triggers);
    _reasonController.text = profile.quitReason ?? '';
    _smokeWindowStartMinutes = profile.usualSmokingWindow.startMinutes;
    _smokeWindowEndMinutes = profile.usualSmokingWindow.endMinutes;
  }

  Future<void> _save(ProfileData? existing) async {
    setState(() => _saving = true);
    try {
      final user = ref.read(currentUserProvider);
      final profileWindow = SmokingWindowData(
        startMinutes: _smokeWindowStartMinutes,
        endMinutes: _smokeWindowEndMinutes,
        source: 'settings',
      );
      final profile = ProfileData(
        userId:
            existing?.userId ?? user?.id ?? DeviceIdentityService.guestUserId,
        displayName:
            existing?.displayName ??
            user?.userMetadata?['full_name']?.toString() ??
            user?.email ??
            'Guest',
        avatarUrl:
            existing?.avatarUrl ??
            user?.userMetadata?['avatar_url']?.toString(),
        quitDate: _quitDate,
        cigarettesPerDay: _cigarettesPerDay,
        packPrice: _packPrice.toDouble(),
        packSize: _packSize,
        currencyCode: _currency.code,
        currencySymbol: _currency.symbol,
        triggers: _triggers.toList(),
        usualSmokingWindow: profileWindow,
        quitReason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );

      await ref.read(onboardingRepositoryProvider).completeOnboarding(profile);
      if (user != null) {
        await ref.read(profileRepositoryProvider).upsertProfile(profile);
      }
      final notificationPreferences = await ref
          .read(notificationPreferencesRepositoryProvider)
          .load();
      await NotificationService.reschedule(
        preferences: notificationPreferences,
        quitDate: profile.quitDate,
        smokingWindow: profile.usualSmokingWindow,
        snapshot: _notificationSnapshot(),
      );
      ref.invalidate(homeBaselineProvider);
      ref.invalidate(editableProfileProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Setup updated.')));
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
    final profile = ref.watch(editableProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Setup details')),
      body: SafeArea(
        child: profile.when(
          data: (data) {
            if (data != null) {
              _hydrate(data);
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                Text(
                  'Keep your baseline honest',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Changing these numbers recalculates cigarettes not smoked, money won back, life won back, projections, and reminders immediately.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _WarningCard(
                  title: 'Quit date affects the clock',
                  body:
                      'Use this only to correct your real start time. Relapse resets should come from logging a cigarette, not by editing this date.',
                ),
                const SizedBox(height: AppSpacing.md),
                _DateTile(date: _quitDate, onTap: _pickQuitDate),
                const SizedBox(height: AppSpacing.md),
                _NumberTile(
                  label: 'Cigarettes per day',
                  value: _cigarettesPerDay,
                  min: 0,
                  max: 80,
                  onChanged: (value) =>
                      setState(() => _cigarettesPerDay = value),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Currency', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'This only changes estimates. Your progress history stays intact.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _currencyOptions.map((currency) {
                    return ChoiceChip(
                      label: Text('${currency.symbol} ${currency.code}'),
                      selected: _currency.code == currency.code,
                      labelStyle: _chipLabelStyle(
                        context,
                        _currency.code == currency.code,
                      ),
                      onSelected: (_) => setState(() => _currency = currency),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                _NumberTile(
                  label: 'Pack price',
                  value: _packPrice,
                  min: 0,
                  max: 10000,
                  prefix: _currency.symbol,
                  step: _currency.largePriceStep ? 10 : 1,
                  onChanged: (value) => setState(() => _packPrice = value),
                ),
                const SizedBox(height: AppSpacing.md),
                _NumberTile(
                  label: 'Cigarettes per pack',
                  value: _packSize,
                  min: 1,
                  max: 60,
                  onChanged: (value) => setState(() => _packSize = value),
                ),
                const SizedBox(height: AppSpacing.md),
                _SmokingWindowSettingsCard(
                  startMinutes: _smokeWindowStartMinutes,
                  endMinutes: _smokeWindowEndMinutes,
                  onRangeChanged: (start, end) => setState(() {
                    _smokeWindowStartMinutes = start;
                    _smokeWindowEndMinutes = end;
                  }),
                  onPickStart: () => _pickSmokeWindowTime(
                    initialMinutes: _smokeWindowStartMinutes,
                    onPicked: (minutes) => setState(() {
                      _smokeWindowStartMinutes = minutes;
                      if (_smokeWindowEndMinutes <= minutes) {
                        _smokeWindowEndMinutes = (minutes + 60).clamp(
                          0,
                          24 * 60,
                        );
                      }
                    }),
                  ),
                  onPickEnd: () => _pickSmokeWindowTime(
                    initialMinutes: _smokeWindowEndMinutes,
                    onPicked: (minutes) => setState(() {
                      _smokeWindowEndMinutes = minutes;
                      if (_smokeWindowStartMinutes >= minutes) {
                        _smokeWindowStartMinutes = (minutes - 60).clamp(
                          0,
                          24 * 60,
                        );
                      }
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Triggers', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _triggerOptions.map((trigger) {
                    final selected = _triggers.contains(trigger);
                    return FilterChip(
                      label: Text(trigger),
                      selected: selected,
                      labelStyle: _chipLabelStyle(context, selected),
                      onSelected: (_) => _toggleTrigger(trigger),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _reasonController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Quit reason',
                    hintText: 'The reason you want future-you to remember.',
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: FilledButton.icon(
            onPressed: profile.hasValue && !_saving
                ? () => _save(profile.value)
                : null,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Saving' : 'Save setup'),
          ),
        ),
      ),
    );
  }

  NotificationScheduleSnapshot _notificationSnapshot() {
    final dashboard = ref.read(homeDashboardProvider).value;
    if (dashboard == null) {
      return const NotificationScheduleSnapshot();
    }
    return NotificationScheduleSnapshot(
      todayCheckedIn: dashboard.todayCheckIn != null,
      smokeFreeDuration: dashboard.smokeFreeDuration,
      smokeFreeStreakDays: dashboard.smokeFreeStreakDays,
      checkInStreakDays: dashboard.checkInStreakDays,
      cigarettesAvoided: dashboard.cigarettesAvoided,
      moneySaved: dashboard.moneySaved,
      currencySymbol: dashboard.currencySymbol,
    );
  }

  Future<void> _pickQuitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _quitDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _quitDate = picked);
    }
  }

  Future<void> _pickSmokeWindowTime({
    required int initialMinutes,
    required ValueChanged<int> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (initialMinutes ~/ 60).clamp(0, 23),
        minute: initialMinutes.remainder(60),
      ),
    );
    if (picked == null) {
      return;
    }
    onPicked(picked.hour * 60 + picked.minute);
  }

  void _toggleTrigger(String trigger) {
    setState(() {
      if (_triggers.contains(trigger) && _triggers.length > 1) {
        _triggers.remove(trigger);
      } else {
        _triggers.add(trigger);
      }
    });
  }

  TextStyle? _chipLabelStyle(BuildContext context, bool selected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.textTheme.labelMedium?.copyWith(
      color: selected
          ? AppColors.textPrimary
          : isDark
          ? AppColors.textPrimaryDark
          : theme.colorScheme.onSurface,
      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
    );
  }
}

class _SmokingWindowSettingsCard extends StatelessWidget {
  const _SmokingWindowSettingsCard({
    required this.startMinutes,
    required this.endMinutes,
    required this.onRangeChanged,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final int startMinutes;
  final int endMinutes;
  final void Function(int startMinutes, int endMinutes) onRangeChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = startMinutes.clamp(0, 24 * 60);
    final end = endMinutes.clamp(0, 24 * 60);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usual smoke window',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Used for future danger-window reminders and AI context.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TimeChoiceButton(
                  label: 'From',
                  value: SmokingWindowData.labelForMinutes(start),
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TimeChoiceButton(
                  label: 'To',
                  value: SmokingWindowData.labelForMinutes(end),
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(start.toDouble(), end.toDouble()),
            min: 0,
            max: 24 * 60,
            divisions: 48,
            onChanged: (next) {
              onRangeChanged(next.start.round(), next.end.round());
            },
          ),
        ],
      ),
    );
  }
}

class _TimeChoiceButton extends StatelessWidget {
  const _TimeChoiceButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(child: Text(value)),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsBox(
      icon: Icons.event_rounded,
      label: 'Quit date',
      value:
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      onTap: onTap,
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.prefix,
    this.step = 1,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? prefix;
  final int step;

  @override
  Widget build(BuildContext context) {
    return _SettingsBox(
      icon: Icons.onetwothree_rounded,
      label: label,
      value: '${prefix ?? ''}$value',
      onTap: () => _edit(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            onPressed: value <= min
                ? null
                : () => onChanged((value - step).clamp(min, max)),
            icon: const Icon(Icons.remove_rounded),
          ),
          IconButton.filledTonal(
            onPressed: value >= max
                ? null
                : () => onChanged((value + step).clamp(min, max)),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: value.toString());
    final next = await showDialog<int>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 56),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixText: prefix,
                          filled: true,
                          helperText: 'Allowed range: $min-$max',
                        ),
                        onSubmitted: (_) {
                          Navigator.of(
                            context,
                          ).pop(int.tryParse(controller.text.trim()));
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(int.tryParse(controller.text.trim()));
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (next != null) {
      onChanged(next.clamp(min, max));
    }
  }
}

class _SettingsBox extends StatelessWidget {
  const _SettingsBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _CurrencyOption {
  const _CurrencyOption(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;

  bool get largePriceStep => code == 'BDT' || code == 'INR';
}
