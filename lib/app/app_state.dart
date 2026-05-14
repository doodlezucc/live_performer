import 'package:get_it/get_it.dart';
import 'package:live_performer/app/data/blocs/audio_overview/bloc.dart';
import 'package:live_performer/app/data/blocs/audio_setup/bloc.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';

final getIt = GetIt.instance;

void registerAppState() {
  getIt.registerLazySingleton(() => AudioIORepository(engine: getIt()));
  getIt.registerLazySingleton(
    () => AudioSetupBloc(repository: getIt())..initialize(),
  );
  getIt.registerLazySingleton(
    () => AudioOverviewBloc(repository: getIt())..rescan(),
  );
}
