import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/repositories/audio_graph_repository.dart';

import 'state.dart';

class GraphRootBloc extends Cubit<GraphRootState> {
  final AudioGraphRepository _repository;

  GraphRootBloc({required AudioGraphRepository repository})
    : _repository = repository,
      super(GraphRootInitial());

  void initialize() {
    final ioNodeInfo = _repository.getIONodeInfo();
    emit(GraphRootReady(ioNodeInfo: ioNodeInfo));
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
