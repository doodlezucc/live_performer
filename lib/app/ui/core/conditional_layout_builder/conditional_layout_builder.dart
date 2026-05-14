import 'package:flutter/material.dart';

class ConditionalLayoutBuilder extends StatelessWidget {
  const ConditionalLayoutBuilder({
    required this.enabled,
    required this.builder,
    super.key,
  });

  final bool enabled;
  final Widget Function(BuildContext context, BoxConstraints? constraints)
  builder;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return LayoutBuilder(builder: builder);
    } else {
      return builder(context, null);
    }
  }
}
