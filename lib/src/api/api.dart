import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:http/http.dart' as http;

part 'request.dart';
part 'response.dart';

class API {
  final String apiUrl;
  final Map<String, String> Function(String url)? getHeaders;
  final bool log;

  const API({required this.apiUrl, this.getHeaders, this.log = false});

  static API? _instance;

  static bool get hasInstance => _instance != null;

  static API get instance {
    if (!hasInstance) {
      throw Exception('API instance has not initialized yet');
    }

    return _instance!;
  }

  static initInstance({
    required String apiUrl,
    Map<String, String> Function(String url)? getHeaders,
    bool log = false,
    bool override = false,
  }) {
    if (hasInstance && !override) {
      throw Exception('API instance has already initialized');
    }

    _instance = API(apiUrl: apiUrl, getHeaders: getHeaders, log: log);
  }

  Future<APIResponse<T>> request<T>(
    String target,
    RequestType type, {
    Map<String, dynamic>? data,
    List<http.MultipartFile> files = const [],
    Function(int bytes, int totalBytes)? onFilesUpload,
    bool? log,
    Map<String, String> headers = const {},
    bool appendHeader = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Encoding? encoding,
    T Function(dynamic value)? parseResponse,
  }) {
    final url = '$apiUrl/$target';

    return APIRequest<T>(
      url,
      type: type,
      data: data,
      files: files,
      onFilesUpload: onFilesUpload,
      log: log ?? this.log,
      headers: appendHeader
          ? {...(getHeaders?.call(url) ?? {}), ...headers}
          : headers,
      errorsField: errorsField,
      decodeErrors: decodeErrors,
      encoding: encoding,
      parseResponse: parseResponse,
    ).send();
  }

  Future<APIResponse<T>> get<T>(
    String target, {
    Map<String, dynamic>? data,
    List<http.MultipartFile> files = const [],
    Function(int bytes, int totalBytes)? onFilesUpload,
    bool? log,
    Map<String, String> headers = const {},
    bool appendHeader = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Encoding? encoding,
    T Function(dynamic value)? parseResponse,
  }) => request<T>(
    target,
    RequestType.get,
    data: data,
    files: files,
    onFilesUpload: onFilesUpload,
    log: log,
    headers: headers,
    errorsField: errorsField,
    decodeErrors: decodeErrors,
    encoding: encoding,
    parseResponse: parseResponse,
  );

  Future<APIResponse<T>> post<T>(
    String target, {
    Map<String, dynamic>? data,
    List<http.MultipartFile> files = const [],
    Function(int bytes, int totalBytes)? onFilesUpload,
    bool? log,
    Map<String, String> headers = const {},
    bool appendHeader = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Encoding? encoding,
    T Function(dynamic value)? parseResponse,
  }) => request<T>(
    target,
    RequestType.post,
    data: data,
    files: files,
    onFilesUpload: onFilesUpload,
    log: log,
    headers: headers,
    errorsField: errorsField,
    decodeErrors: decodeErrors,
    encoding: encoding,
    parseResponse: parseResponse,
  );

  Future<APIResponse<T>> put<T>(
    String target, {
    Map<String, dynamic>? data,
    List<http.MultipartFile> files = const [],
    Function(int bytes, int totalBytes)? onFilesUpload,
    bool? log,
    Map<String, String> headers = const {},
    bool appendHeader = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Encoding? encoding,
    T Function(dynamic value)? parseResponse,
  }) => request<T>(
    target,
    RequestType.put,
    data: data,
    files: files,
    onFilesUpload: onFilesUpload,
    log: log,
    headers: headers,
    errorsField: errorsField,
    decodeErrors: decodeErrors,
    encoding: encoding,
    parseResponse: parseResponse,
  );

  Future<APIResponse<T>> patch<T>(
    String target, {
    Map<String, dynamic>? data,
    List<http.MultipartFile> files = const [],
    Function(int bytes, int totalBytes)? onFilesUpload,
    bool? log,
    Map<String, String> headers = const {},
    bool appendHeader = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Encoding? encoding,
    T Function(dynamic value)? parseResponse,
  }) => request<T>(
    target,
    RequestType.patch,
    data: data,
    files: files,
    onFilesUpload: onFilesUpload,
    log: log,
    headers: headers,
    errorsField: errorsField,
    decodeErrors: decodeErrors,
    encoding: encoding,
    parseResponse: parseResponse,
  );

  Future<APIResponse<T>> delete<T>(
    String target, {
    Map<String, dynamic>? data,
    List<http.MultipartFile> files = const [],
    Function(int bytes, int totalBytes)? onFilesUpload,
    bool? log,
    Map<String, String> headers = const {},
    bool appendHeader = true,
    String errorsField = 'errors',
    Map<String, String> Function(Map errors)? decodeErrors,
    Encoding? encoding,
    T Function(dynamic value)? parseResponse,
  }) => request<T>(
    target,
    RequestType.delete,
    data: data,
    files: files,
    onFilesUpload: onFilesUpload,
    log: log,
    headers: headers,
    errorsField: errorsField,
    decodeErrors: decodeErrors,
    encoding: encoding,
    parseResponse: parseResponse,
  );
}
