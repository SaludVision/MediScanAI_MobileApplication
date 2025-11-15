import '../http_client.dart';
import '../../config/api_config.dart';
import '../../models/iam/auth_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Login
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiConfig.iamService.login,
      body: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response);

    // Guardar tokens en SharedPreferences
    if (loginResponse.accessToken.isNotEmpty) {
      await _saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
        loginResponse.user,
      );
    }

    return loginResponse;
  }

  // Register
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiConfig.iamService.register,
      body: request.toJson(),
    );

    return RegisterResponse.fromJson(response);
  }

  // Verify Email
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      '${ApiConfig.iamService.verifyEmail}/${Uri.encodeComponent(request.email)}',
    );

    return VerifyEmailResponse(
      exists: !(response['available'] as bool),
      email: request.email,
    );
  }

  // Reset Password
  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiConfig.iamService.resetPassword,
      body: request.toJson(),
    );

    return ResetPasswordResponse.fromJson(response);
  }

  // Refresh Token
  Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiConfig.iamService.refreshToken,
      body: {'refreshToken': refreshToken},
    );

    final loginResponse = LoginResponse.fromJson(response);

    await _saveTokens(
      loginResponse.accessToken,
      loginResponse.refreshToken,
      loginResponse.user,
    );

    return loginResponse;
  }

  // Logout
  Future<void> logout() async {
    try {
      await httpClient.post(ApiConfig.iamService.logout);
    } finally {
      await _clearTokens();
    }
  }

  // Get Profile
  Future<UserProfile> getProfile() async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.userService.profile,
    );

    return UserProfile.fromJson(response);
  }

  // Update Profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await httpClient.put<Map<String, dynamic>>(
      ApiConfig.userService.updateProfile,
      body: request.toJson(),
    );

    final updatedProfile = UserProfile.fromJson(response['user']);

    // Actualizar perfil almacenado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', userProfileToJson(updatedProfile));

    return updatedProfile;
  }

  // Helper methods
  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    UserProfile user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userProfile', userProfileToJson(user));
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userProfile');
  }

  Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getStoredRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<UserProfile?> getStoredUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userProfile');
    if (userJson != null) {
      return userProfileFromJson(userJson);
    }
    return null;
  }

  // JSON serialization helpers
  String userProfileToJson(UserProfile profile) {
    return profile.toJson().toString();
  }

  UserProfile? userProfileFromJson(String json) {
    try {
      // TODO: Implement proper JSON parsing
      return null;
    } catch (_) {
      return null;
    }
  }
}
