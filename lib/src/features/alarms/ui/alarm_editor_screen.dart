import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/features/alarms/data/alarm_repository.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';
import 'package:gentle_alarm/src/features/alarms/ui/widgets/alarm_options.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:gentle_alarm/src/features/sounds/domain/sound_catalog.dart';
import 'package:intl/intl.dart';

class AlarmEditorScreen extends ConsumerStatefulWidget {
  const AlarmEditorScreen({super.key, this.initial});

  final Alarm? initial;

  @override
  ConsumerState<AlarmEditorScreen> createState() => _AlarmEditorScreenState();
}

class _AlarmEditorScreenState extends ConsumerState<AlarmEditorScreen> {
  late Alarm _initial;
  late Alarm _alarm;
  late final TextEditingController _label;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initial =
        widget.initial ??
        Alarm.create(
          hour: 7,
          minute: 30,
          defaults: ref.read(alarmDefaultsProvider),
        );
    _alarm = _initial;
    _label = TextEditingController(text: _alarm.label);
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  bool get _dirty => _alarm != _initial;

  void _update(Alarm a) => setState(() => _alarm = a);

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _alarm.hour, minute: _alarm.minute),
    );
    if (t != null) _update(_alarm.copyWith(hour: t.hour, minute: t.minute));
  }

  void _toggleDay(int day) {
    final days = {..._alarm.weekdays};
    if (!days.add(day)) days.remove(day);
    _update(_alarm.copyWith(weekdays: days.toList()..sort()));
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(alarmsProvider.notifier)
          .save(_alarm.copyWith(label: _label.text.trim()));
      final next = saved.nextRingAt;
      final now = ref.read(clockProvider)();
      navigator.pop();
      if (next != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.willRingIn(formatInDuration(l10n, next.difference(now))),
            ),
          ),
        );
      }
    } on AlarmException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'SCHEDULE_FAILED'
                ? l10n.errorScheduleFailed
                : l10n.errorGeneric,
          ),
        ),
      );
      setState(() => _saving = false);
    }
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.discardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final narrow = DateFormat.EEEEE(locale);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initial == null ? l10n.newAlarm : l10n.editAlarm),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: _pickTime,
              child: Center(
                child: Text(
                  formatTime(context, _alarm.hour, _alarm.minute),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.repeat, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (var d = 1; d <= 7; d++)
                  FilterChip(
                    key: ValueKey('day$d'),
                    label: Text(narrow.format(DateTime(2024, 1, d))),
                    selected: _alarm.weekdays.contains(d),
                    onSelected: (_) => _toggleDay(d),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _label,
              maxLength: 40,
              decoration: InputDecoration(hintText: l10n.labelHint),
              onChanged: (v) => _update(_alarm.copyWith(label: v)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sound),
              subtitle: Text(
                SoundCatalog.label(
                  l10n,
                  _alarm.soundId,
                  _alarm.customSoundName,
                ),
              ),
            ),
            SunriseSelector(
              value: _alarm.sunriseMinutes,
              onChanged: (v) => _update(_alarm.copyWith(sunriseMinutes: v)),
            ),
            RampSelector(
              value: _alarm.rampMinutes,
              onChanged: (v) => _update(_alarm.copyWith(rampMinutes: v)),
            ),
            VolumeSlider(
              value: _alarm.maxVolumePercent,
              onChanged: (v) => _update(_alarm.copyWith(maxVolumePercent: v)),
            ),
            VibrationSwitch(
              value: _alarm.vibrate,
              onChanged: (v) => _update(_alarm.copyWith(vibrate: v)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
