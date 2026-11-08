import 'package:flutter/material.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/settings/data/settings_repository.dart';

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.options,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final List<int> options;
  final int value;
  final String Function(int) label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(label(o)),
                selected: o == value,
                onSelected: (_) => onChanged(o),
              ),
          ],
        ),
      ],
    );
  }
}

class SunriseSelector extends StatelessWidget {
  const SunriseSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _ChoiceRow(
      title: l10n.sunrise,
      options: SettingsRepository.sunriseOptions,
      value: value,
      label: (m) => m == 0 ? l10n.noSunrise : l10n.minutesShort(m),
      onChanged: onChanged,
    );
  }
}

class RampSelector extends StatelessWidget {
  const RampSelector({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _ChoiceRow(
      title: l10n.ramp,
      options: SettingsRepository.rampOptions,
      value: value,
      label: l10n.minutesShort,
      onChanged: onChanged,
    );
  }
}

class VolumeSlider extends StatelessWidget {
  const VolumeSlider({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            '${l10n.maxVolume}: $value %',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 10,
          max: 100,
          divisions: 9,
          label: '$value %',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class VibrationSwitch extends StatelessWidget {
  const VibrationSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(AppLocalizations.of(context)!.vibration),
      value: value,
      onChanged: onChanged,
    );
  }
}
