import 'package:flutter/material.dart';

/// A single field tile used on the scan review screen.
///
/// Displays a label, an optional leading icon, and the extracted value.
/// Tapping the tile switches to an inline edit mode so the user can
/// correct or fill in a value.
class ScanFieldTile extends StatefulWidget {
  const ScanFieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  /// Human-readable label shown above the value (e.g. "Roaster").
  final String label;

  /// The current value, or `null` / empty if not extracted.
  final String? value;

  /// Called when the user confirms an edit.
  final ValueChanged<String> onChanged;

  /// Optional leading icon for the field.
  final IconData? icon;

  @override
  State<ScanFieldTile> createState() => _ScanFieldTileState();
}

class _ScanFieldTileState extends State<ScanFieldTile> {
  bool _editing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _hasValue => widget.value != null && widget.value!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(ScanFieldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _commitEdit() {
    widget.onChanged(_controller.text);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20, color: colors.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: widget.label,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _commitEdit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.check_rounded, color: colors.primary),
              onPressed: _commitEdit,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _startEditing,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: _hasValue ? colors.primary : colors.outline,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hasValue ? widget.value! : '\u2014',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _hasValue
                          ? colors.onSurface
                          : colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _hasValue ? Icons.check_circle_rounded : Icons.remove_rounded,
              size: 20,
              color: _hasValue ? colors.primary : colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
