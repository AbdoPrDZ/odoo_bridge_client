import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_bridge_client/src/api/api.dart';

void main() {
  group('API Tests', () {
    late API api;

    setUp(() {
      api = API(apiUrl: 'https://test.example.com/api', log: false);
    });

    test('should initialize API with correct parameters', () {
      expect(api.apiUrl, equals('https://test.example.com/api'));
      expect(api.log, isFalse);
    });

    test('should initialize with default parameters', () {
      final defaultApi = API(apiUrl: 'https://test.com/api');

      expect(defaultApi.apiUrl, equals('https://test.com/api'));
      expect(defaultApi.log, isFalse);
      expect(defaultApi.getHeaders, isNull);
    });

    test('should initialize with headers callback', () {
      Map<String, String> headersCallback(String url) => {
        'Custom-Header': 'value',
        'URL': url,
      };

      final apiWithHeaders = API(
        apiUrl: 'https://test.com/api',
        getHeaders: headersCallback,
      );

      expect(apiWithHeaders.getHeaders, isNotNull);
      final headers = apiWithHeaders.getHeaders!('test-url');
      expect(headers['Custom-Header'], equals('value'));
      expect(headers['URL'], equals('test-url'));
    });

    test('should handle logging configuration', () {
      final loggedApi = API(apiUrl: 'https://test.com/api', log: true);

      expect(loggedApi.log, isTrue);
    });
  });

  group('APIResponse Tests', () {
    test('should create successful response with all parameters', () {
      const headers = {'Content-Type': 'application/json'};
      const response = APIResponse<Map<String, dynamic>>(
        true,
        'Operation successful',
        200,
        value: {'data': 'test'},
        body: {'raw': 'response'},
        headers: headers,
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Operation successful'));
      expect(response.statusCode, equals(200));
      expect(response.value, equals({'data': 'test'}));
      expect(response.body, equals({'raw': 'response'}));
      expect(response.headers, equals(headers));
      expect(response.errors, isNull);
    });

    test('should create error response with validation errors', () {
      const errors = {
        'email': 'Invalid email format',
        'name': 'Name is required',
      };

      const response = APIResponse<String>(
        false,
        'Validation failed',
        422,
        errors: errors,
      );

      expect(response.success, isFalse);
      expect(response.message, equals('Validation failed'));
      expect(response.statusCode, equals(422));
      expect(response.value, isNull);
      expect(response.errors, equals(errors));
    });

    test('should handle different status codes correctly', () {
      const responses = [
        APIResponse<String>(true, 'OK', 200),
        APIResponse<String>(true, 'Created', 201),
        APIResponse<String>(false, 'Bad Request', 400),
        APIResponse<String>(false, 'Unauthorized', 401),
        APIResponse<String>(false, 'Forbidden', 403),
        APIResponse<String>(false, 'Not Found', 404),
        APIResponse<String>(false, 'Internal Server Error', 500),
      ];

      expect(responses[0].statusCode, equals(200));
      expect(responses[1].statusCode, equals(201));
      expect(responses[2].statusCode, equals(400));
      expect(responses[3].statusCode, equals(401));
      expect(responses[4].statusCode, equals(403));
      expect(responses[5].statusCode, equals(404));
      expect(responses[6].statusCode, equals(500));
    });

    test('should handle null values correctly', () {
      const response = APIResponse<String?>(
        true,
        'Success with null value',
        200,
        value: null,
      );

      expect(response.success, isTrue);
      expect(response.value, isNull);
      expect(response.body, isNull);
      expect(response.errors, isNull);
    });

    test('should handle empty headers correctly', () {
      const response = APIResponse<String>(true, 'Success', 200, value: 'test');

      expect(response.headers, equals(const <String, String>{}));
    });

    test('should handle response without body', () {
      const response = APIResponse<String>(
        true,
        'Success',
        200,
        value: 'test',
        body: null,
      );

      expect(response.body, isNull);
      expect(response.value, equals('test'));
    });
  });

  group('RequestType Tests', () {
    test('should handle all request types', () {
      expect(RequestType.get, equals(RequestType.get));
      expect(RequestType.post, equals(RequestType.post));
      expect(RequestType.put, equals(RequestType.put));
      expect(RequestType.patch, equals(RequestType.patch));
      expect(RequestType.delete, equals(RequestType.delete));
    });

    test('should have different enum values', () {
      final types = RequestType.values;
      expect(types, hasLength(5));
      expect(types, contains(RequestType.get));
      expect(types, contains(RequestType.post));
      expect(types, contains(RequestType.put));
      expect(types, contains(RequestType.patch));
      expect(types, contains(RequestType.delete));
    });
  });
}
