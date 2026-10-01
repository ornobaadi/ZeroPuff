import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/errors/friendly_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/number_stepper.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/profile_data.dart';
import '../../../models/smoking_window_data.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/device/device_identity_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../../onboarding/models/onboarding_form.dart';
import '../../onboarding/steps/routine_step.dart' show kTriggerOptions;
import '../../onboarding/widgets/smoking_window_card.dart';

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
  CurrencyOption _currency = CurrencyOption.all.first;
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
    _cigarettesPerDay = profile.cigarettesPerDay.clamp(1, 80);
    _packPrice = profile.packPrice.round();
    _packSize = profile.packSize.clamp(1, 60);
    _currency = CurrencyOption.byCode(profile.currencyCode);
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
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
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
    final scheme = theme.colorScheme;
    final profile = ref.watch(editableProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Setup details')),
      body: SafeArea(
        child: profile.when(
          loading: () => const StateView.loading(),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(editableProfileProvider),
          ),
          data: (data) {
            if (data != null) {
              _hydrate(data);
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Changing these numbers recalculates your stats, projections and reminders straight away.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _QuitDateCard(date: _quitDate, onTap: _pickQuitDate),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Text('Your habit', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      Text('Currency', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'This only changes estimates. Your history stays intact.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final currency in CurrencyOption.all)
                            ChoiceChip(
                              label: Text(
                                '${currency.symbol} ${currency.code}',
                              ),
                              tooltip: currency.name,
                              selected: _currency.code == currency.code,
                              onSelected: (_) =>
                                  setState(() => _currency = currency),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NumberStepper(
                        label: 'Cigarettes per day',
                        value: _cigarettesPerDay,
                        min: 1,
                        max: 80,
                        onChanged: (value) =>
                            setState(() => _cigarettesPerDay = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NumberStepper(
                        label: 'Pack price',
                        value: _packPrice,
                        min: 0,
                        max: 10000,
                        prefix: _currency.symbol,
                        step: _currency.largePriceStep ? 10 : 1,
                        onChanged: (value) =>
                            setState(() => _packPrice = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NumberStepper(
                        label: 'Cigarettes per pack',
                        value: _packSize,
                        min: 1,
                        max: 60,
                        onChanged: (value) => setState(() => _packSize = value),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Text('Your routine', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      SmokingWindowCard(
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
                      const SizedBox(height: AppSpacing.lg),
                      Text('Triggers', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Keep at least one selected.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final option in kTriggerOptions)
                            FilterChip(
                              label: Text(option.label),
                              selected: _triggers.contains(option.value),
                              onSelected: (_) => _toggleTrigger(option.value),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      TextField(
                        controller: _reasonController,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 300,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Your reason',
                          hintText:
                              'The reason you want future-you to remember.',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: ContentWidth(
            child: FilledButton.icon(
              onPressed: profile.hasValue && !_saving
                  ? () => _save(profile.value)
                  : null,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        semanticsLabel: 'Saving',
                      ),
                    )
                  : const Icon(Symbols.check_rounded),
              label: Text(_saving ? 'Saving' : 'Save changes'),
            ),
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
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _quitDate.isAfter(today) ? today : _quitDate,
      firstDate: DateTime(now.year - 10),
      // A quit date in the future would make every stat negative.
      lastDate: today,
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
}

class _QuitDateCard extends StatelessWidget {
  const _QuitDateCard({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final formatted = DateFormat.yMMMMd().format(date);

    return AppCard(
      style: AppCardStyle.tonal,
      onTap: onTap,
      semanticLabel: 'Quit date: $formatted. Double tap to change.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.event_rounded, color: scheme.onPrimaryContainer),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quit date',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      formatted,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                color: scheme.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Only change this to correct your real start. When you log a cigarette, the smoke-free clock restarts on its own.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
