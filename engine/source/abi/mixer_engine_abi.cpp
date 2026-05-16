// ReSharper disable CppParameterMayBeConstPtrOrRef
// ReSharper disable CppPassValueParameterByConstReference
#include "mixer_engine/mixer_engine_abi.h"

#include <juce_events/juce_events.h>

#include "engine/engine.h"
#include "util.h"

void mixer_error_free(mixer_error_t error) {
    freeString(error);
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

mixer_call_result_t mixer_audio_config_get_overview(
    engine_handle_t *handle,
    mixer_AudioIOOverview_t **out,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto [availableTypes] = handle->engine.audioConfig.getAudioHostOverview();

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
        };

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_get_setup_info(
    engine_handle_t *handle,
    mixer_AudioIOSetupInfo_t **out,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        const auto [setup, capabilities] = handle->engine.audioConfig.getCurrentSetup();

        *out = new mixer_AudioIOSetupInfo_t({
            .setup = {
                .ioType = copyString(setup.ioType),
                .inputDevice = copyString(setup.inputDevice),
                .outputDevice = copyString(setup.outputDevice),
                .sampleRate = setup.sampleRate,
                .bufferSize = setup.bufferSize
            },
            .capabilities = capabilities.has_value()
                                ? new mixer_AudioIOCombinationCapabilities_t(
                                    map_audio_io_combination_capabilities(capabilities.value())
                                )
                                : nullptr
        });

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
        const auto capabilities = handle->engine.audioConfig.queryCapabilities(
            juce::CharPointer_UTF8(hostType),
            juce::CharPointer_UTF8(inputDevice),
            juce::CharPointer_UTF8(outputDevice)
        );
        *out = new mixer_AudioIOCombinationCapabilities_t(map_audio_io_combination_capabilities(capabilities));

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_reset(
    engine_handle_t *handle,
    const int32_t numInputChannelsNeeded,
    const int32_t numOutputChannelsNeeded,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioConfig.reset(numInputChannelsNeeded, numOutputChannelsNeeded);
        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_audio_config_apply(
    engine_handle_t *handle,
    mixer_AudioIOSetup_t *setup,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioConfig.applySetup({
            .ioType = juce::CharPointer_UTF8(setup->ioType),
            .inputDevice = juce::CharPointer_UTF8(setup->inputDevice),
            .outputDevice = juce::CharPointer_UTF8(setup->outputDevice),
            .sampleRate = setup->sampleRate,
            .bufferSize = setup->bufferSize
        });

        return MIXER_OK;
    ABI_CATCH
}


mixer_call_result_t mixer_graph_start(engine_handle_t *handle, mixer_error_t *outError) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioGraph.start();
        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_graph_stop(engine_handle_t *handle, mixer_error_t *outError) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioGraph.stop();
        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_graph_get_io_node_info(
    engine_handle_t *handle,
    mixer_GraphIONodeInfo_t **outInfo,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        *outInfo = new mixer_GraphIONodeInfo_t{
            .audioInputNodeID = static_cast<int32_t>(handle->engine.audioGraph.getAudioInputNodeID().uid),
            .audioOutputNodeID = static_cast<int32_t>(handle->engine.audioGraph.getAudioOutputNodeID().uid)
        };

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_graph_rebuild(engine_handle_t *handle, mixer_error_t *outError) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioGraph.rebuildGraph();
        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_graph_add_connection(
    engine_handle_t *handle,
    const int32_t sourceID, const int32_t sourceChannel,
    const int32_t destinationID, const int32_t destinationChannel,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioGraph.addConnection({
            {NodeID(sourceID), sourceChannel},
            {NodeID(destinationID), destinationChannel}
        });

        return MIXER_OK;
    ABI_CATCH
}

mixer_call_result_t mixer_graph_remove_connection(
    engine_handle_t *handle,
    const int32_t sourceID, const int32_t sourceChannel,
    const int32_t destinationID, const int32_t destinationChannel,
    mixer_error_t *outError
) {
    if (handle == nullptr) return asErrorInvalidHandle(outError);

    ABI_TRY
        handle->engine.audioGraph.removeConnection({
            {NodeID(sourceID), sourceChannel},
            {NodeID(destinationID), destinationChannel}
        });

        return MIXER_OK;
    ABI_CATCH
}
