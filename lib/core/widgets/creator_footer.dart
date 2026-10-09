import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Who made the app, signed. Tapping the signature five times in a row opens
/// the maker's portfolio.
class CreatorFooter extends StatefulWidget {
  const CreatorFooter({super.key});

  @override
  State<CreatorFooter> createState() => _CreatorFooterState();
}

class _CreatorFooterState extends State<CreatorFooter> {
  static const _signature =
      'assets/ornob-aadi-signature/ornob-aadi-signature-bold-dark.png';
  static const _tapsToOpen = 5;

  /// Taps further apart than this start the count again.
  static const _tapWindow = Duration(seconds: 2);

  int _taps = 0;
  DateTime? _lastTap;

  Future<void> _onSignatureTap() async {
    final now = DateTime.now();
    final last = _lastTap;
    _taps = last != null && now.difference(last) <= _tapWindow ? _taps + 1 : 1;
    _lastTap = now;
    if (_taps < _tapsToOpen) {
      return;
    }
    _taps = 0;
    _lastTap = null;
    await launchUrl(
      Uri.parse(AppConstants.creatorUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = AppTypography.eyebrow.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text('HANDCRAFTED BY', style: label),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            image: true,
            label: 'Ornob Aadi',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onSignatureTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                // One dark-ink file, tinted so it follows the theme.
                child: Image.asset(
                  _signature,
                  height: 72,
                  color: scheme.onSurface,
                  colorBlendMode: BlendMode.srcIn,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${AppConstants.appName.toUpperCase()}  •  '
            'VERSION ${AppConstants.appBuildLabel.replaceFirst('+', ' (')})',
            textAlign: TextAlign.center,
            style: label,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ONE BREATH  •  ONE CRAVING  •  ONE DAY',
            textAlign: TextAlign.center,
            style: label,
          ),
        ],
      ),
    );
  }
}
