class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.18.141:5000',
  );

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/auth/profile';

  // Email auth
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String forgotPassword = '/api/auth/forgot-password';

  // Products
  static const String products = '/api/products';

  // Stats
  static const String stats = '/api/stats';

  // Sales
  static const String sales = '/api/sales';

  // Cash register
  static const String cashRegisterCurrent = '/api/cash-register/current';
  static const String cashRegisterOpen = '/api/cash-register/open';
  static const String cashRegisterClose = '/api/cash-register/close';

  // Change password
  static const String changePassword = '/api/auth/change-password';

  // Users
  static const String users = '/api/users';
  static const String usersInvite = '/api/users/invite';

  // Sync
  static const String productsSync = '/api/products/sync';
  static const String salesSync = '/api/sales/sync';

  // Timeouts (ms)
  static const int connectionTimeout = 10000;
  static const int receiveTimeout = 15000;
}
