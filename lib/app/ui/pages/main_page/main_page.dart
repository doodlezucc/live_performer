import 'package:flutter/material.dart';

import 'graph_canvas/graph_canvas_view.dart';
import 'settings_dialog/settings_dialog.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Performer'),
        leading: IconButton(
          onPressed: () => _openSettings(context),
          icon: Icon(Icons.settings),
        ),
      ),
      body: const GraphCanvasView(),
    );
  }

  void _openSettings(BuildContext context) {
    showDialog(context: context, builder: (_) => SettingsDialog());
  }
}
