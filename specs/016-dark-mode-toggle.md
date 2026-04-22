# [016] Toggle modo oscuro en Configuración

## Objetivo
Agregar un switch en SettingsPage que permita al usuario cambiar entre modo claro y oscuro. La preferencia debe persistir entre sesiones.

## Archivos a crear/modificar

### CREAR
- `lib/core/providers/theme_provider.dart` — Riverpod notifier que maneja `ThemeMode`

### MODIFICAR
- `pubspec.yaml` — agregar `shared_preferences: ^2.3.3`
- `lib/main.dart` — consumir `themeModeProvider` en `MaterialApp.router`
- `lib/features/settings/presentation/pages/settings_page.dart` — agregar `SwitchListTile`

## Implementación detallada

### 1. pubspec.yaml
Agregar bajo la sección `# Utils`:
```yaml
  shared_preferences: ^2.3.3
```

### 2. lib/core/providers/theme_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.light;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, next == ThemeMode.dark ? 'dark' : 'light');
    state = AsyncData(next);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
```

### 3. lib/main.dart
En `POSIApp.build`, agregar el watch al provider y pasarlo a `MaterialApp.router`:

```dart
// Agregar import al inicio del archivo:
import 'core/providers/theme_provider.dart';

// Dentro de POSIApp.build, después de las líneas existentes de ref.watch:
final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.light;

// En MaterialApp.router, agregar el parámetro themeMode:
return MaterialApp.router(
  title: 'POSI - Punto de Venta e Inventario',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: themeMode,   // <-- agregar esta línea
  routerConfig: router,
);
```

### 4. lib/features/settings/presentation/pages/settings_page.dart
Agregar import:
```dart
import '../../../../core/providers/theme_provider.dart';
```

Agregar este bloque en el `ListView`, entre el Divider de "Cambiar contraseña" y el de "Cerrar sesión":
```dart
const Divider(),
Consumer(
  builder: (context, ref, _) {
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.light;
    final isDark = themeMode == ThemeMode.dark;
    return SwitchListTile(
      secondary: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: AppColors.primary,
      ),
      title: const Text('Modo oscuro'),
      value: isDark,
      onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
    );
  },
),
```

## Restricciones
- No cambiar la lógica de autenticación ni de sincronización
- No agregar más dependencias además de shared_preferences
- El switch debe quedar entre "Cambiar contraseña" y "Cerrar sesión"
- Usar `Consumer` localizado en el tile, no convertir toda la página

## Definición de hecho
- [ ] `flutter pub get` sin errores
- [ ] `flutter analyze` sin errores
- [ ] El switch aparece en Configuración entre "Cambiar contraseña" y "Cerrar sesión"
- [ ] Al activar, la app cambia a modo oscuro inmediatamente
- [ ] Al reiniciar la app, recuerda la preferencia
