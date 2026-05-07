# Common Structs

## Input

```yaml
structs:
  AudioHostType:
    name: string
    hasSeparateInputsAndOutputs: bool
    inputDevices: string[]
    outputDevices: string[]

  AudioHostOverview:
    availableTypes: AudioHostType[]
```

## Output

### ABI Header

```h
typedef struct {
    char* name;
    bool hasSeparateInputsAndOutputs;

    size_t inputDevices_count;
    char** inputDevices;

    size_t outputDevices_count;
    char** outputDevices;
} AudioHostType_t;
void mixer_free_AudioHostType(AudioHostType_t* ref);

typedef struct {
    size_t availableTypes_count;
    AudioHostType_T* availableTypes;
} AudioHostOverview_t;
void mixer_free_AudioHostOverview(AudioHostOverview_t* ref);

```

### ABI Implementation

```cpp
void internal_free_AudioHostType(AudioHostType_t& ref) {
    freeString(ref.name);
    freeStringArray(ref.inputDevices, ref.inputDevices_count);
    freeStringArray(ref.outputDevices, ref.inputDevices_count);
}

void mixer_free_AudioHostType(AudioHostType_t* ref) {
    if (ref == nullptr) return;
    internal_free_AudioHostType(*ref);
    delete ref;
}

void internal_free_AudioHostOverview(AudioHostOverview_t& ref) {
    freeArray(ref.availableTypes, ref.availableTypes_count, internal_free_AudioHostType);
}

void mixer_free_AudioHostType(AudioHostType_t* ref) {
    if (ref == nullptr) return;
    internal_free_AudioHostType(*ref);
    delete ref;
}
```

### Dart

```dart
typedef AudioHostType = ({
    String name,
    bool hasSeparateInputsAndOutputs,
    List<String> inputDevices,
    List<String> outputDevices,
});

extension AudioHostType_toNative on AudioHostType {
    Pointer<mixer_AudioHostType_t> toNative(Arena arena) {
        final result = arena<mixer_AudioHostType_t>();
        result.ref
            ..name = name.toNative(arena)
            ..hasSeparateInputsAndOutputs = hasSeparateInputsAndOutputs
            ..inputDevices_count = inputDevices.length
            ..inputDevices = inputDevices.toNative((e) => e.toNative(arena))
            ..outputDevices_count = outputDevices.length
            ..outputDevices = outputDevices.toNative((e) => e.toNative(arena));
        return result;
    }
}

extension AudioHostType_toDart on mixer_AudioHostType_t {
    AudioHostType toDart() => (
        name: name.toDartString(),
        hasSeparateInputsAndOutputs: hasSeparateInputsAndOutputs,
        inputDevices: inputDevices.toList(inputDevices_count, (e) => e.toDartString()),
        outputDevices: outputDevices.toList(outputDevices_count, (e) => e.toDartString()),
    );
}

extension AudioHostType_free on Pointer<mixer_AudioHostType_t> {
    void free() => mixer_free_AudioHostType(this);
}


typedef AudioHostOverview = ({
    List<AudioHostType> availableTypes,
});

extension AudioHostOverview_toNative on AudioHostOverview {
    Pointer<mixer_AudioHostOverview_t> toNative(Arena arena) {
        final result = arena<mixer_AudioHostOverview_t>();
        result.ref
            ..availableTypes_count = availableTypes.length
            ..availableTypes = availableTypes.toNative((e) => e.toNative(arena));
        return result;
    }
}

extension AudioHostOverview_toDart on mixer_AudioHostOverview_t {
    AudioHostOverview toDart() => (
        availableTypes: availableTypes.toList(availableTypes_count, (e) => e.ref.toDart()),
    );
}

extension AudioHostOverview_free on Pointer<mixer_AudioHostOverview_t> {
    void free() => mixer_free_AudioHostOverview(this);
}
```
