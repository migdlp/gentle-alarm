import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

List<Alarm> _sorted(Iterable<Alarm> alarms) => alarms.toList()
  ..sort((a, b) {
    final c = (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
    return c != 0 ? c : a.createdAtEpochMs.compareTo(b.createdAtEpochMs);
  });

class AlarmsNotifier extends AsyncNotifier<List<Alarm>> {
  AlarmRepository get _repo => ref.read(alarmRepositoryProvider);

  @override
  Future<List<Alarm>> build() => ref.read(alarmRepositoryProvider).list();

  Future<void> refresh() async {
    state = AsyncData(await _repo.list());
  }

  void _replace(Alarm a) {
    final current = state.value ?? const <Alarm>[];
    state = AsyncData(_sorted([...current.where((x) => x.id != a.id), a]));
  }

  Future<void> toggle(String id, bool enabled) async =>
      _replace(await _repo.setEnabled(id, enabled));

  Future<Alarm> save(Alarm alarm) async {
    final saved = await _repo.save(alarm);
    _replace(saved);
    return saved;
  }

  Future<void> skipNext(String id, bool skip) async =>
      _replace(await _repo.setSkipNext(id, skip));

  final Map<String, Alarm> _hidden = {};

  /// Quita la alarma de la lista visible sin borrarla (estado optimista).
  void hideTemporarily(String id) {
    final current = state.value ?? const <Alarm>[];
    final found = current.where((a) => a.id == id);
    if (found.isEmpty) return;
    _hidden[id] = found.first;
    state = AsyncData(current.where((a) => a.id != id).toList());
  }

  void restore(String id) {
    final a = _hidden.remove(id);
    if (a != null) _replace(a);
  }

  Future<void> remove(String id) async {
    _hidden.remove(id);
    await _repo.delete(id);
    state = AsyncData(
      (state.value ?? const <Alarm>[]).where((a) => a.id != id).toList(),
    );
  }
}

final alarmsProvider = AsyncNotifierProvider<AlarmsNotifier, List<Alarm>>(
  AlarmsNotifier.new,
);
