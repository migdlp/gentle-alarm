import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/domain/sunrise.dart';
import 'package:gentle_alarm/src/features/ring/state/brightness_override.dart';

class SunriseView extends ConsumerWidget {
  const SunriseView({super.key, required this.session, required this.now});

  final RingSession session;
  final DateTime now;

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final channel = ref.read(ringChannelProvider);
    final ringsAt = formatTime(
      context,
      session.ringAt.hour,
      session.ringAt.minute,
    );
    ref.read(brightnessOverrideProvider.notifier).set(0.3);
    channel.setBrightness(0.3);
    await showModalBottomSheet<void>(
      context: context,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.sunriseRingsAt(ringsAt),
                style: Theme.of(c).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(c).pop();
                    channel.wakeEarly();
                  },
                  child: Text(l10n.wakeEarly),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: Text(l10n.keepSleeping),
              ),
            ],
          ),
        ),
      ),
    );
    ref.read(brightnessOverrideProvider.notifier).set(null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frame = sunriseFrame(sunriseProgress(session, now));
    final time = formatTime(context, now.hour, now.minute);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openSheet(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [frame.top, frame.bottom],
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w600,
                color: Color(0x1AFFFFFF),
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
