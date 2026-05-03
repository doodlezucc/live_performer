#include "engine.h"

std::vector<AudioDeviceType> Engine::listAudioDeviceTypes() {
    auto &deviceTypes = audioDeviceManager.getAvailableDeviceTypes();

    const auto count = deviceTypes.size();
    auto result = std::vector<AudioDeviceType>(count);

    for (int i = 0; i < count; i++) {
        const auto deviceType = deviceTypes[i];

        const auto deviceNameArray = deviceType->getDeviceNames();

        std::vector<std::string> deviceNames;
        deviceNames.reserve(deviceNameArray.size());

        for (const auto &deviceName: deviceNameArray) {
            deviceNames.push_back(deviceName.toStdString());
        }

        result[i] = AudioDeviceType{
            .name = deviceType->getTypeName().toStdString(),
            .deviceNames = deviceNames
        };
    }

    return result;
}
