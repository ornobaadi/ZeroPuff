import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/selectable_tile.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeControllerProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);

    Future<void> setMode(ThemeMode nextMode) async {
      await ref
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(nextMode);
      await HapticService.selection(enabled: hapticsEnabled);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ZeroPuff follows your device by default, but you can keep it light or dark whenever you want.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SelectableTile(
                    icon: Symbols.phone_android_rounded,
                    title: 'System',
                    subtitle: 'Match your phone automatically.',
                    selected: mode == ThemeMode.system,
                    onTap: () => setMode(ThemeMode.system),
                  ),
                  SelectableTile(
                    icon: Symbols.light_mode_rounded,
                    title: 'Light',
                    subtitle: 'Bright, warm surfaces for daytime.',
                    selected: mode == ThemeMode.light,
                    onTap: () => setMode(ThemeMode.light),
                  ),
                  SelectableTile(
                    icon: Symbols.dark_mode_rounded,
                    title: 'Dark',
                    subtitle: 'Calm, low-glare surfaces for night.',
                    selected: mode == ThemeMode.dark,
                    onTap: () => setMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
