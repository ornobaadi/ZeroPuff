import 'package:flutter/widgets.dart';

/// Material window size classes, based on the available width.
///
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSize {
  compact,
  medium,
  expanded;

  static const double mediumBreakpoint = 600;
  static const double expandedBreakpoint = 840;

  static WindowSize fromWidth(double width) {
    if (width < mediumBreakpoint) {
      return WindowSize.compact;
    }
    if (width < expandedBreakpoint) {
      return WindowSize.medium;
    }
    return WindowSize.expanded;
  }

  static WindowSize of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }

  bool get isCompact => this == WindowSize.compact;
}

/// Widest a page's content should grow on large screens.
const double kMaxContentWidth = 640;
