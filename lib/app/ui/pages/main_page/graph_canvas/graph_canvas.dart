import 'package:flutter/material.dart';
import 'package:live_performer/app/ui/core/infinite_canvas/infinite_canvas.dart';
import 'package:live_performer/app/ui/core/infinite_canvas/infinite_canvas_node.dart';

class GraphCanvas extends StatefulWidget {
  const GraphCanvas({super.key});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  Offset _exampleNodeOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return InfiniteCanvas(
      background: Container(color: Colors.black),
      children: [
        InfiniteCanvasNode(
          offset: _exampleNodeOffset,
          onMove: (offset) => setState(() {
            _exampleNodeOffset = offset;
          }),
          builder: (node) => Container(
            color: node.isDragging ? Colors.red : Colors.black,
            width: 120,
            height: 120,
          ),
        ),
      ],
    );
  }
}
