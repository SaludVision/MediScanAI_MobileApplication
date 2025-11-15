import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/iam/auth_types.dart';
import 'iam_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // URL base del servicio IAM (a través del API Gateway)
  final String _iamBaseUrl = '${ApiConfig.baseUrl}/api/v1';

  // Login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final iamRequest = adaptLoginRequest(request);

      final response = await http
          .post(
            Uri.parse('$_iamBaseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(iamRequest.toJson()),
          )
          .timeout(ApiConfig.timeout);

      // El backend devuelve texto plano, no JSON
      final responseText = response.body.trim();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(responseText);
      }

      final loginResponse = adaptLoginResponseFromText(responseText, request);

      // Guardar tokens y datos en SharedPreferences
      await _saveAuthData(loginResponse);

      return loginResponse;
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception(extractErrorMessage(e));
    }
  }

  // Register
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final iamRequest = adaptRegisterRequest(request);

      final response = await http
          .post(
            Uri.parse('$_iamBaseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(iamRequest.toJson()),
          )
          .timeout(ApiConfig.timeout);

      // El backend devuelve texto plano, no JSON
      final responseText = response.body.trim();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(responseText);
      }

      final registerResponse = adaptRegisterResponseFromText(
        responseText,
        request,
      );

      // Guardar datos profesionales para futuras sesiones
      await _saveProfessionalData(request);

      return registerResponse;
    } catch (e) {
      print('❌ Error en registro: $e');
      throw Exception(extractErrorMessage(e));
    }
  }

  // Verify Email (temporalmente deshabilitado hasta que se implemente en API Gateway)
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    print('⚠️ Verify email no implementado en API Gateway');
    // Por ahora, asumimos que el email está disponible
    return VerifyEmailResponse(exists: false, email: request.email);
  }

  // Reset Password (no implementado en backend IAM)
  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    print('⚠️ Reset password no implementado en backend IAM');
    throw Exception(
      'La función de restablecer contraseña no está disponible temporalmente',
    );
  }

  // Update Profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    // Esta funcionalidad no está implementada en el backend IAM
    // Por ahora, solo actualizamos localmente
    print('⚠️ Update profile no implementado en backend IAM');
    throw Exception(
      'La función de actualizar perfil no está disponible temporalmente',
    );
  }

  // Refresh Token (no implementado en backend IAM)
  Future<LoginResponse> refreshToken(String refreshToken) async {
    print('⚠️ Refresh token no implementado (backend no usa JWT)');
    throw Exception('La renovación de tokens no está disponible');
  }

  // Logout
  Future<void> logout() async {
    try {
      await _clearAuthData();
    } catch (e) {
      print('❌ Error en logout: $e');
      // Limpiar datos incluso si hay error
      await _clearAuthData();
    }
  }

  // Obtener perfil del usuario actual
  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userProfile');
    if (userProfileJson != null) {
      return UserProfile.fromJson(jsonDecode(userProfileJson));
    }
    return null;
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return false;

    // Validar token fake
    return validateFakeToken(token);
  }

  // Métodos de compatibilidad con código existente
  Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<UserProfile?> getStoredUserProfile() async {
    return await getCurrentUser();
  }

  // Métodos privados para manejo de datos
  Future<void> _saveAuthData(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', loginResponse.accessToken);
    await prefs.setString('refreshToken', loginResponse.refreshToken);
    await prefs.setString(
      'userProfile',
      jsonEncode(loginResponse.user.toJson()),
    );
    await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _saveProfessionalData(RegisterRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final professionalData = {
      'dni': request.dni,
      'specialty': request.specialty,
      'professionalId': request.professionalId,
      'hospital': request.hospital,
    };
    await prefs.setString('professionalData', jsonEncode(professionalData));
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userProfile');
    await prefs.remove('professionalData');
    await prefs.remove('loginTimestamp');
  }
}
