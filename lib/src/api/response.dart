part of 'api.dart';

class APIResponse<T> {
  final bool success;
  final String message;
  final int statusCode;
  final Map<String, String>? errors;
  final T? value;
  final dynamic body;
  final Map<String, String> headers;

  const APIResponse(
    this.success,
    this.message,
    this.statusCode, {
    this.errors,
    this.body,
    this.value,
    this.headers = const {},
  });

  static APIResponse<T> fromResponse<T>(
    String response,
    int statusCode, {
    bool log = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Map<String, String> headers = const {},
    T Function(dynamic value)? parseResponse,
  }) {
    try {
      Map responseData = jsonDecode(response);

      if (!responseData.containsKey('message')) {
        switch (statusCode) {
          case 200:
            responseData["message"] = "No response message";
            break;
          case 400:
            responseData["message"] = "Error[$statusCode]: Bad request";
            break;
          case 403:
            responseData["message"] =
                "Error[$statusCode]: Unauthorized response";
            break;
          default:
            responseData["message"] =
                "response failed with status: $statusCode";
        }
      }

      Map values = {
        for (var key in responseData.keys)
          if (!["success", "message", errorsField].contains(key))
            key: responseData[key],
      };

      Map<String, String> errors = responseData.containsKey(errorsField)
          ? decodeErrors?.call(responseData[errorsField]) ??
                Map<String, String>.from(responseData[errorsField]!)
          : {};

      dynamic rawValue = values.length == 1
          ? values[values.keys.first]
          : values.isNotEmpty
          ? values
          : null;

      T? value;

      if (parseResponse != null && rawValue != null) {
        value = parseResponse(rawValue);
      } else {
        value = rawValue as T?;
      }

      if (log) {
        dev.log(
          "[ODOO_BRIDGE_CLIENT.API.Response] - reqErrors: ${jsonEncode(errors)}",
        );
        dev.log(
          "[ODOO_BRIDGE_CLIENT.API.Response] - reqValue: ${jsonEncode(rawValue)}",
        );
      }

      return APIResponse<T>(
        responseData["success"] ?? statusCode == 200,
        responseData["message"] ?? 'No response message',
        statusCode,
        errors: errors,
        body: responseData,
        value: value,
        headers: headers,
      );
    } catch (e) {
      String strBody = response.toString();
      String body = strBody.substring(
        0,
        strBody.length < 50 ? strBody.length : 50,
      );

      if (log) {
        dev.log("[ODOO_BRIDGE_CLIENT.API.Response] - reqErr: $e");
        dev.log("[ODOO_BRIDGE_CLIENT.API.Response] - resBody: $body");
      }

      return APIResponse(false, "body: $body...", statusCode, body: strBody);
    }
  }

  APIResponse<NT> copyWith<NT>({
    bool? success,
    String? message,
    int? statusCode,
    Map<String, String>? errors,
    NT? value,
    dynamic body,
    Map<String, String>? headers,
  }) => APIResponse<NT>(
    success ?? this.success,
    message ?? this.message,
    statusCode ?? this.statusCode,
    errors: errors ?? this.errors,
    value: value ?? this.value as NT?,
    body: body ?? this.body,
    headers: headers ?? this.headers,
  );
}
