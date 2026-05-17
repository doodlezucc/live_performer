import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/repositories/audio_graph_repository.dart';

import 'state.dart';

class EffectiveGraphBloc extends Cubit<EffectiveGraphState> {
  final AudioGraphRepository _repository;

  EffectiveGraphBloc({required AudioGraphRepository repository})
    : _repository = repository,
      super(
        EffectiveGraphState(
          ioNodeInfo: repository.getIONodeInfo(),
          isSynchronized: true,
        ),
      ) {
    _start();
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }

  void addConnection(NodeConnection connection) {
    _repository.addConnection(connection);

    emit(
      state.copyWith(
        isSynchronized: false,
        connections: {...state.connections, connection},
      ),
    );
  }

  void removeConnection(NodeConnection connection) {
    _repository.addConnection(connection);

    final filteredConnections = state.connections.where(
      (other) => other != connection,
    );
    emit(
      state.copyWith(isSynchronized: false, connections: filteredConnections),
    );
  }

  void rebuildGraph() {
    _repository.rebuildGraph();
    emit(state.copyWith(isSynchronized: true));
  }

  void _start() {
    _repository.start();
  }

  void _stop() {
    _repository.stop();
  }
}
