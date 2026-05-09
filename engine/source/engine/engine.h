#pragma once

#include "audio_config.h"
#include "mixer_graph.h"

class Engine {
public:
    AudioConfig audioConfig;
    MixerGraph audioGraph;

    Engine() : audioConfig(audioDeviceManager), audioGraph(audioDeviceManager) {
    }

private:
    juce::AudioDeviceManager audioDeviceManager;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(Engine)
};
