import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';
import 'package:live_performer/mixer_engine/mixer_engine.g.dart';

void main() {
  test('Run FFI thingy', () {
    mixer_initialize();

    final handle = mixer_engine_create();

    expect(handle, isNot(nullptr));

    final engine = MixerEngine(handle: handle);

    final defaultSetup = engine.audioConfig.reset(
      numInputChannelsNeeded: 2,
      numOutputChannelsNeeded: 2,
    );

    print(defaultSetup);

    final overview = engine.audioConfig.getOverview();

    for (final ioType in overview.availableIOTypes) {
      print(ioType.name);
      print('\t${ioType.inputDevices}');
      print('\t${ioType.outputDevices}');
    }

    final ioType = overview.availableIOTypes[0];

    print(
      engine.audioConfig.queryCapabilities(
        hostName: ioType.name,
        inputDevice: ioType.inputDevices[0],
        outputDevice: ioType.outputDevices[0],
      ),
    );

    mixer_engine_destroy(handle);

    mixer_shutdown();
  });
}
