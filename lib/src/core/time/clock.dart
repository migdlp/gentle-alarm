import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reloj inyectable: las vistas no llaman a `DateTime.now()` directamente.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
