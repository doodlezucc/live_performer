#include <catch2/catch_test_macros.hpp>

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
