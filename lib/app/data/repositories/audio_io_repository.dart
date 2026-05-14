import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';
import 'package:live_performer/mixer_engine/mixer_engine.g.dart';

class AudioIORepository {
  final MixerEngine _engine;

  AudioIORepository({required MixerEngine engine}) : _engine = engine;

  Future<AudioIOOverview> getOverview() {
    return Isolate.run(
      () => _engine
          .runGuardedWithResult<mixer_AudioIOOverview_t>(
            mixer_audio_config_get_overview,
          )
          .freeToDart(),
    );
  }

  AudioIOSetupInfo getSetupInfo() {
    return _engine
        .runGuardedWithResult<mixer_AudioIOSetupInfo_t>(
          mixer_audio_config_get_setup_info,
        )
        .freeToDart();
  }

  Future<AudioIOCombinationCapabilities> queryCapabilities({
    required String ioType,
    required String inputDevice,
    required String outputDevice,
  }) {
    return Isolate.run(
      () => using(
        (arena) => _engine
            .runGuardedWithResult<mixer_AudioIOCombinationCapabilities_t>(
              (handle, outResult, outError) =>
                  mixer_audio_config_query_capabilities(
                    handle,
                    ioType.toUtf8(arena),
                    inputDevice.toUtf8(arena),
                    outputDevice.toUtf8(arena),
                    outResult,
                    outError,
                  ),
            )
            .freeToDart(),
      ),
    );
  }

  Future<void> reset({
    required int numInputChannelsNeeded,
    required int numOutputChannelsNeeded,
  }) {
    return Isolate.run(
      () => _engine.runGuarded(
        (handle, outError) => mixer_audio_config_reset(
          handle,
          numInputChannelsNeeded,
          numOutputChannelsNeeded,
          outError,
        ),
      ),
    );
  }

  Future<void> applySetup({required AudioIOSetup setup}) {
    return Isolate.run(
      () => using((arena) {
        _engine.runGuarded(
          (handle, outError) =>
              mixer_audio_config_apply(handle, setup.toNative(arena), outError),
        );
      }),
    );
  }
}
