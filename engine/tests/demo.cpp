#include <catch2/catch_test_macros.hpp>

#include "mixer_engine/mixer_engine_abi.h"
#include "engine/engine.h"

TEST_CASE("one is equal to one", "[dummy]") {
    REQUIRE(1 == 1);
}

TEST_CASE("list audio devices", "[dummy]") {
    Engine engine;

    const auto deviceTypes = engine.listAudioDeviceTypes();

    REQUIRE(deviceTypes.size() > 0);
}

TEST_CASE("list audio devices ABI", "[dummy]") {
    const auto handle = mixer_engine_create();

    mixer_audio_device_type_array *deviceArray = nullptr;
    mixer_error *error = nullptr;

    const auto result = mixer_audio_devices_list(handle, &deviceArray, error);

    REQUIRE(result == OK);
    REQUIRE(deviceArray != nullptr);
    REQUIRE(error == nullptr);

    REQUIRE(deviceArray->count > 0);

    mixer_audio_devices_list_free(deviceArray);
}
