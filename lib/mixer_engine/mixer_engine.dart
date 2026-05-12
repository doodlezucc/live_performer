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
    }, calloc);
  }

  Pointer<T> _runGuardedWithResult<T extends Struct>(
    int Function(
      Pointer<engine_handle_t> handle,
      Pointer<Pointer<T>> outResult,
      Pointer<mixer_error_t> outError,
    )
    call,
  ) {
    return using((arena) {
      final outResult = arena<Pointer>().cast<Pointer<T>>();

      _runGuarded((handle, outError) => call(handle, outResult, outError));

      if (outResult.value == nullptr) {
        throw StateError('Out parameter returned nullptr');
      }

      return outResult.value;
    }, calloc);
  }
}

class AudioConfig {
  final MixerEngine _engine;

  AudioConfig._(this._engine);

  AudioIOSetupInfo reset({
    required int numInputChannelsNeeded,
    required numOutputChannelsNeeded,
  }) {
    return _engine
        ._runGuardedWithResult<mixer_AudioIOSetupInfo_t>(
          (handle, outResult, outError) => mixer_audio_config_reset(
            handle,
            numInputChannelsNeeded,
            numOutputChannelsNeeded,
            outResult,
            outError,
          ),
        )
        .freeToDart();
  }

  AudioIOOverview getOverview() {
    return _engine
        ._runGuardedWithResult<mixer_AudioIOOverview_t>(
          mixer_audio_config_get_overview,
        )
        .freeToDart();
  }

  AudioIOCombinationCapabilities queryCapabilities({
    required String hostName,
    required String inputDevice,
    required String outputDevice,
  }) {
    return using(
      (arena) => _engine
          ._runGuardedWithResult<mixer_AudioIOCombinationCapabilities_t>(
            (handle, outResult, outError) =>
                mixer_audio_config_query_capabilities(
                  handle,
                  hostName.toUtf8(arena),
                  inputDevice.toUtf8(arena),
                  outputDevice.toUtf8(arena),
                  outResult,
                  outError,
                ),
          )
          .freeToDart(),
    );
  }
}
