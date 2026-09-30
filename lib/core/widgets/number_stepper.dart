import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_shapes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A labelled whole-number input with minus/plus buttons. Tapping the value
/// opens a keyboard dialog that validates the range instead of silently
/// clamping what the user typed.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.prefix,
    this.step = 1,
    this.errorText,
    super.key,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? prefix;
  final int step;

  /// Shown under the control in the error color.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = errorText != null;

    return Semantics(
      container: true,
      label: label,
      value: '${prefix ?? ''}$value',
      increasedValue: '${prefix ?? ''}${(value + step).clamp(min, max)}',
      decreasedValue: '${prefix ?? ''}${(value - step).clamp(min, max)}',
      onIncrease: value >= max ? null : () => onChanged((value + step).clamp(min, max)),
      onDecrease: value <= min ? null : () => onChanged((value - step).clamp(min, max)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: AppShapes.largeIncreased,
              border: Border.all(
                color: hasError ? scheme.error : scheme.outlineVariant,
                width: hasError ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(label, style: theme.textTheme.titleMedium),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Decrease $label',
                    onPressed: value <= min
                        ? null
                        : () => onChanged((value - step).clamp(min, max)),
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  InkWell(
                    borderRadius: AppShapes.medium,
                    onTap: () => _editValue(context),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 88,
                        minHeight: 48,
                      ),
                      child: Center(
                        child: ExcludeSemantics(
                          child: Text(
                            '${prefix ?? ''}$value',
                            style: AppTypography.statNumber.copyWith(
                              fontSize: 26,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Increase $label',
                    onPressed: value >= max
                        ? null
                        : () => onChanged((value + step).clamp(min, max)),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.xs,
              ),
              child: Text(
                errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editValue(BuildContext context) async {
    final next = await showDialog<int>(
      context: context,
      builder: (context) => _EditValueDialog(
        label: label,
        value: value,
        min: min,
        max: max,
        prefix: prefix,
      ),
    );
    if (next != null) {
      onChanged(next);
    }
  }
}

class _EditValueDialog extends StatefulWidget {
  const _EditValueDialog({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.prefix,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String? prefix;

  @override
  State<_EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<_EditValueDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) {
      setState(() => _error = 'Enter a whole number.');
      return;
    }
    if (parsed < widget.min || parsed > widget.max) {
      setState(
        () => _error = 'Enter a number from ${widget.min} to ${widget.max}.',
      );
      return;
    }
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          prefixText: widget.prefix,
          errorText: _error,
          helperText: 'From ${widget.min} to ${widget.max}',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
