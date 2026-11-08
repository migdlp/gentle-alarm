import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/ring_channel.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';
import 'package:gentle_alarm/src/core/time/clock.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/features/greeting/domain/phrase_picker.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather_text.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';
import 'package:gentle_alarm/src/features/ring/domain/sunrise.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';

class GreetingView extends ConsumerStatefulWidget {
  const GreetingView({super.key, Random? random}) : _random = random;

  final Random? _random;

  @override
  ConsumerState<GreetingView> createState() => _GreetingViewState();
}

class _GreetingViewState extends ConsumerState<GreetingView> {
  late final int _phrase;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    final last = prefs.getInt('greeting.lastIndex') ?? -1;
    _phrase = pickPhraseIndex(widget._random ?? Random(), last);
    prefs.setInt('greeting.lastIndex', _phrase);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = ref.read(clockProvider)();
    final weather = ref.read(weatherRepositoryProvider).cachedFresh();
    final condition = weather == null
        ? null
        : weatherConditionText(l10n, weather.weatherCode);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.greetingTitle,
                style: ink.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              Text(
                formatTime(context, now.hour, now.minute),
                style: ink.copyWith(fontSize: 72, fontWeight: FontWeight.w600),
              ),
              if (weather != null && condition != null)
                Text(
                  l10n.weatherLine(
                    '${weather.temperatureC.round()}',
                    condition,
                    weather.cityName,
                  ),
                  style: ink.copyWith(fontSize: 18),
                ),
              const SizedBox(height: 24),
              Opacity(
                opacity: 0.85,
                child: Text(
                  greetingPhrase(l10n, _phrase),
                  textAlign: TextAlign.center,
                  style: ink.copyWith(fontSize: 20),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.accent,
                    foregroundColor: Palette.cream,
                  ),
                  onPressed: ref.read(ringChannelProvider).finishGreeting,
                  child: Text(l10n.startDay),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
