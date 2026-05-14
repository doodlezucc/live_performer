import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/app_state.dart';
import 'package:live_performer/app/data/blocs/audio_setup/bloc.dart';
import 'package:live_performer/app/data/blocs/audio_setup/state.dart';
import 'package:live_performer/app/data/repositories/audio_io_repository.dart';
import 'package:live_performer/app/ui/core/dropdown/dropdown.dart';
import 'package:live_performer/app/ui/core/dropdown/option.dart';
import 'package:live_performer/app/ui/core/dropdown/optional_dropdown.dart';
import 'package:live_performer/app/ui/pages/main_page/settings_dialog/device_config.dart';
import 'package:live_performer/mixer_engine/mixer_engine_structs.g.dart';

class AudioSetupView extends StatefulWidget {
  const AudioSetupView({super.key});

  @override
  State<AudioSetupView> createState() => _AudioSetupViewState();
}

class _AudioSetupViewState extends State<AudioSetupView> {
  late AudioIOOverview _latestOverview;

  @override
  void initState() {
    super.initState();

    _latestOverview = getIt<AudioIORepository>().getOverview();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioSetupBloc, AudioSetupState>(
      bloc: getIt(),
      builder: (context, state) => switch (state) {
        AudioSetupInitial() => Text('Loading audio setup...'),

        AudioSetupLoadFailure(error: final error) => Text(
          'Failed to load active audio setup.\n$error',
        ),

        AudioSetupLoadSuccess() => LoadedAudioSetupView(
          overview: _latestOverview,
          effective: state.setupInfo,
        ),
      },
    );
  }
}

class LoadedAudioSetupView extends StatefulWidget {
  const LoadedAudioSetupView({
    super.key,
    required this.overview,
    required this.effective,
  });

  final AudioIOOverview overview;
  final AudioIOSetupInfo effective;

  @override
  State<LoadedAudioSetupView> createState() => _LoadedAudioSetupViewState();
}

class _LoadedAudioSetupViewState extends State<LoadedAudioSetupView> {
  AudioIOSetup get effectiveSetup => widget.effective.setup;

  late String _selectedIOTypeName = effectiveSetup.ioType;
  late String? _selectedInputDevice = effectiveSetup.inputDevice;
  late String _selectedOutputDevice = effectiveSetup.outputDevice;
  late int _selectedBufferSize = effectiveSetup.bufferSize;
  late double _selectedSampleRate = effectiveSetup.sampleRate;

  AudioIOSetup get selectedSetup => (
    ioType: _selectedIOTypeName,
    inputDevice: _selectedInputDevice ?? '',
    outputDevice: _selectedOutputDevice,
    bufferSize: _selectedBufferSize,
    sampleRate: _selectedSampleRate,
  );

  late AudioIOCombinationCapabilities? _selectedCapabilities =
      widget.effective.capabilities;

  bool get isDifferentFromEffectiveSetup => effectiveSetup != selectedSetup;

  AudioIOType get selectedIOType => widget.overview.availableIOTypes.firstWhere(
    (type) => type.name == _selectedIOTypeName,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Dropdown<String>(
            label: 'Audio IO Type',
            value: _selectedIOTypeName,

            options: widget.overview.availableIOTypes.map((type) {
              return DropdownOption(value: type.name, label: type.name);
            }).toList(),

            onSelected: (typeName) {
              setState(() {
                _selectedIOTypeName = typeName;
                _selectedInputDevice = selectedIOType.inputDevices.firstOrNull;
                _selectedOutputDevice = selectedIOType.outputDevices.first;
              });

              _reloadCapabilities();
            },
          ),
          if (!selectedIOType.hasSeparateInputsAndOutputs)
            Text(
              "This IO type doesn't support using a separate input and output device.",
            ),
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: DeviceConfig(
                  deviceDropdown: OptionalDropdown<String>(
                    expand: true,
                    label: 'Input Device',
                    value: _selectedInputDevice,

                    options: selectedIOType.inputDevices.map((deviceName) {
                      return DropdownOption(
                        value: deviceName,
                        label: deviceName,
                      );
                    }).toList(),

                    onSelected: (inputDevice) {
                      setState(() => _selectedInputDevice = inputDevice);
                      _reloadCapabilities();
                    },
                  ),
                  channelNames: _selectedCapabilities?.inputChannelNames,
                ),
              ),
              Flexible(
                child: DeviceConfig(
                  deviceDropdown: Dropdown<String>(
                    expand: true,
                    label: 'Output Device',
                    value: _selectedOutputDevice,

                    options: selectedIOType.outputDevices.map((deviceName) {
                      return DropdownOption(
                        value: deviceName,
                        label: deviceName,
                      );
                    }).toList(),

                    onSelected: (outputDevice) {
                      setState(() => _selectedOutputDevice = outputDevice);
                      _reloadCapabilities();
                    },
                  ),
                  channelNames: _selectedCapabilities?.outputChannelNames,
                ),
              ),
            ],
          ),
          if (_selectedCapabilities != null)
            Row(
              mainAxisAlignment: .center,
              spacing: 8,
              children: [
                Dropdown<int>(
                  label: 'Buffer Size',
                  value: _selectedBufferSize,

                  options: _selectedCapabilities!.availableBufferSizes
                      .map(
                        (bufferSize) => DropdownOption(
                          value: bufferSize,
                          label: '$bufferSize',
                        ),
                      )
                      .toList(),

                  onSelected: (bufferSize) {
                    setState(() => _selectedBufferSize = bufferSize);
                  },
                ),
                Dropdown<double>(
                  label: 'Sample Rate',
                  value: _selectedSampleRate,

                  options: _selectedCapabilities!.availableSampleRates
                      .map(
                        (sampleRate) => DropdownOption(
                          value: sampleRate,
                          label: '$sampleRate',
                        ),
                      )
                      .toList(),

                  onSelected: (sampleRate) {
                    setState(() => _selectedSampleRate = sampleRate);
                  },
                ),
              ],
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 32,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Effective setup: ${widget.effective.setup}',
                  style: TextTheme.of(context).bodySmall,
                ),
              ),
              FilledButton(
                onPressed: isDifferentFromEffectiveSetup
                    ? _applySelectedSetup
                    : null,
                child: Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reloadCapabilities() {
    final selectedCapabilities = getIt<AudioIORepository>().queryCapabilities(
      ioType: _selectedIOTypeName,
      inputDevice: _selectedInputDevice ?? '',
      outputDevice: _selectedOutputDevice,
    );

    setState(() {
      _selectedCapabilities = selectedCapabilities;

      final bufferSizes = selectedCapabilities.availableBufferSizes;
      final sampleRates = selectedCapabilities.availableSampleRates;

      if (!bufferSizes.contains(_selectedBufferSize)) {
        _selectedBufferSize = selectedCapabilities.defaultBufferSize;
      }

      if (!sampleRates.contains(_selectedSampleRate)) {
        if (sampleRates.contains(41_000.0)) {
          _selectedSampleRate = 41_000.0;
        } else if (sampleRates.contains(48_000.0)) {
          _selectedSampleRate = 48_000.0;
        } else if (sampleRates.isNotEmpty) {
          _selectedSampleRate = sampleRates.first;
        } else {
          // TODO: This should be reflected in the UI.
          throw StateError('Capabilities returned empty list of sample rates');
        }
      }
    });
  }

  void _applySelectedSetup() {
    if (_selectedCapabilities == null) {
      throw StateError("Can't apply setup rn");
    }

    getIt<AudioSetupBloc>().applySetup(selectedSetup);

    setState(() {
      // Selected setup and effective setup may now be the same, in which
      // case the widget should redraw.
    });
  }
}
