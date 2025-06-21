# my_flutter_api_client.api.DefaultApi

## Load the API package
```dart
import 'package:my_flutter_api_client/api.dart';
```

All URIs are relative to *http://localhost:8000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCase**](DefaultApi.md#addcase) | **POST** /api/v1/add_case | Add a new case with user prompt analysis
[**getHealth**](DefaultApi.md#gethealth) | **GET** /health | Health check endpoint


# **addCase**
> AnalysisResponse addCase(addCaseRequest)

Add a new case with user prompt analysis

Takes a user prompt and returns arguments with related legal cases

### Example
```dart
import 'package:my_flutter_api_client/api.dart';

final api = MyFlutterApiClient().getDefaultApi();
final AddCaseRequest addCaseRequest = ; // AddCaseRequest | 

try {
    final response = api.addCase(addCaseRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->addCase: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addCaseRequest** | [**AddCaseRequest**](AddCaseRequest.md)|  | 

### Return type

[**AnalysisResponse**](AnalysisResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealth**
> GetHealth200Response getHealth()

Health check endpoint

Returns the health status of the API

### Example
```dart
import 'package:my_flutter_api_client/api.dart';

final api = MyFlutterApiClient().getDefaultApi();

try {
    final response = api.getHealth();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->getHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetHealth200Response**](GetHealth200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

