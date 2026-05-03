#pragma once

#include <string>

#include "mixer_engine/mixer_engine_abi.h"

#define ABI_TRY try {
#define ABI_CATCH } catch (const std::exception &exception) { \
    return asError(MIXER_ERROR, exception.what(), outError);        \
} catch (...) {                                               \
    return asError(MIXER_ERROR, "Unknown Error", outError);         \
}

char *copyString(const std::string &source);

char *copyString(const char *source);

char *copyString(const char *source, size_t size);

mixer_call_result asError(mixer_call_result result, const char *message, mixer_error *outError);

mixer_call_result asErrorInvalidHandle(mixer_error *outError);
