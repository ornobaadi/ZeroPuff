import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../core/errors/friendly_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../controllers/google_sign_in_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    container: true,
                    child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.air_rounded,
                            size: 18,
                            color: scheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Private by default',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    header: true,
                    container: true,
                    child: Text(
                      AppConstants.appName,
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    container: true,
                    child: Text(
                    'Open it at the craving moment. Delay the decision, breathe, then log only what matters.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _PromiseCard(
                    icon: Icons.air_rounded,
                    title: 'A two-minute pause',
                    body: 'Guided steps help the urge pass before you choose.',
                  ),
                  const SizedBox(height: AppSpacing.componentGap),
                  const _PromiseCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'Start without pressure',
                    body:
                        'Guest mode works right away. Google is only for backup and sync.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    button: true,
                    enabled: !_isSigningIn,
                    label: _isSigningIn
                        ? 'Opening Google'
                        : 'Continue with Google',
                    excludeSemantics: true,
                    onTap: _isSigningIn ? null : _signIn,
                    child: FilledButton.icon(
                    onPressed: _isSigningIn ? null : _signIn,
                    icon: _isSigningIn
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              semanticsLabel: 'Opening Google',
                            ),
                          )
                        : const _GoogleMark(),
                    label: Text(
                      _isSigningIn ? 'Opening Google' : 'Continue with Google',
                    ),
                  ),
                  ),
                  const SizedBox(height: AppSpacing.componentGap),
                  OutlinedButton.icon(
                    onPressed: _isSigningIn
                        ? null
                        : () {
                            _lightHaptic();
                            context.go(AppRoutes.onboarding);
                          },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Start as guest'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No public feed and no shame score. Your quit data stays on this device unless you choose backup.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    _lightHaptic();
    setState(() => _isSigningIn = true);
    try {
      final outcome = await ref
          .read(googleSignInControllerProvider)
          .signInAndLinkGuestProfile();

      if (mounted) {
        context.go(
          outcome.hasLocalProfile || outcome.restoredRows > 0
              ? AppRoutes.home
              : AppRoutes.onboarding,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _lightHaptic() {
    HapticService.light(enabled: _hapticsEnabled);
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ExcludeSemantics(
        child: Image.memory(
          _googleLogoBytes,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

final Uint8List _googleLogoBytes = base64Decode(
  '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',
);

class _PromiseCard extends StatelessWidget {
  const _PromiseCard({
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
    final scheme = theme.colorScheme;

    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel: '$title. $body',
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 48,
              child: Icon(icon, color: scheme.onSecondaryContainer),
            ),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
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
