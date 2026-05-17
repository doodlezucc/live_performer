import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/blocs/graph_effective.dart';

import 'state.dart';

class GraphBloc extends Cubit<GraphState> {
  GraphBloc({required EffectiveGraphBloc effectiveGraph})
    : _effectiveGraph = effectiveGraph,
      super(
        GraphState(
          audioInputNode: .new(
            id: 0,
            idInBackend: effectiveGraph.state.ioNodeInfo.audioInputNodeID,
            offset: Offset(-150, 0),
          ),
          audioOutputNode: .new(
            id: 1,
            idInBackend: effectiveGraph.state.ioNodeInfo.audioOutputNodeID,
            offset: Offset(150, 0),
          ),
        ),
      );

  // Discouraged because of coupling, but come on.
  final EffectiveGraphBloc _effectiveGraph;

  void addConnection(UINodeConnection connection) {
    final source = connection.$1.$1;
    final destination = connection.$2.$1;

    if (source is RealNode && destination is RealNode) {
      _effectiveGraph.addConnection((
        (source.idInBackend, connection.$1.$2),
        (destination.idInBackend, connection.$2.$2),
      ));
    } else {
      throw UnimplementedError(
        'Graph connections for facade nodes not supported yet',
      );
    }

    _effectiveGraph.rebuildGraph();
    emit(state.copyWith(connections: {...state.connections, connection}));
  }

  void removeConnection(UINodeConnection connection) {
    throw UnimplementedError('removeConnection not implemented yet');
  }
}
