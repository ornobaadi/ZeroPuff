import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../services/sync/sync_service.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
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
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: widget.navigationShell),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingNavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavigationBar extends StatelessWidget {
  const _FloatingNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Journal',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    _NavItem(
      label: 'Progress',
      icon: Icons.timeline_outlined,
      selectedIcon: Icons.timeline_rounded,
    ),
    _NavItem(
      label: 'You',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 22),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: Material(
          color: isDark
              ? AppColors.surfaceCardDark.withValues(alpha: 0.98)
              : AppColors.navBlue,
          borderRadius: BorderRadius.circular(999),
          elevation: isDark ? 8 : 14,
          shadowColor: Colors.black.withValues(alpha: isDark ? 0.26 : 0.18),
          surfaceTintColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: isDark
                  ? Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.08),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < _items.length; index++)
                  _FloatingNavDestination(
                    item: _items[index],
                    selected: index == selectedIndex,
                    onTap: () => onDestinationSelected(index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavDestination extends StatelessWidget {
  const _FloatingNavDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? AppColors.primaryLight : AppColors.navInk;
    final idleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.navInk.withValues(alpha: 0.82);

    return InkResponse(
      borderRadius: BorderRadius.circular(999),
      containedInkWell: true,
      highlightShape: BoxShape.rectangle,
      splashColor: selectedColor.withValues(alpha: 0.08),
      highlightColor: selectedColor.withValues(alpha: 0.05),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubicEmphasized,
        height: 54,
        padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 13),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColors.surfaceDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color: selected ? selectedColor : idleColor,
              size: 25,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOutCubicEmphasized,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Text(
                        item.label,
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          color: selectedColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
