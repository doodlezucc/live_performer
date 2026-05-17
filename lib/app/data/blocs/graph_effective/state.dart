import 'dart:collection';

import 'package:live_performer/app/data/repositories/audio_graph_repository.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';

class EffectiveGraphState {
  final GraphIONodeInfo ioNodeInfo;
  final bool isSynchronized;

  final Map<int, ProcessorNode> _nodes;
  late final nodes = UnmodifiableMapView(_nodes);

  final Set<NodeConnection> _connections;
  late final connections = UnmodifiableSetView(_connections);

  EffectiveGraphState._({
    required this.ioNodeInfo,
    required this.isSynchronized,
    required Map<int, ProcessorNode> nodes,
    required Set<NodeConnection> connections,
  }) : _nodes = nodes,
       _connections = connections;

  EffectiveGraphState({
    required this.ioNodeInfo,
    required this.isSynchronized,
    Map<int, ProcessorNode> nodes = const {},
    Iterable<NodeConnection> connections = const [],
  }) : _nodes = .from(nodes),
       _connections = .from(connections);

  EffectiveGraphState copyWith({
    GraphIONodeInfo? ioNodeInfo,
    bool? isSynchronized,
    Map<int, ProcessorNode>? nodes,
    Iterable<NodeConnection>? connections,
  }) => ._(
    ioNodeInfo: ioNodeInfo ?? this.ioNodeInfo,
    isSynchronized: isSynchronized ?? this.isSynchronized,
    nodes: nodes != null ? .from(nodes) : _nodes,
    connections: connections != null ? .from(connections) : _connections,
  );
}

class ProcessorNode {}
