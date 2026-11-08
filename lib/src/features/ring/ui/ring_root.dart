import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/state/ring_controller.dart';

class RingRoot extends ConsumerStatefulWidget {
  const RingRoot({super.key});

  @override
  ConsumerState<RingRoot> createState() => _RingRootState();
}

class _RingRootState extends ConsumerState<RingRoot> {
  RingState? _lastLive;

  void _close() {
    if (_lastLive == RingState.greeting) {
      ref.read(ringChannelProvider).finishGreeting();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(ringControllerProvider, (prev, next) {
      final s = next.value;
      if (next is AsyncData<RingSession?> &&
          (s == null || s.state == RingState.ended)) {
        _close();
      } else if (s != null) {
        _lastLive = s.state;
      }
    });
    final session = ref.watch(ringControllerProvider).value;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            session?.state.name ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
