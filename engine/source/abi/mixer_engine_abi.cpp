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

mixer_AudioHostSetup_t map_audio_host_setup(const AudioConfig::HostSetup &source) {
    return {
        .inputDevice = copyString(source.inputDevice),
        .outputDevice = copyString(source.outputDevice),
        .sampleRate = source.sampleRate,
        .bufferSize = source.bufferSize,
        .availableSampleRates_count = static_cast<size_t>(source.availableSampleRates.size()),
        .availableSampleRates = copyArray(source.availableSampleRates),
        .availableBufferSizes_count = static_cast<size_t>(source.availableBufferSizes.size()),
        .availableBufferSizes = copyArrayAs<int32_t>(source.availableBufferSizes)
    };
}

mixer_call_result_t mixer_audio_config_get_overview(
    engine_handle_t *handle,
    mixer_AudioHostOverview_t **out,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto [
            currentType,
            availableTypes,
            currentSetup
        ] = handle->engine.audioConfig.getAudioHostOverview();

        const auto availableTypesNative = new mixer_AudioHostType_t[availableTypes.size()];
        for (int i = 0; i < availableTypes.size(); i++) {
            const auto [
                name,
                hasSeparateInputsAndOutputs,
                inputDevices,
                outputDevices
            ] = availableTypes[i];

            availableTypesNative[i] = {
                .name = copyString(name),
                .hasSeparateInputsAndOutputs = hasSeparateInputsAndOutputs,
                .inputDevices_count = static_cast<size_t>(inputDevices.size()),
                .inputDevices = copyStringArray(inputDevices),
                .outputDevices_count = static_cast<size_t>(outputDevices.size()),
                .outputDevices = copyStringArray(outputDevices)
            };
        }

        *out = new mixer_AudioHostOverview_t{
            .currentType = copyString(currentType),
            .availableTypes_count = static_cast<size_t>(availableTypes.size()),
            .availableTypes = availableTypesNative,
            .currentSetup = map_audio_host_setup(currentSetup)
        };

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_reset(
    engine_handle_t *handle,
    const int32_t numInputChannelsNeeded,
    const int32_t numOutputChannelsNeeded,
    mixer_AudioHostSetup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.reset(numInputChannelsNeeded, numOutputChannelsNeeded);
        *outSetup = new mixer_AudioHostSetup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_switch_host_to(
    engine_handle_t *handle,
    char *name,
    mixer_AudioHostSetup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.switchAudioHostTo(juce::String(name));
        *outSetup = new mixer_AudioHostSetup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply_input_device(
    engine_handle_t *handle,
    char *name,
    mixer_AudioHostSetup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.applyInputDevice(juce::String(name));
        *outSetup = new mixer_AudioHostSetup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply_output_device(
    engine_handle_t *handle,
    char *name,
    mixer_AudioHostSetup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.applyOutputDevice(juce::String(name));
        *outSetup = new mixer_AudioHostSetup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply_quality_configuration(
    engine_handle_t *handle,
    const double sampleRate,
    const int bufferSize,
    mixer_AudioHostSetup_t **outSetup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto setup = handle->engine.audioConfig.applyQualityConfiguration(sampleRate, bufferSize);
        *outSetup = new mixer_AudioHostSetup_t(map_audio_host_setup(setup));

        return MIXER_OK;
    ABI_CATCH
}
