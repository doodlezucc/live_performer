import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/blocs/graph.dart';
import 'package:live_performer/app/ui/core/infinite_canvas.dart';
import 'package:live_performer/app/ui/pages/main_page/graph_canvas/graph_node_content.dart';

class GraphCanvas extends StatefulWidget {
  const GraphCanvas({required this.nodes, super.key});

  final SetBase<Node> nodes;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  late final nodeControllers = <Node, CanvasNodeController>{};

  @override
  void initState() {
    super.initState();

    for (final node in widget.nodes) {
      nodeControllers[node] = CanvasNodeController((offset: node.offset));
    }
  }

  @override
  void dispose() {
    for (final controller in nodeControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InfiniteCanvas(
      onDoubleTap: (_) => context.read<GraphBloc>()
        ..addConnection(((widget.nodes.first, 0), (widget.nodes.last, 0)))
        ..addConnection(((widget.nodes.first, 1), (widget.nodes.last, 1))),
      children: [
        ...nodeControllers.entries.map((entry) {
          final node = entry.key;
          final controller = entry.value;

          return CanvasNode(
            controller: controller,
            builder: (canvasNode) =>
                GraphNodeContent(data: node, canvasNode: canvasNode),
          );
        }),
      ],
    );
  }
}
