#pragma once

#include <juce_audio_devices/juce_audio_devices.h>

class AudioConfig {
public:
    struct HostType {
        juce::String name;
        bool hasSeparateInputsAndOutputs;
        juce::StringArray inputDevices;
        juce::StringArray outputDevices;
    };

    struct HostSetup {
        juce::String inputDevice;
        juce::String outputDevice;
        double sampleRate;
        int bufferSize;
        juce::Array<double> availableSampleRates;
        juce::Array<int> availableBufferSizes;
    };

    struct Overview {
        juce::String currentType;
        juce::Array<HostType> availableTypes;
        HostSetup currentSetup;
    };

    Overview getAudioHostOverview() {
        juce::Array<HostType> availableTypes;

        for (auto &deviceType: audioDeviceManager.getAvailableDeviceTypes()) {
            availableTypes.add(HostType{
                .name = deviceType->getTypeName(),
                .hasSeparateInputsAndOutputs = deviceType->hasSeparateInputsAndOutputs(),
                .inputDevices = deviceType->getDeviceNames(true),
                .outputDevices = deviceType->getDeviceNames(false),
            });
        }

        return {
            .currentType = audioDeviceManager.getCurrentAudioDeviceType(),
            .availableTypes = availableTypes,
            .currentSetup = getCurrentSetup()
        };
    }

    /**
     * @throws std::runtime_error If the default initialization fails.
     */
    HostSetup reset(const int numInputChannelsNeeded, const int numOutputChannelsNeeded) {
        const auto error = audioDeviceManager.initialiseWithDefaultDevices(
            numInputChannelsNeeded,
            numOutputChannelsNeeded
        );

        if (error.isNotEmpty()) {
            throw std::runtime_error(error.toStdString());
        }

        return getCurrentSetup();
    }

    HostSetup switchAudioHostTo(const juce::String &name) {
        audioDeviceManager.setCurrentAudioDeviceType(name, false);

        const auto audioHost = audioDeviceManager.getCurrentDeviceTypeObject();
        audioHost->scanForDevices();

        return getCurrentSetup();
    }

    /**
     * @throws std::runtime_error If the setup can't be applied.
     */
    HostSetup applyInputDevice(const juce::String &name) {
        applySetupChanges([&](auto &setup) {
            setup.inputDeviceName = name;
        });
        return getCurrentSetup();
    }

    /**
     * @throws std::runtime_error If the setup can't be applied.
     */
    HostSetup applyOutputDevice(const juce::String &name) {
        applySetupChanges([&](auto &setup) {
            setup.outputDeviceName = name;
        });
        return getCurrentSetup();
    }


    /**
     * @throws std::runtime_error If the setup can't be applied.
     */
    HostSetup applyQualityConfiguration(const double sampleRate, const int bufferSize) {
        applySetupChanges([&](auto &setup) {
            setup.sampleRate = sampleRate;
            setup.bufferSize = bufferSize;
        });
        return getCurrentSetup();
    }

private:
    juce::AudioDeviceManager audioDeviceManager;

    HostSetup getCurrentSetup() const {
        const auto selectedDevice = audioDeviceManager.getCurrentAudioDevice();
        const auto setup = audioDeviceManager.getAudioDeviceSetup();

        HostSetup result = {
            .inputDevice = setup.inputDeviceName,
            .outputDevice = setup.outputDeviceName,
            .sampleRate = setup.sampleRate,
            .bufferSize = setup.bufferSize,
        };

        if (selectedDevice != nullptr) {
            result.availableSampleRates = selectedDevice->getAvailableSampleRates();
            result.availableBufferSizes = selectedDevice->getAvailableBufferSizes();
        }

        return result;
    }

    void applySetupChanges(const std::function<void(juce::AudioDeviceManager::AudioDeviceSetup &)> &apply) {
        auto setup = audioDeviceManager.getAudioDeviceSetup();
        apply(setup);

        auto const error = audioDeviceManager.setAudioDeviceSetup(setup, false);

        if (error.isNotEmpty()) {
            throw std::runtime_error(error.toStdString());
        }
    }
};
