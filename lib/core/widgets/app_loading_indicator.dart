import 'package:flutter/material.dart';

/// The app's loading indicator: Material's expressive (wavy, rounded) circular
/// progress. Announces itself to screen readers.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    this.size = 48,
    this.label = 'Loading',
    super.key,
  });

  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: SizedBox(
        width: size,
        height: size,
        // ignore: deprecated_member_use
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
