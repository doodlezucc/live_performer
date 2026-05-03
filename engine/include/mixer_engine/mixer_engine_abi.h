#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#if defined(MIXER_ENGINE_ABI_BUILDING)
#define MIXER_ENGINE_ABI_EXPORT __declspec(dllexport)
#else
#define MIXER_ENGINE_ABI_EXPORT __declspec(dllimport)
#endif
#else
#define MIXER_ENGINE_ABI_EXPORT __attribute__((visibility("default")))
#endif


typedef enum {
    OK = 0,
    ERROR,
    ERROR_INVALID_HANDLE,
} mixer_call_result;

typedef char *mixer_error;

MIXER_ENGINE_ABI_EXPORT void mixer_error_free(mixer_error *error);

MIXER_ENGINE_ABI_EXPORT void mixer_initialize();

MIXER_ENGINE_ABI_EXPORT void mixer_shutdown();


typedef struct engine_handle engine_handle;

MIXER_ENGINE_ABI_EXPORT engine_handle *mixer_engine_create();

MIXER_ENGINE_ABI_EXPORT void mixer_engine_destroy(
    const engine_handle *handle
);


typedef struct {
    char *name;
    size_t device_count;
    char **device_names;
} mixer_audio_device_type;

typedef struct {
    size_t count;
    mixer_audio_device_type **device_types;
} mixer_audio_device_type_array;

MIXER_ENGINE_ABI_EXPORT mixer_call_result mixer_audio_devices_list(
    engine_handle *handle,
    mixer_audio_device_type_array **out,
    mixer_error *outError
);

MIXER_ENGINE_ABI_EXPORT void mixer_audio_devices_list_free(const mixer_audio_device_type_array *reference);

#ifdef __cplusplus
}
#endif
