# Adapted from https://github.com/sudara/pamplejuce/blob/c045cfb49a942422fb94fe8203f0266e0c389f5c/CMakeLists.txt

cmake_minimum_required(VERSION 3.25)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CPM)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pamplejuce")
include(PamplejuceMacOS)
include(JUCEDefaults)

set(PROJECT_NAME "MixerEngine")

# TODO: Some bundling and signing stuff for MacOS, probably

# Force JUCE to work with sccache
# instruct MSVC to embed debug info (/Z7) instead of emitting a .pdb
set(CMAKE_POLICY_DEFAULT_CMP0141 NEW CACHE STRING "" FORCE)
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT Embedded CACHE STRING "" FORCE)


project("${PROJECT_NAME}" VERSION 0.0.1)

include(PamplejuceLog)

add_subdirectory(juce)

juce_add_console_app("${PROJECT_NAME}"
        PRODUCT_NAME "Mixer Engine Demo"
)

# This lets us use our code in both the JUCE targets and our Test target
# Without running into ODR violations
add_library(SharedCode INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/catch2_main.cpp"
)

# Enable fast math, C++20 and a few other target defaults
include(SharedCodeDefaults)

# Manually list all .h and .cpp files for the plugin
# If you are like me, you'll use globs for your sanity.
# Just ensure you employ CONFIGURE_DEPENDS so the build system picks up changes
# If you want to appease the CMake gods and avoid globs, manually add files like so:
# set(SourceFiles Source/PluginEditor.h Source/PluginProcessor.h Source/PluginEditor.cpp Source/PluginProcessor.cpp)
file(GLOB_RECURSE SourceFiles CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/source/*.h")
target_sources(SharedCode INTERFACE ${SourceFiles})

target_include_directories(SharedCode
        INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/source"
)

# This is where you can set preprocessor definitions for JUCE and your plugin
target_compile_definitions(SharedCode
        INTERFACE

        # JUCE_WEB_BROWSER and JUCE_USE_CURL off by default
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0

        # Uncomment if you are paying for a an Indie/Pro license or releasing under GPLv3
        # JUCE_DISPLAY_SPLASH_SCREEN=0

        # lets the app known if we're Debug or Release
        CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}"
        VERSION="${CURRENT_VERSION}"

        # JucePlugin_Name is for some reason doesn't use the nicer PRODUCT_NAME
        PRODUCT_NAME_WITHOUT_VERSION="Mixer Engine"
)

# Link to any other modules you added (with juce_add_module) here!
# Usually JUCE modules must have PRIVATE visibility
# See https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md#juce_add_module
# However, with Pamplejuce, you'll link modules to SharedCode with INTERFACE visibility
# This allows the JUCE plugin targets and the Tests target to link against it
target_link_libraries(SharedCode
        INTERFACE
        juce_audio_utils
        juce_audio_processors
        juce_dsp
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags
)

# Link the JUCE targets our SharedCode target
# target_link_libraries("${PROJECT_NAME}" PRIVATE SharedCode)


add_library(MixerEngineABI SHARED
        source/abi/mixer_engine_abi.cpp
        include/mixer_engine/mixer_engine_abi.h
)

target_include_directories(MixerEngineABI
        PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_link_libraries(MixerEngineABI
        PRIVATE
        SharedCode
)

target_compile_definitions(MixerEngineABI
        PRIVATE
        MIXER_ENGINE_ABI_BUILDING=1
)

set_target_properties(MixerEngineABI
        PROPERTIES
        OUTPUT_NAME "mixer_engine"
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN YES
)

# IPP support, comment out to disable
include(PamplejuceIPP)

# Everything related to the tests target
include(Tests)
