import 'package:flutter/material.dart';

class ConfigDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const ConfigDialog({required this.title, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
      shape: RoundedRectangleBorder(borderRadius: .circular(24)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
