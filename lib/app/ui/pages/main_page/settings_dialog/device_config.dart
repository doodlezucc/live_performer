import 'package:flutter/material.dart';

class DeviceConfig extends StatelessWidget {
  final Widget deviceDropdown;
  final List<String>? channelNames;

  const DeviceConfig({
    required this.deviceDropdown,
    required this.channelNames,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        deviceDropdown,
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 120),
          child: ListView(
            shrinkWrap: true,
            children:
                channelNames?.indexed.map((channel) {
                  return Text('${channel.$1 + 1} - "${channel.$2}"');
                }).toList() ??
                [],
          ),
        ),
      ],
    );
  }
}
