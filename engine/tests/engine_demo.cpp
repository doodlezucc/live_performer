#include <catch2/catch_test_macros.hpp>

#include "engine/engine.h"

TEST_CASE("list plugins", "[dummy]") {
    Engine engine;

    engine.audioConfig.reset(2, 2);

    std::cout << "Buffer size: " << engine.audioConfig.getAudioHostOverview().currentSetup.bufferSize << std::endl;

    engine.audioGraph.start();
    engine.audioGraph.addTestNode();

    std::cout << "Added Valhalla?" << std::endl;

    juce::Time::waitForMillisecondCounter(juce::Time::getMillisecondCounter() + 15000);

    std::cout << "Ending the thing now" << std::endl;
    engine.audioGraph.stop();
}
