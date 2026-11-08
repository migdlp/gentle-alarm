import 'package:flutter/material.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
  });

  final Alarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final days = formatDays(l10n, alarm.weekdays, locale);
    final subtitle = alarm.label.isEmpty ? days : '$days · ${alarm.label}';
    final time = formatTime(context, alarm.hour, alarm.minute);
    return Opacity(
      opacity: alarm.enabled ? 1 : 0.5,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(subtitle),
                      ],
                    ),
                  ),
                  Semantics(
                    label: '$time ${l10n.defaultLabel}',
                    child: Switch(value: alarm.enabled, onChanged: onToggle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
