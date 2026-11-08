# gentle_alarm

Despertador amable para Android hecho en Flutter: amanecer en la pantalla, sonido que sube poco a poco y un saludo tranquilo. Es gratuito, sin cuentas ni anuncios, en español e inglés.

## Requisitos
- Flutter estable **3.47.9** (Dart 3.13.7)
- JDK 17 o superior
- Android SDK 35 (y 36 para compilar los plugins)

## Comandos
```bash
flutter pub get
flutter gen-l10n
flutter run
flutter test
(cd android && ./gradlew testDebugUnitTest)
```

Plan completo: [`docs/plan/gentle-alarm/README.md`](docs/plan/gentle-alarm/README.md).
