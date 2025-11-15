// Export all microservice models
export 'iam/auth_types.dart';
export 'analysis/analysis_types.dart';
export 'reports/report_types.dart';
export 'notifications/notification_types.dart';

// Legacy models - Deprecated, use microservice models instead
class UserProfile {
  final String name;
  final String email;
  final String specialty;
  final String dni;
  final String professionalId;
  final String hospital;
  final String phone;

  UserProfile({
    required this.name,
    required this.email,
    required this.specialty,
    required this.dni,
    required this.professionalId,
    required this.hospital,
    required this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialty: json['specialty'] ?? '',
      dni: json['dni'] ?? '',
      professionalId: json['professionalId'] ?? '',
      hospital: json['hospital'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'specialty': specialty,
      'dni': dni,
      'professionalId': professionalId,
      'hospital': hospital,
      'phone': phone,
    };
  }
}

class Analysis {
  final int id;
  final String patient;
  final String type;
  final String time;
  final String status;

  Analysis({
    required this.id,
    required this.patient,
    required this.type,
    required this.time,
    required this.status,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      id: json['id'],
      patient: json['patient'],
      type: json['type'],
      time: json['time'],
      status: json['status'],
    );
  }
}

class Report {
  final int id;
  final String patient;
  final String type;
  final String date;
  final String result;
  final String status;

  Report({
    required this.id,
    required this.patient,
    required this.type,
    required this.date,
    required this.result,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      patient: json['patient'],
      type: json['type'],
      date: json['date'],
      result: json['result'],
      status: json['status'],
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type;
  bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.read = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      time: json['time'],
      type: json['type'],
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'type': type,
      'read': read,
    };
  }
}
