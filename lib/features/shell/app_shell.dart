import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../core/layout/window_size.dart';
import '../../core/theme/app_spacing.dart';
import '../../repositories/app_settings_repository.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/sync/sync_service.dart';
import 'widgets/floating_nav_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _showingExitDialog = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final result = await ref.read(syncServiceProvider).syncPending();
        if (result.attempted > 0 || result.succeeded > 0) {
          ref.invalidate(pendingSyncCountProvider);
        }
      } on Object {
        ref.invalidate(pendingSyncCountProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _showingExitDialog) {
          return;
        }
        _showingExitDialog = true;
        HapticService.medium(
          enabled: ref.read(hapticsEnabledControllerProvider),
        );
        final shouldClose = await _confirmCloseApp();
        _showingExitDialog = false;
        if (shouldClose && mounted) {
          await HapticService.medium(
            enabled: ref.read(hapticsEnabledControllerProvider),
          );
          await SystemNavigator.pop();
        }
      },
      child: _ShellScaffold(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          HapticService.selection(
            enabled: ref.read(hapticsEnabledControllerProvider),
          );
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        body: widget.navigationShell,
      ),
    );
  }

  Future<bool> _confirmCloseApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _CloseAppDialog(),
    );
    return confirmed ?? false;
  }
}

class _CloseAppDialog extends StatelessWidget {
  const _CloseAppDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Close ZeroPuff?', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your progress is safe. Close the app only if you are done for now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Stay'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom [NavigationBar] on phones; a [NavigationRail] on wider windows.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  static const _items = [
    FloatingNavItem(label: 'Home', icon: Symbols.home_rounded),
    FloatingNavItem(label: 'Journal', icon: Symbols.book_2_rounded),
    FloatingNavItem(label: 'Progress', icon: Symbols.monitoring_rounded),
    FloatingNavItem(label: 'You', icon: Symbols.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (WindowSize.of(context).isCompact) {
      return Scaffold(
        // Pages scroll underneath the floating bar.
        extendBody: true,
        body: body,
        bottomNavigationBar: FloatingNavBar(
          items: _items,
          selectedIndex: selectedIndex,
          onSelected: onDestinationSelected,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final item in _items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, fill: 1),
                    label: Text(item.label),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
