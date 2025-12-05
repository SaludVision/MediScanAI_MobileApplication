import 'package:flutter/material.dart';
import '../services/analysis/analysis_service.dart';
import '../models/analysis/analysis_types.dart';
import '../models/reports/report_types.dart';
import '../services/reports/report_service.dart';
import '../services/notifications/notification_service.dart';

class AnalysisProvider extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();
  final ReportService _reportService = ReportService();
  final NotificationService _notificationService = NotificationService();

  AnalysisResponse? _lastAnalysis;
  AnalysisRequest? _lastRequest;
  List<AnalysisHistory> _history = [];
  bool _isAnalyzing = false;
  String? _errorMessage;

  AnalysisResponse? get lastAnalysis => _lastAnalysis;
  AnalysisRequest? get lastRequest => _lastRequest;
  List<AnalysisHistory> get history => _history;
  bool get isAnalyzing => _isAnalyzing;
  bool get isLoading => _isAnalyzing; // Alias for compatibility
  String? get errorMessage => _errorMessage;

  AnalysisProvider() {
    loadHistory();
  }

  // Analyze image
  Future<bool> analyzeImage(AnalysisRequest request) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔵 Iniciando análisis de imagen...');

      final response = await _analysisService.analyzeImage(request);

      _lastAnalysis = response;
      _lastRequest = request;
      _isAnalyzing = false;

      // Reload history to include new analysis
      await loadHistory();

      print('✅ Análisis completado exitosamente');

      // 🆕 GUARDAR AUTOMÁTICAMENTE REPORTE Y NOTIFICACIÓN
      await _autoSaveReportAndNotification(request, response);

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en análisis: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  // 🆕 Guardar automáticamente reporte y notificación
  Future<void> _autoSaveReportAndNotification(
    AnalysisRequest request,
    AnalysisResponse response,
  ) async {
    try {
      // TODO: Get actual doctor ID from AuthProvider
      final doctorId = 1;

      // 1. CREAR REPORTE AUTOMÁTICAMENTE
      print('💾 Guardando reporte automáticamente...');

      String reportContent =
          '''
DIAGNÓSTICO: ${response.analysis.primaryDiagnosis}
CONFIANZA: ${(response.analysis.confidenceScore * 100).toStringAsFixed(1)}%

${response.analysis.secondaryDiagnosis.isNotEmpty ? 'SECUNDARIO: ${response.analysis.secondaryDiagnosis}\n' : ''}
NOTAS DEL TÉCNICO: ${request.technicianNotes}

${response.report != null ? '\n--- REPORTE GEMINI AI ---\n${response.report!.content}' : ''}
''';

      final reportRequest = CreateReportRequest(
        patientName: request.patientName,
        studyType: request.studyType,
        content: reportContent,
        doctorId: doctorId,
      );

      await _reportService.createReport(reportRequest);
      print('✅ Reporte guardado automáticamente');

      // 2. CREAR NOTIFICACIÓN AUTOMÁTICAMENTE
      print('🔔 Creando notificación automáticamente...');

      final notificationMessage =
          'Análisis completado para ${request.patientName}: ${response.analysis.primaryDiagnosis} (${(response.analysis.confidenceScore * 100).toStringAsFixed(1)}% confianza)';

      await _notificationService.createNotification(
        notificationMessage,
        doctorId,
      );
      print('✅ Notificación creada automáticamente');
    } catch (e) {
      print('⚠️ Error al guardar reporte/notificación automáticamente: $e');
      // No lanzamos el error para no interrumpir el flujo del análisis
    }
  }

  // Load history
  Future<void> loadHistory() async {
    try {
      _history = await _analysisService.getHistory();
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar historial: $e');
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    try {
      await _analysisService.clearHistory();
      _history = [];
      notifyListeners();
    } catch (e) {
      print('❌ Error al limpiar historial: $e');
    }
  }

  // Delete history item
  Future<void> deleteHistoryItem(String id) async {
    try {
      await _analysisService.deleteHistoryItem(id);
      await loadHistory();
    } catch (e) {
      print('❌ Error al eliminar elemento: $e');
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear last analysis
  void clearLastAnalysis() {
    _lastAnalysis = null;
    notifyListeners();
  }
}
