// AI Analysis Types

class AnalysisRequest {
  final String patientName;
  final String studyType;
  final String technicianNotes;
  final String imagePath; // Local path to image file

  AnalysisRequest({
    required this.patientName,
    required this.studyType,
    required this.technicianNotes,
    required this.imagePath,
  });
}

class AnalysisResponse {
  final String status;
  final AnalysisData analysis;
  final ReportData? report; // Optional - only in Gemini version

  AnalysisResponse({required this.status, required this.analysis, this.report});

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    // Check if it's Gemini version (main.py) or simple version (main3.py)
    if (json.containsKey('analysis') && json.containsKey('report')) {
      // Gemini version
      return AnalysisResponse(
        status: json['status'] ?? 'success',
        analysis: AnalysisData.fromJson(json['analysis']),
        report: ReportData.fromJson(json['report']),
      );
    } else {
      // Simple version (main3.py)
      return AnalysisResponse(
        status: 'success',
        analysis: AnalysisData.fromJsonSimple(json),
        report: null,
      );
    }
  }
}

class AnalysisData {
  final String primaryDiagnosis;
  final String secondaryDiagnosis;
  final double confidenceScore;
  final Map<String, double> rawProbabilities;
  final AnalysisMetrics? metrics; // For simple version

  AnalysisData({
    required this.primaryDiagnosis,
    this.secondaryDiagnosis = '',
    required this.confidenceScore,
    required this.rawProbabilities,
    this.metrics,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    // Gemini version
    final probabilities = <String, double>{};
    if (json['raw_probabilities'] != null) {
      (json['raw_probabilities'] as Map<String, dynamic>).forEach((key, value) {
        probabilities[key] = (value as num).toDouble();
      });
    }

    return AnalysisData(
      primaryDiagnosis: json['primary_diagnosis'] ?? '',
      secondaryDiagnosis: json['secondary_diagnosis'] ?? '',
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      rawProbabilities: probabilities,
      metrics: null,
    );
  }

  factory AnalysisData.fromJsonSimple(Map<String, dynamic> json) {
    // Simple version (main3.py)
    final aiFindings = json['aiFindings'] as Map<String, dynamic>;
    final probabilities = <String, double>{};

    if (aiFindings['probabilities'] != null) {
      (aiFindings['probabilities'] as Map<String, dynamic>).forEach((
        key,
        value,
      ) {
        probabilities[key] = (value as num).toDouble();
      });
    }

    return AnalysisData(
      primaryDiagnosis: aiFindings['finalLabel'] ?? '',
      secondaryDiagnosis: '', // No secondary in simple version
      confidenceScore: (aiFindings['metrics']['topClassConfidence'] as num)
          .toDouble(),
      rawProbabilities: probabilities,
      metrics: AnalysisMetrics.fromJson(aiFindings['metrics']),
    );
  }

  String get confidencePercentage =>
      '${(confidenceScore * 100).toStringAsFixed(1)}%';

  List<ProbabilityItem> get probabilities => sortedProbabilities;

  List<ProbabilityItem> get sortedProbabilities {
    final items = rawProbabilities.entries
        .map((e) => ProbabilityItem(className: e.key, probability: e.value))
        .toList();
    items.sort((a, b) => b.probability.compareTo(a.probability));
    return items;
  }
}

class ProbabilityItem {
  final String className;
  final double probability;

  ProbabilityItem({required this.className, required this.probability});

  String get percentage => '${(probability * 100).toStringAsFixed(1)}%';
}

class AnalysisMetrics {
  final String topClass;
  final double topClassConfidence;
  final String secondClass;
  final double secondClassConfidence;
  final String processingTime;
  final String modelVersion;
  final String imageQuality;

  AnalysisMetrics({
    required this.topClass,
    required this.topClassConfidence,
    required this.secondClass,
    required this.secondClassConfidence,
    this.processingTime = 'N/A',
    this.modelVersion = 'EfficientNetV3',
    this.imageQuality = 'Good',
  });

  factory AnalysisMetrics.fromJson(Map<String, dynamic> json) {
    return AnalysisMetrics(
      topClass: json['topClass'] ?? '',
      topClassConfidence: (json['topClassConfidence'] as num).toDouble(),
      secondClass: json['secondClass'] ?? 'N/A',
      secondClassConfidence: (json['secondClassConfidence'] as num).toDouble(),
    );
  }
}

class ReportData {
  final String contentHtml;
  final String source;
  final String title;
  final String content;
  final String recommendations;

  ReportData({
    required this.contentHtml,
    required this.source,
    this.title = '',
    this.content = '',
    this.recommendations = '',
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    // Parse HTML to extract title and content
    final html = json['content_html'] ?? '';
    String title = '';
    String content = html;
    String recommendations = '';

    // Simple HTML parsing for title
    final titleMatch = RegExp(
      r'<h1[^>]*>(.*?)</h1>',
      caseSensitive: false,
    ).firstMatch(html);
    if (titleMatch != null) {
      title = titleMatch.group(1) ?? '';
    }

    // Remove HTML tags for plain text content
    content = html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return ReportData(
      contentHtml: html,
      source: json['source'] ?? 'Google Gemini AI',
      title: title,
      content: content,
      recommendations: recommendations,
    );
  }
}

class AnalysisHistory {
  final String id;
  final String patientName;
  final String studyType;
  final String diagnosis;
  final double confidence;
  final DateTime timestamp;
  final String? imagePath;

  AnalysisHistory({
    required this.id,
    required this.patientName,
    required this.studyType,
    required this.diagnosis,
    required this.confidence,
    required this.timestamp,
    this.imagePath,
  });

  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    return AnalysisHistory(
      id: json['id'] ?? '',
      patientName: json['patientName'] ?? '',
      studyType: json['studyType'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientName': patientName,
    'studyType': studyType,
    'diagnosis': diagnosis,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
    'imagePath': imagePath,
  };
}
