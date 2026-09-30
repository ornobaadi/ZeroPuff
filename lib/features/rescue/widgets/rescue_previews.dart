import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/theme/app_theme.dart';
import '../models/rescue_phase.dart';
import 'rescue_active_view.dart';
import 'rescue_outcome_view.dart';
import 'rescue_reasons.dart';

@Preview(name: 'Active low intensity', group: 'Rescue')
Widget rescueActiveLowIntensityPreview() {
  return _RescuePreviewShell(
    child: RescueActiveView(
      intensity: 5,
      progress: const RescueProgressState(phaseIndex: 0),
      quitReason: rescueFallbackReason,
      onCompletePhase: () {},
    ),
  );
}

@Preview(name: 'Active high intensity checkpoint', group: 'Rescue')
Widget rescueActiveHighIntensityPreview() {
  return _RescuePreviewShell(
    child: RescueActiveView(
      intensity: 10,
      progress: const RescueProgressState(
        phaseIndex: 0,
        remainingSeconds: 91,
        phaseRemainingSeconds: 0,
        waitingForConfirmation: true,
      ),
      quitReason: rescueFallbackReason,
      onCompletePhase: () {},
    ),
  );
}

@Preview(name: 'Breathing phase', group: 'Rescue')
Widget rescueBreathingPhasePreview() {
  return _RescuePreviewShell(
    child: RescueActiveView(
      intensity: 6,
      progress: const RescueProgressState(
        phaseIndex: 1,
        remainingSeconds: 80,
        phaseRemainingSeconds: 20,
        completedPhaseIds: {'water'},
      ),
      quitReason: rescueFallbackReason,
      onCompletePhase: () {},
    ),
  );
}

@Preview(name: 'Outcome', group: 'Rescue')
Widget rescueOutcomePreview() {
  return _RescuePreviewShell(
    child: RescueOutcomeView(
      completedPhaseIds: rescuePhases.map((phase) => phase.id).toSet(),
      urgeAfter: 3,
      onUrgeChanged: (_) {},
      onOutcome: (_) {},
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
