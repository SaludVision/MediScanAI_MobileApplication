class ApiConfig {
  // URL base del API Gateway
  // Para Android Emulator: usa 10.0.2.2
  // Para dispositivo físico: usa la IP de tu computadora (ej: 192.168.1.100)
  // Para iOS Simulator: usa localhost
  static const String baseUrl = String.fromEnvironment(
    'API_GATEWAY_URL',
    defaultValue: 'http://10.0.2.2:8080', // Emulador Android por defecto
  );

  // Timeout
  static const Duration timeout = Duration(seconds: 30);

  // Endpoints del microservicio IAM (Identity and Access Management)
  static const iamService = _IamServiceEndpoints();

  // Endpoints del microservicio Analysis
  static const analysisService = _AnalysisServiceEndpoints();

  // Endpoints del microservicio Reports
  static const reportService = _ReportServiceEndpoints();

  // Endpoints del microservicio Notifications
  static const notificationService = _NotificationServiceEndpoints();

  // Endpoints del microservicio User
  static const userService = _UserServiceEndpoints();
}

class _IamServiceEndpoints {
  const _IamServiceEndpoints();

  String get base => '/api/v1';
  String get login => '/api/v1/login';
  String get register => '/api/v1/register';
  String get verifyEmail => '/api/v1/iam/check-email';
  String get resetPassword => '/api/v1/iam/reset-password';
  String get refreshToken => '/api/v1/iam/refresh-token';
  String get logout => '/api/v1/iam/logout';
}

class _AnalysisServiceEndpoints {
  const _AnalysisServiceEndpoints();

  String get base => '/analysis';
  String get upload => '/analysis/upload';
  String getById(String id) => '/analysis/$id';
  String get list => '/analysis/list';
  String delete(String id) => '/analysis/$id';
}

class _ReportServiceEndpoints {
  const _ReportServiceEndpoints();

  String get base => '/api/reports';
  String get create => '/api/reports';
  String getById(int id) => '/api/reports/$id';
  String getByDoctor(int doctorId) => '/api/reports/doctor/$doctorId';
  String update(int id) => '/api/reports/$id';
}

class _NotificationServiceEndpoints {
  const _NotificationServiceEndpoints();

  String get base => '/api/notifications';
  String get create => '/api/notifications';
  String getByDoctor(int doctorId) => '/api/notifications/doctor/$doctorId';
}

class _UserServiceEndpoints {
  const _UserServiceEndpoints();

  String get base => '/users';
  String get profile => '/api/v1/iam/users/profile';
  String get updateProfile => '/api/v1/iam/users/profile';
}
