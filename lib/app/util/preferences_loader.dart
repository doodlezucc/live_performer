import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/app_state.dart';
import 'package:live_performer/app/data/blocs/audio_setup.dart';
import 'package:live_performer/app/data/blocs/preferences.dart';

class PreferencesLoader extends StatefulWidget {
  final Widget child;

  const PreferencesLoader({required this.child, super.key});

  @override
  State<PreferencesLoader> createState() => _PreferencesLoaderState();
}

class _PreferencesLoaderState extends State<PreferencesLoader> {
  void _applyPreferences(Preferences preferences) {
    getIt<AudioSetupBloc>().initialize(preferredSetup: preferences.audioSetup);
  }

  @override
  void initState() {
    super.initState();

    final preferencesState = getIt<PreferencesBloc>().state;
    if (preferencesState is PreferencesReady) {
      _applyPreferences(preferencesState.preferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PreferencesBloc, PreferencesState>(
      bloc: getIt(),
      listenWhen: (previous, current) =>
          previous is PreferencesInitial && current is PreferencesReady,
      listener: (context, state) {
        _applyPreferences((state as PreferencesReady).preferences);
      },
      child: widget.child,
    );
  }
}
