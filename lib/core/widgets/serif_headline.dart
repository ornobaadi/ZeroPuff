import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// The signature headline: a regular serif line followed by an italic,
/// sage-colored emphasis ("Opening this took *courage.*").
class SerifHeadline extends StatelessWidget {
  const SerifHeadline({
    required this.lead,
    this.emphasis,
    this.style,
    this.textAlign,
    this.emphasisOnNewLine = true,
    super.key,
  });

  final String lead;
  final String? emphasis;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool emphasisOnNewLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.displaySmall;
    final separator = emphasisOnNewLine ? '\n' : ' ';

    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: lead),
            if (emphasis != null)
              TextSpan(
                text: '$separator$emphasis',
                style: AppTypography.emphasis(base, theme.colorScheme.primary),
              ),
          ],
        ),
        textAlign: textAlign,
      ),
    );
  }
}
