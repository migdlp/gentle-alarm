import 'package:flutter/material.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:intl/intl.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    this.onSkip,
    this.onDelete,
  });

  final Alarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback? onSkip;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final days = formatDays(l10n, alarm.weekdays, locale);
    var subtitle = alarm.label.isEmpty ? days : '$days · ${alarm.label}';
    if (alarm.skipsNext) {
      final date = DateFormat.MMMEd(
        locale,
      ).format(DateTime.fromMillisecondsSinceEpoch(alarm.skipRingAtEpochMs!));
      subtitle = '$subtitle\n${l10n.skippingOn(date)}';
    }
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
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'skip') onSkip?.call();
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (alarm.isRepeating)
                        PopupMenuItem(
                          value: 'skip',
                          child: Text(
                            alarm.skipsNext ? l10n.unskipNext : l10n.skipNext,
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.deleteAlarm),
                      ),
                    ],
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
