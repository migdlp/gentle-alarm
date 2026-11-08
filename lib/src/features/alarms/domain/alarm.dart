import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const Object _unset = Object();

class AlarmDefaults {
  const AlarmDefaults({
    this.sunriseMinutes = 20,
    this.rampMinutes = 3,
    this.maxVolumePercent = 70,
    this.vibrate = true,
    this.soundId = 'birds_dawn',
  });

  final int sunriseMinutes;
  final int rampMinutes;
  final int maxVolumePercent;
  final bool vibrate;
  final String soundId;

  @override
  bool operator ==(Object other) =>
      other is AlarmDefaults &&
      other.sunriseMinutes == sunriseMinutes &&
      other.rampMinutes == rampMinutes &&
      other.maxVolumePercent == maxVolumePercent &&
      other.vibrate == vibrate &&
      other.soundId == soundId;

  @override
  int get hashCode => Object.hash(
    sunriseMinutes,
    rampMinutes,
    maxVolumePercent,
    vibrate,
    soundId,
  );
}

@immutable
class Alarm {
  Alarm({
    required this.id,
    this.enabled = true,
    this.hour = 7,
    this.minute = 30,
    List<int> weekdays = const [],
    this.label = '',
    this.soundId = 'birds_dawn',
    this.customSoundUri,
    this.customSoundName,
    this.sunriseMinutes = 20,
    this.rampMinutes = 3,
    this.maxVolumePercent = 70,
    this.vibrate = true,
    this.skipRingAtEpochMs,
    this.scheduledRingAtEpochMs,
    required this.createdAtEpochMs,
  }) : weekdays = List.unmodifiable(weekdays);

  factory Alarm.create({
    required int hour,
    required int minute,
    required AlarmDefaults defaults,
  }) => Alarm(
    id: const Uuid().v4(),
    hour: hour,
    minute: minute,
    soundId: defaults.soundId,
    sunriseMinutes: defaults.sunriseMinutes,
    rampMinutes: defaults.rampMinutes,
    maxVolumePercent: defaults.maxVolumePercent,
    vibrate: defaults.vibrate,
    createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
  );

  factory Alarm.fromMap(Map<dynamic, dynamic> m) => Alarm(
    id: m['id'] as String,
    enabled: m['enabled'] as bool? ?? true,
    hour: m['hour'] as int? ?? 7,
    minute: m['minute'] as int? ?? 30,
    weekdays: ((m['weekdays'] as List?) ?? const []).cast<int>(),
    label: m['label'] as String? ?? '',
    soundId: m['soundId'] as String? ?? 'birds_dawn',
    customSoundUri: m['customSoundUri'] as String?,
    customSoundName: m['customSoundName'] as String?,
    sunriseMinutes: m['sunriseMinutes'] as int? ?? 20,
    rampMinutes: m['rampMinutes'] as int? ?? 3,
    maxVolumePercent: m['maxVolumePercent'] as int? ?? 70,
    vibrate: m['vibrate'] as bool? ?? true,
    skipRingAtEpochMs: m['skipRingAtEpochMs'] as int?,
    scheduledRingAtEpochMs: m['scheduledRingAtEpochMs'] as int?,
    createdAtEpochMs: m['createdAtEpochMs'] as int? ?? 0,
  );

  final String id;
  final bool enabled;
  final int hour;
  final int minute;
  final List<int> weekdays;
  final String label;
  final String soundId;
  final String? customSoundUri;
  final String? customSoundName;
  final int sunriseMinutes;
  final int rampMinutes;
  final int maxVolumePercent;
  final bool vibrate;
  final int? skipRingAtEpochMs;
  final int? scheduledRingAtEpochMs;
  final int createdAtEpochMs;

  DateTime? get nextRingAt => scheduledRingAtEpochMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(scheduledRingAtEpochMs!);
  bool get isRepeating => weekdays.isNotEmpty;
  bool get skipsNext => skipRingAtEpochMs != null;

  Alarm copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    List<int>? weekdays,
    String? label,
    String? soundId,
    Object? customSoundUri = _unset,
    Object? customSoundName = _unset,
    int? sunriseMinutes,
    int? rampMinutes,
    int? maxVolumePercent,
    bool? vibrate,
    Object? skipRingAtEpochMs = _unset,
    Object? scheduledRingAtEpochMs = _unset,
  }) => Alarm(
    id: id,
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekdays: weekdays ?? this.weekdays,
    label: label ?? this.label,
    soundId: soundId ?? this.soundId,
    customSoundUri: identical(customSoundUri, _unset)
        ? this.customSoundUri
        : customSoundUri as String?,
    customSoundName: identical(customSoundName, _unset)
        ? this.customSoundName
        : customSoundName as String?,
    sunriseMinutes: sunriseMinutes ?? this.sunriseMinutes,
    rampMinutes: rampMinutes ?? this.rampMinutes,
    maxVolumePercent: maxVolumePercent ?? this.maxVolumePercent,
    vibrate: vibrate ?? this.vibrate,
    skipRingAtEpochMs: identical(skipRingAtEpochMs, _unset)
        ? this.skipRingAtEpochMs
        : skipRingAtEpochMs as int?,
    scheduledRingAtEpochMs: identical(scheduledRingAtEpochMs, _unset)
        ? this.scheduledRingAtEpochMs
        : scheduledRingAtEpochMs as int?,
    createdAtEpochMs: createdAtEpochMs,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
    'weekdays': weekdays,
    'label': label,
    'soundId': soundId,
    'customSoundUri': customSoundUri,
    'customSoundName': customSoundName,
    'sunriseMinutes': sunriseMinutes,
    'rampMinutes': rampMinutes,
    'maxVolumePercent': maxVolumePercent,
    'vibrate': vibrate,
    'skipRingAtEpochMs': skipRingAtEpochMs,
    'scheduledRingAtEpochMs': scheduledRingAtEpochMs,
    'createdAtEpochMs': createdAtEpochMs,
  };

  @override
  bool operator ==(Object other) =>
      other is Alarm &&
      other.id == id &&
      other.enabled == enabled &&
      other.hour == hour &&
      other.minute == minute &&
      listEquals(other.weekdays, weekdays) &&
      other.label == label &&
      other.soundId == soundId &&
      other.customSoundUri == customSoundUri &&
      other.customSoundName == customSoundName &&
      other.sunriseMinutes == sunriseMinutes &&
      other.rampMinutes == rampMinutes &&
      other.maxVolumePercent == maxVolumePercent &&
      other.vibrate == vibrate &&
      other.skipRingAtEpochMs == skipRingAtEpochMs &&
      other.scheduledRingAtEpochMs == scheduledRingAtEpochMs &&
      other.createdAtEpochMs == createdAtEpochMs;

  @override
  int get hashCode => Object.hash(
    id,
    enabled,
    hour,
    minute,
    Object.hashAll(weekdays),
    label,
    soundId,
    customSoundUri,
    customSoundName,
    sunriseMinutes,
    rampMinutes,
    maxVolumePercent,
    vibrate,
    skipRingAtEpochMs,
    scheduledRingAtEpochMs,
    createdAtEpochMs,
  );
}
