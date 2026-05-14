import 'package:flutter/material.dart';

import 'app/app_state.dart';
import 'app/mixer_engine_lifecycle_widget.dart';
import 'app/ui/pages/main_page/main_page.dart';

void main() {
  registerAppState();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MixerEngineLifecycleWidget(child: MaterialApp(home: MainPage()));
  }
}
