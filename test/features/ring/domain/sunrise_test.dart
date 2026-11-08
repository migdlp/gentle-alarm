import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/domain/sunrise.dart';

RingSession session(
  RingState state, {
  bool ramp = false,
  bool preview = false,
  int since = 0,
}) => RingSession(
  alarmId: 'a',
  label: '',
  ringAtEpochMs: 1000,
  sunriseStartEpochMs: 0,
  state: state,
  stateSinceEpochMs: since,
  snoozesLeft: 3,
  autoSnoozeUsed: false,
  isPreview: preview,
  soundFallback: false,
  brightnessRampFromSnooze: ramp,
);

DateTime at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

void main() {
  test('colores clave', () {
    expect(sunriseFrame(0).top, const Color(0xFF05060F));
    expect(sunriseFrame(0).bottom, const Color(0xFF0B1026));
    expect(sunriseFrame(0.25).top, const Color(0xFF1A1033));
    expect(sunriseFrame(0.5).bottom, const Color(0xFFC2452D));
    expect(sunriseFrame(0.75).top, const Color(0xFFFF7A3D));
    expect(sunriseFrame(1).bottom, const Color(0xFFFFF4E0));
  });

  test('p=0,125 está a medio camino entre los dos primeros', () {
    final f = sunriseFrame(0.125);
    final expected = (0x05 + 0x1A) / 2;
    expect((f.top.r * 255 - expected).abs(), lessThanOrEqualTo(1));
  });

  test('p fuera de rango se limita', () {
    expect(sunriseFrame(-1).top, sunriseFrame(0).top);
    expect(sunriseFrame(5).bottom, sunriseFrame(1).bottom);
  });

  test('brillo en el amanecer', () {
    final s = session(RingState.sunrise);
    expect(targetBrightness(s, at(0)), closeTo(0.01, 1e-9));
    expect(targetBrightness(s, at(500)), closeTo(0.2575, 1e-9));
    expect(targetBrightness(s, at(1000)), closeTo(1.0, 1e-9));
    expect(targetBrightness(s, at(5000)), closeTo(1.0, 1e-9));
  });

  test('brillo por estado', () {
    expect(targetBrightness(session(RingState.ringing), at(10)), 1.0);
    expect(targetBrightness(session(RingState.snoozed), at(10)), 0.15);
    expect(targetBrightness(session(RingState.confirming), at(10)), 1.0);
    expect(targetBrightness(session(RingState.greeting), at(10)), 1.0);
    final r = session(RingState.ringing, ramp: true, since: 0);
    expect(targetBrightness(r, at(0)), closeTo(0.15, 1e-9));
    expect(targetBrightness(r, at(30000)), closeTo(0.575, 1e-9));
    expect(targetBrightness(r, at(60000)), closeTo(1.0, 1e-9));
    final p = session(RingState.ringing, ramp: true, preview: true);
    expect(targetBrightness(p, at(5000)), closeTo(1.0, 1e-9));
  });

  test('duración cero = progreso 1', () {
    const s = RingSession(
      alarmId: 'a',
      label: '',
      ringAtEpochMs: 5,
      sunriseStartEpochMs: 5,
      state: RingState.sunrise,
      stateSinceEpochMs: 0,
      snoozesLeft: 3,
      autoSnoozeUsed: false,
      isPreview: false,
      soundFallback: false,
      brightnessRampFromSnooze: false,
    );
    expect(sunriseProgress(s, at(0)), 1);
  });
}
