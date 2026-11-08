import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/greeting/domain/weather.dart';
import 'package:gentle_alarm/src/features/greeting/state/weather_providers.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  Timer? _debounce;
  String _query = '';
  bool _loading = false;
  List<City> _results = const [];
  int _seq = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _query = value.trim();
      if (_query.length < 2) {
        _loading = false;
        _results = const [];
      }
    });
    if (_query.length < 2) return;
    final lang = Localizations.localeOf(context).languageCode;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final seq = ++_seq;
      setState(() => _loading = true);
      final r = await ref
          .read(weatherRepositoryProvider)
          .searchCities(_query, lang);
      if (!mounted || seq != _seq) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    });
  }

  Future<void> _choose(City? city) async {
    await ref.read(cityProvider.notifier).choose(city);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasCity = ref.watch(cityProvider) != null;
    final Widget body;
    if (_query.length < 2) {
      body = _Message(l10n.citySearchStart);
    } else if (_loading) {
      body = const LinearProgressIndicator();
    } else if (_results.isEmpty) {
      body = _Message(l10n.citySearchEmpty);
    } else {
      body = ListView(
        children: [
          for (final c in _results)
            ListTile(
              title: Text(c.name),
              subtitle: Text(
                [if (c.admin1 != null) c.admin1!, c.country].join(', '),
              ),
              onTap: () => _choose(c),
            ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.citySearchHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
        actions: [
          if (hasCity)
            TextButton(
              onPressed: () => _choose(null),
              child: Text(l10n.cityRemove),
            ),
        ],
      ),
      body: body,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(24), child: Text(text)),
  );
}
