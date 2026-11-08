import 'package:flutter/material.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:intl/intl.dart';

/// «en 2 h 5 min», «en 45 min» o «en menos de 1 min» (minutos hacia arriba).
String formatInDuration(AppLocalizations l10n, Duration d) {
  if (d.inSeconds < 60) return l10n.inLessThanMinute;
  final minutes = (d.inSeconds + 59) ~/ 60;
  if (minutes < 60) return l10n.inMinutes(minutes);
  return l10n.inHoursMinutes(minutes ~/ 60, minutes % 60);
}

/// «hoy a las …», «mañana a las …» o «el lunes a las …».
String formatWhen(
  AppLocalizations l10n,
  DateTime ringAt,
  DateTime now,
  String time,
  String localeName,
) {
  final days = DateTime(
    ringAt.year,
    ringAt.month,
    ringAt.day,
  ).difference(DateTime(now.year, now.month, now.day)).inDays;
  if (days <= 0) return l10n.todayAt(time);
  if (days == 1) return l10n.tomorrowAt(time);
  return l10n.weekdayAt(DateFormat.EEEE(localeName).format(ringAt), time);
}

String formatDays(
  AppLocalizations l10n,
  List<int> weekdays,
  String localeName,
) {
  final d = [...weekdays]..sort();
  if (d.isEmpty) return l10n.onceOnly;
  if (d.length == 7) return l10n.everyDay;
  if (d.join() == '12345') return l10n.weekdaysOnly;
  if (d.join() == '67') return l10n.weekendsOnly;
  final fmt = DateFormat.E(localeName);
  // 2024-01-01 fue lunes: el día ISO n cae en 2024-01-n.
  return d.map((n) => fmt.format(DateTime(2024, 1, n))).join(', ');
}

String formatTime(BuildContext context, int hour, int minute) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: hour, minute: minute),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
