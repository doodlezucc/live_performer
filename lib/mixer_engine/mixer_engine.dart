import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'mixer_engine.g.dart';
import 'mixer_engine_structs.g.dart';

class MixerEngine {
  final Pointer<engine_handle_t> _handle;

  late final audioConfig = AudioConfig._(this);

  MixerEngine({required Pointer<engine_handle_t> handle}) : _handle = handle;

  void _runGuarded(
    int Function(
      Pointer<engine_handle_t> handle,
      Pointer<mixer_error_t> outError,
    )
    call,
  ) {
    using((arena) {
      final outError = arena<mixer_error_t>();

      final result = call(_handle, outError);

      if (result != MIXER_OK) {
        final errorCharPointer = outError.value;

        if (errorCharPointer != nullptr) {
          final errorMessage = errorCharPointer.cast<Utf8>().toDartString();
          mixer_error_free(outError);

          throw errorMessage;
        } else {
          throw "Unknown error with result $result";
        }
      }
    });
  }
}

class AudioConfig {
  final MixerEngine _engine;

  AudioConfig._(this._engine);

  AudioHostSetup reset({
    required int numInputChannelsNeeded,
    required numOutputChannelsNeeded,
  }) {
    return using((arena) {
      final outSetup = arena<Pointer<mixer_AudioHostSetup_t>>();

      _engine._runGuarded(
        (handle, outError) => mixer_audio_config_reset(
          handle,
          numInputChannelsNeeded,
          numOutputChannelsNeeded,
          outSetup,
          outError,
        ),
      );

      final setup = outSetup.value;

      if (setup == nullptr) {
        throw StateError('Out parameter returned nullptr');
      }

      try {
        return setup.ref.toDart();
      } finally {
        setup.free();
      }
    });
  }

  AudioHostOverview getOverview() {
    return using((arena) {
      final outOverview = arena<Pointer<mixer_AudioHostOverview_t>>();

      _engine._runGuarded(
        (handle, outError) =>
            mixer_audio_config_get_overview(handle, outOverview, outError),
      );

      if (outOverview.value == nullptr) {
        throw StateError('message');
      }

      try {
        return outOverview.value.ref.toDart();
      } finally {
        outOverview.value.free();
      }
    });
  }
}
