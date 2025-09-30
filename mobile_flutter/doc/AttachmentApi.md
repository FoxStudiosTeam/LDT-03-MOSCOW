# openapi.api.AttachmentApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**uploadProject**](AttachmentApi.md#uploadproject) | **POST** /api/attach/project | Attach files to project ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️
[**uploadPunishmentItem**](AttachmentApi.md#uploadpunishmentitem) | **POST** /api/attach/punishment_item | Attach files to punishment_item ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️
[**uploadReports**](AttachmentApi.md#uploadreports) | **POST** /api/attach/reports | Attach files to reports ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️


# **uploadProject**
> Attachments uploadProject(id)

Attach files to project ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAttachmentApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.uploadProject(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AttachmentApi->uploadProject: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Attachments**](Attachments.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadPunishmentItem**
> Attachments uploadPunishmentItem(id)

Attach files to punishment_item ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAttachmentApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.uploadPunishmentItem(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AttachmentApi->uploadPunishmentItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Attachments**](Attachments.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadReports**
> Attachments uploadReports(id)

Attach files to reports ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAttachmentApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.uploadReports(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AttachmentApi->uploadReports: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Attachments**](Attachments.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

