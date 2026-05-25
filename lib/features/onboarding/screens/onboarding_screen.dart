import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/app_event.dart';
import '../../../models/onboarding_data.dart';
import '../../../models/profile_data.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/device/device_identity_service.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';

const _triggerOptions = [
  _TriggerOption('stress', 'Stressed', Icons.bolt_rounded),
  _TriggerOption('bored', 'Bored', Icons.hourglass_empty_rounded),
  _TriggerOption('social', 'Social pressure', Icons.groups_rounded),
  _TriggerOption('after food', 'After food', Icons.restaurant_rounded),
  _TriggerOption('coffee', 'Coffee', Icons.local_cafe_rounded),
  _TriggerOption('routine', 'Routine', Icons.repeat_rounded),
  _TriggerOption('other', 'Something else', Icons.more_horiz_rounded),
];

const _currencyOptions = [
  _CurrencyOption('USD', r'$', 'US dollar'),
  _CurrencyOption('EUR', '€', 'Euro'),
  _CurrencyOption('GBP', '£', 'British pound'),
  _CurrencyOption('INR', '₹', 'Indian rupee'),
  _CurrencyOption('BDT', '৳', 'Bangladeshi taka'),
];

const _totalOnboardingSteps = 5;
const _lastOnboardingStep = _totalOnboardingSteps - 1;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _reasonController = TextEditingController();

  int _step = 0;
  DateTime _quitDate = DateTime.now();
  int _cigarettesPerDay = 10;
  int _packPrice = 12;
  int _packSize = 20;
  _CurrencyOption _currency = _currencyOptions.first;
  final Set<String> _triggers = {'stress'};
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.md,
                AppSpacing.pagePadding,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _step == 0 || _isSaving ? null : _previous,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: (_step + 1) / _totalOnboardingSteps,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${_step + 1}/$_totalOnboardingSteps',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepPane(
                    icon: Icons.flag_rounded,
                    eyebrow: 'Your clock',
                    title: 'When should ZeroPuff start counting?',
                    subtitle:
                        'Pick the moment that feels honest. You can adjust it later.',
                    body: Column(
                      children: [
                        _ChoiceTile(
                          title: 'Today',
                          subtitle: 'Start fresh from this moment.',
                          icon: Icons.wb_sunny_outlined,
                          selected: _isSameDate(_quitDate, DateTime.now()),
                          onTap: () {
                            _selectionHaptic();
                            setState(() => _quitDate = DateTime.now());
                          },
                        ),
                        _ChoiceTile(
                          title: 'Yesterday',
                          subtitle: 'You have already begun.',
                          icon: Icons.nightlight_round,
                          selected: _isSameDate(
                            _quitDate,
                            DateTime.now().subtract(const Duration(days: 1)),
                          ),
                          onTap: () {
                            _selectionHaptic();
                            setState(() {
                              _quitDate = DateTime.now().subtract(
                                const Duration(days: 1),
                              );
                            });
                          },
                        ),
                        _ChoiceTile(
                          title: 'Choose a date',
                          subtitle: _dateLabel(_quitDate),
                          icon: Icons.event_rounded,
                          selected:
                              !_isSameDate(_quitDate, DateTime.now()) &&
                              !_isSameDate(
                                _quitDate,
                                DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                              ),
                          onTap: _pickQuitDate,
                        ),
                      ],
                    ),
                  ),
                  _StepPane(
                    icon: Icons.payments_outlined,
                    eyebrow: 'Your baseline',
                    title: 'Make progress measurable',
                    subtitle:
                        'No judgement here. These numbers turn time into real feedback.',
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Currency', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _currencyOptions.map((currency) {
                            return ChoiceChip(
                              label: Text(
                                '${currency.symbol} ${currency.code}',
                              ),
                              selected: _currency.code == currency.code,
                              onSelected: (_) {
                                _selectionHaptic();
                                setState(() => _currency = currency);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _NumberStepper(
                          label: 'Cigarettes per day',
                          value: _cigarettesPerDay,
                          min: 0,
                          max: 80,
                          onChanged: (value) {
                            _selectionHaptic();
                            setState(() => _cigarettesPerDay = value);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _NumberStepper(
                          label: 'Pack price',
                          value: _packPrice,
                          min: 0,
                          max: 10000,
                          prefix: _currency.symbol,
                          step: _currency.largePriceStep ? 10 : 1,
                          onChanged: (value) {
                            _selectionHaptic();
                            setState(() => _packPrice = value);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _NumberStepper(
                          label: 'Cigarettes per pack',
                          value: _packSize,
                          min: 1,
                          max: 60,
                          onChanged: (value) {
                            _selectionHaptic();
                            setState(() => _packSize = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  _StepPane(
                    icon: Icons.bolt_rounded,
                    eyebrow: 'Rescue shortcuts',
                    title: 'What usually pulls you toward smoking?',
                    subtitle:
                        'Pick a few. During a craving, we will keep choices fast.',
                    body: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _triggerOptions.map((trigger) {
                        final selected = _triggers.contains(trigger.value);
                        return _OnboardingTriggerChip(
                          option: trigger,
                          selected: selected,
                          onTap: () => _toggleTrigger(trigger.value),
                        );
                      }).toList(),
                    ),
                  ),
                  _StepPane(
                    icon: Icons.favorite_border_rounded,
                    eyebrow: 'Future-you',
                    title: 'Leave yourself one honest reason',
                    subtitle:
                        'When a craving hits, this sentence can become the pause.',
                    body: TextField(
                      controller: _reasonController,
                      minLines: 5,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Example: I want my breathing back.',
                      ),
                    ),
                  ),
                  _StepPane(
                    icon: Icons.notifications_active_outlined,
                    eyebrow: 'Helpful nudges',
                    title: 'Let ZeroPuff remind you at the right moment',
                    subtitle:
                        'Cravings often arrive when motivation is quiet. Smart reminders help you notice progress before autopilot takes over.',
                    body: const Column(
                      children: [
                        _NotificationBenefitCard(
                          icon: Icons.savings_outlined,
                          title: 'Progress, not spam',
                          body:
                              'Reminders can mention money saved, cigarettes avoided, or your current streak.',
                        ),
                        SizedBox(height: AppSpacing.md),
                        _NotificationBenefitCard(
                          icon: Icons.fact_check_outlined,
                          title: 'Skips irrelevant check-ins',
                          body:
                              'If today is already recorded, ZeroPuff moves the nudge to tomorrow.',
                        ),
                        SizedBox(height: AppSpacing.md),
                        _NotificationBenefitCard(
                          icon: Icons.nightlight_round,
                          title: 'A gentle evening backup',
                          body:
                              'If the day is still blank, one reminder helps protect your timeline.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _next,
            icon: Icon(
              _step == _lastOnboardingStep
                  ? Icons.notifications_active_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(_buttonLabel()),
          ),
        ),
      ),
    );
  }

  String _buttonLabel() {
    if (_isSaving) {
      return 'Saving';
    }
    return _step == _lastOnboardingStep
        ? 'Enable reminders & finish'
        : 'Continue';
  }

  String _dateLabel(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
      _selectionHaptic();
      setState(() => _quitDate = picked);
    }
  }

  void _toggleTrigger(String trigger) {
    _selectionHaptic();
    setState(() {
      if (_triggers.contains(trigger) && _triggers.length > 1) {
        _triggers.remove(trigger);
      } else {
        _triggers.add(trigger);
      }
    });
  }

  Future<void> _previous() async {
    _selectionHaptic();
    setState(() => _step -= 1);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    if (_step == _lastOnboardingStep) {
      _mediumHaptic();
    } else {
      _lightHaptic();
    }
    await _saveDraft(completed: false);
    if (_step < _lastOnboardingStep) {
      setState(() => _step += 1);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _complete();
  }

  Future<void> _saveDraft({required bool completed}) async {
    final data = OnboardingData(
      quitDate: _quitDate,
      cigarettesPerDay: _cigarettesPerDay,
      packPrice: _packPrice.toDouble(),
      packSize: _packSize,
      currencyCode: _currency.code,
      currencySymbol: _currency.symbol,
      triggers: _triggers.toList(),
      quitReason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      currentStep: _step,
      completed: completed,
    );
    await ref.read(onboardingRepositoryProvider).saveDraft(data);
  }

  Future<void> _complete() async {
    setState(() => _isSaving = true);
    try {
      final notificationsGranted =
          await NotificationService.requestPermission();
      final user = ref.read(currentUserProvider);
      final profile = ProfileData(
        userId: user?.id ?? DeviceIdentityService.guestUserId,
        displayName:
            user?.userMetadata?['full_name']?.toString() ??
            user?.email ??
            'Guest',
        avatarUrl: user?.userMetadata?['avatar_url']?.toString(),
        quitDate: _quitDate,
        cigarettesPerDay: _cigarettesPerDay,
        packPrice: _packPrice.toDouble(),
        packSize: _packSize,
        currencyCode: _currency.code,
        currencySymbol: _currency.symbol,
        triggers: _triggers.toList(),
        quitReason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );

      await ref.read(onboardingRepositoryProvider).completeOnboarding(profile);
      if (user != null) {
        await ref.read(profileRepositoryProvider).upsertProfile(profile);
      }
      await ref
          .read(appEventRepositoryProvider)
          .track(const AppEvent(eventName: 'onboarding_completed'));
      await _setupNotifications(profile, notificationsGranted);

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _setupNotifications(
    ProfileData profile,
    bool notificationsGranted,
  ) async {
    final nextPreferences = NotificationPreferences(
      dailyCheckInEnabled: notificationsGranted,
      milestoneReminderEnabled: notificationsGranted,
      streakProtectionEnabled: notificationsGranted,
    );
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .save(nextPreferences);
    final now = DateTime.now();
    final smokeFreeDuration = now.isBefore(profile.quitDate)
        ? Duration.zero
        : now.difference(profile.quitDate);
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile.quitDate,
      snapshot: NotificationScheduleSnapshot(
        smokeFreeDuration: smokeFreeDuration,
        currencySymbol: profile.currencySymbol,
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() {
    HapticService.selection(enabled: _hapticsEnabled);
  }

  void _lightHaptic() {
    HapticService.light(enabled: _hapticsEnabled);
  }

  void _mediumHaptic() {
    HapticService.medium(enabled: _hapticsEnabled);
  }
}

class _StepPane extends StatelessWidget {
  const _StepPane({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.subtitle,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              eyebrow,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: theme.textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        body,
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primary : null),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBenefitCard extends StatelessWidget {
  const _NotificationBenefitCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
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

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
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
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _editValue(context),
      child: Container(
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
                Expanded(
                  child: Text(label, style: theme.textTheme.titleMedium),
                ),
                IconButton.filledTonal(
                  onPressed: value <= min
                      ? null
                      : () => onChanged((value - step).clamp(min, max)),
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 112,
                  child: Text(
                    '${prefix ?? ''}$value',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: value >= max
                      ? null
                      : () => onChanged((value + step).clamp(min, max)),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editValue(BuildContext context) async {
    final controller = TextEditingController(text: value.toString());
    final next = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(prefixText: prefix),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                Navigator.of(context).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (next != null) {
      onChanged(next.clamp(min, max));
    }
  }
}

class _OnboardingTriggerChip extends StatelessWidget {
  const _OnboardingTriggerChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _TriggerOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = selected
        ? AppColors.primaryLight
        : isDark
        ? AppColors.surfaceCardDark
        : AppColors.surfaceElevated;
    final foreground = selected
        ? AppColors.textPrimary
        : theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primaryLight
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ] else ...[
              Icon(option.icon, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              option.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriggerOption {
  const _TriggerOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class _CurrencyOption {
  const _CurrencyOption(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;

  bool get largePriceStep => code == 'BDT' || code == 'INR';
}
