import 'package:get_it/get_it.dart';
import 'package:live_performer/app/data/blocs/audio_overview.dart';
import 'package:live_performer/app/data/blocs/audio_setup.dart';
import 'package:live_performer/app/data/blocs/preferences.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';
import 'package:live_performer/app/data/repositories/file_repository.dart';

final getIt = GetIt.instance;

void registerAppState() {
  _registerFileSystem();
  _registerEngine();
}

void _registerFileSystem() {
  getIt.registerSingleton(FileRepository());
  getIt.registerSingleton(PreferencesBloc(fileRepository: getIt())..load());
}

void _registerEngine() {
  getIt.registerLazySingleton(() => AudioIORepository(engine: getIt()));
  getIt.registerLazySingleton(
    () => AudioSetupBloc(repository: getIt())..initialize(),
  );
  getIt.registerLazySingleton(
    () => AudioOverviewBloc(repository: getIt())..rescan(),
  );
}
