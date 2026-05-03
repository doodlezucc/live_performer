# Copied from https://github.com/sudara/cmake-includes/blob/1de088dc5495b0f73ca7c75c10c9fcc37404ca59/PamplejuceLog.cmake

# Logs useful build environment information during configuration

message(STATUS "CMake version: ${CMAKE_VERSION}")
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "System: ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "Generator: ${CMAKE_GENERATOR}")
