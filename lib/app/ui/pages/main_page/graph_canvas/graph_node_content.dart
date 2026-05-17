import 'package:flutter/material.dart';
import 'package:live_performer/app/data/blocs/graph_group.dart';
import 'package:live_performer/app/ui/core/infinite_canvas.dart';

class GraphNodeContent extends StatelessWidget {
  const GraphNodeContent({
    required this.data,
    required this.canvasNode,
    super.key,
  });

  final UIGraphNodeData data;
  final CanvasNodeContext canvasNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      color: canvasNode.isDragging ? Colors.red : Colors.redAccent,
      child: _buildChild(context),
    );
  }

  Widget _buildChild(BuildContext context) {
    return switch (data) {
      UIGraphIONodeData(type: final type) => Text('IO (${type.name})'),

      UIGraphGroupNodeData(name: final name) => Text('Group ($name)'),
    };
  }
}
