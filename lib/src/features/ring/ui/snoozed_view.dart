import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';
import 'package:gentle_alarm/src/core/time/clock.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';

class SnoozedView extends ConsumerStatefulWidget {
  const SnoozedView({super.key, required this.session});

  final RingSession session;

  @override
  ConsumerState<SnoozedView> createState() => _SnoozedViewState();
}

class _SnoozedViewState extends ConsumerState<SnoozedView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _mmss() {
    final until = widget.session.snoozeUntilEpochMs ?? 0;
    final left = until - ref.read(clockProvider)().millisecondsSinceEpoch;
    final secs = (left <= 0 ? 0 : (left / 1000).ceil());
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Palette.peach,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.snoozeBackIn(_mmss()),
              style: const TextStyle(
                color: Palette.inkOnLight,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Palette.inkOnLight,
                minimumSize: const Size(64, 56),
              ),
              onPressed: ref.read(ringChannelProvider).wakeUp,
              child: Text(l10n.iGetUp, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
