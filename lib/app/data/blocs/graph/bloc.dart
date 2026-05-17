import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/repositories/audio_graph_repository.dart';

import 'state.dart';

class GraphBloc extends Cubit<GraphState> {
  final AudioGraphRepository _repository;

  GraphBloc({required AudioGraphRepository repository})
    : _repository = repository,
      super(GraphInitial());

  void initialize() {
    final ioNodeInfo = _repository.getIONodeInfo();
    emit(
      GraphReady(
        ioNodeInfo: ioNodeInfo,
        audioInputNode: .new(offset: Offset(-100, 0)),
        audioOutputNode: .new(offset: Offset(100, 0)),
      ),
    );
  }

  void addConnection(NodeConnection connection) {
    _repository.addConnection(connection);
    // Should emit new state maybe
  }

  void removeConnection(NodeConnection connection) {
    _repository.removeConnection(connection);
    // Should emit new state maybe
  }

  void rebuildGraph() {
    _repository.rebuildGraph();
    // Should definitely emit new state
  }
}
