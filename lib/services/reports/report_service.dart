import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/reports/report_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Get authorization token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create Report
  Future<Report> createReport(CreateReportRequest request) async {
    try {
      print('📝 Creating report for: ${request.patientName}');

      final uri = Uri.parse('$_baseUrl${ApiConfig.reportService.create}');
      final headers = await _getHeaders();

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Report.fromJson(jsonData);
      } else {
        throw Exception('Error al crear reporte: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating report: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Get Reports by Doctor ID
  Future<List<Report>> getReportsByDoctor(int doctorId) async {
    try {
      print('📋 Fetching reports for doctor: $doctorId');

      final uri = Uri.parse(
        '$_baseUrl${ApiConfig.reportService.getByDoctor(doctorId)}',
      );
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching reports: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Get Report by ID
  Future<Report> getReportById(int id) async {
    try {
      print('📄 Fetching report: $id');

      final uri = Uri.parse('$_baseUrl${ApiConfig.reportService.getById(id)}');
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Report.fromJson(jsonData);
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching report: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Update Report
  Future<Report> updateReport(int id, UpdateReportRequest request) async {
    try {
      print('✏️ Updating report: $id');

      final uri = Uri.parse('$_baseUrl${ApiConfig.reportService.update(id)}');
      final headers = await _getHeaders();

      final response = await http
          .put(uri, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Report.fromJson(jsonData);
      } else {
        throw Exception('Error al actualizar reporte: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating report: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Get Recent Reports (using current doctor's ID from token)
  Future<List<Report>> getRecentReports({int limit = 10}) async {
    try {
      // Get current doctor ID from auth
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      final reports = await getReportsByDoctor(userId);

      // Sort by createdAt descending and take limit
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports.take(limit).toList();
    } catch (e) {
      print('❌ Error fetching recent reports: $e');
      return [];
    }
  }

  // Get Reports by Status
  Future<List<Report>> getReportsByStatus(
    ReportStatus status, {
    int? doctorId,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentDoctorId = doctorId ?? prefs.getInt('user_id');

      if (currentDoctorId == null) {
        throw Exception('No se pudo obtener el ID del doctor');
      }

      final reports = await getReportsByDoctor(currentDoctorId);

      // Filter by status
      final filtered = reports.where((r) => r.status == status).toList();

      // Sort and limit
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered.take(limit).toList();
    } catch (e) {
      print('❌ Error fetching reports by status: $e');
      return [];
    }
  }

  // Approve Report
  Future<Report> approveReport(int id) async {
    return updateReport(id, UpdateReportRequest(status: 'APPROVED'));
  }

  // Reject Report
  Future<Report> rejectReport(int id) async {
    return updateReport(id, UpdateReportRequest(status: 'REJECTED'));
  }

  // Update Report Content
  Future<Report> updateReportContent(int id, String content) async {
    return updateReport(id, UpdateReportRequest(content: content));
  }

  // Helper method to extract error messages
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.contains('SocketException') ||
          message.contains('Connection')) {
        return 'No se pudo conectar al servidor. Verifica tu conexión.';
      }
      if (message.contains('TimeoutException')) {
        return 'La solicitud está tardando demasiado. Intenta de nuevo.';
      }
      return message;
    }
    return error.toString();
  }
}
