import 'package:live_performer/mixer_engine/mixer_engine.dart';
import 'package:live_performer/mixer_engine/mixer_engine.g.dart';

typedef NodeIDAndChannel = (int id, int channel);
typedef NodeConnection = (
  NodeIDAndChannel source,
  NodeIDAndChannel destination,
);

class AudioGraphRepository {
  final MixerEngine _engine;

  AudioGraphRepository({required MixerEngine engine}) : _engine = engine;

  void start() => _engine.runGuarded(mixer_graph_start);
  void stop() => _engine.runGuarded(mixer_graph_stop);

  GraphIONodeInfo getIONodeInfo() {
    return _engine
        .runGuardedWithResult(mixer_graph_get_io_node_info)
        .freeToDart();
  }

  void rebuildGraph() => _engine.runGuarded(mixer_graph_rebuild);

  void addConnection(NodeConnection connection) {
    _engine.runGuarded(
      (handle, outError) => mixer_graph_add_connection(
        handle,
        connection.$1.$1,
        connection.$1.$2,
        connection.$2.$1,
        connection.$2.$2,
        outError,
      ),
    );
  }

  void removeConnection(NodeConnection connection) {
    _engine.runGuarded(
      (handle, outError) => mixer_graph_remove_connection(
        handle,
        connection.$1.$1,
        connection.$1.$2,
        connection.$2.$1,
        connection.$2.$2,
        outError,
      ),
    );
  }
}
