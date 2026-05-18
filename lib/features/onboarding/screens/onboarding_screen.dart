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
import '../../../repositories/auth_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';

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
  _CurrencyOption('EUR', '€', 'Euro'),
  _CurrencyOption('GBP', '£', 'British pound'),
  _CurrencyOption('INR', '₹', 'Indian rupee'),
  _CurrencyOption('BDT', '৳', 'Bangladeshi taka'),
];

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
                        value: (_step + 1) / 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${_step + 1}/4',
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
                          helperText: _currency.largePriceStep
                              ? 'Use +/- 10 or tap the price to type.'
                              : 'Use +/- 1 or tap the price to type.',
                          onChanged: (value) {
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
                        final selected = _triggers.contains(trigger);
                        return FilterChip(
                          avatar: selected
                              ? const Icon(Icons.check_rounded, size: 16)
                              : null,
                          label: Text(trigger),
                          selected: selected,
                          onSelected: (_) => _toggleTrigger(trigger),
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
              _step == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded,
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
    return _step == 3 ? 'Finish setup' : 'Continue';
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
      setState(() => _quitDate = picked);
    }
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

  Future<void> _previous() async {
    setState(() => _step -= 1);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    await _saveDraft(completed: _step == 3);
    if (_step < 3) {
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
      final user = ref.read(currentUserProvider);
      final profile = ProfileData(
        userId: user?.id ?? 'guest-device',
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

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.prefix,
    this.step = 1,
    this.helperText,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? prefix;
  final int step;
  final String? helperText;

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
            if (helperText != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                helperText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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

class _CurrencyOption {
  const _CurrencyOption(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;

  bool get largePriceStep => code == 'BDT' || code == 'INR';
}
