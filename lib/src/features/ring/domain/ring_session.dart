import 'package:flutter/foundation.dart';

enum RingState { sunrise, ringing, confirming, snoozed, greeting, ended }

@immutable
class RingSession {
  const RingSession({
    required this.alarmId,
    required this.label,
    required this.ringAtEpochMs,
    required this.sunriseStartEpochMs,
    required this.state,
    required this.stateSinceEpochMs,
    required this.snoozesLeft,
    required this.autoSnoozeUsed,
    this.snoozeUntilEpochMs,
    this.segmentStartEpochMs,
    this.endReason,
    required this.isPreview,
    required this.soundFallback,
    required this.brightnessRampFromSnooze,
  });

  factory RingSession.fromMap(Map<dynamic, dynamic> m) => RingSession(
    alarmId: m['alarmId'] as String,
    label: m['label'] as String? ?? '',
    ringAtEpochMs: m['ringAtEpochMs'] as int,
    sunriseStartEpochMs: m['sunriseStartEpochMs'] as int,
    state: RingState.values.firstWhere(
      (s) => s.name == m['state'],
      orElse: () => RingState.ended,
    ),
    stateSinceEpochMs: m['stateSinceEpochMs'] as int,
    snoozesLeft: m['snoozesLeft'] as int,
    autoSnoozeUsed: m['autoSnoozeUsed'] as bool? ?? false,
    snoozeUntilEpochMs: m['snoozeUntilEpochMs'] as int?,
    segmentStartEpochMs: m['segmentStartEpochMs'] as int?,
    endReason: m['endReason'] as String?,
    isPreview: m['isPreview'] as bool? ?? false,
    soundFallback: m['soundFallback'] as bool? ?? false,
    brightnessRampFromSnooze: m['brightnessRampFromSnooze'] as bool? ?? false,
  );

  final String alarmId;
  final String label;
  final int ringAtEpochMs;
  final int sunriseStartEpochMs;
  final RingState state;
  final int stateSinceEpochMs;
  final int snoozesLeft;
  final bool autoSnoozeUsed;
  final int? snoozeUntilEpochMs;
  final int? segmentStartEpochMs;
  final String? endReason;
  final bool isPreview;
  final bool soundFallback;
  final bool brightnessRampFromSnooze;

  DateTime get ringAt => DateTime.fromMillisecondsSinceEpoch(ringAtEpochMs);

  @override
  bool operator ==(Object other) =>
      other is RingSession &&
      other.alarmId == alarmId &&
      other.label == label &&
      other.ringAtEpochMs == ringAtEpochMs &&
      other.sunriseStartEpochMs == sunriseStartEpochMs &&
      other.state == state &&
      other.stateSinceEpochMs == stateSinceEpochMs &&
      other.snoozesLeft == snoozesLeft &&
      other.autoSnoozeUsed == autoSnoozeUsed &&
      other.snoozeUntilEpochMs == snoozeUntilEpochMs &&
      other.segmentStartEpochMs == segmentStartEpochMs &&
      other.endReason == endReason &&
      other.isPreview == isPreview &&
      other.soundFallback == soundFallback &&
      other.brightnessRampFromSnooze == brightnessRampFromSnooze;

  @override
  int get hashCode => Object.hash(
    alarmId,
    ringAtEpochMs,
    state,
    stateSinceEpochMs,
    snoozesLeft,
    autoSnoozeUsed,
    snoozeUntilEpochMs,
    segmentStartEpochMs,
    endReason,
    isPreview,
    soundFallback,
    brightnessRampFromSnooze,
  );
}
