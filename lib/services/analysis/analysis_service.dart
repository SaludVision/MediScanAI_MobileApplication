import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../http_client.dart';
import '../../config/api_config.dart';
import '../../models/analysis/analysis_types.dart';

class AnalysisService {
  // Upload Analysis
  Future<Analysis> uploadAnalysis(UploadAnalysisRequest request) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiConfig.analysisService.upload,
      body: request.toJson(),
    );

    return Analysis.fromJson(response);
  }

  // Upload Analysis from File
  Future<Analysis> uploadAnalysisFromFile({
    required File imageFile,
    required AnalysisType analysisType,
    String? patientId,
    String? notes,
  }) async {
    // Read file as bytes and convert to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final request = UploadAnalysisRequest(
      imageBase64: base64Image,
      analysisType: analysisType,
      patientId: patientId,
      notes: notes,
    );

    return uploadAnalysis(request);
  }

  // Upload Analysis from Bytes
  Future<Analysis> uploadAnalysisFromBytes({
    required Uint8List imageBytes,
    required AnalysisType analysisType,
    String? patientId,
    String? notes,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final request = UploadAnalysisRequest(
      imageBase64: base64Image,
      analysisType: analysisType,
      patientId: patientId,
      notes: notes,
    );

    return uploadAnalysis(request);
  }

  // Get Analysis by ID
  Future<Analysis> getAnalysisById(String id) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.analysisService.getById(id),
    );

    return Analysis.fromJson(response);
  }

  // List Analyses
  Future<AnalysisListResponse> listAnalyses([PaginationParams? params]) async {
    final queryParams = params?.toQueryParameters() ?? {};

    final response = await httpClient.get<Map<String, dynamic>>(
      ApiConfig.analysisService.list,
      queryParameters: queryParams,
    );

    return AnalysisListResponse.fromJson(response);
  }

  // Delete Analysis
  Future<void> deleteAnalysis(String id) async {
    await httpClient.delete(ApiConfig.analysisService.delete(id));
  }

  // Get Recent Analyses
  Future<List<Analysis>> getRecentAnalyses({int limit = 5}) async {
    final params = PaginationParams(
      page: 1,
      pageSize: limit,
      sortBy: 'createdAt',
      sortOrder: 'desc',
    );

    final response = await listAnalyses(params);
    return response.analyses;
  }
}
