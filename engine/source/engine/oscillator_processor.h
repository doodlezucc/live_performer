#pragma once

#include "juce_audio_processors_headless/juce_audio_processors_headless.h"
#include "juce_dsp/juce_dsp.h"

class OscillatorProcessor : public juce::AudioProcessor {
public:
    //==============================================================================
    OscillatorProcessor()
        : AudioProcessor(
            BusesProperties().withInput("Input", juce::AudioChannelSet::stereo()).withOutput(
                "Output", juce::AudioChannelSet::stereo())) {
        oscillator.setFrequency(440.0f);
        oscillator.initialise([](float x) { return 0.05f * std::sin(x); });
    }

    //==============================================================================
    void prepareToPlay(double sampleRate, int samplesPerBlock) override {
        juce::dsp::ProcessSpec spec{sampleRate, static_cast<juce::uint32>(samplesPerBlock), 2};
        oscillator.prepare(spec);
    }

    void releaseResources() override {
    }

    void processBlock(juce::AudioSampleBuffer &buffer, juce::MidiBuffer &) override {
        juce::dsp::AudioBlock<float> block(buffer);
        juce::dsp::ProcessContextReplacing<float> context(block);
        oscillator.process(context);
    }

    //==============================================================================
    juce::AudioProcessorEditor *createEditor() override { return nullptr; }
    bool hasEditor() const override { return false; }
    //==============================================================================
    const juce::String getName() const override { return "Oscillator"; }
    bool acceptsMidi() const override { return false; }
    bool producesMidi() const override { return false; }
    double getTailLengthSeconds() const override { return 0; }
    //==============================================================================
    int getNumPrograms() override { return 0; }
    int getCurrentProgram() override { return 0; }

    void setCurrentProgram(int) override {
    }

    const juce::String getProgramName(int) override { return {}; }

    void changeProgramName(int, const juce::String &) override {
    }

    //==============================================================================
    void getStateInformation(juce::MemoryBlock &) override {
    }

    void setStateInformation(const void *, int) override {
    }

private:
    juce::dsp::Oscillator<float> oscillator;

    //==============================================================================
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(OscillatorProcessor)
};
