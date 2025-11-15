import 'dart:convert';
import '../../models/iam/auth_types.dart';
import '../http_client.dart';

// Interfaces para las respuestas del backend IAM
class IamLoginRequest {
  final String username;
  final String password;

  IamLoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class IamRegisterRequest {
  final String usernameDto;
  final String passwordDto;
  final String nameDto;
  final String emailDto;
  final String phoneDto;
  final String roleDto;

  IamRegisterRequest({
    required this.usernameDto,
    required this.passwordDto,
    required this.nameDto,
    required this.emailDto,
    required this.phoneDto,
    required this.roleDto,
  });

  Map<String, dynamic> toJson() => {
    'usernameDto': usernameDto,
    'passwordDto': passwordDto,
    'nameDto': nameDto,
    'emailDto': emailDto,
    'phoneDto': phoneDto,
    'roleDto': roleDto,
  };
}

class IamUserResponse {
  final int id;
  final String username;
  final String password;
  final String name;
  final String email;
  final String phone;
  final String role;

  IamUserResponse({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory IamUserResponse.fromJson(Map<String, dynamic> json) =>
      IamUserResponse(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'],
      );
}

class IamApiResponse<T> {
  final bool success;
  final String message;
  final T? user;
  final String? error;

  IamApiResponse({
    required this.success,
    required this.message,
    this.user,
    this.error,
  });

  factory IamApiResponse.fromJson(Map<String, dynamic> json) => IamApiResponse(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    user: json['user'] != null ? json['user'] as T : null,
    error: json['error'],
  );
}

// Adaptadores para transformar datos entre frontend y backend IAM

IamLoginRequest adaptLoginRequest(LoginRequest request) {
  return IamLoginRequest(username: request.email, password: request.password);
}

IamRegisterRequest adaptRegisterRequest(RegisterRequest request) {
  return IamRegisterRequest(
    usernameDto: request.email,
    passwordDto: request.password,
    nameDto: request.name,
    emailDto: request.email,
    phoneDto: request.phone,
    roleDto: 'DOCTOR',
  );
}

UserProfile adaptUserProfile(
  IamUserResponse iamUser, [
  Map<String, dynamic>? professionalData,
]) {
  return UserProfile(
    id: iamUser.id.toString(), // Convertir int → String
    name: iamUser.name,
    email: iamUser.email,
    phone: iamUser.phone,
    dni: professionalData?['dni'] ?? '',
    specialty: professionalData?['specialty'] ?? '',
    professionalId: professionalData?['professionalId'] ?? '',
    hospital: professionalData?['hospital'] ?? '',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}

LoginResponse adaptLoginResponse(IamApiResponse<IamUserResponse> iamResponse) {
  if (!iamResponse.success || iamResponse.user == null) {
    throw Exception(iamResponse.message ?? 'Error en login');
  }

  final userProfile = adaptUserProfile(iamResponse.user!);

  final accessToken = generateFakeToken('access', iamResponse.user!.id);
  final refreshToken = generateFakeToken('refresh', iamResponse.user!.id);

  return LoginResponse(
    user: userProfile,
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: 3600,
  );
}

// Adaptador para respuestas de texto plano del backend
LoginResponse adaptLoginResponseFromText(
  String responseText,
  LoginRequest originalRequest,
) {
  // El backend devuelve "Usuario loggeado exitosamente." para login exitoso
  if (responseText.contains('loggeado exitosamente')) {
    // Crear un usuario fake basado en el email del login
    final fakeUser = IamUserResponse(
      id: DateTime.now().millisecondsSinceEpoch, // ID temporal
      username: originalRequest.email,
      password: '', // No almacenamos password
      name: originalRequest.email.split('@')[0], // Nombre basado en email
      email: originalRequest.email,
      phone: '',
      role: 'DOCTOR',
    );

    final userProfile = adaptUserProfile(fakeUser);
    final accessToken = generateFakeToken('access', fakeUser.id);
    final refreshToken = generateFakeToken('refresh', fakeUser.id);

    return LoginResponse(
      user: userProfile,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: 3600,
    );
  } else {
    throw Exception(responseText);
  }
}

RegisterResponse adaptRegisterResponse(
  IamApiResponse<IamUserResponse> iamResponse,
  RegisterRequest originalRequest,
) {
  if (!iamResponse.success || iamResponse.user == null) {
    throw Exception(iamResponse.message ?? 'Error en registro');
  }

  final professionalData = {
    'dni': originalRequest.dni,
    'specialty': originalRequest.specialty,
    'professionalId': originalRequest.professionalId,
    'hospital': originalRequest.hospital,
  };

  final userProfile = adaptUserProfile(iamResponse.user!, professionalData);

  return RegisterResponse(
    user: userProfile,
    message: iamResponse.message ?? 'Usuario registrado exitosamente',
  );
}

// Adaptador para respuestas de texto plano del backend
RegisterResponse adaptRegisterResponseFromText(
  String responseText,
  RegisterRequest originalRequest,
) {
  // El backend devuelve "Usuario registrado exitosamente." para registro exitoso
  if (responseText.contains('registrado exitosamente')) {
    // Crear un usuario fake basado en los datos del registro
    final fakeUser = IamUserResponse(
      id: DateTime.now().millisecondsSinceEpoch, // ID temporal
      username: originalRequest.email,
      password: '', // No almacenamos password
      name: originalRequest.name,
      email: originalRequest.email,
      phone: originalRequest.phone,
      role: 'DOCTOR',
    );

    final professionalData = {
      'dni': originalRequest.dni,
      'specialty': originalRequest.specialty,
      'professionalId': originalRequest.professionalId,
      'hospital': originalRequest.hospital,
    };

    final userProfile = adaptUserProfile(fakeUser, professionalData);

    return RegisterResponse(user: userProfile, message: responseText);
  } else {
    throw Exception(responseText);
  }
}

// Generación de tokens "fake" para desarrollo
String generateFakeToken(String type, int userId) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = DateTime.now().microsecondsSinceEpoch.toString();
  final payload = base64Encode(
    utf8.encode(
      jsonEncode({
        'userId': userId,
        'type': type,
        'timestamp': timestamp,
        'warning': 'This is a fake token for development only',
      }),
    ),
  );

  return 'fake-$type-$userId-$timestamp-$random.$payload';
}

bool validateFakeToken(String token) {
  if (!token.startsWith('fake-')) return false;

  final parts = token.split('.');
  if (parts.length != 2) return false;

  try {
    final payload = jsonDecode(utf8.decode(base64Decode(parts[1])));

    if (payload['userId'] == null ||
        payload['type'] == null ||
        payload['timestamp'] == null) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final tokenAge = now - payload['timestamp'];
    const oneHour = 60 * 60 * 1000;

    return tokenAge < oneHour;
  } catch (e) {
    return false;
  }
}

Map<String, dynamic>? decodeFakeToken(String token) {
  if (!validateFakeToken(token)) {
    return null;
  }

  try {
    final parts = token.split('.');
    return jsonDecode(utf8.decode(base64Decode(parts[1])))
        as Map<String, dynamic>;
  } catch (e) {
    return null;
  }
}

void validateIamResponse(IamApiResponse response) {
  if (!response.success) {
    throw Exception(response.message ?? response.error ?? 'Error desconocido');
  }
}

String extractErrorMessage(dynamic error) {
  if (error is ApiException) {
    return error.message;
  }
  if (error is Exception) {
    return error.toString();
  }
  return 'Error desconocido en el servidor';
}
