import 'package:flutter/material.dart';

class DeviceConfig extends StatelessWidget {
  final String dropdownLabel;
  final String? selectedDeviceName;
  final void Function(String deviceName) onSelectDevice;
  final List<String> availableDeviceNames;
  final List<String> channelNames;

  const DeviceConfig({
    required this.dropdownLabel,
    required this.selectedDeviceName,
    required this.onSelectDevice,
    required this.availableDeviceNames,
    required this.channelNames,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownMenu<String>(
            width: constraints.maxWidth,
            menuStyle: MenuStyle(visualDensity: VisualDensity.compact),
            expandedInsets: EdgeInsets.zero,
            label: Text(dropdownLabel),
            selectOnly: true,
            initialSelection: selectedDeviceName,

            dropdownMenuEntries: availableDeviceNames.map((deviceName) {
              return DropdownMenuEntry(value: deviceName, label: deviceName);
            }).toList(),

            onSelected: (deviceName) => onSelectDevice(deviceName!),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 120),
            child: ListView(
              shrinkWrap: true,
              children: channelNames.indexed
                  .map((channel) => Text('${channel.$1 + 1} - "${channel.$2}"'))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
