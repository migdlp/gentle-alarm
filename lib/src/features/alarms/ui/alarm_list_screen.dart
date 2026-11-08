import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';
import 'package:gentle_alarm/src/core/time/format.dart';
import 'package:gentle_alarm/src/features/alarms/domain/alarm.dart';
import 'package:gentle_alarm/src/features/alarms/state/alarms_providers.dart';
import 'package:gentle_alarm/src/features/alarms/ui/alarm_editor_screen.dart';
import 'package:gentle_alarm/src/features/alarms/ui/widgets/alarm_tile.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(alarmsProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _create() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const AlarmEditorScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alarms = ref.watch(alarmsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alarmsTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: alarms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? _EmptyState(onCreate: _create)
            : _AlarmList(alarms: list),
      ),
      floatingActionButton: alarms.value?.isNotEmpty ?? false
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: Text(l10n.createAlarm),
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wb_twilight, size: 96, color: Palette.coral),
            const SizedBox(height: 16),
            Text(
              l10n.emptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.emptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onCreate, child: Text(l10n.createAlarm)),
          ],
        ),
      ),
    );
  }
}

class _AlarmList extends ConsumerWidget {
  const _AlarmList({required this.alarms});

  final List<Alarm> alarms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = ref.watch(clockProvider)();
    final locale = Localizations.localeOf(context).toString();
    final upcoming =
        alarms
            .where((a) => a.enabled && a.nextRingAt != null)
            .map((a) => a.nextRingAt!)
            .toList()
          ..sort();
    final String header;
    if (upcoming.isEmpty) {
      header = l10n.noActiveAlarms;
    } else {
      final next = upcoming.first;
      final time = formatTime(context, next.hour, next.minute);
      header = l10n.nextAlarm(
        formatWhen(l10n, next, now, time, locale),
        formatInDuration(l10n, next.difference(now)),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(header, style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final a in alarms)
          AlarmTile(
            key: ValueKey(a.id),
            alarm: a,
            onToggle: (v) => ref.read(alarmsProvider.notifier).toggle(a.id, v),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AlarmEditorScreen(initial: a),
              ),
            ),
          ),
      ],
    );
  }
}
