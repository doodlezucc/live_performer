#include "mixer_engine/mixer_engine_abi.h"

#include <juce_events/juce_events.h>

#include "engine/engine.h"
#include "util.h"

void mixer_error_free(mixer_error *error) {
    std::free(error);
}

void mixer_initialize() {
    juce::initialiseJuce_GUI();
}

void mixer_shutdown() {
    juce::shutdownJuce_GUI();
}


// ReSharper disable once CppClassNeverUsed
struct engine_handle {
    Engine engine;
};

engine_handle *mixer_engine_create() {
    return new engine_handle();
}

void mixer_engine_destroy(const engine_handle *handle) {
    delete handle;
}


mixer_call_result mixer_audio_devices_list(
    engine_handle *handle,
    mixer_audio_device_type_array **out,
    mixer_error *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto array = handle->engine.listAudioDeviceTypes();

        const auto result = new mixer_audio_device_type_array{
            .count = array.size(),
            .device_types = new mixer_audio_device_type *[array.size()],
        };
        *out = result;

        for (int i = 0; i < array.size(); i++) {
            const auto &[name, deviceNames] = array[i];

            const auto deviceNameArray = new char *[deviceNames.size()];
            for (int j = 0; j < deviceNames.size(); j++) {
                deviceNameArray[j] = copyString(deviceNames[j]);
            }

            result->device_types[i] = new mixer_audio_device_type{
                .name = copyString(name),
                .device_count = deviceNames.size(),
                .device_names = deviceNameArray
            };
        }

        return OK;
    ABI_CATCH
}

void mixer_audio_devices_list_free(const mixer_audio_device_type_array *reference) {
    if (reference == nullptr) return;

    for (int i = 0; i < reference->count; i++) {
        const auto deviceType = reference->device_types[i];
        if (deviceType == nullptr) continue;

        std::free(deviceType->name);

        for (int j = 0; j < deviceType->device_count; j++) {
            std::free(deviceType->device_names[j]);
        }

        delete[] deviceType->device_names;
        delete deviceType;
    }

    delete[] reference->device_types;
    delete reference;
}
