import 'package:live_performer/mixer_engine/mixer_engine.dart';

final class Preferences {
  final AudioIOSetup? audioSetup;

  Preferences({required this.audioSetup});

  Preferences copyWith({required AudioIOSetup? Function()? audioSetup}) =>
      .new(audioSetup: audioSetup != null ? audioSetup() : this.audioSetup);

  Preferences.fromJson(Map<String, dynamic> json)
    : this(
        audioSetup: json['audioSetup'] != null
            ? AudioIOSetupJson.fromJson(json['audioSetup'])
            : null,
      );

  Map<String, dynamic> toJson() => {'audioSetup': audioSetup?.toJson()};
}

extension AudioIOSetupJson on AudioIOSetup {
  static AudioIOSetup fromJson(Map<String, dynamic> json) => (
    ioType: json['ioType'],
    inputDevice: json['inputDevice'],
    outputDevice: json['outputDevice'],
    bufferSize: json['bufferSize'],
    sampleRate: json['sampleRate'],
  );

  Map<String, dynamic> toJson() => {
    'ioType': ioType,
    'inputDevice': inputDevice,
    'outputDevice': outputDevice,
    'bufferSize': bufferSize,
    'sampleRate': sampleRate,
  };
}

sealed class PreferencesState {}

final class PreferencesInitial extends PreferencesState {}

final class PreferencesReady extends PreferencesState {
  final bool isNewlyCreated;
  final Preferences preferences;

  PreferencesReady({required this.isNewlyCreated, required this.preferences});
}
