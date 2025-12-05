import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../config/api_config.dart';
import '../../models/analysis/analysis_types.dart';
import '../../models/reports/report_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisService {
  // Conectar directamente al servicio Python FastAPI
  // Para Android Emulator: 10.0.2.2 es el localhost de tu PC
  // Puerto 8000 es el puerto por defecto de FastAPI
  final String _baseUrl = 'http://10.0.2.2:8000';

  // Analyze medical image
  Future<AnalysisResponse> analyzeImage(AnalysisRequest request) async {
    try {
      print('🔵 Analizando imagen para: ${request.patientName}');
      print('📤 Tipo de estudio: ${request.studyType}');

      // Prepare multipart request
      // Según tu main.py, el endpoint es /ia/predict
      var uri = Uri.parse('$_baseUrl/ia/predict');
      print('🌐 URL del servicio IA: $uri');
      var multipartRequest = http.MultipartRequest('POST', uri);

      // Add form fields (según tu código Python)
      multipartRequest.fields['patientName'] = request.patientName;
      multipartRequest.fields['studyType'] = request.studyType;
      multipartRequest.fields['technicianNotes'] = request.technicianNotes;

      // Add image file
      var imageFile = File(request.imagePath);
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var filename = path.basename(request.imagePath);

      // Según tu main.py: @app.post("/ia/predict") -> image: UploadFile = File(...)
      // El campo se llama 'image' (no 'file')
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: filename,
      );

      multipartRequest.files.add(multipartFile);

      print(
        '📸 Enviando imagen: $filename (${(length / 1024).toStringAsFixed(2)} KB)',
      );

      // Send request
      var streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 60),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Respuesta del servidor:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final analysisResponse = AnalysisResponse.fromJson(jsonData);

      // Save to history
      await _saveToHistory(request, analysisResponse);

      print(
        '✅ Análisis completado: ${analysisResponse.analysis.primaryDiagnosis}',
      );
      print('   Confianza: ${analysisResponse.analysis.confidencePercentage}');

      return analysisResponse;
    } catch (e) {
      print('❌ Error en análisis: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Get analysis history
  Future<List<AnalysisHistory>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('analysis_history');

      if (historyJson == null) {
        return [];
      }

      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList.map((item) => AnalysisHistory.fromJson(item)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('❌ Error al cargar historial: $e');
      return [];
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('analysis_history');
      print('✅ Historial limpiado');
    } catch (e) {
      print('❌ Error al limpiar historial: $e');
    }
  }

  // Delete history item
  Future<void> deleteHistoryItem(String id) async {
    try {
      final history = await getHistory();
      final updatedHistory = history.where((item) => item.id != id).toList();
      await _saveHistory(updatedHistory);
      print('✅ Elemento eliminado del historial');
    } catch (e) {
      print('❌ Error al eliminar elemento: $e');
    }
  }

  // Get recent analyses for dashboard (converts AnalysisHistory to Analysis)
  Future<List<Analysis>> getRecentAnalyses({int limit = 10}) async {
    try {
      final history = await getHistory();
      final recentHistory = history.take(limit).toList();

      // Convert AnalysisHistory to Analysis for dashboard
      return recentHistory.map((item) {
        return Analysis(
          id: item.id,
          patientId: item.patientName, // Using patientName as patientId
          analysisType: _parseAnalysisType(item.studyType),
          createdAt: item.timestamp.toIso8601String(),
          status: AnalysisStatus.completed,
          result: item.diagnosis,
        );
      }).toList();
    } catch (e) {
      print('❌ Error al obtener análisis recientes: $e');
      return [];
    }
  }

  // Upload analysis from file (wrapper for analyzeImage)
  Future<Analysis> uploadAnalysisFromFile({
    required File imageFile,
    required AnalysisType analysisType,
    required String patientId,
  }) async {
    try {
      final request = AnalysisRequest(
        patientName: patientId,
        studyType: _getAnalysisTypeString(analysisType),
        technicianNotes: 'Análisis automático desde app móvil',
        imagePath: imageFile.path,
      );

      final response = await analyzeImage(request);

      // Return as Analysis type
      return Analysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        analysisType: analysisType,
        createdAt: DateTime.now().toIso8601String(),
        status: AnalysisStatus.completed,
        result: response.analysis.primaryDiagnosis,
        imageUrl: imageFile.path,
      );
    } catch (e) {
      print('❌ Error al subir análisis: $e');
      rethrow;
    }
  }

  // Helper methods
  AnalysisType _parseAnalysisType(String studyType) {
    final lowerType = studyType.toLowerCase();
    if (lowerType.contains('radio') || lowerType.contains('x-ray')) {
      return AnalysisType.radiografia;
    }
    if (lowerType.contains('tomo') || lowerType.contains('ct')) {
      return AnalysisType.tomografia;
    }
    if (lowerType.contains('reson') || lowerType.contains('mri')) {
      return AnalysisType.resonancia;
    }
    if (lowerType.contains('eco') || lowerType.contains('ultra')) {
      return AnalysisType.ecografia;
    }
    if (lowerType.contains('mamo')) {
      return AnalysisType.mamografia;
    }
    return AnalysisType.radiografia; // default
  }

  String _getAnalysisTypeString(AnalysisType type) {
    switch (type) {
      case AnalysisType.radiografia:
        return 'Radiografía';
      case AnalysisType.tomografia:
        return 'Tomografía';
      case AnalysisType.resonancia:
        return 'Resonancia Magnética';
      case AnalysisType.ecografia:
        return 'Ecografía';
      case AnalysisType.mamografia:
        return 'Mamografía';
    }
  }

  // Private methods

  Future<void> _saveToHistory(
    AnalysisRequest request,
    AnalysisResponse response,
  ) async {
    try {
      final history = await getHistory();

      final newItem = AnalysisHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: request.patientName,
        studyType: request.studyType,
        diagnosis: response.analysis.primaryDiagnosis,
        confidence: response.analysis.confidenceScore,
        timestamp: DateTime.now(),
        imagePath: request.imagePath,
      );

      history.insert(0, newItem);

      // Keep only last 50 items
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      await _saveHistory(history);
    } catch (e) {
      print('❌ Error al guardar en historial: $e');
    }
  }

  Future<void> _saveHistory(List<AnalysisHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(
      history.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('analysis_history', historyJson);
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.contains('SocketException') ||
          message.contains('Connection')) {
        return 'No se pudo conectar al servidor de IA. Verifica tu conexión.';
      }
      if (message.contains('TimeoutException')) {
        return 'El análisis está tardando demasiado. Intenta de nuevo.';
      }
      return message;
    }
    return error.toString();
  }
}
