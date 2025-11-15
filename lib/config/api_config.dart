class ApiConfig {
  // URL base del API Gateway
  static const String baseUrl = String.fromEnvironment(
    'API_GATEWAY_URL',
    defaultValue: 'http://localhost:8080',
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

  String get base => '/reports';
  String getById(String id) => '/reports/$id';
  String get list => '/reports/list';
  String download(String id) => '/reports/$id/download';
}

class _NotificationServiceEndpoints {
  const _NotificationServiceEndpoints();

  String get base => '/notifications';
  String get list => '/notifications/list';
  String markRead(String id) => '/notifications/$id/read';
  String get markAllRead => '/notifications/read-all';
}

class _UserServiceEndpoints {
  const _UserServiceEndpoints();

  String get base => '/users';
  String get profile => '/api/v1/iam/users/profile';
  String get updateProfile => '/api/v1/iam/users/profile';
}
