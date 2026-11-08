import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/ui/widgets/alarm_options.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';
import 'package:gentle_alarm/src/features/greeting/ui/city_search_screen.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:gentle_alarm/src/features/sounds/domain/sound_catalog.dart';

const _appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final d = ref.watch(alarmDefaultsProvider);
    final notifier = ref.read(alarmDefaultsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(l10n.forNewAlarms),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.sound),
            subtitle: Text(SoundCatalog.label(l10n, d.soundId, null)),
          ),
          SunriseSelector(
            value: d.sunriseMinutes,
            onChanged: (v) => notifier.update(_copy(d, sunriseMinutes: v)),
          ),
          RampSelector(
            value: d.rampMinutes,
            onChanged: (v) => notifier.update(_copy(d, rampMinutes: v)),
          ),
          VolumeSlider(
            value: d.maxVolumePercent,
            onChanged: (v) => notifier.update(_copy(d, maxVolumePercent: v)),
          ),
          VibrationSwitch(
            value: d.vibrate,
            onChanged: (v) => notifier.update(_copy(d, vibrate: v)),
          ),
          const SizedBox(height: 16),
          _Header(l10n.weatherSection),
          Builder(
            builder: (context) {
              final city = ref.watch(cityProvider);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.weatherCity),
                subtitle: Text(
                  city == null
                      ? l10n.weatherCityNone
                      : '${city.name}, ${city.country}',
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CitySearchScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _Header(l10n.aboutSection),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.aboutVersion(_appVersion)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.weatherAttribution),
          ),
        ],
      ),
    );
  }
}

AlarmDefaults _copy(
  AlarmDefaults d, {
  int? sunriseMinutes,
  int? rampMinutes,
  int? maxVolumePercent,
  bool? vibrate,
}) => d.copyWith(
  sunriseMinutes: sunriseMinutes,
  rampMinutes: rampMinutes,
  maxVolumePercent: maxVolumePercent,
  vibrate: vibrate,
);

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
