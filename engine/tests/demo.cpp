#include <catch2/catch_test_macros.hpp>

#include "abi/util.h"
#include "mixer_engine/mixer_engine_abi.h"
#include "engine/engine.h"

TEST_CASE("one is equal to one", "[dummy]") {
    REQUIRE(1 == 1);
}

TEST_CASE("list audio host types", "[dummy]") {
    Engine engine;

    const auto overview = engine.audioConfig.getAudioHostOverview();

    REQUIRE(!overview.availableIOTypes.isEmpty());

    for (const auto &type: overview.availableIOTypes) {
        std::cout << type.name << std::endl;
    }
}

TEST_CASE("list audio devices ABI", "[dummy]") {
    const auto handle = mixer_engine_create();

    mixer_AudioIOOverview_t *overview = nullptr;
    mixer_error_t *error = nullptr;

    const auto result = mixer_audio_config_get_overview(handle, &overview, error);

    REQUIRE(result == MIXER_OK);
    REQUIRE(overview != nullptr);
    REQUIRE(error == nullptr);

    REQUIRE(overview->availableIOTypes_count > 0);

    for (size_t i = 0; i < overview->availableIOTypes_count; i++) {
        const auto &type = overview->availableIOTypes[i];
        std::cout << type.name << std::endl;

        for (size_t j = 0; j < type.inputDevices_count; j++) {
            std::cout << "\t" << type.inputDevices[j] << std::endl;
        }

        for (size_t j = 0; j < type.outputDevices_count; j++) {
            std::cout << "\t" << type.outputDevices[j] << std::endl;
        }
    }

    mixer_free_AudioIOOverview(overview);
}

TEST_CASE("query capabilities", "[dummy]") {
    const auto handle = mixer_engine_create();

    mixer_AudioIOOverview_t *overview = nullptr;
    mixer_error_t *error = nullptr;

    mixer_audio_config_get_overview(handle, &overview, error);

    mixer_AudioIOCombinationCapabilities_t *capabilities = nullptr;
    const auto result = mixer_audio_config_query_capabilities(
        handle,
        overview->availableIOTypes[0].name,
        overview->availableIOTypes[0].inputDevices[0],
        overview->availableIOTypes[0].outputDevices[0],
        &capabilities,
        error
    );
    mixer_free_AudioIOOverview(overview);

    REQUIRE(result == MIXER_OK);
    REQUIRE(capabilities != nullptr);
    REQUIRE(error == nullptr);

    REQUIRE(capabilities->defaultBufferSize > 0);

    for (size_t i = 0; i < capabilities->availableBufferSizes_count; i++) {
        const auto &bufferSize = capabilities->availableBufferSizes[i];
        std::cout << bufferSize << std::endl;
    }

    mixer_free_AudioIOCombinationCapabilities(capabilities);
}

TEST_CASE("apply setup without input device", "[dummy]") {
    const auto handle = mixer_engine_create();

    mixer_AudioIOOverview_t *overview = nullptr;
    mixer_error_t *error = nullptr;

    mixer_audio_config_get_overview(handle, &overview, error);

    // This is basically just a test for Windows DirectSound and will
    // definitely fail on macOS and probably on most Linux systems.
    const auto ioType = overview->availableIOTypes[3];

    const auto setup = new mixer_AudioIOSetup_t{
        .ioType = copyString(ioType.name),
        .inputDevice = copyString(""),
        .outputDevice = copyString(ioType.outputDevices[0]),
        .sampleRate = 44100.0f,
        .bufferSize = 2560
    };

    const auto result = mixer_audio_config_apply(handle, setup, error);
    mixer_free_AudioIOSetup(setup);
    mixer_free_AudioIOOverview(overview);

    REQUIRE(result == MIXER_OK);
    REQUIRE(error == nullptr);
}
