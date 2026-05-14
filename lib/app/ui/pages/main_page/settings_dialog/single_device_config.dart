import 'package:flutter/material.dart';

class SingleDeviceConfig extends StatelessWidget {
  final Widget deviceDropdown;
  final List<String> channelNames;
  final bool isLoadingCapabilities;

  const SingleDeviceConfig({
    required this.deviceDropdown,
    required this.channelNames,
    required this.isLoadingCapabilities,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        deviceDropdown,
        Opacity(
          opacity: isLoadingCapabilities ? 0.5 : 1,
          child: Tooltip(
            message: channelNames.indexed
                .map((entry) => '${entry.$1 + 1}: "${entry.$2}"')
                .join('\n'),
            child: Text(
              channelNames.length == 1
                  ? '1 channel'
                  : '${channelNames.length} channels',
              style: TextTheme.of(context).bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
