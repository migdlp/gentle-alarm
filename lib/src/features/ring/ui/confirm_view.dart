import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';
import 'package:gentle_alarm/src/features/ring/domain/sunrise.dart';

class ConfirmView extends ConsumerWidget {
  const ConfirmView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final frame = sunriseFrame(1);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.confirmQuestion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Palette.inkOnLight,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: 0.7,
                child: Text(
                  l10n.confirmHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.inkOnLight,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 72,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.accent,
                    foregroundColor: Palette.cream,
                  ),
                  onPressed: ref.read(ringChannelProvider).confirmAwake,
                  child: Text(
                    l10n.confirmYes,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
