import 'package:flutter/material.dart';

/// Contenido que ocupa al menos la altura disponible (permite `Spacer`) y
/// se desplaza si, por ejemplo con el texto al 200 %, no cabe.
class ScrollBody extends StatelessWidget {
  const ScrollBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
