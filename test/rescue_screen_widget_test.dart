import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/rescue/screens/rescue_screen.dart';

void main() {
  testWidgets('rescue setup renders intensity, triggers, and start action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const RescueScreen()),
      ),
    );

    expect(find.text('Let us lower the urge first.'), findsOneWidget);
    expect(find.text('Intensity'), findsOneWidget);
    expect(find.text('5/10'), findsOneWidget);
    expect(find.text('What is pulling you right now?'), findsOneWidget);
    expect(find.text('Stressed'), findsOneWidget);

    expect(find.text('Start two minutes'), findsOneWidget);
  });
}
