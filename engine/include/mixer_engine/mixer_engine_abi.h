#pragma once


#ifdef __cplusplus
extern "C" {
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

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_get_overview(
    engine_handle_t *handle,
    mixer_AudioIOOverview_t **out,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_get_setup_info(
    engine_handle_t *handle,
    mixer_AudioIOSetupInfo_t **out,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_query_capabilities(
    engine_handle_t *handle,
    const char *hostType,
    const char *inputDevice,
    const char *outputDevice,
    mixer_AudioIOCombinationCapabilities_t **out,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_reset(
    engine_handle_t *handle,
    int32_t numInputChannelsNeeded,
    int32_t numOutputChannelsNeeded,
    mixer_error_t *outError
);

MIXER_ABI_EXPORT mixer_call_result_t mixer_audio_config_apply(
    engine_handle_t *handle,
    mixer_AudioIOSetup_t *setup,
    mixer_error_t *outError
);

#ifdef __cplusplus
}
#endif
