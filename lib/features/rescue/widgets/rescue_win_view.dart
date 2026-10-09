import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/number_formatting.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../services/haptics/haptic_service.dart';

/// The payoff for getting through a craving: what just happened, in numbers
/// that belong to the user.
class RescueWinView extends StatefulWidget {
  const RescueWinView({
    required this.intensityBefore,
    required this.intensityAfter,
    required this.currencySymbol,
    required this.hapticsEnabled,
    required this.onDone,
    this.beatenCount,
    this.moneyKept,
    this.streak = 0,
    this.onShare,
    super.key,
  });

  final int intensityBefore;
  final int intensityAfter;
  final String currencySymbol;
  final bool hapticsEnabled;
  final VoidCallback onDone;

  /// Cravings beaten so far, including this one, when known.
  final int? beatenCount;

  /// The price of the cigarette that was not smoked.
  final double? moneyKept;

  /// Cravings resisted in a row, including this one.
  final int streak;
  final VoidCallback? onShare;

  @override
  State<RescueWinView> createState() => _RescueWinViewState();
}

class _RescueWinViewState extends State<RescueWinView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drop;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _drop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (AppMotion.reduced(context)) {
      _drop.value = 1;
      HapticService.coin(enabled: widget.hapticsEnabled);
    } else {
      _drop.forward().whenComplete(() {
        if (mounted) {
          HapticService.coin(enabled: widget.hapticsEnabled);
        }
      });
    }
  }

  @override
  void dispose() {
    _drop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final count = widget.beatenCount;
    final money = widget.moneyKept;
    final title = count == null ? 'Craving beaten' : 'Craving #$count beaten';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              ExcludeSemantics(
                child: SizedBox(
                  height: 150,
                  child: _CoinJar(
                    drop: _drop,
                    jar: accents.money,
                    coin: accents.money,
                    fill: accents.moneyContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'It came, you stayed with it, and it passed. That is the whole skill.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                style: AppCardStyle.tonal,
                semanticLabel:
                    'Urge went from ${widget.intensityBefore} to ${widget.intensityAfter} out of 10',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UrgeNumber(
                      value: widget.intensityBefore,
                      label: 'urge before',
                      color: scheme.onPrimaryContainer,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Icon(
                        Symbols.arrow_forward_rounded,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    _UrgeNumber(
                      value: widget.intensityAfter,
                      label: 'urge now',
                      color: scheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              if (money != null && money > 0) ...[
                _WinLine(
                  icon: Symbols.savings_rounded,
                  color: accents.money,
                  text:
                      '${formatMoney(widget.currencySymbol, money)} stayed in your pocket',
                ),
                const SizedBox(height: AppSpacing.componentGap),
              ],
              if (widget.streak >= 2)
                _WinLine(
                  icon: Symbols.local_fire_department_rounded,
                  color: accents.streak,
                  text: '${widget.streak} cravings beaten in a row',
                ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: widget.onDone,
                child: const Text('Done'),
              ),
              if (widget.onShare != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  onPressed: widget.onShare,
                  icon: const Icon(Symbols.ios_share_rounded),
                  label: const Text('Share this win'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UrgeNumber extends StatelessWidget {
  const _UrgeNumber({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: AppTypography.statNumber.copyWith(color: color)),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _WinLine extends StatelessWidget {
  const _WinLine({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

/// A coin falling into a jar.
class _CoinJar extends StatelessWidget {
  const _CoinJar({
    required this.drop,
    required this.jar,
    required this.coin,
    required this.fill,
  });

  final Animation<double> drop;
  final Color jar;
  final Color coin;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: drop,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _CoinJarPainter(
          progress: Curves.easeIn.transform(drop.value),
          jar: jar,
          coin: coin,
          fill: fill,
        ),
      ),
    );
  }
}

class _CoinJarPainter extends CustomPainter {
  const _CoinJarPainter({
    required this.progress,
    required this.jar,
    required this.coin,
    required this.fill,
  });

  final double progress;
  final Color jar;
  final Color coin;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const jarWidth = 96.0;
    const jarHeight = 92.0;
    const coinRadius = 13.0;
    final jarRect = Rect.fromLTWH(
      (size.width - jarWidth) / 2,
      size.height - jarHeight - 4,
      jarWidth,
      jarHeight,
    );
    final jarShape = RRect.fromRectAndCorners(
      jarRect,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(26),
      bottomRight: const Radius.circular(26),
    );

    // What is already saved, sitting in the bottom of the jar.
    canvas.save();
    canvas.clipRRect(jarShape);
    canvas.drawRect(
      Rect.fromLTWH(
        jarRect.left,
        jarRect.bottom - jarHeight * 0.38,
        jarWidth,
        jarHeight * 0.38,
      ),
      Paint()..color = fill,
    );
    canvas.restore();

    final restY = jarRect.bottom - jarHeight * 0.38 - coinRadius + 4;
    final startY = coinRadius;
    final coinCenter = Offset(
      size.width / 2,
      startY + (restY - startY) * progress,
    );
    canvas.drawCircle(coinCenter, coinRadius, Paint()..color = coin);
    canvas.drawCircle(
      coinCenter,
      coinRadius - 5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = fill,
    );

    canvas.drawRRect(
      jarShape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = jar,
    );
  }

  @override
  bool shouldRepaint(covariant _CoinJarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.jar != jar ||
        oldDelegate.coin != coin ||
        oldDelegate.fill != fill;
  }
}
