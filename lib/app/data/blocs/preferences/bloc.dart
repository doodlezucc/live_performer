import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/repositories/file_repository.dart';

import 'state.dart';

class PreferencesBloc extends Cubit<PreferencesState> {
  static const _fileName = 'preferences.json';

  final FileRepository _fileRepository;

  PreferencesBloc({required FileRepository fileRepository})
    : _fileRepository = fileRepository,
      super(PreferencesInitial());

  void load() async {
    final preferencesJsonString = await _fileRepository.readFromFile(_fileName);

    if (preferencesJsonString != null) {
      emit(
        PreferencesReady(
          isNewlyCreated: false,
          preferences: Preferences.fromJson(jsonDecode(preferencesJsonString)),
        ),
      );
    } else {
      emit(
        PreferencesReady(
          isNewlyCreated: true,
          preferences: Preferences(audioSetup: null),
        ),
      );
    }
  }

  void update(Preferences Function(Preferences preferences) modify) {
    if (state is! PreferencesReady) {
      throw StateError("Can't update preferences before initialized");
    }

    final newPreferences = modify((state as PreferencesReady).preferences);
    emit(PreferencesReady(isNewlyCreated: false, preferences: newPreferences));

    save();
  }

  void save() async {
    if (state is! PreferencesReady) {
      throw StateError("Can't write preferences before initialized");
    }

    final preferencesJson = (state as PreferencesReady).preferences.toJson();
    await _fileRepository.writeToFile(_fileName, jsonEncode(preferencesJson));
  }
}
