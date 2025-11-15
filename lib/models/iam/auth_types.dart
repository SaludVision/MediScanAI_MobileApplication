// IAM Authentication Types

class LoginRequest {
  final String email;
  final String password;
  final bool? rememberMe;

  LoginRequest({required this.email, required this.password, this.rememberMe});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'rememberMe': rememberMe,
  };
}

class LoginResponse {
  final UserProfile user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: UserProfile.fromJson(json['user']),
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    expiresIn: json['expiresIn'],
  );
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String dni;
  final String specialty;
  final String professionalId;
  final String hospital;
  final String phone;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.dni,
    required this.specialty,
    required this.professionalId,
    required this.hospital,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'dni': dni,
    'specialty': specialty,
    'professionalId': professionalId,
    'hospital': hospital,
    'phone': phone,
  };
}

class RegisterResponse {
  final UserProfile user;
  final String message;

  RegisterResponse({required this.user, required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        user: UserProfile.fromJson(json['user']),
        message: json['message'],
      );
}

class VerifyEmailRequest {
  final String email;

  VerifyEmailRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class VerifyEmailResponse {
  final bool exists;
  final String email;

  VerifyEmailResponse({required this.exists, required this.email});

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      VerifyEmailResponse(exists: json['exists'], email: json['email']);
}

class ResetPasswordRequest {
  final String email;
  final String newPassword;

  ResetPasswordRequest({required this.email, required this.newPassword});

  Map<String, dynamic> toJson() => {'email': email, 'newPassword': newPassword};
}

class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({required this.success, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ResetPasswordResponse(success: json['success'], message: json['message']);
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String dni;
  final String specialty;
  final String professionalId;
  final String hospital;
  final String phone;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.dni,
    required this.specialty,
    required this.professionalId,
    required this.hospital,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    dni: json['dni'],
    specialty: json['specialty'],
    professionalId: json['professionalId'],
    hospital: json['hospital'],
    phone: json['phone'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dni': dni,
    'specialty': specialty,
    'professionalId': professionalId,
    'hospital': hospital,
    'phone': phone,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class UpdateProfileRequest {
  final String? name;
  final String? dni;
  final String? specialty;
  final String? hospital;
  final String? phone;

  UpdateProfileRequest({
    this.name,
    this.dni,
    this.specialty,
    this.hospital,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (dni != null) data['dni'] = dni;
    if (specialty != null) data['specialty'] = specialty;
    if (hospital != null) data['hospital'] = hospital;
    if (phone != null) data['phone'] = phone;
    return data;
  }
}

class ApiError {
  final String message;
  final String code;
  final int status;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    required this.code,
    required this.status,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
    message: json['message'],
    code: json['code'],
    status: json['status'],
    details: json['details'],
  );
}
