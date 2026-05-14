import 'package:flutter/material.dart';

class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({required this.value, required this.label});

  DropdownMenuEntry<T> toMenuEntry(BuildContext context) {
    return DropdownMenuEntry(
      value: value,
      label: label,
      style: MenuButtonTheme.of(context).style,
    );
  }
}
