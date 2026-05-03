#include "util.h"

#include <cstring>

char *copyString(const std::string &source) {
    return copyString(source.c_str(), source.size() + 1);
}

char *copyString(const char *source) {
    return copyString(source, std::strlen(source) + 1);
}

char *copyString(const char *source, const size_t size) {
    if (source == nullptr) {
        return nullptr;
    }

    const auto destination = static_cast<char *>(std::malloc(size));
    std::memcpy(destination, source, size);

    return destination;
}


mixer_call_result asError(const mixer_call_result result, const char *message, mixer_error *outError) {
    if (outError != nullptr) {
        *outError = copyString(message);
    }
    return result;
}

// ReSharper disable once CppDFAConstantFunctionResult
mixer_call_result asErrorInvalidHandle(mixer_error *outError) {
    return asError(MIXER_ERROR_INVALID_HANDLE, "Invalid handle", outError);
}
