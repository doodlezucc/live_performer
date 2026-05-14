import 'package:flutter/material.dart';
import 'package:live_performer/app/ui/core/config_dialog/config_dialog.dart';

import 'audio_setup_view.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigDialog(title: 'Audio Setup', child: const AudioSetupView());
  }
}
