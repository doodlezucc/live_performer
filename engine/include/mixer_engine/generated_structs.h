#pragma once

#include "common.h"

typedef struct {
  char* name;
  bool hasSeparateInputsAndOutputs;
  size_t inputDevices_count;
  char** inputDevices;
  size_t outputDevices_count;
  char** outputDevices;
} mixer_AudioHostType_t;

MIXER_ABI_EXPORT void mixer_free_AudioHostType(mixer_AudioHostType_t* ref);

typedef struct {
  size_t availableTypes_count;
  mixer_AudioHostType_t* availableTypes;
} mixer_AudioHostOverview_t;

MIXER_ABI_EXPORT void mixer_free_AudioHostOverview(mixer_AudioHostOverview_t* ref);
