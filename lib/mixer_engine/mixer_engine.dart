import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'converter_extensions.dart';
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
          final errorMessage = errorCharPointer.toDart();
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

  AudioIOSetupInfo reset({
    required int numInputChannelsNeeded,
    required numOutputChannelsNeeded,
  }) {
    return using((arena) {
      final outSetupInfo = arena<Pointer<mixer_AudioIOSetupInfo_t>>();

      _engine._runGuarded(
        (handle, outError) => mixer_audio_config_reset(
          handle,
          numInputChannelsNeeded,
          numOutputChannelsNeeded,
          outSetupInfo,
          outError,
        ),
      );

      final setup = outSetupInfo.value;

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

  AudioIOOverview getOverview() {
    return using((arena) {
      final outOverview = arena<Pointer<mixer_AudioIOOverview_t>>();

      _engine._runGuarded(
        (handle, outError) =>
            mixer_audio_config_get_overview(handle, outOverview, outError),
      );

      if (outOverview.value == nullptr) {
        throw StateError('Out parameter returned nullptr');
      }

      try {
        return outOverview.value.ref.toDart();
      } finally {
        outOverview.value.free();
      }
    });
  }

  AudioIOCombinationCapabilities queryCapabilities({
    required String hostName,
    required String inputDevice,
    required String outputDevice,
  }) {
    return using((arena) {
      final out = arena<Pointer<mixer_AudioIOCombinationCapabilities_t>>();

      _engine._runGuarded(
        (handle, outError) => mixer_audio_config_query_capabilities(
          handle,
          hostName.toUtf8(arena),
          inputDevice.toUtf8(arena),
          outputDevice.toUtf8(arena),
          out,
          outError,
        ),
      );

      if (out.value == nullptr) {
        throw StateError('Out parameter returned nullptr');
      }

      try {
        return out.value.ref.toDart();
      } finally {
        out.value.free();
      }
    });
  }
}
