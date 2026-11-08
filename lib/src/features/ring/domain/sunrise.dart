import 'dart:ui';

import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';

class SunriseFrame {
  const SunriseFrame(this.top, this.bottom);

  final Color top;
  final Color bottom;
}

const _keys = <(double, Color, Color)>[
  (0.00, Color(0xFF05060F), Color(0xFF0B1026)),
  (0.25, Color(0xFF1A1033), Color(0xFF3A0F1E)),
  (0.50, Color(0xFF5A1E3A), Color(0xFFC2452D)),
  (0.75, Color(0xFFFF7A3D), Color(0xFFFFC872)),
  (1.00, Color(0xFFFFE3B8), Color(0xFFFFF4E0)),
];

/// Colores del gradiente para un progreso p ∈ [0, 1] (se limita fuera de rango).
SunriseFrame sunriseFrame(double p) {
  final c = p.clamp(0.0, 1.0);
  for (var i = 1; i < _keys.length; i++) {
    if (c <= _keys[i].$1) {
      final a = _keys[i - 1];
      final b = _keys[i];
      final t = (c - a.$1) / (b.$1 - a.$1);
      return SunriseFrame(
        Color.lerp(a.$2, b.$2, t)!,
        Color.lerp(a.$3, b.$3, t)!,
      );
    }
  }
  return SunriseFrame(_keys.last.$2, _keys.last.$3);
}

/// Progreso del amanecer; 1 si la duración es cero.
double sunriseProgress(RingSession s, DateTime now) {
  final total = s.ringAtEpochMs - s.sunriseStartEpochMs;
  if (total <= 0) return 1;
  return ((now.millisecondsSinceEpoch - s.sunriseStartEpochMs) / total).clamp(
    0.0,
    1.0,
  );
}

/// Brillo de la ventana (0,01-1,0) para cada estado.
double targetBrightness(RingSession s, DateTime now) {
  switch (s.state) {
    case RingState.sunrise:
      final p = sunriseProgress(s, now);
      return 0.01 + 0.99 * p * p;
    case RingState.ringing:
      if (s.brightnessRampFromSnooze) {
        final ramp = s.isPreview ? 5000 : 60000;
        final t = ((now.millisecondsSinceEpoch - s.stateSinceEpochMs) / ramp)
            .clamp(0.0, 1.0);
        return 0.15 + 0.85 * t;
      }
      return 1.0;
    case RingState.snoozed:
      return 0.15;
    case RingState.confirming:
    case RingState.greeting:
    case RingState.ended:
      return 1.0;
  }
}
