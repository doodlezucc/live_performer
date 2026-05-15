import 'package:flutter/material.dart';
import 'package:live_performer/app/util/preferences_loader.dart';

import 'app/data/app_state.dart';
import 'app/ui/pages/main_page/main_page.dart';
import 'app/ui/theme/theme.dart';
import 'app/util/mixer_engine_lifecycle_widget.dart';

void main() {
  registerAppState();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MixerEngineLifecycleWidget(
      child: PreferencesLoader(
        child: MaterialApp(theme: AppTheme.theme, home: MainPage()),
      ),
    );
  }
}
