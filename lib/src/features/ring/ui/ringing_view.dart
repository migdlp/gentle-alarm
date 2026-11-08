import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/core/widgets/scroll_body.dart';
import 'package:gentle_alarm/src/features/ring/domain/ring_session.dart';
import 'package:gentle_alarm/src/features/ring/domain/sunrise.dart';
import 'package:gentle_alarm/src/features/ring/ui/widgets/swipe_sun.dart';

class RingingView extends ConsumerWidget {
  const RingingView({super.key, required this.session, required this.now});

  final RingSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final channel = ref.read(ringChannelProvider);
    final frame = sunriseFrame(1);
    const ink = TextStyle(color: Palette.inkOnLight);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [frame.top, frame.bottom],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ScrollBody(
            child: Column(
              children: [
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatTime(context, now.hour, now.minute),
                    style: ink.copyWith(
                      fontSize: 96,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  session.label.isEmpty ? l10n.defaultLabel : session.label,
                  style: ink.copyWith(fontSize: 24),
                ),
                const Spacer(),
                SwipeSun(onDismiss: channel.dismissSwipe),
                const SizedBox(height: 32),
                if (session.snoozesLeft > 0)
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Palette.inkOnLight,
                        side: const BorderSide(color: Palette.inkOnLight),
                      ),
                      onPressed: channel.snooze,
                      child: Text.rich(
                        TextSpan(
                          text: l10n.snoozeButton,
                          children: [
                            TextSpan(
                              text:
                                  '\n${l10n.snoozesLeftText(session.snoozesLeft)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 64,
                    child: Center(child: Text(l10n.noMoreSnoozes, style: ink)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
