import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/core/widgets/settings_tiles.dart';
import 'package:zeropuff/core/widgets/stat_card.dart';
import 'package:zeropuff/features/journal/widgets/journal_calendar.dart';
import 'package:zeropuff/features/progress/widgets/badge_image.dart';
import 'package:zeropuff/features/stats/widgets/detail_widgets.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('Settings tiles', () {
    testWidgets('a tile is tappable and meets the 48dp target', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          SettingsSection(
            title: 'Preferences',
            children: [
              SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'System, light or dark mode',
                trailing: 'System',
                onTap: () => taps++,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      await tester.tap(find.text('Appearance'));
      expect(taps, 1);
      expect(
        tester.getSize(find.byType(ListTile)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('a switch row toggles from anywhere on the row', (
      tester,
    ) async {
      var value = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _host(
            SettingsSwitchTile(
              icon: Icons.vibration_rounded,
              title: 'Haptics',
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Haptics'));
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('confirm dialog returns false on cancel, true on confirm', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showConfirmDialog(
                  context,
                  title: 'Delete your account?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('Detail widgets', () {
    testWidgets('hero speaks its value and label together', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const DetailHero(
            value: r'$120',
            label: 'won back from cigarettes',
            icon: Icons.savings_rounded,
            tone: StatTone.money,
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(r'$120 won back from cigarettes'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('even row gives cells equal width', (tester) async {
      await tester.pumpWidget(
        _host(
          const EvenRow(
            children: [
              MiniStat(value: '3', label: 'this week'),
              MiniStat(value: '12%', label: 'resisted'),
            ],
          ),
        ),
      );

      final sizes = tester
          .widgetList<MiniStat>(find.byType(MiniStat))
          .map((w) => tester.getSize(find.byWidget(w)).width)
          .toList();
      expect(sizes[0], sizes[1]);
    });

    test('compactDuration uses plain units', () {
      expect(compactDuration(const Duration(minutes: 20)), '20 minutes');
      expect(compactDuration(const Duration(hours: 1)), '1 hour');
      expect(compactDuration(const Duration(days: 1)), '1 day');
      expect(compactDuration(const Duration(days: 60)), '2 months');
      expect(compactDuration(const Duration(days: 365)), '1 year');
    });

    testWidgets('locked badge shows a lock, unlocked does not', (tester) async {
      await tester.pumpWidget(
        _host(const BadgeImage(asset: null, unlocked: false, size: 96)),
      );
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      await tester.pumpWidget(
        _host(const BadgeImage(asset: null, unlocked: true, size: 96)),
      );
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });
  });

  testWidgets('journal legend names every status in words', (tester) async {
    await tester.pumpWidget(_host(const JournalLegend()));

    expect(find.text('Smoke-free'), findsOneWidget);
    expect(find.text('Craving'), findsOneWidget);
    expect(find.text('Smoked'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
  });
}
