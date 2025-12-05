// Report Types matching Spring Boot backend

class Report {
  final int id;
  final String patientName;
  final String studyType;
  final String content;
  final ReportStatus status;
  final int doctorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.patientName,
    required this.studyType,
    required this.content,
    required this.status,
    required this.doctorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'] as int,
    patientName: json['patientName'] as String,
    studyType: json['studyType'] as String,
    content: json['content'] as String,
    status: ReportStatus.fromString(json['status'] as String),
    doctorId: json['doctorId'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientName': patientName,
    'studyType': studyType,
    'content': content,
    'status': status.toJson(),
    'doctorId': doctorId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

// Request DTOs
class CreateReportRequest {
  final String patientName;
  final String studyType;
  final String content;
  final int doctorId;

  CreateReportRequest({
    required this.patientName,
    required this.studyType,
    required this.content,
    required this.doctorId,
  });

  Map<String, dynamic> toJson() => {
    'patientName': patientName,
    'studyType': studyType,
    'content': content,
    'doctorId': doctorId,
  };
}

class UpdateReportRequest {
  final String? content;
  final String? status;

  UpdateReportRequest({this.content, this.status});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (content != null) json['content'] = content;
    if (status != null) json['status'] = status;
    return json;
  }
}

enum ReportStatus {
  pending,
  approved,
  rejected;

  String toJson() => name.toUpperCase();

  static ReportStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ReportStatus.pending;
      case 'APPROVED':
        return ReportStatus.approved;
      case 'REJECTED':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.approved:
        return 'Aprobado';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }
}

// Analysis types for dashboard
class Analysis {
  final String id;
  final String patientId;
  final AnalysisType analysisType;
  final String createdAt;
  final AnalysisStatus status;
  final String? result;
  final String? imageUrl;

  Analysis({
    required this.id,
    required this.patientId,
    required this.analysisType,
    required this.createdAt,
    required this.status,
    this.result,
    this.imageUrl,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) => Analysis(
    id: json['id'],
    patientId: json['patientId'],
    analysisType: AnalysisType.fromJson(json['analysisType']),
    createdAt: json['createdAt'],
    status: AnalysisStatus.fromJson(json['status']),
    result: json['result'],
    imageUrl: json['imageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'analysisType': analysisType.toJson(),
    'createdAt': createdAt,
    'status': status.toJson(),
    if (result != null) 'result': result,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

enum AnalysisType {
  radiografia,
  tomografia,
  resonancia,
  ecografia,
  mamografia;

  String toJson() => name;

  static AnalysisType fromJson(String json) {
    return AnalysisType.values.firstWhere((e) => e.name == json);
  }
}

enum AnalysisStatus {
  pending,
  processing,
  completed,
  failed;

  String toJson() => name;

  static AnalysisStatus fromJson(String json) {
    return AnalysisStatus.values.firstWhere((e) => e.name == json);
  }
}

// Pagination parameters (keeping for compatibility)
class PaginationParams {
  final int page;
  final int pageSize;
  final String? sortBy;
  final String? sortOrder;

  PaginationParams({
    this.page = 1,
    this.pageSize = 10,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortOrder != null) params['sortOrder'] = sortOrder!;
    return params;
  }
}
