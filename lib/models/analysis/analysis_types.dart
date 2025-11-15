// Analysis Types

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

class UploadAnalysisRequest {
  final String imageBase64;
  final AnalysisType analysisType;
  final String? patientId;
  final String? notes;

  UploadAnalysisRequest({
    required this.imageBase64,
    required this.analysisType,
    this.patientId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'image': imageBase64,
    'analysisType': analysisType.toJson(),
    if (patientId != null) 'patientId': patientId,
    if (notes != null) 'notes': notes,
  };
}

class Analysis {
  final String id;
  final String patientId;
  final AnalysisType analysisType;
  final AnalysisStatus status;
  final String imageUrl;
  final AnalysisResult? result;
  final String createdAt;
  final String updatedAt;

  Analysis({
    required this.id,
    required this.patientId,
    required this.analysisType,
    required this.status,
    required this.imageUrl,
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) => Analysis(
    id: json['id'],
    patientId: json['patientId'],
    analysisType: AnalysisType.fromJson(json['analysisType']),
    status: AnalysisStatus.fromJson(json['status']),
    imageUrl: json['imageUrl'],
    result: json['result'] != null
        ? AnalysisResult.fromJson(json['result'])
        : null,
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'analysisType': analysisType.toJson(),
    'status': status.toJson(),
    'imageUrl': imageUrl,
    if (result != null) 'result': result!.toJson(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class AnalysisResult {
  final String diagnosis;
  final double confidence;
  final List<String> findings;
  final List<String> recommendations;

  AnalysisResult({
    required this.diagnosis,
    required this.confidence,
    required this.findings,
    required this.recommendations,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    diagnosis: json['diagnosis'],
    confidence: (json['confidence'] as num).toDouble(),
    findings: List<String>.from(json['findings']),
    recommendations: List<String>.from(json['recommendations']),
  );

  Map<String, dynamic> toJson() => {
    'diagnosis': diagnosis,
    'confidence': confidence,
    'findings': findings,
    'recommendations': recommendations,
  };
}

class AnalysisListResponse {
  final List<Analysis> analyses;
  final int total;
  final int page;
  final int pageSize;

  AnalysisListResponse({
    required this.analyses,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory AnalysisListResponse.fromJson(Map<String, dynamic> json) =>
      AnalysisListResponse(
        analyses: (json['analyses'] as List)
            .map((e) => Analysis.fromJson(e))
            .toList(),
        total: json['total'],
        page: json['page'],
        pageSize: json['pageSize'],
      );
}

class PaginationParams {
  final int? page;
  final int? pageSize;
  final String? sortBy;
  final String? sortOrder;

  PaginationParams({this.page, this.pageSize, this.sortBy, this.sortOrder});

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['pageSize'] = pageSize.toString();
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    return params;
  }
}
