import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';

/// Emite primero la sesión actual y después cada cambio; `null` = no hay sesión.
final ringControllerProvider = StreamProvider<RingSession?>((ref) async* {
  final ch = ref.watch(ringChannelProvider);
  yield await ch.getSession();
  yield* ch.events();
});
