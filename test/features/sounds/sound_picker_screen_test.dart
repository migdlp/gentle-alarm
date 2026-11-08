import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/sounds/ui/sound_picker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  Object? pickResult;
  SoundChoice? result;
  var popped = false;

  setUp(() {
    calls.clear();
    pickResult = null;
    result = null;
    popped = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gentle_alarm/system'), (
          c,
        ) async {
          calls.add(c);
          return c.method == 'pickAudio' ? pickResult : null;
        });
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (c) => TextButton(
              onPressed: () async {
                result = await Navigator.of(c).push<SoundChoice>(
                  MaterialPageRoute(
                    builder: (_) =>
                        const SoundPickerScreen(selectedId: 'birds_dawn'),
                  ),
                );
                popped = true;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('elegir Campanillas devuelve chimes', (tester) async {
    await open(tester);
    await tester.tap(find.text('Campanillas'));
    await tester.pumpAndSettle();
    expect(result, const SoundChoice('chimes'));
  });

  testWidgets('play y stop llaman al canal', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Escuchar Campanillas'));
    await tester.pump();
    expect(calls.last.method, 'previewSound');
    expect((calls.last.arguments as Map)['soundId'], 'chimes');
    await tester.tap(find.byTooltip('Parar'));
    await tester.pump();
    expect(calls.last.method, 'stopPreviewSound');
  });

  testWidgets('elegir de mi móvil devuelve custom', (tester) async {
    pickResult = {'uri': 'content://a', 'name': 'a.mp3'};
    await open(tester);
    await tester.tap(find.text('Elegir de mi móvil'));
    await tester.pumpAndSettle();
    expect(result, const SoundChoice('custom', 'content://a', 'a.mp3'));
  });

  testWidgets('cancelar no cambia la selección', (tester) async {
    await open(tester);
    await tester.tap(find.text('Elegir de mi móvil'));
    await tester.pumpAndSettle();
    expect(popped, isFalse);
    expect(find.text('Elige un sonido'), findsOneWidget);
  });
}
