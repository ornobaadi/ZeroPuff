import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/layout/window_size.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/core/widgets/app_card.dart';
import 'package:zeropuff/core/widgets/content_width.dart';
import 'package:zeropuff/core/widgets/section_header.dart';
import 'package:zeropuff/core/widgets/state_view.dart';
import 'package:zeropuff/core/widgets/stat_card.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('WindowSize', () {
    test('maps widths to Material window size classes', () {
      expect(WindowSize.fromWidth(360), WindowSize.compact);
      expect(WindowSize.fromWidth(599), WindowSize.compact);
      expect(WindowSize.fromWidth(600), WindowSize.medium);
      expect(WindowSize.fromWidth(839), WindowSize.medium);
      expect(WindowSize.fromWidth(840), WindowSize.expanded);
    });
  });

  group('AppCard', () {
    testWidgets('is tappable with at least a 48dp target', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          AppCard(
            onTap: () => taps += 1,
            child: const Text('Card body'),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppCard));
      expect(size.height, greaterThanOrEqualTo(48));

      await tester.tap(find.text('Card body'));
      expect(taps, 1);
    });
  });

  group('StatCard', () {
    testWidgets('shows value and label, and speaks them together', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 180,
            child: StatCard(
              label: 'Not smoked',
              value: '72',
              suffix: 'cigarettes',
              icon: Icons.smoke_free_rounded,
              tone: StatTone.streak,
            ),
          ),
        ),
      );

      expect(find.text('72'), findsOneWidget);
      expect(find.text('Not smoked'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Not smoked: 72 cigarettes'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('renders in dark mode at 2x text scale without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(
            body: SizedBox(
              width: 180,
              child: StatCard(
                label: 'Money won back',
                value: r'$1,240',
                icon: Icons.savings_rounded,
                tone: StatTone.money,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders title, subtitle and an action', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _host(
          SectionHeader(
            title: 'Quick stats',
            subtitle: 'Your progress at a glance',
            actionLabel: 'See all',
            onAction: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Quick stats'), findsOneWidget);
      expect(find.text('Your progress at a glance'), findsOneWidget);
      await tester.tap(find.text('See all'));
      expect(pressed, isTrue);
    });
  });

  group('StateView', () {
    testWidgets('error state hides the raw exception and offers retry', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        _host(
          SizedBox(
            height: 400,
            child: StateView.error(
              error: StateError('PostgrestException: secret table name'),
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('Postgrest'), findsNothing);
      expect(find.textContaining('secret'), findsNothing);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('empty state shows title and message', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            height: 400,
            child: StateView.empty(
              icon: Icons.inbox_outlined,
              title: 'Nothing here yet',
              message: 'Log your first craving to see it here.',
            ),
          ),
        ),
      );

      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(
        find.text('Log your first craving to see it here.'),
        findsOneWidget,
      );
    });
  });

  group('ContentWidth', () {
    testWidgets('caps content width on wide screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const ContentWidth(
            child: SizedBox(
              key: Key('content'),
              width: double.infinity,
              height: 40,
            ),
          ),
        ),
      );

      final width = tester.getSize(find.byKey(const Key('content'))).width;
      expect(width, kMaxContentWidth);
    });
  });
}
