import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_environment.dart';
import '../constants/api_constants.dart';
import '../providers/environment_provider.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kCachedUser = 'cached_user';

final apiClientProvider = Provider<ApiClient>((ref) {
  final env = ref.watch(environmentProvider).valueOrNull
      ?? AppEnvironment.production;
  return ApiClient(baseUrl: env.baseUrl);
});

class ApiClient {
  ApiClient({String? baseUrl}) {
    _baseUrl = baseUrl ?? ApiConstants.baseUrl;
    _storage = const FlutterSecureStorage();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_buildAuthInterceptor());
  }

  late final String _baseUrl;
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  // ── Token helpers ──────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }

  // ── Cached user (offline support) ─────────────────────────────────────────

  Future<void> saveUserJson(String json) =>
      _storage.write(key: _kCachedUser, value: json);

  Future<String?> getCachedUserJson() => _storage.read(key: _kCachedUser);

  Future<void> clearCachedUser() => _storage.delete(key: _kCachedUser);

  // ── Interceptor ────────────────────────────────────────────────────────────

  QueuedInterceptorsWrapper _buildAuthInterceptor() {
    return QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final token = await getAccessToken();
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              handler.resolve(response);
              return;
            } catch (_) {}
          }
          await clearTokens();
        }
        handler.next(error);
      },
    );
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await Dio().post(
        '$_baseUrl${ApiConstants.refresh}',
        data: {'refreshToken': refreshToken},
      );
      final newAccess = response.data['accessToken'] as String;
      final newRefresh = response.data['refreshToken'] as String;
      await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── API methods ────────────────────────────────────────────────────────────

  Future<Response> post(String path, {Object? data}) =>
      _dio.post(path, data: data);

  Future<Response> get(String path,
          {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> put(String path, {Object? data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) =>
      _dio.delete(path);

  Future<Response> patch(String path, {Object? data}) =>
      _dio.patch(path, data: data);
}
