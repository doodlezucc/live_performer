import 'package:flutter_test/flutter_test.dart';
import 'package:live_performer/app/data/repositories/audio_graph_repository.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';
import 'package:live_performer/mixer_engine/mixer_engine.g.dart';

void main() {
  late MixerEngine engine;

  setUp(() {
    mixer_initialize();
    engine = MixerEngine.create();
  });
  tearDown(() {
    engine.destroy();
    mixer_shutdown();
  });

  test('Loopback audio input into audio output', () async {
    final audioIORepository = AudioIORepository(engine: engine);

    await audioIORepository.reset(
      numInputChannelsNeeded: 2,
      numOutputChannelsNeeded: 2,
    );

    final audioGraphRepository = AudioGraphRepository(engine: engine);

    audioGraphRepository.start();

    final defaultSetup = audioIORepository.getSetupInfo();
    print(defaultSetup);

    final ioNodeInfo = audioGraphRepository.getIONodeInfo();
    audioGraphRepository.addConnection((
      (ioNodeInfo.audioInputNodeID, 0),
      (ioNodeInfo.audioOutputNodeID, 0),
    ));
    audioGraphRepository.addConnection((
      (ioNodeInfo.audioInputNodeID, 1),
      (ioNodeInfo.audioOutputNodeID, 1),
    ));
    audioGraphRepository.rebuildGraph();

    await Future.delayed(Duration(seconds: 20));
    audioGraphRepository.stop();
  });
}
