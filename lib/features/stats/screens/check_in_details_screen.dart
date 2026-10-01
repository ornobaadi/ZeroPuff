import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/stat_card.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../widgets/detail_widgets.dart';

class CheckInDetailsScreen extends ConsumerWidget {
  const CheckInDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(recentCheckInsProvider).value ?? const [];
    final smokeFree = rows.where((row) => row.smokeFreeToday).length;

    return DetailScaffold(
      title: 'Check-ins',
      builder: (context, data) => [
        DetailHero(
          value: '${rows.length}',
          label: 'recent check-ins',
          icon: Symbols.fact_check_rounded,
          tone: StatTone.craving,
        ),
        InfoCard(
          title: 'Smoke-free check-ins',
          body: rows.isEmpty
              ? 'No check-ins yet. Start with today.'
              : '$smokeFree of your last ${rows.length} check-ins were marked smoke-free.',
          icon: Symbols.check_circle_rounded,
        ),
        const InfoCard(
          title: 'Why this matters',
          body:
              'Daily logs make the calendar useful. Even a hard day becomes data you can recover from.',
          icon: Symbols.calendar_month_rounded,
          tone: StatTone.money,
        ),
      ],
    );
  }
}
