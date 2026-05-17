import 'dart:collection';
import 'dart:ui';

import 'package:live_performer/mixer_engine/mixer_engine.dart';

sealed class GraphState {}

final class GraphInitial extends GraphState {}

mixin HasIOSocketNodes {
  GroupSocketNode get audioInputNode;
  GroupSocketNode get audioOutputNode;
}

final class GraphReady extends GraphState with HasIOSocketNodes {
  final GraphIONodeInfo ioNodeInfo;

  @override
  final GroupSocketNode audioInputNode;
  @override
  final GroupSocketNode audioOutputNode;

  final Map<int, GraphNode> _nodes;
  late final nodes = UnmodifiableMapView(_nodes);

  final Set<NodeConnection> _connections;
  late final connections = UnmodifiableSetView(_connections);

  GraphReady({
    required this.ioNodeInfo,
    required this.audioInputNode,
    required this.audioOutputNode,
    Map<int, GraphNode> nodes = const {},
    Iterable<NodeConnection> connections = const [],
  }) : _nodes = .from(nodes),
       _connections = .from(connections);

  GraphReady copyWith({
    GraphIONodeInfo? ioNodeInfo,
    GroupSocketNode? audioInputNode,
    GroupSocketNode? audioOutputNode,
    Map<int, GraphNode>? nodes,
    Iterable<NodeConnection>? connections,
  }) => .new(
    ioNodeInfo: ioNodeInfo ?? this.ioNodeInfo,
    audioInputNode: audioInputNode ?? this.audioInputNode,
    audioOutputNode: audioOutputNode ?? this.audioOutputNode,
    nodes: nodes ?? _nodes,
    connections: connections ?? _connections,
  );
}

typedef NodeIDAndChannel = (int id, int channel);
typedef NodeConnection = (
  NodeIDAndChannel source,
  NodeIDAndChannel destination,
);

mixin GraphNodeTransform {
  Offset get offset;
}

class GraphNode with GraphNodeTransform {
  final int? parentId;
  final GraphNodeData data;

  @override
  final Offset offset;

  const GraphNode({
    required this.parentId,
    required this.offset,
    required this.data,
  });
}

sealed class GraphNodeData {
  const GraphNodeData();
}

class GraphGroupNodeData extends GraphNodeData with HasIOSocketNodes {
  final String name;

  @override
  final GroupSocketNode audioInputNode;
  @override
  final GroupSocketNode audioOutputNode;

  const GraphGroupNodeData({
    required this.name,
    required this.audioInputNode,
    required this.audioOutputNode,
  });
}

class GroupSocketNode with GraphNodeTransform {
  @override
  final Offset offset;

  const GroupSocketNode({required this.offset});
}
