import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/app.dart';

void main() {
  for (final (code, text) in [
    ('en', 'Gentle Alarm'),
    ('es', 'Despertar suave'),
  ]) {
    testWidgets('muestra $text en $code', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: GentleAlarmApp(locale: Locale(code))),
      );
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget);
    });
  }
}
