import 'package:counterclaimer/api/lib/src/api.dart';
import 'package:dio/dio.dart';
import '../api/lib/my_flutter_api_client.dart';
import 'package:counterclaimer/api/lib/src/model/add_case_request.dart';
import 'package:counterclaimer/api/lib/src/model/analysis_response.dart';


class ApiService {
  late final MyFlutterApiClient _apiClient;

  ApiService({String? baseUrl}) {
    _apiClient = MyFlutterApiClient(
      basePathOverride: baseUrl ?? 'http://172.25.43.81:8000', // Change this URL
    );
  }

  /// Calls the addCase endpoint with the provided user prompt
  Future<AnalysisResponse?> addCase(String userPrompt) async {
    try {
      final request = AddCaseRequest((b) => b..userPrompt = userPrompt);
      
      final response = await _apiClient.getDefaultApi().addCase(
        addCaseRequest: request,
      );
      
      return response.data;
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
