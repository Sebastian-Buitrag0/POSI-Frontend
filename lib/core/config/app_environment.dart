import 'package:flutter/material.dart';

enum AppEnvironment { production, qa, testing, local }

extension AppEnvironmentX on AppEnvironment {
  String get label => switch (this) {
    AppEnvironment.production => 'Producción',
    AppEnvironment.qa => 'QA',
    AppEnvironment.testing => 'Pruebas',
    AppEnvironment.local => 'Local',
  };

  String get baseUrl => switch (this) {
    AppEnvironment.production => 'https://api.sebas898.site',
    AppEnvironment.qa => 'https://api-qa.districolor.site',
    AppEnvironment.testing => 'https://api-pruebas.districolor.site',
    AppEnvironment.local => 'http://localhost:8989',
  };

  Color get badgeColor => switch (this) {
    AppEnvironment.production => const Color(0xFF22C55E),
    AppEnvironment.qa => const Color(0xFFF59E0B),
    AppEnvironment.testing => const Color(0xFFEF4444),
    AppEnvironment.local => const Color(0xFF8B5CF6),
  };
}

// Solo disponible en debug
const bool kIsDebugMode = !bool.fromEnvironment('dart.vm.product');
