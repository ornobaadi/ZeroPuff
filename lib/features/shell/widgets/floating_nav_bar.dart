import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// One destination in the [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Material 3 Expressive floating toolbar used as the app's navigation.
///
/// Specs (md.comp.toolbar.floating): 64dp tall, fully rounded, elevation
/// level 3, 16dp from the screen edge, 8dp leading/trailing and 4dp between
/// items. The selected destination expands into a labelled pill while the
/// others collapse to icons, driven by spatial springs that overshoot slightly
/// and settle (md.sys.motion.spring.*.spatial).
///
/// Use with `Scaffold(extendBody: true)` so content scrolls underneath it.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double height = 64;
  static const double externalPadding = 16;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    // Standard floating toolbar container: a raised surface that stays in
    // the theme (lighter charcoal in dark, white on linen in light).
    final container = dark
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainerLowest;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          externalPadding,
          0,
          externalPadding,
          externalPadding,
        ),
        child: Center(
          heightFactor: 1,
          child: Material(
            color: container,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.25),
            surfaceTintColor: Colors.transparent,
            shape: StadiumBorder(
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: dark ? 1 : 0.6),
              ),
            ),
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      _NavButton(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> with TickerProviderStateMixin {
  // Expressive default spatial spring, slightly looser for a visible bounce.
  static final _expandSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 700,
    ratio: 0.62,
  );

  // Expressive fast spatial spring for the press "squish".
  static final _pressSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 1400,
    ratio: 0.55,
  );

  static const double _buttonHeight = 48;
  static const double _sidePadding = 16;
  static const double _iconSize = 24;
  static const double _labelGap = 8;

  late final AnimationController _expand = AnimationController.unbounded(
    vsync: this,
    value: widget.selected ? 1 : 0,
  );
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  @override
  void didUpdateWidget(_NavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _springTo(_expand, widget.selected ? 1 : 0, _expandSpring);
    }
  }

  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = target;
      return;
    }
    controller.animateWith(
      SpringSimulation(spring, controller.value, target, controller.velocity),
    );
  }

  @override
  void dispose() {
    _expand.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Dark: a solid sage pill with dark text, the same pairing as the primary
    // CTA, so the active tab is the brightest thing in the bar. Light: the
    // softer tonal container reads clearly on white.
    final dark = scheme.brightness == Brightness.dark;
    final selectedBackground = dark ? scheme.primary : scheme.primaryContainer;
    final selectedForeground = dark
        ? scheme.onPrimary
        : scheme.onPrimaryContainer;
    final labelStyle = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w600,
      color: selectedForeground,
    );
    final labelWidth = _measure(widget.item.label, labelStyle, context);
    final labelSlot = _labelGap + labelWidth;

    return Semantics(
      label: widget.item.label,
      button: true,
      selected: widget.selected,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _springTo(_press, 0.9, _pressSpring),
        onTapUp: (_) => _springTo(_press, 1, _pressSpring),
        onTapCancel: () => _springTo(_press, 1, _pressSpring),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_expand, _press]),
          builder: (context, _) {
            final t = _expand.value;
            final presence = t.clamp(0.0, 1.0);
            final labelOpacity = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
            final iconColor = Color.lerp(
              scheme.onSurfaceVariant,
              selectedForeground,
              presence,
            );

            return Transform.scale(
              scale: _press.value,
              child: Container(
                height: _buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
                decoration: ShapeDecoration(
                  color: selectedBackground.withValues(alpha: presence),
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      // A small pop on the icon as its pill arrives.
                      scale: 1 + 0.12 * math.sin(presence * math.pi),
                      child: Icon(
                        widget.item.icon,
                        size: _iconSize,
                        fill: presence,
                        weight: 400 + 200 * presence,
                        color: iconColor,
                      ),
                    ),
                    ClipRect(
                      child: SizedBox(
                        width: math.max(0, labelSlot * t),
                        child: OverflowBox(
                          alignment: Alignment.centerLeft,
                          minWidth: labelSlot,
                          maxWidth: labelSlot,
                          child: Padding(
                            padding: const EdgeInsets.only(left: _labelGap),
                            child: Opacity(
                              opacity: labelOpacity,
                              child: Text(
                                widget.item.label,
                                maxLines: 1,
                                softWrap: false,
                                style: labelStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static double _measure(String text, TextStyle style, BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width.ceilToDouble();
  }
}
