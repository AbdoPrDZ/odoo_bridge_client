import 'odoo_model_registry.dart';
import 'models/res_users.dart';
import 'src/api/api.dart';

export 'odoo_model.dart';
export 'odoo_model_registry.dart';
export 'src/api/api.dart';
export 'models/models.dart';

/// Default RPC function mappings.
const Map<String, String> DEFAULT_RPC_FUNCTIONS = {
  'search': 'app_search',
  'search_read': 'app_search_read',
  'search_count': 'app_search_count',
  'read': 'app_read',
  'create': 'app_create',
  'write': 'app_write',
  'unlink': 'app_unlink',
  'copy': 'app_copy',
  'fields_get': 'app_fields_get',
};

class Odoo {
  /// Base URL of the Odoo server.
  final String baseUrl;

  /// Target name for the Odoo API.
  final String targetName;

  /// API version to use.
  final int version;

  final Map<String, String> rpcFunctions;

  String? _token;

  Odoo({
    required this.baseUrl,
    required this.targetName,
    this.version = 1,
    this.rpcFunctions = DEFAULT_RPC_FUNCTIONS,
  });

  API get _api => API(
    apiUrl: "$baseUrl/api/v$version/$targetName",
    log: true,
    getHeaders: (url) => {
      "Accept": "application/json",
      if (_token != null) 'Authorization': 'Bearer $_token',
    },
  );

  /// Gets the authentication token.
  ///
  /// - Returns: The authentication token as a [String].
  /// - Throws an [Exception] if not authenticated.
  String get token {
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please authenticate first.');
    }

    return _token!;
  }

  ResUsers? _currentUser;

  /// Checks if the client is authenticated.
  bool get isAuthenticated => _currentUser != null;

  /// Gets the current authenticated user.
  ///
  /// - Returns: The authenticated [ResUsers] object.
  /// - Throws an [Exception] if not authenticated.
  ResUsers get currentUser {
    if (!isAuthenticated) {
      throw Exception('Not authenticated. Please authenticate first.');
    }

    return _currentUser!;
  }

  /// Tests the API connection.
  ///
  /// - Returns: A [Future] that resolves to `true` if the connection is successful, otherwise `false`.
  Future<bool> test() async => (await _api.get(
    'info',
    headers: {'Content-Type': 'application/json'},
  )).success;

  /// Authenticates the user.
  ///
  /// - [login]: The user's login (username or email).
  /// - [password]: The user's password.
  /// - [token]: An existing authentication token.
  /// - Returns: An [APIResponse] containing the authenticated [ResUsers] object.
  Future<APIResponse<ResUsers>> authenticate({
    String? login,
    String? password,
    String? token,
  }) async {
    assert(
      (login != null && password != null) || token != null,
      'Either login and password or token must be provided for authentication.',
    );

    if (token != null) {
      _token = token;
      final response = await getUser();

      /// Check if authentication failed and no login/password provided to retry using them
      if (!response.success && login == null && password == null) {
        _token = null;
        return response;
      }
    }

    final response = await _api.post(
      'authenticate',
      data: {
        'req_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'login': login,
        'password': password,
      },
      headers: {'Content-Type': 'application/json'},
    );

    if (response.success &&
        response.value is Map &&
        response.value.containsKey('token')) {
      _token = response.value['token'];

      return await getUser();
    }

    return APIResponse<ResUsers>(
      false,
      response.message,
      response.statusCode,
      errors: response.errors,
    );
  }

  /// Retrieves the current authenticated user.
  ///
  /// - Returns: An [APIResponse] containing the authenticated [ResUsers] object.
  /// - Throws: An [Exception] if the user data is invalid.
  Future<APIResponse<ResUsers>> getUser() async {
    final response = await call<ResUsers, ResUsers>(
      'get_current_user',
      parseResponse: (value) {
        if (value is Map) {
          return ModelRegistry.parse<ResUsers>(value)!;
        }

        throw Exception('Invalid user data');
      },
    );

    if (response.success) {
      _currentUser = response.value;
    }

    return response;
  }

  /// Generic method to call Odoo RPC methods.
  ///
  /// - [RT]: The expected response value type.
  /// - [MT]: The model type associated with the RPC method.
  /// - [method]: The RPC method name to call.
  /// - [args]: Positional arguments for the RPC method.
  /// - [kwArgs]: Keyword arguments for the RPC method.
  /// - [parseResponse]: Optional function to parse the response value.
  /// - Returns: An [APIResponse] containing the response value of type [RT].
  Future<APIResponse<RT>> call<RT, MT>(
    String method, {
    List<dynamic> args = const [],
    Map<String, dynamic> kwArgs = const {},
    RT Function(dynamic value)? parseResponse,
  }) => _api.post<RT>(
    'rpc/${ModelRegistry.getModelName<MT>()}/$method',
    data: {'args': args, 'kwargs': kwArgs},
    headers: {'Content-Type': 'application/json'},
    parseResponse: parseResponse,
  );

  /// Searches for records of type [MT] based on the provided [domain] criteria.
  ///
  /// - [MT]: The model type to search.
  /// - [domain]: The search criteria as a list (Odoo domain format).
  /// - Returns: An [APIResponse] containing a list of records of type [MT].
  Future<APIResponse<List<MT>>> searchRead<MT>({
    List<dynamic> domain = const [],
    List<String>? fields,
    int offset = 0,
    int? limit,
    String? order,
  }) => call<List<MT>, MT>(
    rpcFunctions['search_read']!,
    args: [domain],
    kwArgs: {
      'fields': ModelRegistry.getFieldNames<MT>(),
      if (limit != null) 'limit': limit,
      'offset': offset,
      if (order != null) 'order_by': order,
    },
    parseResponse: (value) {
      if (value is List) {
        return value.map((e) {
          if (e is Map) {
            return ModelRegistry.parse<MT>(e)!;
          } else {
            throw Exception('Invalid user data');
          }
        }).toList();
      }

      throw Exception('Invalid response data');
    },
  );

  /// Creates a new record of type [MT] with the provided [values].
  ///
  /// - [MT]: The model type to create.
  /// - [values]: The field values for the new record.
  /// - Returns: An [APIResponse] containing the ID of the created record.
  Future<APIResponse<List<MT>>> create<MT>(Map<String, dynamic> values) =>
      call<List<MT>, MT>(
        rpcFunctions['create']!,
        args: [values],
        parseResponse: (value) {
          if (value is List) {
            return value.map((e) {
              if (e is Map) {
                return ModelRegistry.parse<MT>(e)!;
              } else {
                throw Exception('Invalid record data');
              }
            }).toList();
          }
          throw Exception('Invalid read response');
        },
      );

  /// Reads records of type [MT] by their IDs.
  ///
  /// - [MT]: The model type to read.
  /// - [ids]: List of record IDs to read.
  /// - [fields]: Optional list of field names to read. If null, reads all fields.
  /// - Returns: An [APIResponse] containing a list of records of type [MT].
  Future<APIResponse<List<MT>>> read<MT>(
    List<int> ids, {
    List<String>? fields,
    int offset = 0,
    int? limit,
    String? order,
  }) => call<List<MT>, MT>(
    rpcFunctions['read']!,
    args: [ids],
    kwArgs: {
      'fields': fields ?? ModelRegistry.getFieldNames<MT>(),
      'offset': offset,
      if (limit != null) 'limit': limit,
      if (order != null) 'order': order,
    },
    parseResponse: (value) {
      if (value is List) {
        return value.map((e) {
          if (e is Map) {
            return ModelRegistry.parse<MT>(e)!;
          } else {
            throw Exception('Invalid record data');
          }
        }).toList();
      }
      throw Exception('Invalid read response');
    },
  );

  /// Updates records of type [MT] with the provided [values].
  ///
  /// - [MT]: The model type to update.
  /// - [ids]: List of record IDs to update.
  /// - [values]: The field values to update.
  /// - Returns: An [APIResponse] containing true if successful.
  Future<APIResponse<bool>> write<MT>(
    List<int> ids,
    Map<String, dynamic> values,
  ) => call<bool, MT>(
    rpcFunctions['write']!,
    args: [ids, values],
    parseResponse: (value) {
      if (value is bool) {
        return value;
      }
      throw Exception('Invalid write response');
    },
  );

  /// Deletes records of type [MT] by their IDs.
  ///
  /// - [MT]: The model type to delete from.
  /// - [ids]: List of record IDs to delete.
  /// - Returns: An [APIResponse] containing true if successful.
  Future<APIResponse<bool>> unlink<MT>(List<int> ids) => call<bool, MT>(
    rpcFunctions['unlink']!,
    args: [ids],
    parseResponse: (value) {
      if (value is bool) {
        return value;
      }
      throw Exception('Invalid unlink response');
    },
  );

  /// Searches for record IDs of type [MT] based on the provided [domain] criteria.
  ///
  /// - [MT]: The model type to search.
  /// - [domain]: The search criteria as a list (Odoo domain format).
  /// - [offset]: Number of records to skip.
  /// - [limit]: Maximum number of records to return.
  /// - [order]: Sort order specification.
  /// - Returns: An [APIResponse] containing a list of record IDs.
  Future<APIResponse<List<int>>> search<MT>(
    List<dynamic> domain, {
    int offset = 0,
    int? limit,
    String? order,
  }) => call<List<int>, MT>(
    rpcFunctions['search']!,
    args: [domain],
    kwArgs: {
      'offset': offset,
      if (limit != null) 'limit': limit,
      if (order != null) 'order': order,
    },
    parseResponse: (value) {
      if (value is List) {
        return value.map((e) => e as int).toList();
      }
      throw Exception('Invalid search response');
    },
  );

  /// Counts records of type [MT] based on the provided [domain] criteria.
  ///
  /// - [MT]: The model type to count.
  /// - [domain]: The search criteria as a list (Odoo domain format).
  /// - Returns: An [APIResponse] containing the record count.
  Future<APIResponse<int>> searchCount<MT>(List<dynamic> domain) =>
      call<int, MT>(
        rpcFunctions['search_count']!,
        args: [domain],
        parseResponse: (value) {
          if (value is int) {
            return value;
          }
          throw Exception('Invalid search_count response');
        },
      );

  /// Checks if records exist for the given [domain] criteria.
  ///
  /// - [MT]: The model type to check.
  /// - [domain]: The search criteria as a list (Odoo domain format).
  /// - Returns: An [APIResponse] containing true if records exist, false otherwise.
  Future<APIResponse<bool>> exists<MT>(List<dynamic> domain) async {
    final countResponse = await searchCount<MT>(domain);
    if (countResponse.success) {
      return APIResponse<bool>(
        true,
        'Exists check completed',
        countResponse.statusCode,
        value: countResponse.value! > 0,
      );
    }
    return APIResponse<bool>(
      false,
      countResponse.message,
      countResponse.statusCode,
      errors: countResponse.errors,
    );
  }

  /// Gets the fields information for a model type [MT].
  ///
  /// - [MT]: The model type to get fields for.
  /// - [attributes]: List of field attributes to retrieve.
  /// - Returns: An [APIResponse] containing the fields information.
  Future<APIResponse<Map<String, dynamic>>> getFields<MT>({
    List<String> attributes = const ['string', 'help', 'type'],
  }) => call<Map<String, dynamic>, MT>(
    rpcFunctions['fields_get']!,
    kwArgs: {'attributes': attributes},
    parseResponse: (value) {
      if (value is Map<String, dynamic>) {
        return value;
      }
      throw Exception('Invalid fields_get response');
    },
  );

  /// Copies a record of type [MT] with optional field overrides.
  ///
  /// - [MT]: The model type to copy.
  /// - [id]: The ID of the record to copy.
  /// - [defaults]: Optional field values to override in the copy.
  /// - Returns: An [APIResponse] containing the ID of the copied record.
  Future<APIResponse<int>> copy<MT>(int id, {Map<String, dynamic>? defaults}) {
    final kwArgs = <String, dynamic>{};
    if (defaults != null) {
      kwArgs['default'] = defaults;
    }

    return call<int, MT>(
      rpcFunctions['copy']!,
      args: [id],
      kwArgs: kwArgs,
      parseResponse: (value) {
        if (value is int) {
          return value;
        } else if (value is Map && value.containsKey('id')) {
          return value['id'] as int;
        }
        throw Exception('Invalid copy response');
      },
    );
  }
}
