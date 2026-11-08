import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/platform/system_channel.dart';
import 'package:gentle_alarm/src/features/sounds/domain/sound_catalog.dart';

class SoundChoice {
  const SoundChoice(this.id, [this.uri, this.name]);

  final String id;
  final String? uri;
  final String? name;

  @override
  bool operator ==(Object other) =>
      other is SoundChoice &&
      other.id == id &&
      other.uri == uri &&
      other.name == name;

  @override
  int get hashCode => Object.hash(id, uri, name);
}

class SoundPickerScreen extends ConsumerStatefulWidget {
  const SoundPickerScreen({
    super.key,
    required this.selectedId,
    this.customUri,
    this.customName,
    this.allowCustom = true,
  });

  final String selectedId;
  final String? customUri;
  final String? customName;
  final bool allowCustom;

  @override
  ConsumerState<SoundPickerScreen> createState() => _SoundPickerScreenState();
}

class _SoundPickerScreenState extends ConsumerState<SoundPickerScreen> {
  String? _playing;
  late final SystemChannel _system;

  @override
  void initState() {
    super.initState();
    _system = ref.read(systemChannelProvider);
  }

  @override
  void dispose() {
    _system.stopPreviewSound();
    super.dispose();
  }

  Future<void> _togglePlay(String id, {String? uri}) async {
    if (_playing == id) {
      setState(() => _playing = null);
      await _system.stopPreviewSound();
    } else {
      setState(() => _playing = id);
      await _system.previewSound(id, uri: uri);
    }
  }

  Future<void> _pickFromPhone() async {
    final picked = await _system.pickAudio();
    if (picked == null || !mounted) return;
    Navigator.of(context).pop(SoundChoice('custom', picked.uri, picked.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasCustom = widget.selectedId == 'custom' && widget.customUri != null;
    Widget play(String id, String name, {String? uri}) => IconButton(
      tooltip: _playing == id
          ? l10n.stopPreviewA11y
          : l10n.playPreviewA11y(name),
      icon: Icon(_playing == id ? Icons.stop : Icons.play_arrow),
      onPressed: () => _togglePlay(id, uri: uri),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.soundPickerTitle)),
      body: RadioGroup<String>(
        groupValue: widget.selectedId,
        onChanged: (id) {
          if (id == 'custom') {
            Navigator.of(
              context,
            ).pop(SoundChoice('custom', widget.customUri, widget.customName));
          } else if (id != null) {
            Navigator.of(context).pop(SoundChoice(id));
          }
        },
        child: ListView(
          children: [
            for (final id in SoundCatalog.builtInIds)
              RadioListTile<String>(
                value: id,
                title: Text(SoundCatalog.label(l10n, id, null)),
                secondary: play(id, SoundCatalog.label(l10n, id, null)),
              ),
            if (hasCustom)
              RadioListTile<String>(
                value: 'custom',
                title: Text(
                  SoundCatalog.label(l10n, 'custom', widget.customName),
                ),
                secondary: play(
                  'custom',
                  widget.customName ?? '',
                  uri: widget.customUri,
                ),
              ),
            if (widget.allowCustom)
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(l10n.pickFromPhone),
                onTap: _pickFromPhone,
              ),
          ],
        ),
      ),
    );
  }
}
