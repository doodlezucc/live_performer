import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_performer/mixer_engine.g.dart';

void main() {
  test('Run FFI thingy', () {
    mixer_initialize();

    final handle = mixer_engine_create();

    expect(handle, isNotNull);

    final arrayPointer = calloc<Pointer<mixer_audio_device_type_array>>();
    final errorPointer = calloc<mixer_error>();
    final result = mixer_audio_devices_list(handle, arrayPointer, errorPointer);

    expect(result, MIXER_OK);
    expect(arrayPointer.value, isNot(nullptr));

    final deviceTypes = arrayPointer.value.ref;

    for (var i = 0; i < deviceTypes.count; i++) {
      final name = (deviceTypes.device_types + i).value.ref.name;
      print(name.cast<Utf8>().toDartString());
    }

    mixer_audio_devices_list_free(arrayPointer.value);

    mixer_engine_destroy(handle);

    mixer_shutdown();
  });
}
