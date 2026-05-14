import 'package:flutter/material.dart';
import 'package:live_performer/app/ui/core/conditional_layout_builder/conditional_layout_builder.dart';

import 'dropdown.dart';
import 'option.dart';

class OptionalDropdown<T extends Object> extends StatelessWidget {
  const OptionalDropdown({
    required this.label,
    required this.value,
    required this.onSelected,
    required this.options,
    this.expand = false,
    this.enabled = true,
    super.key,
  });

  final String label;
  final T? value;
  final void Function(T? value) onSelected;
  final List<DropdownOption<T>> options;
  final bool expand;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ConditionalLayoutBuilder(
      enabled: expand,
      builder: (context, constraints) {
        return DropdownMenu<T?>(
          width: expand ? constraints!.maxWidth : null,
          selectOnly: true,
          enabled: enabled,

          decorationBuilder: (context, controller) =>
              buildDecoration(label: label),

          initialSelection: value,
          dropdownMenuEntries: [
            DropdownMenuEntry(
              value: null,
              label: '(none)',
              style: MenuButtonTheme.of(context).style,
            ),
            ...options.map((option) => option.toMenuEntry(context)),
          ],
          onSelected: onSelected,
        );
      },
    );
  }
}
