import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../widgets/detail_widgets.dart';

class SmokeFreeDetailsScreen extends ConsumerWidget {
  const SmokeFreeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);

    return DetailScaffold(
      title: 'Smoke-free time',
      builder: (context, data) => [
        DetailHero(
          value: '${data.smokeFreeDays}',
          label: data.smokeFreeDays == 1 ? 'day smoke-free' : 'days smoke-free',
          icon: Icons.air_rounded,
        ),
        InfoCard(
          title: 'Into today',
          body:
              '${data.smokeFreeHours}h ${data.smokeFreeMinutes}m into your current day.',
          icon: Icons.schedule_rounded,
        ),
        const InfoCard(
          title: 'How it is calculated',
          body:
              'This starts from your quit date, or from the latest cigarette you honestly logged.',
          icon: Icons.calculate_rounded,
          tone: StatTone.money,
        ),
        InfoCard(
          title: 'Milestones',
          body: 'See the milestones you have reached and the next one coming up.',
          icon: Icons.flag_rounded,
          tone: StatTone.streak,
          onTap: () {
            HapticService.selection(enabled: hapticsEnabled);
            context.push(AppRoutes.milestoneDetails);
          },
        ),
      ],
    );
  }
}
