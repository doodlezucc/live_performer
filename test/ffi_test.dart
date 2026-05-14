import 'package:flutter_test/flutter_test.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';
import 'package:live_performer/mixer_engine/mixer_engine.g.dart';

void main() {
  setUp(() => mixer_initialize());
  tearDown(() => mixer_shutdown());

  test('Run FFI thingy', () {
    late final MixerEngine engine;

    setUp(() => engine = MixerEngine.create());
    tearDown(() => engine.destroy());

    final audioIORepository = AudioIORepository(engine: engine);

    audioIORepository.reset(
      numInputChannelsNeeded: 2,
      numOutputChannelsNeeded: 2,
    );

    final defaultSetup = audioIORepository.getSetupInfo();
    print(defaultSetup);

    final overview = audioIORepository.getOverview();

    for (final ioType in overview.availableIOTypes) {
      print(ioType.name);
      print('\t${ioType.inputDevices}');
      print('\t${ioType.outputDevices}');
    }

    final ioType = overview.availableIOTypes[0];

    print(
      audioIORepository.queryCapabilities(
        ioType: ioType.name,
        inputDevice: ioType.inputDevices[0],
        outputDevice: ioType.outputDevices[0],
      ),
    );
  });
}
