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
