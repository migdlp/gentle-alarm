import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/core/time/clock.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/domain/sunrise.dart';
import 'package:gentle_alarm/src/features/ring/state/brightness_override.dart';
import 'package:gentle_alarm/src/features/ring/state/ring_controller.dart';
import 'package:gentle_alarm/src/features/ring/ui/confirm_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/ringing_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/snoozed_view.dart';
import 'package:gentle_alarm/src/features/ring/ui/sunrise_view.dart';

class RingRoot extends ConsumerStatefulWidget {
  const RingRoot({super.key});

  @override
  ConsumerState<RingRoot> createState() => _RingRootState();
}

class _RingRootState extends ConsumerState<RingRoot> {
  RingState? _lastLive;
  late DateTime _now;
  Timer? _timer;
  double _lastBrightness = -1;

  @override
  void initState() {
    super.initState();
    _now = ref.read(clockProvider)();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _now = ref.read(clockProvider)();
      _syncBrightness();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncBrightness() {
    final session = ref.read(ringControllerProvider).value;
    if (session == null) return;
    final target =
        ref.read(brightnessOverrideProvider) ?? targetBrightness(session, _now);
    if ((target - _lastBrightness).abs() > 0.005) {
      _lastBrightness = target;
      ref.read(ringChannelProvider).setBrightness(target);
    }
  }

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
        _syncBrightness();
      }
    });
    final session = ref.watch(ringControllerProvider).value;
    final Widget body;
    if (session == null) {
      body = const SizedBox.shrink();
    } else if (session.state == RingState.sunrise) {
      body = SunriseView(session: session, now: _now);
    } else if (session.state == RingState.ringing) {
      body = RingingView(session: session, now: _now);
    } else if (session.state == RingState.confirming) {
      body = const ConfirmView();
    } else if (session.state == RingState.snoozed) {
      body = SnoozedView(session: session);
    } else {
      body = Center(
        child: Text(
          session.state.name,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: KeyedSubtree(key: ValueKey(session?.state), child: body),
        ),
      ),
    );
  }
}
