import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'converter_extensions.dart';
import 'mixer_engine.g.dart';

export 'converter_extensions.dart';
export 'mixer_engine_structs.g.dart';

class MixerEngine {
  final Pointer<engine_handle_t> _handle;

  MixerEngine({required Pointer<engine_handle_t> handle}) : _handle = handle;

  static MixerEngine create() {
    final engineHandle = mixer_engine_create();

    if (engineHandle == nullptr) {
      throw StateError('Failed to create mixer engine');
    }

    return MixerEngine(handle: engineHandle);
  }

  void destroy() {
    mixer_engine_destroy(_handle);
  }

  void runGuarded(
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
          mixer_error_free(errorCharPointer);

          throw errorMessage;
        } else {
          throw "Unknown error with result $result";
        }
      }
    }, calloc);
  }

  Pointer<T> runGuardedWithResult<T extends Struct>(
    int Function(
      Pointer<engine_handle_t> handle,
      Pointer<Pointer<T>> outResult,
      Pointer<mixer_error_t> outError,
    )
    call,
  ) {
    return using((arena) {
      final outResult = arena<Pointer>().cast<Pointer<T>>();

      runGuarded((handle, outError) => call(handle, outResult, outError));

      if (outResult.value == nullptr) {
        throw StateError('Out parameter returned nullptr');
      }

      return outResult.value;
    }, calloc);
  }
}
