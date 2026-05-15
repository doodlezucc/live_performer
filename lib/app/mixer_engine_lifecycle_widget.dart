import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/app_state.dart';
import 'package:live_performer/app/data/blocs/audio_setup.dart';
import 'package:live_performer/mixer_engine/mixer_engine.dart';
import 'package:live_performer/mixer_engine/mixer_engine.g.dart';

class MixerEngineLifecycleWidget extends StatefulWidget {
  final Widget child;

  const MixerEngineLifecycleWidget({required this.child, super.key});

  @override
  State<MixerEngineLifecycleWidget> createState() =>
      _MixerEngineLifecycleWidgetState();
}

class _MixerEngineLifecycleWidgetState
    extends State<MixerEngineLifecycleWidget> {
  late final AppLifecycleListener _lifecycleListener;
  late final MixerEngine _engine;

  bool _isEngineDisposed = false;

  @override
  void initState() {
    super.initState();

    _createEngine();

    _lifecycleListener = AppLifecycleListener(
      onExitRequested: () async {
        _disposeEngine();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _disposeEngine();

    super.dispose();
  }

  void _createEngine() {
    mixer_initialize();
    _engine = MixerEngine.create();

    getIt.registerSingleton(_engine);
  }

  void _disposeEngine() {
    if (!_isEngineDisposed) {
      _isEngineDisposed = true;

      _engine.destroy();
      mixer_shutdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector(
      // Only trigger the lazy AudioSetupBloc initialization
      bloc: getIt<AudioSetupBloc>(),
      selector: (state) => null,
      builder: (context, _) => widget.child,
    );
  }
}
