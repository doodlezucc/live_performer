#pragma once

#include <juce_audio_devices/juce_audio_devices.h>

struct AudioDeviceType {
    std::string name;
    std::vector<std::string> deviceNames;
};

class Engine {
public:
    std::vector<AudioDeviceType> listAudioDeviceTypes();

private:
    juce::AudioDeviceManager audioDeviceManager;
};
