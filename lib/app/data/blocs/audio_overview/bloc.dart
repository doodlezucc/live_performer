import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';

import 'state.dart';

class AudioOverviewBloc extends Cubit<AudioOverviewState> {
  final AudioIORepository _repository;

  AudioOverviewBloc({required AudioIORepository repository})
    : _repository = repository,
      super(AudioOverviewInitial());

  void rescan() async {
    emit(AudioOverviewLoadInProgress());
    try {
      final overview = await _repository.getOverview();
      emit(AudioOverviewLoadSuccess(overview: overview));
    } catch (error) {
      emit(AudioOverviewLoadFailure(error: error));
    }
  }
}
