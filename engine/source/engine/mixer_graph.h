#pragma once

#include "mixer_graph_processor.h"
#include "juce_audio_processors_headless/juce_audio_processors_headless.h"
#include "juce_audio_utils/juce_audio_utils.h"

using AudioGraphIOProcessor = juce::AudioProcessorGraph::AudioGraphIOProcessor;
using Node = juce::AudioProcessorGraph::Node;

class MixerGraph {
public:
    MixerGraph(juce::AudioDeviceManager &audioDeviceManager) : audioDeviceManager(audioDeviceManager) {
        processor.enableAllBuses();

        audioInputNode = processor.graph->addNode(
            std::make_unique<AudioGraphIOProcessor>(AudioGraphIOProcessor::audioInputNode)
        );
        audioOutputNode = processor.graph->addNode(
            std::make_unique<AudioGraphIOProcessor>(AudioGraphIOProcessor::audioOutputNode)
        );

        processorPlayer.setProcessor(&processor);
    }

    ~MixerGraph() {
        processorPlayer.setProcessor(nullptr);
    }

    void addTestNode() const {
        juce::AudioPluginFormatManager formatManager;
        juce::addDefaultFormatsToManager(formatManager);

        juce::KnownPluginList pluginList;

        juce::String pluginBeingScanned;

        for (const auto format: formatManager.getFormats()) {
            if (format->canScanForPlugins()) {
                const auto scanner = new juce::PluginDirectoryScanner(
                    pluginList,
                    *format,
                    format->getDefaultLocationsToSearch(),
                    true,
                    juce::File()
                );

                while (scanner->scanNextFile(true, pluginBeingScanned)) {
                    std::cout << "Discovered plugin: " << pluginBeingScanned << std::endl;
                }
            }
        }

        juce::PluginDescription examplePlugin;

        for (const auto &plugin: pluginList.getTypes()) {
            std::cout << "Plugin " << plugin.descriptiveName << " - " << plugin.pluginFormatName << std::endl;

            if (plugin.descriptiveName.equalsIgnoreCase("GxEcho-Stereo")) {
                examplePlugin = plugin;
            }
        }

        if (examplePlugin.fileOrIdentifier.isEmpty()) {
            throw "Example plugin not found";
        }

        juce::String error;
        auto pluginInstance = formatManager.createPluginInstance(examplePlugin, 48000.0, 512, error);

        if (pluginInstance == nullptr) {
            throw "Failed to create plugin instance";
        }

        pluginInstance->enableAllBuses();

        const auto pluginNode = processor.graph->addNode(std::move(pluginInstance));

        for (int channel = 0; channel < 2; channel++) {
            processor.graph->addConnection({
                {audioInputNode->nodeID, 1}, // Only use the guitar input from my little interface
                {pluginNode->nodeID, channel}
            });
            processor.graph->addConnection({
                {pluginNode->nodeID, channel},
                {audioOutputNode->nodeID, channel}
            });
        }
    }


    void start() {
        audioDeviceManager.addAudioCallback(&processorPlayer);
    }

    void stop() {
        audioDeviceManager.removeAudioCallback(&processorPlayer);
    }

private:
    juce::AudioDeviceManager &audioDeviceManager;

    juce::AudioProcessorPlayer processorPlayer;
    MixerGraphProcessor processor;

    std::unordered_map<uint32_t, Node::Ptr> nodeMap;
    Node::Ptr audioInputNode, audioOutputNode;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MixerGraph)
};
