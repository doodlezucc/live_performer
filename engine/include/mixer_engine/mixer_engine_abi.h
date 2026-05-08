#pragma once

#include <stdint.h> // NOLINT(*-deprecated-headers)


#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

#include "structs.g.h"

typedef int32_t mixer_call_result_t;

enum {
    MIXER_OK = 0,
    MIXER_ERROR = 1,
    MIXER_ERROR_INVALID_HANDLE = 2,
};

typedef char *mixer_error_t;

MIXER_ABI_EXPORT void mixer_error_free(mixer_error_t *error);

MIXER_ABI_EXPORT void mixer_initialize();

MIXER_ABI_EXPORT void mixer_shutdown();


typedef struct engine_handle_t engine_handle_t;

MIXER_ABI_EXPORT engine_handle_t *mixer_engine_create();

MIXER_ABI_EXPORT void mixer_engine_destroy(engine_handle_t *handle);


typedef struct {
    char *name;
    bool has_separate_inputs_and_outputs;

    size_t input_device_count;
    char **input_devices;

    size_t output_device_count;
    char **output_devices;
} mixer_audio_host_type_t;

typedef struct {
    char *input_device;
    char *output_device;
    double sample_rate;
    int32_t buffer_size;

    size_t available_sample_rate_count;
    double *available_sample_rates;

    size_t available_buffer_size_count;
    int32_t *available_buffer_sizes;
} mixer_audio_host_setup_t;

MIXER_ABI_EXPORT void mixer_audio_host_setup_free(mixer_audio_host_setup_t *ref);

typedef struct {
    char *current_type;
    size_t available_type_count;
    mixer_audio_host_type_t *available_types;
    mixer_audio_host_setup_t current_setup;
} mixer_audio_host_overview_t;

MIXER_ABI_EXPORT void mixer_audio_host_overview_free(mixer_audio_host_overview_t *ref);


MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_get_overview(
    engine_handle_t *handle,
    mixer_audio_host_overview_t **out,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_reset(
    engine_handle_t *handle,
    int32_t numInputChannelsNeeded,
    int32_t numOutputChannelsNeeded,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_switch_host_to(
    engine_handle_t *handle,
    char *name,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_apply_input_device(
    engine_handle_t *handle,
    char *name,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_apply_output_device(
    engine_handle_t *handle,
    char *name,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_apply_quality_configuration(
    engine_handle_t *handle,
    double sampleRate,
    int bufferSize,
    mixer_audio_host_setup_t **outSetup,
    mixer_error_t *outError
);

#ifdef __cplusplus
}
#endif
