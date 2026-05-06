import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'mixer_engine.g.dart';

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
      final outSetup = arena<Pointer<mixer_audio_host_setup_t>>();

      _engine._runGuarded(
        (handle, outError) => mixer_audio_config_reset(
          handle,
          numInputChannelsNeeded,
          numOutputChannelsNeeded,
          outSetup,
          outError,
        ),
      );

      try {
        return outSetup.value.ref.toDart();
      } finally {
        mixer_audio_host_setup_free(outSetup.value);
      }
    });
  }

  AudioHostOverview getOverview() {
    return using((arena) {
      final outOverview = arena<Pointer<mixer_audio_host_overview_t>>();

      _engine._runGuarded(
        (handle, outError) =>
            mixer_audio_config_get_overview(handle, outOverview, outError),
      );

      try {
        final overview = outOverview.value.ref;
        return overview.toDart();
      } finally {
        mixer_audio_host_overview_free(outOverview.value);
      }
    });
  }
}

typedef AudioHostOverview = ({
  String currentType,
  List<AudioHostType> availableTypes,
  AudioHostSetup currentSetup,
});

extension on mixer_audio_host_overview_t {
  AudioHostOverview toDart() => (
    currentType: current_type.cast<Utf8>().toDartString(),
    availableTypes: List.generate(
      available_type_count,
      (i) => (available_types + i).ref.toDart(),
    ),
    currentSetup: current_setup.toDart(),
  );
}

typedef AudioHostType = ({
  String name,
  bool hasSeparateInputsAndOutputs,
  List<String> inputDevices,
  List<String> outputDevices,
});

extension on mixer_audio_host_type_t {
  AudioHostType toDart() => (
    name: name.cast<Utf8>().toDartString(),
    hasSeparateInputsAndOutputs: has_separate_inputs_and_outputs,
    inputDevices: List.generate(
      input_device_count,
      (i) => (input_devices + i).value.cast<Utf8>().toDartString(),
    ),
    outputDevices: List.generate(
      output_device_count,
      (i) => (output_devices + i).value.cast<Utf8>().toDartString(),
    ),
  );
}

typedef AudioHostSetup = ({
  String inputDevice,
  String outputDevice,
  double sampleRate,
  int bufferSize,
  List<double> availableSampleRates,
  List<int> availableBufferSizes,
});

extension on mixer_audio_host_setup_t {
  AudioHostSetup toDart() => (
    inputDevice: input_device.cast<Utf8>().toDartString(),
    outputDevice: output_device.cast<Utf8>().toDartString(),
    sampleRate: sample_rate,
    bufferSize: buffer_size,
    availableSampleRates: List.generate(
      available_sample_rate_count,
      (i) => (available_sample_rates + i).value,
    ),
    availableBufferSizes: List.generate(
      available_buffer_size_count,
      (i) => (available_buffer_sizes + i).value,
    ),
  );
}
