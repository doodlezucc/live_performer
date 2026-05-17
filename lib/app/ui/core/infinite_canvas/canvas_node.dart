import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'canvas_node_controller.dart';

typedef CanvasNodeContext = ({bool isDragging});

class CanvasNode extends StatefulWidget {
  final CanvasNodeController controller;

  final GestureTapCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;
  final Widget Function(CanvasNodeContext context) builder;

  const CanvasNode({
    super.key,
    required this.controller,
    this.onTap,
    this.onLongPressStart,
    required this.builder,
  });

  @override
  State<CanvasNode> createState() => _CanvasNodeState();
}

class _CanvasNodeState extends State<CanvasNode> {
  bool isDragging = false;
  late Offset _startPointerPosition;
  late Offset _startBoardPosition;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        return Transform.translate(
          transformHitTests: true,
          offset: state.offset,
          child: child,
        );
      },
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onLongPressStart: widget.onLongPressStart,
        onTap: widget.onTap,
        onPanDown: (details) {
          setState(() => isDragging = true);
          _startPointerPosition = details.localPosition;
          _startBoardPosition = widget.controller.value.offset;
        },
        onPanUpdate: (details) {
          widget.controller.value = (
            offset:
                _startBoardPosition +
                (details.localPosition - _startPointerPosition),
          );
        },
        onPanEnd: (_) => setState(() => isDragging = false),
        onPanCancel: () => setState(() => isDragging = false),
        child: widget.builder((isDragging: isDragging)),
      ),
    );
  }
}
