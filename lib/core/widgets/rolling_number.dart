import 'package:flutter/material.dart';

/// An odometer-style number: each digit rolls up independently when it
/// changes, so a ticking clock reads as steady forward motion rather than
/// flicker. With [countUp], the first appearance counts up from zero.
///
/// Respects the platform "reduce motion" setting.
class RollingNumber extends StatefulWidget {
  const RollingNumber({
    required this.value,
    required this.style,
    this.minDigits = 1,
    this.countUp = false,
    this.duration = const Duration(milliseconds: 450),
    super.key,
  });

  final int value;
  final TextStyle style;

  /// Pads with leading zeros (2 for "05").
  final int minDigits;

  /// Counts up from zero the first time the widget is shown.
  final bool countUp;

  final Duration duration;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber> {
  late bool _intro = widget.countUp && widget.value > 0;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return Text(_format(widget.value), style: widget.style);
    }
    if (_intro) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: widget.value.toDouble()),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        onEnd: () => setState(() => _intro = false),
        builder: (context, v, _) => _digits(v.round()),
      );
    }
    return _digits(widget.value);
  }

  String _format(int value) => value.toString().padLeft(widget.minDigits, '0');

  Widget _digits(int value) {
    final text = _format(value);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < text.length; i++)
          // Key by place value (ones, tens, ...) so digits keep their
          // identity when the number gains a digit.
          _RollingDigit(
            key: ValueKey(text.length - i),
            digit: text[i],
            style: widget.style,
            duration: _intro ? Duration.zero : widget.duration,
          ),
      ],
    );
  }
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({
    required this.digit,
    required this.style,
    required this.duration,
    super.key,
  });

  final String digit;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final current = ValueKey(digit);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previous) => Stack(
          alignment: Alignment.center,
          children: [...previous, ?currentChild],
        ),
        transitionBuilder: (child, animation) {
          final incoming = child.key == current;
          final slide = Tween<Offset>(
            begin: incoming ? const Offset(0, 0.9) : const Offset(0, -0.9),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Text(digit, key: current, style: style),
      ),
    );
  }
}
