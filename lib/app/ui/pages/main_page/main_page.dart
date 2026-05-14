import 'package:flutter/material.dart';
import 'package:live_performer/app/ui/pages/main_page/settings_dialog/settings_dialog.dart';

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
      body: Center(child: Text('content pending :)')),
    );
  }

  void _openSettings(BuildContext context) {
    showDialog(context: context, builder: (_) => SettingsDialog());
  }
}
