// Report Types

class Report {
  final String id;
  final String analysisId;
  final String patientId;
  final String analysisType;
  final String result;
  final ReportStatus status;
  final String generatedAt;
  final String? downloadUrl;

  Report({
    required this.id,
    required this.analysisId,
    required this.patientId,
    required this.analysisType,
    required this.result,
    required this.status,
    required this.generatedAt,
    this.downloadUrl,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    analysisId: json['analysisId'],
    patientId: json['patientId'],
    analysisType: json['analysisType'],
    result: json['result'],
    status: ReportStatus.fromJson(json['status']),
    generatedAt: json['generatedAt'],
    downloadUrl: json['downloadUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'analysisId': analysisId,
    'patientId': patientId,
    'analysisType': analysisType,
    'result': result,
    'status': status.toJson(),
    'generatedAt': generatedAt,
    if (downloadUrl != null) 'downloadUrl': downloadUrl,
  };
}

enum ReportStatus {
  success,
  warning,
  error;

  String toJson() => name;

  static ReportStatus fromJson(String json) {
    return ReportStatus.values.firstWhere((e) => e.name == json);
  }
}

class ReportListResponse {
  final List<Report> reports;
  final int total;
  final int page;
  final int pageSize;

  ReportListResponse({
    required this.reports,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ReportListResponse.fromJson(Map<String, dynamic> json) =>
      ReportListResponse(
        reports: (json['reports'] as List)
            .map((e) => Report.fromJson(e))
            .toList(),
        total: json['total'],
        page: json['page'],
        pageSize: json['pageSize'],
      );
}
