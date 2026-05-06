#include <catch2/catch_test_macros.hpp>

#include "mixer_engine/mixer_engine_abi.h"
#include "engine/engine.h"

TEST_CASE("one is equal to one", "[dummy]") {
    REQUIRE(1 == 1);
}

TEST_CASE("list audio host types", "[dummy]") {
    Engine engine;

    const auto overview = engine.audioConfig.getAudioHostOverview();

    REQUIRE(!overview.availableTypes.isEmpty());

    for (const auto &type: overview.availableTypes) {
        std::cout << type.name << std::endl;
    }
}

TEST_CASE("list audio devices ABI", "[dummy]") {
    const auto handle = mixer_engine_create();

    mixer_audio_host_overview_t *overview = nullptr;
    mixer_error_t *error = nullptr;

    const auto result = mixer_audio_config_get_overview(handle, &overview, error);

    REQUIRE(result == MIXER_OK);
    REQUIRE(overview != nullptr);
    REQUIRE(error == nullptr);

    REQUIRE(overview->available_type_count > 0);

    for (size_t i = 0; i < overview->available_type_count; i++) {
        const auto &type = overview->available_types[i];
        std::cout << type.name << std::endl;

        for (size_t j = 0; j < type.input_device_count; j++) {
            std::cout << "\t" << type.input_devices[j] << std::endl;
        }
        
        for (size_t j = 0; j < type.output_device_count; j++) {
            std::cout << "\t" << type.output_devices[j] << std::endl;
        }
    }

    mixer_audio_host_overview_free(overview);
}
