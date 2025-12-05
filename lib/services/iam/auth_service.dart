import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/iam/auth_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _authBaseUrl = '${ApiConfig.baseUrl}/api/auth';
  final String _doctorBaseUrl = '${ApiConfig.baseUrl}/api/doctors';

  // Register
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      print('🔵 Registrando usuario: ${request.email}');
      print('📤 Request: ${jsonEncode(request.toJson())}');

      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      print('📥 Respuesta del servidor:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error en registro');
      }

      final doctorData = jsonDecode(response.body) as Map<String, dynamic>;
      final registerResponse = RegisterResponse.fromJson(doctorData);

      // Guardar datos del usuario registrado
      await _saveAuthData(registerResponse.user);

      print('✅ Registro exitoso: ${registerResponse.user.name}');
      return registerResponse;
    } catch (e) {
      print('❌ Error en registro: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print('🔵 Intentando login: ${request.email}');

      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      print('📥 Respuesta del servidor:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Credenciales inválidas');
      }

      final doctorData = jsonDecode(response.body) as Map<String, dynamic>;
      final userProfile = UserProfile.fromJson(doctorData);

      // Guardar datos del usuario
      await _saveAuthData(userProfile);

      // Generar tokens fake (ya que el backend no usa JWT)
      final accessToken = _generateFakeToken('access', userProfile.id);
      final refreshToken = _generateFakeToken('refresh', userProfile.id);

      final loginResponse = LoginResponse(
        user: userProfile,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: 3600,
      );

      print('✅ Login exitoso: ${userProfile.name}');
      return loginResponse;
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Get Profile
  Future<UserProfile> getProfile(String userId) async {
    try {
      print('🔵 Obteniendo perfil del usuario: $userId');

      final response = await http
          .get(
            Uri.parse('$_doctorBaseUrl/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Error al obtener perfil');
      }

      final doctorData = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(doctorData);

      print('✅ Perfil obtenido: ${profile.name}');
      return profile;
    } catch (e) {
      print('❌ Error al obtener perfil: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Update Profile
  Future<UserProfile> updateProfile(
    String userId,
    UpdateProfileRequest request,
  ) async {
    try {
      print('🔵 Actualizando perfil del usuario: $userId');

      final response = await http
          .put(
            Uri.parse('$_doctorBaseUrl/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Error al actualizar perfil');
      }

      final doctorData = jsonDecode(response.body) as Map<String, dynamic>;
      final updatedProfile = UserProfile.fromJson(doctorData);

      // Actualizar datos guardados localmente
      await _saveAuthData(updatedProfile);

      print('✅ Perfil actualizado exitosamente');
      return updatedProfile;
    } catch (e) {
      print('❌ Error al actualizar perfil: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Change Password
  Future<void> changePassword(
    String userId,
    ChangePasswordRequest request,
  ) async {
    try {
      print('🔵 Cambiando contraseña del usuario: $userId');

      final response = await http
          .post(
            Uri.parse('$_doctorBaseUrl/$userId/change-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al cambiar contraseña');
      }

      print('✅ Contraseña cambiada exitosamente');
    } catch (e) {
      print('❌ Error al cambiar contraseña: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Forgot Password
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      print('🔵 Restableciendo contraseña para: ${request.email}');

      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al restablecer contraseña');
      }

      print('✅ Contraseña restablecida exitosamente');
    } catch (e) {
      print('❌ Error al restablecer contraseña: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _clearAuthData();
      print('✅ Logout exitoso');
    } catch (e) {
      print('❌ Error en logout: $e');
      await _clearAuthData();
    }
  }

  // Verify Email (placeholder - no implementado en backend)
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    print('⚠️ Verify email no implementado en backend');
    // Por ahora, asumimos que el email está disponible
    return VerifyEmailResponse(exists: false, email: request.email);
  }

  // Reset Password (usa forgot-password del backend)
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      print('🔵 Restableciendo contraseña para: ${request.email}');

      final forgotPasswordRequest = ForgotPasswordRequest(
        email: request.email,
        newPassword: request.newPassword,
      );

      await forgotPassword(forgotPasswordRequest);
      print('✅ Contraseña restablecida exitosamente');
    } catch (e) {
      print('❌ Error al restablecer contraseña: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Get Current User
  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userProfile');
    if (userProfileJson != null) {
      return UserProfile.fromJson(jsonDecode(userProfileJson));
    }
    return null;
  }

  // Is Authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null;
  }

  // Get Stored Access Token
  Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Get Stored User Profile
  Future<UserProfile?> getStoredUserProfile() async {
    return await getCurrentUser();
  }

  // Private Methods

  Future<void> _saveAuthData(UserProfile userProfile) async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = _generateFakeToken('access', userProfile.id);
    final refreshToken = _generateFakeToken('refresh', userProfile.id);

    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userProfile', jsonEncode(userProfile.toJson()));
    await prefs.setString('userId', userProfile.id);
    await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userProfile');
    await prefs.remove('userId');
    await prefs.remove('loginTimestamp');
  }

  String _generateFakeToken(String type, String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = '$type-$userId-$timestamp';
    return 'fake_token_${base64Encode(utf8.encode(payload))}';
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.contains('Email already registered')) {
        return 'El correo electrónico ya está registrado';
      }
      if (message.contains('Invalid credentials')) {
        return 'Credenciales inválidas';
      }
      if (message.contains('Doctor not found')) {
        return 'Usuario no encontrado';
      }
      if (message.contains('Contraseña actual incorrecta')) {
        return 'La contraseña actual es incorrecta';
      }
      if (message.contains('Email no registrado')) {
        return 'El correo electrónico no está registrado';
      }
      return message;
    }
    return error.toString();
  }
}
