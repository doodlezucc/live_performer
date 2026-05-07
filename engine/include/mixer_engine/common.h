#pragma once

#if defined(_WIN32)
#if defined(MIXER_ENGINE_ABI_BUILDING)
#define MIXER_ABI_EXPORT __declspec(dllexport)
#else
#define MIXER_ABI_EXPORT __declspec(dllimport)
#endif
#else
#define MIXER_ABI_EXPORT __attribute__((visibility("default")))
#endif
