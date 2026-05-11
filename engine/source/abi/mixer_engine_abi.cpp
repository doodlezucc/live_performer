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


mixer_AudioIOCombinationCapabilities_t map_audio_io_combination_capabilities(
    const AudioConfig::IOCombinationCapabilities &source) {
    return {
        .inputChannelNames_count = static_cast<size_t>(source.inputChannelNames.size()),
        .inputChannelNames = copyStringArray(source.inputChannelNames),
        .outputChannelNames_count = static_cast<size_t>(source.outputChannelNames.size()),
        .outputChannelNames = copyStringArray(source.outputChannelNames),
        .defaultBufferSize = source.defaultBufferSize,
        .availableSampleRates_count = static_cast<size_t>(source.availableSampleRates.size()),
        .availableSampleRates = copyArray(source.availableSampleRates),
        .availableBufferSizes_count = static_cast<size_t>(source.availableBufferSizes.size()),
        .availableBufferSizes = copyArray(source.availableBufferSizes)
    };
}

mixer_AudioIOSetupInfo_t map_audio_io_setup_info(const AudioConfig::IOSetupInfo &source) {
    return {
        .setup = {
            .ioType = copyString(source.setup.ioType),
            .inputDevice = copyString(source.setup.inputDevice),
            .outputDevice = copyString(source.setup.outputDevice),
            .sampleRate = source.setup.sampleRate,
            .bufferSize = source.setup.bufferSize
        },
        .capabilities = source.capabilities.has_value()
                            ? new mixer_AudioIOCombinationCapabilities_t(
                                map_audio_io_combination_capabilities(source.capabilities.value())
                            )
                            : nullptr
    };
}

mixer_call_result_t mixer_audio_config_get_overview(
    engine_handle_t *handle,
    mixer_AudioIOOverview_t **out,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto [availableTypes, currentSetup] = handle->engine.audioConfig.getAudioHostOverview();

        const auto availableTypesNative = new mixer_AudioIOType_t[availableTypes.size()];
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

        *out = new mixer_AudioIOOverview_t{
            .availableIOTypes_count = static_cast<size_t>(availableTypes.size()),
            .availableIOTypes = availableTypesNative,
            .currentSetup = map_audio_io_setup_info(currentSetup)
        };

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_query_capabilities(
    engine_handle_t *handle,
    const char *hostType,
    const char *inputDevice,
    const char *outputDevice,
    mixer_AudioIOCombinationCapabilities_t **out,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto capabilities = handle->engine.audioConfig.queryCapabilities(hostType, inputDevice, outputDevice);
        *out = new mixer_AudioIOCombinationCapabilities_t(map_audio_io_combination_capabilities(capabilities));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_reset(
    engine_handle_t *handle,
    const int32_t numInputChannelsNeeded,
    const int32_t numOutputChannelsNeeded,
    mixer_AudioIOSetupInfo_t **outSetupInfo,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioConfig.reset(numInputChannelsNeeded, numOutputChannelsNeeded);

        const auto newSetup = handle->engine.audioConfig.getCurrentSetup();
        *outSetupInfo = new mixer_AudioIOSetupInfo_t(map_audio_io_setup_info(newSetup));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply(
    engine_handle_t *handle,
    mixer_AudioIOSetup_t *setup,
    mixer_AudioIOSetupInfo_t **outSetupInfo,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        try {
            handle->engine.audioConfig.applySetup({
                .ioType = setup->ioType,
                .inputDevice = setup->inputDevice,
                .outputDevice = setup->outputDevice,
                .sampleRate = setup->sampleRate,
                .bufferSize = setup->bufferSize
            });

            const auto newSetup = handle->engine.audioConfig.getCurrentSetup();
            *outSetupInfo = new mixer_AudioIOSetupInfo_t(map_audio_io_setup_info(newSetup));

            return MIXER_OK;
        } catch (...) {
            // ReSharper disable once CppDFANullDereference
            const auto newSetup = handle->engine.audioConfig.getCurrentSetup();
            *outSetupInfo = new mixer_AudioIOSetupInfo_t(map_audio_io_setup_info(newSetup));

            throw;
        }
    ABI_CATCH
}
