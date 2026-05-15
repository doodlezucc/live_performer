#pragma once

#include <juce_audio_devices/juce_audio_devices.h>

class AudioConfig {
public:
    explicit AudioConfig(juce::AudioDeviceManager &audioDeviceManager) : audioDeviceManager(audioDeviceManager) {
    }

    struct IOType {
        juce::String name;
        bool hasSeparateInputsAndOutputs;
        juce::StringArray inputDevices;
        juce::StringArray outputDevices;
    };

    struct IOCombinationCapabilities {
        juce::StringArray inputChannelNames;
        juce::StringArray outputChannelNames;

        int defaultBufferSize;
        juce::Array<double> availableSampleRates;
        juce::Array<int> availableBufferSizes;
    };

    struct IOSetup {
        juce::String ioType;
        juce::String inputDevice;
        juce::String outputDevice;
        double sampleRate;
        int bufferSize;
    };

    struct IOSetupInfo {
        IOSetup setup;
        std::optional<IOCombinationCapabilities> capabilities;
    };

    struct Overview {
        juce::Array<IOType> availableIOTypes;
    };

    [[nodiscard]] Overview getAudioHostOverview() const {
        juce::Array<IOType> availableTypes;

        for (auto &deviceType: audioDeviceManager.getAvailableDeviceTypes()) {
            availableTypes.add(IOType{
                .name = deviceType->getTypeName(),
                .hasSeparateInputsAndOutputs = deviceType->hasSeparateInputsAndOutputs(),
                .inputDevices = deviceType->getDeviceNames(true),
                .outputDevices = deviceType->getDeviceNames(false),
            });
        }

        return {
            .availableIOTypes = availableTypes,
        };
    }

    static IOCombinationCapabilities mapAudioIODeviceToCapabilities(juce::AudioIODevice &device) {
        return {
            .inputChannelNames = device.getInputChannelNames(),
            .outputChannelNames = device.getOutputChannelNames(),
            .defaultBufferSize = device.getDefaultBufferSize(),
            .availableSampleRates = device.getAvailableSampleRates(),
            .availableBufferSizes = device.getAvailableBufferSizes(),
        };
    }

    /**
     * @throws std::runtime_error If the hostType, inputDevice or outputDevice doesn't exist.
     * @throws std::runtime_error If AudioIODevice creation for the specified devices fails.
     */
    [[nodiscard]] IOCombinationCapabilities queryCapabilities(
        const juce::String &hostType,
        const juce::String &inputDevice,
        const juce::String &outputDevice
    ) const {
        const auto &availableTypes = audioDeviceManager.getAvailableDeviceTypes();

        for (auto &type: availableTypes) {
            if (type->getTypeName() == hostType) {
                const auto combination = type->createDevice(outputDevice, inputDevice);

                if (combination == nullptr) {
                    throw std::runtime_error("Failed to create device combination");
                }

                // Success, device was created! :)
                return mapAudioIODeviceToCapabilities(*combination);
            }
        }

        throw std::runtime_error("Host type does not exist");
    }

    /**
     * @throws std::runtime_error If the default initialization fails.
     */
    void reset(
        const int numInputChannelsNeeded,
        const int numOutputChannelsNeeded
    ) const {
        const auto error = audioDeviceManager.initialiseWithDefaultDevices(
            numInputChannelsNeeded,
            numOutputChannelsNeeded
        );

        if (error.isNotEmpty()) {
            throw std::runtime_error(error.toStdString());
        }
    }

    /**
     * @throws std::runtime_error If the setup can't be applied.
     */
    void applySetup(const IOSetup &setup) const {
        // Force the private "scanDevicesIfNeeded" function to be called
        audioDeviceManager.getAvailableDeviceTypes();

        const auto originalSetup = audioDeviceManager.getAudioDeviceSetup();
        const auto originalState = audioDeviceManager.createStateXml();

        try {
            audioDeviceManager.setCurrentAudioDeviceType(setup.ioType, false);

            auto deviceSetup = audioDeviceManager.getAudioDeviceSetup();
            deviceSetup.inputDeviceName = setup.inputDevice;
            deviceSetup.outputDeviceName = setup.outputDevice;
            deviceSetup.bufferSize = setup.bufferSize;
            deviceSetup.sampleRate = setup.sampleRate;

            // Maybe this should be switched out for an explicit "enable all channels" thing.
            deviceSetup.useDefaultInputChannels = true;
            deviceSetup.useDefaultOutputChannels = true;

            auto const error = audioDeviceManager.setAudioDeviceSetup(deviceSetup, true);

            if (error.isNotEmpty()) {
                throw std::runtime_error(error.toStdString());
            }
        } catch (...) {
            audioDeviceManager.initialise(
                originalSetup.inputChannels.countNumberOfSetBits(),
                originalSetup.outputChannels.countNumberOfSetBits(),
                originalState.get(),
                false
            );
            throw;
        }
    }

    [[nodiscard]] IOSetupInfo getCurrentSetup() const {
        const auto selectedDevice = audioDeviceManager.getCurrentAudioDevice();
        const auto setup = audioDeviceManager.getAudioDeviceSetup();

        return {
            .setup = {
                .ioType = audioDeviceManager.getCurrentAudioDeviceType(),
                .inputDevice = setup.inputDeviceName,
                .outputDevice = setup.outputDeviceName,
                .sampleRate = setup.sampleRate,
                .bufferSize = setup.bufferSize,
            },
            .capabilities = selectedDevice != nullptr
                                ? std::optional(mapAudioIODeviceToCapabilities(*selectedDevice))
                                : std::nullopt
        };
    }

private:
    juce::AudioDeviceManager &audioDeviceManager;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(AudioConfig)
};
