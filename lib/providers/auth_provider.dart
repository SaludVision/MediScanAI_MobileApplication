import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  Map<String, dynamic>? _userProfile;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<bool> login(String email, String password) async {
    // Simular llamada a API
    await Future.delayed(const Duration(seconds: 2));

    // Para demo, cualquier email/password funciona
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = email;
      _userProfile = {
        'name': 'Dr. Usuario',
        'email': email,
        'specialty': 'Radiología',
        'dni': '12345678',
        'professionalId': 'MED001',
        'hospital': 'Hospital Central',
        'phone': '+1234567890',
      };
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    // Simular llamada a API
    await Future.delayed(const Duration(seconds: 2));

    _isAuthenticated = true;
    _userEmail = userData['email'];
    _userProfile = userData;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _userProfile = null;
    notifyListeners();
  }

  void updateProfile(Map<String, dynamic> updatedProfile) {
    _userProfile = updatedProfile;
    notifyListeners();
  }
}
