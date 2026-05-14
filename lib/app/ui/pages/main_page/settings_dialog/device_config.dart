import 'package:flutter/material.dart';
import 'package:live_performer/app/ui/core/dropdown/option.dart';
import 'package:live_performer/app/ui/core/dropdown/optional_dropdown.dart';

class DeviceConfig extends StatelessWidget {
  final String dropdownLabel;
  final String? selectedDeviceName;
  final void Function(String? deviceName) onSelectDevice;
  final List<String> availableDeviceNames;
  final List<String>? channelNames;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OptionalDropdown<String>(
          expand: true,
          label: dropdownLabel,
          value: selectedDeviceName!,

          options: availableDeviceNames.map((deviceName) {
            return DropdownOption(value: deviceName, label: deviceName);
          }).toList(),

          onSelected: onSelectDevice,
        ),
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
