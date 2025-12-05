import 'package:flutter/material.dart';
import '../services/iam/auth_service.dart';
import '../services/http_client.dart';
import '../models/iam/auth_types.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  String? _userEmail;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Convertir UserProfile a Map para compatibilidad con código existente
  Map<String, dynamic>? get userProfileMap => _userProfile?.toJson();

  AuthProvider() {
    _checkAuthStatus();
  }

  // Verificar si hay sesión guardada al iniciar
  Future<void> _checkAuthStatus() async {
    try {
      final storedProfile = await _authService.getStoredUserProfile();
      final isAuth = await _authService.isAuthenticated();

      if (storedProfile != null && isAuth) {
        _userProfile = storedProfile;
        _userEmail = storedProfile.email;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      // No hay sesión guardada
      _isAuthenticated = false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔵 Intentando login: $email');
      final response = await _authService.login(
        LoginRequest(email: email, password: password, rememberMe: true),
      );

      _isAuthenticated = true;
      _userEmail = response.user.email;
      _userProfile = response.user;
      _isLoading = false;
      print('✅ Login exitoso: ${response.user.name}');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en login: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔵 Intentando registrar usuario: ${userData['email']}');

      final response = await _authService.register(
        RegisterRequest(
          name: userData['name'],
          email: userData['email'],
          password: userData['password'],
          dni: userData['dni'] ?? '',
          specialty: userData['specialty'],
          cmpNumber: userData['cmpNumber'] ?? '',
          hospital: userData['hospital'] ?? '',
          phone: userData['phone'] ?? '',
        ),
      );

      print('✅ Registro exitoso: ${response.message}');

      // Ahora podemos hacer login automático porque el backend está completo
      print('🔄 Haciendo login automático...');
      final loginSuccess = await login(userData['email'], userData['password']);

      if (!loginSuccess) {
        print('⚠️ Login automático falló, pero el registro fue exitoso');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      print('❌ Error API en registro: ${e.message} (Status: ${e.statusCode})');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error desconocido en registro: $e');
      _errorMessage = 'Error al registrar. Verifica tu conexión.\n\n$e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      // Ignorar errores de logout
    } finally {
      _isAuthenticated = false;
      _userEmail = null;
      _userProfile = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_userProfile == null) {
        throw Exception('No hay usuario autenticado');
      }

      final updatedProfile = await _authService.updateProfile(
        _userProfile!.id,
        UpdateProfileRequest(
          name: updatedData['name'],
          dni: updatedData['dni'],
          specialty: updatedData['specialty'],
          hospital: updatedData['hospital'],
          phone: updatedData['phone'],
        ),
      );

      _userProfile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmail(String email) async {
    try {
      final response = await _authService.verifyEmail(
        VerifyEmailRequest(email: email),
      );
      return response.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        ResetPasswordRequest(email: email, newPassword: newPassword),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al restablecer contraseña.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
