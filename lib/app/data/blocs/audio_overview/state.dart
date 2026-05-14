import 'package:live_performer/mixer_engine/mixer_engine.dart';

sealed class AudioOverviewState {}

final class AudioOverviewInitial extends AudioOverviewState {}

final class AudioOverviewLoadInProgress extends AudioOverviewState {}

final class AudioOverviewLoadSuccess extends AudioOverviewState {
  final AudioIOOverview overview;

  AudioOverviewLoadSuccess({required this.overview});
}

final class AudioOverviewLoadFailure extends AudioOverviewState {
  final Object error;

  AudioOverviewLoadFailure({required this.error});
}
