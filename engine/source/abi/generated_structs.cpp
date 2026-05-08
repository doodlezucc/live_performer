#include "mixer_engine/mixer_engine_abi.h"
#include "util.h"

void internal_free_AudioHostType(mixer_AudioHostType_t& ref) {
  freeString(ref.name);
  freeStringArray(ref.inputDevices, ref.inputDevices_count);
  freeStringArray(ref.outputDevices, ref.outputDevices_count);
}

void mixer_free_AudioHostType(mixer_AudioHostType_t* ref) {
  if (ref == nullptr) return;
  internal_free_AudioHostType(*ref);
  delete ref;
}

void internal_free_AudioHostOverview(mixer_AudioHostOverview_t& ref) {
  freeArray(ref.availableTypes, ref.availableTypes_count, internal_free_AudioHostType);
}

void mixer_free_AudioHostOverview(mixer_AudioHostOverview_t* ref) {
  if (ref == nullptr) return;
  internal_free_AudioHostOverview(*ref);
  delete ref;
}
