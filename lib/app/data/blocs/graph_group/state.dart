import 'dart:collection';

import 'package:live_performer/app/data/blocs/graph.dart';

class GraphGroupState {
  final Set<Node> _nodes;
  late final nodes = UnmodifiableSetView(_nodes);

  GraphGroupState({Iterable<Node> nodes = const []}) : _nodes = .from(nodes);

  static GraphGroupState fromGraph(GraphState graph, {required int? groupId}) {
    final uiNodes = <Node>{};

    if (groupId == null) {
      uiNodes.add(graph.audioInputNode);
      uiNodes.add(graph.audioOutputNode);
    } else {
      final groupNode = graph.resolveNode(groupId) as GroupNode;
      uiNodes.add(groupNode.entryNode);
      uiNodes.add(groupNode.exitNode);
    }

    for (final node in graph.nodes.values) {
      if (node is ScopedNode && (node as ScopedNode).parentId == groupId) {
        uiNodes.add(node);
      }
    }

    return GraphGroupState(nodes: uiNodes);
  }
}
