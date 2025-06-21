import 'package:dio/dio.dart';

// Simple data models
class AddCaseRequest {
  final String userPrompt;
  
  AddCaseRequest({required this.userPrompt});
  
  Map<String, dynamic> toJson() => {'user_prompt': userPrompt};
}

class CaseReference {
  final String caseIdentifier;
  final String title;
  final String? date;
  final double matchingDegree;
  final String fileReference;
  
  CaseReference({
    required this.caseIdentifier,
    required this.title,
    this.date,
    required this.matchingDegree,
    required this.fileReference,
  });
  
  factory CaseReference.fromJson(Map<String, dynamic> json) {
    return CaseReference(
      caseIdentifier: json['caseIdentifier'] ?? '',
      title: json['title'] ?? '',
      date: json['Date'],
      matchingDegree: (json['matchingDegree'] ?? 0.0).toDouble(),
      fileReference: json['fileReference'] ?? '',
    );
  }
}

class Argument {
  final String argument;
  final List<CaseReference> caseReferences;
  
  Argument({
    required this.argument,
    required this.caseReferences,
  });
  
  factory Argument.fromJson(Map<String, dynamic> json) {
    return Argument(
      argument: json['argument'] ?? '',
      caseReferences: (json['case_references'] as List<dynamic>? ?? [])
          .map((ref) => CaseReference.fromJson(ref))
          .toList(),
    );
  }
}

class AnalysisResponse {
  final String caseId;
  final List<Argument> strengths;
  final List<Argument> weaknesses;
  
  AnalysisResponse({
    required this.caseId,
    required this.strengths,
    required this.weaknesses,
  });
  
  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      caseId: json['caseId'] ?? '',
      strengths: (json['strengths'] as List<dynamic>? ?? [])
          .map((arg) => Argument.fromJson(arg))
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>? ?? [])
          .map((arg) => Argument.fromJson(arg))
          .toList(),
    );
  }
}

class ApiService {
  late final Dio _dio;

  ApiService({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://172.25.43.81:8000',
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Calls the addCase endpoint with the provided user prompt
  Future<AnalysisResponse?> addCase(String userPrompt) async {
    try {
      final request = AddCaseRequest(userPrompt: userPrompt);
      
      final response = await _dio.post(
        '/api/v1/add_case',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return AnalysisResponse.fromJson(response.data);
      }
      
      return null;
    } on DioException catch (e) {
      // Handle API errors
      print('API Error: ${e.message}');
      if (e.response != null) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      // Handle other errors
      print('Unexpected error: $e');
      rethrow;
    }
  }
}
