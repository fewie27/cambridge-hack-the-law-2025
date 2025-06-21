import 'package:dio/dio.dart';

class AddCaseRequest {
  final String userPrompt;
  
  AddCaseRequest(this.userPrompt);
  
  Map<String, dynamic> toJson() => {'user_prompt': userPrompt};
}

class GenDraftResponse {
  final String text;
  
  GenDraftResponse({required this.text});
  
  factory GenDraftResponse.fromJson(Map<String, dynamic> json) {
    return GenDraftResponse(text: json['text'] as String);
  }
}

class CambridgeApi {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static Future<Map<String, dynamic>> addCase(AddCaseRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/add_case',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception('Failed to get response from server');
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      if (e.response != null) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  static Future<GenDraftResponse> generateDraft(String caseId) async {
    try {
      final response = await _dio.get(
        '/api/v1/gen_draft',
        queryParameters: {'case_id': caseId},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return GenDraftResponse.fromJson(response.data);
      }
      
      throw Exception('Failed to get response from server');
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      if (e.response != null) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        if (e.response?.statusCode == 404) {
          throw Exception('Case not found');
        }
      }
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }
} 