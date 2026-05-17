import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
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
  'other',
];

const _currencyOptions = [
  _CurrencyOption('USD', r'$', 'US dollar'),
  _CurrencyOption('EUR', 'EUR', 'Euro'),
  _CurrencyOption('GBP', 'GBP', 'British pound'),
  _CurrencyOption('INR', 'INR', 'Indian rupee'),
  _CurrencyOption('BDT', 'BDT', 'Bangladeshi taka'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _cigarettesController = TextEditingController(text: '10');
  final _packPriceController = TextEditingController(text: '12');
  final _packSizeController = TextEditingController(text: '20');
  final _reasonController = TextEditingController();

  int _step = 0;
  DateTime _quitDate = DateTime.now();
  _CurrencyOption _currency = _currencyOptions.first;
  final Set<String> _triggers = {'stress'};
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _cigarettesController.dispose();
    _packPriceController.dispose();
    _packSizeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set your baseline'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / 4),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StepPane(
              title: 'When does your clean-air clock start?',
              subtitle:
                  'Choose the moment ZeroPuff should count from. You can change it later.',
              body: Column(
                children: [
                  _ChoiceTile(
                    title: 'Today',
                    subtitle: 'Start fresh from this moment.',
                    selected: _isSameDate(_quitDate, DateTime.now()),
                    onTap: () => setState(() => _quitDate = DateTime.now()),
                  ),
                  _ChoiceTile(
                    title: 'Yesterday',
                    subtitle: 'You have already begun.',
                    selected: _isSameDate(
                      _quitDate,
                      DateTime.now().subtract(const Duration(days: 1)),
                    ),
                    onTap: () => setState(
                      () => _quitDate = DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                    ),
                  ),
                  _ChoiceTile(
                    title: 'Tomorrow',
                    subtitle: 'Prepare first, start with intention.',
                    selected: _quitDate.isAfter(DateTime.now()),
                    onTap: () => setState(
                      () => _quitDate = DateTime.now().add(
                        const Duration(days: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _StepPane(
              title: 'Make the progress feel real',
              subtitle:
                  'These numbers power your private counter and savings estimate.',
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _currencyOptions.map((currency) {
                      return ChoiceChip(
                        label: Text('${currency.symbol} ${currency.code}'),
                        selected: _currency.code == currency.code,
                        onSelected: (_) {
                          setState(() => _currency = currency);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _NumberField(
                    controller: _cigarettesController,
                    label: 'Cigarettes per day',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _NumberField(
                    controller: _packPriceController,
                    label: 'Pack price',
                    prefixText: '${_currency.symbol} ',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _NumberField(
                    controller: _packSizeController,
                    label: 'Cigarettes per pack',
                  ),
                ],
              ),
            ),
            _StepPane(
              title: 'What usually pulls you toward smoking?',
              subtitle: 'Pick what fits. This keeps the rescue flow fast.',
              body: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _triggerOptions.map((trigger) {
                  final selected = _triggers.contains(trigger);
                  return FilterChip(
                    label: Text(trigger),
                    selected: selected,
                    onSelected: (_) => _toggleTrigger(trigger),
                  );
                }).toList(),
              ),
            ),
            _StepPane(
              title: 'Give future-you one honest reason',
              subtitle:
                  'When a craving hits, this is the sentence we bring back.',
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _previous,
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _next,
                  child: Text(_buttonLabel()),
                ),
              ),
            ],
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
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    await _saveDraft(completed: _step == 3);
    if (_step < 3) {
      setState(() => _step += 1);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _complete();
  }

  Future<void> _saveDraft({required bool completed}) async {
    final data = OnboardingData(
      quitDate: _quitDate,
      cigarettesPerDay: int.tryParse(_cigarettesController.text.trim()) ?? 0,
      packPrice: double.tryParse(_packPriceController.text.trim()) ?? 0,
      packSize: int.tryParse(_packSizeController.text.trim()) ?? 20,
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
        cigarettesPerDay: int.tryParse(_cigarettesController.text.trim()) ?? 0,
        packPrice: double.tryParse(_packPriceController.text.trim()) ?? 0,
        packSize: int.tryParse(_packSizeController.text.trim()) ?? 20,
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
  const _StepPane({required this.title, required this.body, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
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
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        color: selected
            ? theme.colorScheme.primaryContainer
            : theme.cardTheme.color,
        child: ListTile(
          onTap: onTap,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: selected ? const Icon(Icons.check_circle_rounded) : null,
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.prefixText,
  });

  final TextEditingController controller;
  final String label;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label, prefixText: prefixText),
    );
  }
}

class _CurrencyOption {
  const _CurrencyOption(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;
}
