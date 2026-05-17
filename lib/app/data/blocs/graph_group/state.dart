import 'dart:collection';
import 'dart:ui';

import 'package:live_performer/app/data/blocs/graph.dart';

class GraphGroupState {
  final Set<UIGraphNode> _nodes;
  late final nodes = UnmodifiableSetView(_nodes);

  GraphGroupState({Iterable<UIGraphNode> nodes = const []})
    : _nodes = .from(nodes);

  static GraphGroupState fromGraph(GraphState graph, {required int? groupId}) {
    if (graph is GraphReady) {
      return _fromReadyGraph(graph, groupId);
    } else {
      throw StateError('Source graph is not ready');
    }
  }

  static GraphGroupState _fromReadyGraph(GraphReady graph, int? groupId) {
    final uiNodes = <UIGraphNode>{};

    if (groupId == null) {
      uiNodes.addAll(_createNodesFromIOSockets(graph));
    } else {
      final groupNode = graph.nodes[groupId]!;
      final group = groupNode.data as GraphGroupNodeData;
      uiNodes.addAll(_createNodesFromIOSockets(group));
    }

    for (final entry in graph.nodes.entries) {
      final node = entry.value;

      if (node.parentId == groupId) {
        final id = entry.key;
        uiNodes.add(
          UIGraphNode(
            offset: node.offset,
            data: UIGraphNodeData.from(id, node.data),
          ),
        );
      }
    }

    return GraphGroupState(nodes: uiNodes);
  }

  static List<UIGraphNode> _createNodesFromIOSockets(HasIOSocketNodes group) {
    return [
      UIGraphNode(
        offset: group.audioInputNode.offset,
        data: UIGraphIONodeData(type: .audioInput),
      ),
      UIGraphNode(
        offset: group.audioOutputNode.offset,
        data: UIGraphIONodeData(type: .audioOutput),
      ),
    ];
  }
}

class UIGraphNode {
  final Offset offset;
  final UIGraphNodeData data;

  const UIGraphNode({required this.offset, required this.data});
}

sealed class UIGraphNodeData {
  const UIGraphNodeData();

  static UIGraphNodeData from(int id, GraphNodeData data) {
    return switch (data) {
      GraphGroupNodeData() => UIGraphGroupNodeData(name: data.name, id: id),
    };
  }
}

enum UIGraphIONodeType { audioInput, audioOutput }

class UIGraphIONodeData extends UIGraphNodeData {
  final UIGraphIONodeType type;

  const UIGraphIONodeData({required this.type});
}

class UIGraphGroupNodeData extends UIGraphNodeData {
  final String name;
  final int id;

  const UIGraphGroupNodeData({required this.name, required this.id});
}
