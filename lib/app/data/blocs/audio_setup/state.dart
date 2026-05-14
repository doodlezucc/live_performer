import 'package:live_performer/mixer_engine/mixer_engine.dart';

sealed class AudioSetupState {}

final class AudioSetupInitial extends AudioSetupState {}

final class AudioSetupLoadInProgress extends AudioSetupState {}

final class AudioSetupLoadSuccess extends AudioSetupState {
  final AudioIOSetupInfo setupInfo;

  AudioSetupLoadSuccess({required this.setupInfo});
}

final class AudioSetupLoadFailure extends AudioSetupState {
  final Object error;

  AudioSetupLoadFailure({required this.error});
}
