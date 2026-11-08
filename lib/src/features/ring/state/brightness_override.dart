import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Si no es null, `RingRoot` usa este brillo en lugar del calculado
/// (p. ej. 0,3 mientras la hoja de «Ya estoy despierto/a» está abierta).
class BrightnessOverride extends Notifier<double?> {
  @override
  double? build() => null;

  void set(double? value) => state = value;
}

final brightnessOverrideProvider =
    NotifierProvider<BrightnessOverride, double?>(BrightnessOverride.new);
