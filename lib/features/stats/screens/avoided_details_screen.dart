import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/stat_card.dart';
import '../widgets/detail_widgets.dart';

class AvoidedDetailsScreen extends ConsumerWidget {
  const AvoidedDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailScaffold(
      title: 'Cigarettes not smoked',
      builder: (context, data) => [
        DetailHero(
          value: '${data.cigarettesAvoided}',
          label: 'not smoked',
          icon: Icons.smoke_free_rounded,
          tone: StatTone.streak,
        ),
        const InfoCard(
          title: 'What this means',
          body:
              'This is an estimate based on your old daily baseline and how long you have been smoke-free.',
          icon: Icons.insights_rounded,
          tone: StatTone.streak,
        ),
        const InfoCard(
          title: 'Next action',
          body:
              'When a craving hits, open rescue before deciding. That is how this number keeps climbing.',
          icon: Icons.air_rounded,
        ),
      ],
    );
  }
}
