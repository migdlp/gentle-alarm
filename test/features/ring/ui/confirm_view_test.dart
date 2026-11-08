import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/ring/ui/confirm_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('«Sí, buenos días» llama a confirmAwake', (tester) async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gentle_alarm/ring'), (
          c,
        ) async {
          calls.add(c.method);
          return null;
        });
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ConfirmView()),
        ),
      ),
    );
    expect(find.text('¿Ya estás despierto/a?'), findsOneWidget);
    await tester.tap(find.text('Sí, buenos días'));
    expect(calls, ['confirmAwake']);
  });
}
