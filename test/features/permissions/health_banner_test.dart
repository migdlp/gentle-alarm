import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/l10n/gen/app_localizations.dart';
import 'package:gentle_alarm/src/features/permissions/domain/permission_status.dart';
import 'package:gentle_alarm/src/features/permissions/state/permission_providers.dart';
import 'package:gentle_alarm/src/features/permissions/ui/health_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gentle_alarm/system'), (
          c,
        ) async {
          calls.add(c.method);
          return c.method == 'requestNotificationPermission' ? false : null;
        });
  });

  Future<void> pump(WidgetTester tester, PermissionStatus s) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [permissionStatusProvider.overrideWith((ref) async => s)],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: Column(children: [HealthBanner()])),
          ),
        ),
      );

  PermissionStatus st({bool n = true, bool e = true, bool f = true}) =>
      PermissionStatus(notifications: n, exactAlarms: e, fullScreen: f);

  testWidgets('sin faltas no hay banner', (tester) async {
    await pump(tester, st());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('falta pantalla completa: Arreglarlo abre sus ajustes', (
    tester,
  ) async {
    await pump(tester, st(f: false));
    await tester.pumpAndSettle();
    expect(
      find.text('Falta la pantalla completa para el amanecer.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Arreglarlo'));
    await tester.pumpAndSettle();
    expect(calls, contains('openFullScreenSettings'));
  });

  testWidgets('muestra primero el aviso de notificaciones', (tester) async {
    await pump(tester, st(n: false, f: false));
    await tester.pumpAndSettle();
    expect(find.text('Faltan los avisos de alarma.'), findsOneWidget);
    expect(find.textContaining('pantalla completa'), findsNothing);
    await tester.tap(find.text('Arreglarlo'));
    await tester.pumpAndSettle();
    expect(
      calls,
      containsAllInOrder([
        'requestNotificationPermission',
        'openNotificationSettings',
      ]),
    );
  });
}
