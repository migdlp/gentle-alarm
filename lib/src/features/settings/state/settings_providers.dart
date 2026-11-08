import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/settings/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Sobrescribir en main.dart'),
);

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

class AlarmDefaultsNotifier extends Notifier<AlarmDefaults> {
  @override
  AlarmDefaults build() => ref.watch(settingsRepositoryProvider).readDefaults();

  Future<void> update(AlarmDefaults d) async {
    state = d;
    await ref.read(settingsRepositoryProvider).saveDefaults(d);
  }
}

final alarmDefaultsProvider =
    NotifierProvider<AlarmDefaultsNotifier, AlarmDefaults>(
      AlarmDefaultsNotifier.new,
    );
