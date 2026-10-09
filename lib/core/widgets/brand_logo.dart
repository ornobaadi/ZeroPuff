import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// The ZeroPuff logo from the brand kit: the snapped-cigarette mark alone, or
/// the mark with the wordmark beside it. Picks the light or dark cut from the
/// theme. The files are used as drawn; only their size is set here.
class BrandLogo extends StatelessWidget {
  /// The mark alone. It is 96 by 54 at its natural size.
  const BrandLogo.mark({double width = 96, super.key})
    : _lockup = false,
      _size = width;

  /// The mark with "ZeroPuff" beside it. It is 40 tall at its natural size.
  const BrandLogo.lockup({double height = 40, super.key})
    : _lockup = true,
      _size = height;

  final bool _lockup;
  final double _size;

  @override
  Widget build(BuildContext context) {
    final tone = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    final name = _lockup ? 'lockup' : 'mark';

    return Image.asset(
      'assets/branding/logo/logo_${name}_$tone.png',
      width: _lockup ? null : _size,
      height: _lockup ? _size : null,
      filterQuality: FilterQuality.medium,
      semanticLabel: AppConstants.appName,
    );
  }
}
