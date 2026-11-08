import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';

/// Sol que se arrastra hacia arriba; al soltarlo ≥ [threshold] dp llama a [onDismiss].
class SwipeSun extends StatefulWidget {
  const SwipeSun({super.key, required this.onDismiss, this.threshold = 160});

  final VoidCallback onDismiss;
  final double threshold;

  @override
  State<SwipeSun> createState() => _SwipeSunState();
}

class _SwipeSunState extends State<SwipeSun> with TickerProviderStateMixin {
  double _dy = 0;
  bool _dragging = false;
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Animation<double>? _backAnim;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _back.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails d) {
    _back.stop();
    setState(() {
      _dragging = true;
      _dy = (_dy - d.delta.dy).clamp(0.0, 400.0);
    });
  }

  void _onEnd(DragEndDetails _) {
    _dragging = false;
    if (_dy >= widget.threshold) {
      widget.onDismiss();
      return;
    }
    final from = _dy;
    _backAnim = Tween<double>(begin: from, end: 0).animate(
      CurvedAnimation(parent: _back, curve: Curves.easeOutBack),
    )..addListener(() => setState(() => _dy = _backAnim!.value.clamp(0, 400)));
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textOpacity = (1 - _dy / widget.threshold).clamp(0.0, 1.0);
    final scale = Tween<double>(begin: 1.0, end: 1.06).animate(_breath);
    return Semantics(
      label: l10n.stopAlarmA11y,
      button: true,
      onTap: widget.onDismiss,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.stopAlarmA11y): widget.onDismiss,
      },
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              key: const ValueKey('sun'),
              onVerticalDragUpdate: _onUpdate,
              onVerticalDragEnd: _onEnd,
              child: Transform.translate(
                offset: Offset(0, -_dy),
                child: ScaleTransition(
                  scale: scale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Palette.honey, Palette.coral],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66FF7A3D),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      size: 48,
                      color: Palette.inkOnLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: _dragging || _dy > 0 ? textOpacity : 1,
              child: Text(
                l10n.swipeUpToStop,
                style: const TextStyle(color: Palette.inkOnLight, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
