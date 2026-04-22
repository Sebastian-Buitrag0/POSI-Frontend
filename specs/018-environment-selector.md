# [018] Selector de entorno (dev/qa/producción)

## Objetivo
En modo debug, mostrar un selector que permita cambiar el servidor al que apunta la app
entre 3 entornos: Producción, QA y Pruebas. La selección persiste con shared_preferences.
En modo release, siempre usa Producción y no muestra el selector.

## Los 3 entornos
```dart
enum AppEnvironment {
  production,  // https://api.sebas898.site
  qa,          // https://api-qa.sebas898.site
  testing,     // https://api-dev.sebas898.site  (o localhost)
}
```
(Las URLs exactas son placeholders — el usuario las definirá luego)

## Archivos a CREAR

### lib/core/config/app_environment.dart
```dart
import 'package:flutter/foundation.dart';

enum AppEnvironment { production, qa, testing }

extension AppEnvironmentX on AppEnvironment {
  String get label => switch (this) {
    AppEnvironment.production => 'Producción',
    AppEnvironment.qa => 'QA',
    AppEnvironment.testing => 'Pruebas',
  };

  String get baseUrl => switch (this) {
    AppEnvironment.production => 'https://api.sebas898.site',
    AppEnvironment.qa => 'https://api-qa.sebas898.site',
    AppEnvironment.testing => 'https://api-dev.sebas898.site',
  };

  Color get badgeColor => switch (this) {
    AppEnvironment.production => const Color(0xFF22C55E),
    AppEnvironment.qa => const Color(0xFFF59E0B),
    AppEnvironment.testing => const Color(0xFFEF4444),
  };
}

// Solo disponible en debug
const bool kIsDebugMode = !bool.fromEnvironment('dart.vm.product');
```

### lib/core/providers/environment_provider.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_environment.dart';

const _kEnvKey = 'selected_environment';

class EnvironmentNotifier extends AsyncNotifier<AppEnvironment> {
  @override
  Future<AppEnvironment> build() async {
    // En release, siempre producción
    if (!kIsDebugMode) return AppEnvironment.production;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kEnvKey);
    return AppEnvironment.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppEnvironment.production,
    );
  }

  Future<void> setEnvironment(AppEnvironment env) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEnvKey, env.name);
    state = AsyncData(env);
  }
}

final environmentProvider =
    AsyncNotifierProvider<EnvironmentNotifier, AppEnvironment>(
        EnvironmentNotifier.new);
```

## Archivos a MODIFICAR

### lib/core/services/api_client.dart
Cambiar para recibir la baseUrl dinámicamente:

```dart
// Agregar parámetro al constructor:
ApiClient({String? baseUrl}) {
  _storage = const FlutterSecureStorage();
  _dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? ApiConstants.baseUrl,
    ...
  ));
  ...
}
```

### lib/core/services/api_client.dart — provider
Cambiar `apiClientProvider` para leer el entorno:
```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  final env = ref.watch(environmentProvider).valueOrNull
      ?? AppEnvironment.production;
  return ApiClient(baseUrl: env.baseUrl);
});
```

### lib/features/settings/presentation/pages/settings_page.dart
Agregar sección de entorno **solo en debug** (`if (kIsDebugMode)`), entre la sección de sincronización y "Cambiar contraseña":

```dart
if (kIsDebugMode) ...[
  const Divider(),
  Consumer(
    builder: (context, ref, _) {
      final env = ref.watch(environmentProvider).valueOrNull
          ?? AppEnvironment.production;
      return ListTile(
        leading: Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: env.badgeColor,
            shape: BoxShape.circle,
          ),
        ),
        title: const Text('Entorno'),
        subtitle: Text(env.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showEnvironmentPicker(context, ref),
      );
    },
  ),
],
```

Agregar método `_showEnvironmentPicker`:
```dart
void _showEnvironmentPicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ListTile(title: Text('Seleccionar entorno',
            style: TextStyle(fontWeight: FontWeight.bold))),
        const Divider(),
        ...AppEnvironment.values.map((env) => ListTile(
          leading: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: env.badgeColor, shape: BoxShape.circle),
          ),
          title: Text(env.label),
          subtitle: Text(env.baseUrl),
          onTap: () {
            ref.read(environmentProvider.notifier).setEnvironment(env);
            Navigator.pop(context);
            // Reiniciar sesión para reconectar al nuevo servidor
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cambiado a ${env.label}')),
            );
          },
        )),
        const SizedBox(height: 16),
      ],
    ),
  );
}
```

### lib/main.dart
Agregar badge de entorno en debug en el AppBar del `_HomePage`:
```dart
// En el AppBar de _HomePage, agregar en actions[] antes del IconButton de settings:
if (kIsDebugMode)
  Consumer(
    builder: (_, ref, __) {
      final env = ref.watch(environmentProvider).valueOrNull;
      if (env == null || env == AppEnvironment.production) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: env.badgeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: env.badgeColor),
        ),
        child: Text(env.label,
            style: TextStyle(color: env.badgeColor, fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
    },
  ),
```

## Restricciones
- En modo release (`!kIsDebugMode`) el selector NO debe aparecer en ningún lado
- No crear flavors de Flutter — solo usar `kReleaseMode` / `kDebugMode` de foundation
- shared_preferences ya está instalado (spec 016)
- Al cambiar entorno, la app NO se reinicia automáticamente — el usuario debe hacer logout/login para conectar al nuevo servidor

## Definición de hecho
- [ ] `flutter analyze` sin errores
- [ ] En debug: tile "Entorno" visible en Configuración
- [ ] Bottom sheet muestra los 3 entornos con sus URLs
- [ ] Al seleccionar uno, el ApiClient usa la nueva baseUrl
- [ ] Badge de entorno visible en home cuando no es Producción
- [ ] En release: nada de esto es visible
