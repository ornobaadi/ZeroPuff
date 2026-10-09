import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/theme/app_theme.dart';
import '../models/rescue_flow.dart';
import '../models/rescue_tool.dart';
import 'rescue_breathe_view.dart';
import 'rescue_check_view.dart';
import 'rescue_reasons.dart';
import 'rescue_tool_view.dart';
import 'rescue_tools_view.dart';
import 'rescue_win_view.dart';

@Preview(name: 'Breathe', group: 'Rescue')
Widget rescueBreathePreview() {
  return _RescuePreviewShell(
    child: RescueBreatheView(
      breathsThisRound: 2,
      hapticsEnabled: false,
      pocketMode: false,
      onBreath: () {},
      onPocketModeChanged: (_) {},
      onSkip: () {},
    ),
  );
}

@Preview(name: 'Check', group: 'Rescue')
Widget rescueCheckPreview() {
  return _RescuePreviewShell(
    child: RescueCheckView(
      startStrength: UrgeStrength.strong,
      triggers: const {'coffee'},
      onStartStrengthChanged: (_) {},
      onTriggerToggled: (_) {},
      onAnswer: (_) {},
      onSmoked: () {},
    ),
  );
}

@Preview(name: 'Other tools', group: 'Rescue')
Widget rescueToolsPreview() {
  return _RescuePreviewShell(
    child: RescueToolsView(
      toolsUsed: const ['water'],
      onPick: (_) {},
      onBreatheAgain: () {},
    ),
  );
}

@Preview(name: 'Grounding tool', group: 'Rescue')
Widget rescueGroundingPreview() {
  return _RescuePreviewShell(
    child: RescueToolView(
      tool: rescueToolById('grounding'),
      quitReason: rescueFallbackReason,
      hapticsEnabled: false,
      onDone: () {},
      onBack: () {},
      onStartDelay: () async => true,
    ),
  );
}

@Preview(name: 'Win', group: 'Rescue')
Widget rescueWinPreview() {
  return _RescuePreviewShell(
    child: RescueWinView(
      intensityBefore: 9,
      intensityAfter: 1,
      currencySymbol: r'$',
      hapticsEnabled: false,
      beatenCount: 12,
      moneyKept: 0.6,
      streak: 4,
      onDone: () {},
    ),
  );
}

class _RescuePreviewShell extends StatelessWidget {
  const _RescuePreviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(body: SafeArea(child: child)),
    );
  }
}
