#pragma once

#include <juce_core/juce_core.h>
#include <string>

#include "mixer_engine/mixer_engine_abi.h"

#define ABI_TRY try {
#define ABI_CATCH } catch (const std::exception &exception) { \
    return asError(MIXER_ERROR, exception.what(), outError);        \
} catch (...) {                                               \
    return asError(MIXER_ERROR, "Unknown Error", outError);         \
}


inline char *copyString(const char *source, const size_t size) {
    if (source == nullptr) throw std::invalid_argument{"Source string is null"};

    const auto destination = static_cast<char *>(std::malloc(size));
    if (destination == nullptr) throw std::bad_alloc{};

    std::memcpy(destination, source, size);

    return destination;
}

inline char *copyString(const juce::String &source) {
    return copyString(source.toRawUTF8(), source.getCharPointer().sizeInBytes());
}

inline char *copyString(const std::string &source) {
    return copyString(source.c_str(), source.size() + 1);
}

inline char *copyString(const char *source) {
    if (source == nullptr) throw std::invalid_argument{"Source string is null"};

    return copyString(source, std::strlen(source) + 1);
}

inline char **copyStringArray(const juce::StringArray &source) {
    const auto count = source.size();
    auto *destination = new char *[count];

    for (size_t i = 0; i < count; i++) {
        destination[i] = copyString(source.getReference(i));
    }

    return destination;
}


template<typename T>
T *copyArray(const juce::Array<T> &source) {
    const auto count = source.size();

    auto *destination = new T[static_cast<size_t>(count)];
    std::memcpy(destination, source.getRawDataPointer(), sizeof(T) * static_cast<size_t>(count));
    return destination;
}

template<typename T, typename S>
T *copyArrayAs(const juce::Array<S> &source) {
    const auto count = source.size();

    auto *destination = new T[static_cast<size_t>(count)];
    for (size_t i = 0; i < count; i++) {
        destination[i] = static_cast<T>(source.getUnchecked(i));
    }

    return destination;
}

template<typename T, std::invocable<T &> TForEach>
void freeArray(T *array, const size_t count, TForEach freeItem) {
    for (size_t i = 0; i < count; i++) {
        freeItem(array[i]);
    }
    delete[] array;
}

template<typename T>
void freeArray(T *array) {
    delete[] array;
}

inline void freeString(char *string) {
    std::free(string);
}

inline void freeStringArray(char **stringArray, const size_t count) {
    freeArray(stringArray, count, freeString);
}

inline mixer_call_result_t asError(const mixer_call_result_t result, const char *message, mixer_error_t *outError) {
    if (outError != nullptr) {
        *outError = copyString(message);
    }
    return result;
}

// ReSharper disable once CppDFAConstantFunctionResult
inline mixer_call_result_t asErrorInvalidHandle(mixer_error_t *outError) {
    return asError(MIXER_ERROR_INVALID_HANDLE, "Invalid handle", outError);
}
