import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../errors/friendly_error.dart';
import '../theme/app_spacing.dart';
import 'app_loading_indicator.dart';

/// Consistent loading, empty and error states for any screen or section.
class StateView extends StatelessWidget {
  const StateView._({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.loading = false,
    super.key,
  });

  const StateView.loading({String label = 'Loading', Key? key})
    : this._(
        icon: Symbols.hourglass_empty_rounded,
        title: label,
        loading: true,
        key: key,
      );

  const StateView.empty({
    required IconData icon,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) : this._(
         icon: icon,
         title: title,
         message: message,
         actionLabel: actionLabel,
         onAction: onAction,
         key: key,
       );

  /// Shows a user-safe message for [error]; the raw error is never displayed.
  StateView.error({required Object error, VoidCallback? onRetry, Key? key})
    : this._(
        icon: Symbols.error_rounded,
        title: 'Something went wrong',
        message: friendlyError(error),
        actionLabel: onRetry == null ? null : 'Try again',
        onAction: onRetry,
        key: key,
      );

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              AppLoadingIndicator(label: title)
            else
              Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            if (!loading) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
