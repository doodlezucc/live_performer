import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';

import 'state.dart';

class AudioSetupBloc extends Cubit<AudioSetupState> {
  final AudioIORepository _repository;

  AudioSetupBloc({required AudioIORepository repository})
    : _repository = repository,
      super(AudioSetupInitial());

  void initialize() {
    resetToDefault(numInputChannelsNeeded: 2, numOutputChannelsNeeded: 2);
  }

  void resetToDefault({
    required int numInputChannelsNeeded,
    required int numOutputChannelsNeeded,
  }) async {
    try {
      emit(AudioSetupLoadInProgress());
      await _repository.reset(
        numInputChannelsNeeded: numInputChannelsNeeded,
        numOutputChannelsNeeded: numOutputChannelsNeeded,
      );
    } finally {
      _refreshCurrentSetupInfo();
    }
  }

  void applySetup(AudioIOSetup setup) async {
    try {
      emit(AudioSetupLoadInProgress());
      await _repository.applySetup(setup: setup);
    } finally {
      _refreshCurrentSetupInfo();
    }
  }

  void _refreshCurrentSetupInfo() {
    try {
      final setupInfo = _repository.getSetupInfo();

      emit(AudioSetupLoadSuccess(setupInfo: setupInfo));
    } catch (error) {
      emit(AudioSetupLoadFailure(error: error));
    }
  }
}
