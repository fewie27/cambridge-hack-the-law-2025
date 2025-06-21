import 'package:test/test.dart';
import 'package:my_flutter_api_client/my_flutter_api_client.dart';


/// tests for DefaultApi
void main() {
  final instance = MyFlutterApiClient().getDefaultApi();

  group(DefaultApi, () {
    // Add a new case with user prompt analysis
    //
    // Takes a user prompt and returns arguments with related legal cases
    //
    //Future<AnalysisResponse> addCase(AddCaseRequest addCaseRequest) async
    test('test addCase', () async {
      // TODO
    });

    // Health check endpoint
    //
    // Returns the health status of the API
    //
    //Future<GetHealth200Response> getHealth() async
    test('test getHealth', () async {
      // TODO
    });

  });
}
