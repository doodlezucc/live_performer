#pragma once

#include "juce_audio_processors_headless/juce_audio_processors_headless.h"

class MixerGraphProcessor : public juce::AudioProcessor {
public:
	std::unique_ptr<juce::AudioProcessorGraph> graph;

	MixerGraphProcessor() : AudioProcessor(BusesProperties()
		                        .withInput("Input", juce::AudioChannelSet::stereo())
		                        .withOutput("Output", juce::AudioChannelSet::stereo())
	                        ),
	                        graph(new juce::AudioProcessorGraph()) {
	}

	void prepareToPlay(const double sampleRate, const int samplesPerBlock) override {
		graph->setPlayConfigDetails(getMainBusNumInputChannels(), getMainBusNumOutputChannels(), sampleRate,
		                            samplesPerBlock);
		graph->prepareToPlay(sampleRate, samplesPerBlock);
		// initializeGraph();
	}

	void releaseResources() override {
		graph->releaseResources();
	}

	void processBlock(juce::AudioSampleBuffer &buffer, juce::MidiBuffer &midiMessages) override {
		for (int i = getTotalNumInputChannels(); i < getTotalNumOutputChannels(); ++i) {
			buffer.clear(i, 0, buffer.getNumSamples());
		}

		// updateGraph();
		graph->processBlock(buffer, midiMessages);
	}

	//==============================================================================
	bool hasEditor() const override { return false; }

	//==============================================================================
	const juce::String getName() const override { return {}; }
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

protected:
	bool isBusesLayoutSupported(const BusesLayout &layouts) const override {
		if (layouts.getMainInputChannelSet() == juce::AudioChannelSet::disabled()
		    || layouts.getMainOutputChannelSet() == juce::AudioChannelSet::disabled())
			return false;

		// I can only do stereo->stereo and I can do mono->mono
		if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
		    && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
			return false;

		return layouts.getMainInputChannelSet() == layouts.getMainOutputChannelSet();
	}

private:
	juce::AudioProcessorEditor *createEditor() override { return nullptr; }

	JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MixerGraphProcessor)
};
