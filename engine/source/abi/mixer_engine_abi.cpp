// ReSharper disable CppParameterMayBeConstPtrOrRef
// ReSharper disable CppPassValueParameterByConstReference
#include "mixer_engine/mixer_engine_abi.h"

#include <juce_events/juce_events.h>

#include "engine/engine.h"
#include "util.h"

void mixer_error_free(mixer_error_t *error) {
    freeString(*error);
    delete error;
}

void mixer_initialize() {
    juce::initialiseJuce_GUI();
}

void mixer_shutdown() {
    juce::shutdownJuce_GUI();
}


// ReSharper disable once CppClassNeverUsed
struct engine_handle_t {
    Engine engine;
};

engine_handle_t *mixer_engine_create() {
    return new engine_handle_t();
}

void mixer_engine_destroy(engine_handle_t *handle) {
    delete handle;
}


void mixer_audio_host_setup_free_members(mixer_audio_host_setup_t ref) {
    freeString(ref.input_device);
    freeString(ref.output_device);
    freeArray(ref.available_sample_rates);
    freeArray(ref.available_buffer_sizes);
}

void mixer_audio_host_setup_free(mixer_audio_host_setup_t *ref) {
    if (ref == nullptr) return;

    mixer_audio_host_setup_free_members(*ref);
    delete ref;
}


void mixer_audio_host_overview_free(mixer_audio_host_overview_t *ref) {
    if (ref == nullptr) return;

    freeString(ref->current_type);

    freeArray(ref->available_types, ref->available_type_count, [](auto type) {
        freeString(type.name);
        freeStringArray(type.input_devices, type.input_device_count);
        freeStringArray(type.output_devices, type.output_device_count);
    });

    mixer_audio_host_setup_free_members(ref->current_setup);
    delete ref;
}

mixer_audio_host_setup_t map_audio_host_setup(const AudioConfig::HostSetup &source) {
    return {
        .input_device = copyString(source.inputDevice),
        .output_device = copyString(source.outputDevice),
        .sample_rate = source.sampleRate,
        .buffer_size = source.bufferSize,
        .available_sample_rate_count = static_cast<size_t>(source.availableSampleRates.size()),
        .available_sample_rates = copyArray(source.availableSampleRates),
        .available_buffer_size_count = static_cast<size_t>(source.availableBufferSizes.size()),
        .available_buffer_sizes = copyArrayAs<int32_t>(source.availableBufferSizes)
    };
}

mixer_call_result_t mixer_audio_config_get_overview(
    engine_handle_t *handle,
    mixer_audio_host_overview_t **out,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto [
            currentType,
            availableTypes,
            currentSetup
        ] = handle->engine.audioConfig.getAudioHostOverview();

        const auto available_types = new mixer_audio_host_type_t[availableTypes.size()];
        for (int i = 0; i < availableTypes.size(); i++) {
            const auto [
                name,
                hasSeparateInputsAndOutputs,
                inputDevices,
                outputDevices
            ] = availableTypes[i];

            available_types[i] = {
                .name = copyString(name),
                .has_separate_inputs_and_outputs = hasSeparateInputsAndOutputs,
                .input_device_count = static_cast<size_t>(inputDevices.size()),
                .input_devices = copyStringArray(inputDevices),
                .output_device_count = static_cast<size_t>(outputDevices.size()),
                .output_devices = copyStringArray(outputDevices)
            };
        }

        *out = new mixer_audio_host_overview_t{
            .current_type = copyString(currentType),
            .available_type_count = static_cast<size_t>(availableTypes.size()),
            .available_types = available_types,
            .current_setup = map_audio_host_setup(currentSetup)
        };

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_reset(
    engine_handle_t *handle,
    const int32_t numInputChannelsNeeded,
    const int32_t numOutputChannelsNeeded,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.reset(numInputChannelsNeeded, numOutputChannelsNeeded);
        *outSetup = new mixer_audio_host_setup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_switch_host_to(
    engine_handle_t *handle,
    char *name,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.switchAudioHostTo(juce::String(name));
        *outSetup = new mixer_audio_host_setup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply_input_device(
    engine_handle_t *handle,
    char *name,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.applyInputDevice(juce::String(name));
        *outSetup = new mixer_audio_host_setup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply_output_device(
    engine_handle_t *handle,
    char *name,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.applyOutputDevice(juce::String(name));
        *outSetup = new mixer_audio_host_setup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply_quality_configuration(
    engine_handle_t *handle,
    const double sampleRate,
    const int bufferSize,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.applyQualityConfiguration(sampleRate, bufferSize);
        *outSetup = new mixer_audio_host_setup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}
