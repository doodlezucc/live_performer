import 'dart:collection';
import 'dart:ui';

typedef UINodeIDAndChannel = (Node id, int channel);
typedef UINodeConnection = (
  UINodeIDAndChannel source,
  UINodeIDAndChannel destination,
);

final class GraphState {
  final AudioInputNode audioInputNode;
  final AudioOutputNode audioOutputNode;

  final Map<int, Node> _nodes;
  late final nodes = UnmodifiableMapView(_nodes);

  final Set<UINodeConnection> _connections;
  late final connections = UnmodifiableSetView(_connections);

  GraphState({
    required this.audioInputNode,
    required this.audioOutputNode,
    Map<int, Node> nodes = const {},
    Iterable<UINodeConnection> connections = const [],
  }) : _nodes = .from(nodes),
       _connections = .from(connections);

  GraphState copyWith({
    Map<int, Node>? nodes,
    Iterable<UINodeConnection>? connections,
  }) => .new(
    audioInputNode: audioInputNode,
    audioOutputNode: audioOutputNode,
    nodes: nodes ?? _nodes,
    connections: connections ?? _connections,
  );

  Node resolveNode(int id) {
    if (id == audioInputNode.id) return audioInputNode;
    if (id == audioOutputNode.id) return audioOutputNode;

    return _nodes[id]!;
  }
}

mixin ScopedNode {
  int? get parentId;
}

sealed class Node {
  final int id;
  final Offset offset;

  const Node({required this.id, required this.offset});

  ConnectableNode get entry;
  ConnectableNode get exit;
}

mixin ConnectableNode on Node {
  int get numInputs;
  int get numOutputs;

  @override
  ConnectableNode get entry => this;
  @override
  ConnectableNode get exit => this;
}

sealed class RealNode extends Node {
  final int idInBackend;

  const RealNode({
    required super.id,
    required super.offset,
    required this.idInBackend,
  });
}

sealed class AudioIONode extends RealNode with ConnectableNode {
  const AudioIONode({
    required super.id,
    required super.offset,
    required super.idInBackend,
  });
}

class AudioInputNode extends AudioIONode {
  const AudioInputNode({
    required super.id,
    required super.offset,
    required super.idInBackend,
  });

  @override
  int get numInputs => 0;

  @override
  int get numOutputs => 2;
}

class AudioOutputNode extends AudioIONode {
  const AudioOutputNode({
    required super.id,
    required super.offset,
    required super.idInBackend,
  });

  @override
  int get numInputs => 2;

  @override
  int get numOutputs => 0;
}

class PluginNode extends RealNode with ConnectableNode, ScopedNode {
  @override
  final int? parentId;
  @override
  final int numInputs;
  @override
  final int numOutputs;

  const PluginNode({
    required super.id,
    required this.parentId,
    required super.offset,
    required super.idInBackend,
    required this.numInputs,
    required this.numOutputs,
  });
}

class GroupNode extends Node {
  final String name;
  final GroupEntrySocketNode entryNode;
  final GroupExitSocketNode exitNode;

  const GroupNode({
    required super.id,
    required super.offset,
    required this.name,
    required this.entryNode,
    required this.exitNode,
  });

  @override
  ConnectableNode get entry => entryNode;
  @override
  ConnectableNode get exit => exitNode;
}

sealed class GroupSocketNode extends Node with ConnectableNode, ScopedNode {
  @override
  final int parentId;

  const GroupSocketNode({
    required super.id,
    required this.parentId,
    required super.offset,
  });

  int get numChannels => 2;

  @override
  int get numInputs => numChannels;

  @override
  int get numOutputs => numChannels;
}

class GroupEntrySocketNode extends GroupSocketNode {
  const GroupEntrySocketNode({
    required super.id,
    required super.parentId,
    required super.offset,
  });
}

class GroupExitSocketNode extends GroupSocketNode {
  const GroupExitSocketNode({
    required super.id,
    required super.parentId,
    required super.offset,
  });
}
