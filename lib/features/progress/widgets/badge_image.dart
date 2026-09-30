import 'package:flutter/material.dart';

import '../../../core/theme/app_accents.dart';

const _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

/// A milestone or achievement badge. Locked badges are greyscale and faded;
/// the lock icon and the surrounding text carry the state, not color alone.
class BadgeImage extends StatelessWidget {
  const BadgeImage({
    required this.asset,
    required this.unlocked,
    required this.size,
    this.fallbackIcon = Icons.emoji_events_rounded,
    this.showLock = true,
    super.key,
  });

  final String? asset;
  final bool unlocked;
  final double size;
  final IconData fallbackIcon;
  final bool showLock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accents = AppAccents.of(context);

    final fallback = Icon(
      fallbackIcon,
      size: size * 0.62,
      color: unlocked ? accents.money : scheme.outline,
    );
    final badge = asset == null
        ? fallback
        : Image.asset(
            asset!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) => fallback,
          );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ColorFiltered(
              colorFilter: unlocked
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                  : _greyscale,
              child: Opacity(opacity: unlocked ? 1 : 0.58, child: badge),
            ),
            if (!unlocked && showLock)
              Positioned(
                bottom: size * 0.06,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.86),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.lock_rounded,
                      size: (size * 0.2).clamp(14, 24),
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
