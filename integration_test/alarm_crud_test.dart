import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/app.dart';
import 'package:gentle_alarm/src/core/platform/alarm_channel.dart';
import 'package:gentle_alarm/src/features/alarms/ui/widgets/alarm_tile.dart';
import 'package:gentle_alarm/src/features/settings/state/settings_providers.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('crear, editar y borrar una alarma', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding.done', true);
    final channel = AlarmChannel();
    // Estado limpio: borra lo que hubiera de ejecuciones anteriores.
    for (final a in await channel.list()) {
      await channel.delete(a['id'] as String);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const GentleAlarmApp(locale: Locale('es')),
      ),
    );
    await tester.pumpAndSettle();

    // Crear: FAB / botón del estado vacío → hora 06:45 con el selector.
    expect(find.text('Aún no tienes alarmas'), findsOneWidget);
    await tester.tap(find.text('Crear alarma'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('7:30'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    // Solo los campos del diálogo: el editor de debajo también tiene un TextField (la etiqueta).
    final dialog = find.byType(Dialog);
    final fields = find.descendant(
      of: dialog,
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), '45');
    final am = find.text('a. m.');
    if (am.evaluate().isNotEmpty) await tester.tap(am);
    // El botón de aceptar es el último del diálogo (su texto depende del idioma).
    await tester.tap(
      find.descendant(of: dialog, matching: find.byType(TextButton)).last,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Guardar'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('6:45'), findsOneWidget);

    // Comprobación nativa: la alarma está programada.
    final saved = await channel.list();
    expect(saved, hasLength(1));
    expect(saved.single['scheduledRingAtEpochMs'], isNotNull);

    // Editar: marcar L.
    await tester.tap(find.byType(AlarmTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('day1')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Guardar'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('lun'), findsWidgets);
    expect((await channel.list()).single['weekdays'], [1]);

    // Borrar: deslizar y esperar a que caduque el «Deshacer».
    await tester.drag(find.byType(AlarmTile), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes alarmas'), findsOneWidget);
    expect(await channel.list(), isEmpty);
  });
}
