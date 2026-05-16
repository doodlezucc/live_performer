import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef CanvasNodeContext = ({bool isDragging});

class InfiniteCanvasNode extends StatefulWidget {
  final Offset offset;
  final void Function(Offset position) onMove;
  final GestureTapCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;
  final Widget Function(CanvasNodeContext context) builder;

  const InfiniteCanvasNode({
    super.key,
    required this.offset,
    required this.onMove,
    this.onTap,
    this.onLongPressStart,
    required this.builder,
  });

  @override
  State<InfiniteCanvasNode> createState() => _InfiniteCanvasNodeState();
}

class _InfiniteCanvasNodeState extends State<InfiniteCanvasNode> {
  bool isDragging = false;
  late Offset _startPointerPosition;
  late Offset _startBoardPosition;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      transformHitTests: true,
      offset: widget.offset,
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onLongPressStart: widget.onLongPressStart,
        onTap: widget.onTap,
        onPanDown: (details) {
          setState(() => isDragging = true);
          _startPointerPosition = details.localPosition;
          _startBoardPosition = widget.offset;
        },
        onPanUpdate: (details) {
          widget.onMove(
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
