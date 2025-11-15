import 'odoo_field.dart';
import './src/extensions/map.dart';

class ModelRegistry {
  static final Map<Type, ModelRegistryItem> _registry = {};

  /// Registers a model in the registry.
  ///
  /// - [T]: The model type.
  /// - [modelName]: The name of the model in Odoo.
  /// - [fields]: The list of fields associated with the model.
  /// - [parser]: A function to parse JSON data into an instance of the model.
  ///
  /// This function is used to convert the raw JSON response from the Odoo API into a strongly-typed Dart object.
  static void registerModel<T>(
    String modelName,
    List<OdooField> fields,
    T? Function(Map<String, dynamic> json) parser,
  ) {
    _registry[T] = ModelRegistryItem<T>(
      modelName: modelName,
      fields: {for (var field in fields) field.name: field},
      parser: parser,
    );
  }

  /// Retrieves the registry item for the specified model type [T].
  ///
  /// - [T]: The model type.
  /// - Returns: The [ModelRegistryItem] associated with the model type [T].
  /// - Throws: An [Exception] if the model type [T] is not registered.
  static ModelRegistryItem<T> get<T>() {
    final registryItem = _registry[T];

    if (registryItem == null) {
      throw Exception('Model $T is not registered in the ModelRegistry');
    }

    return registryItem as ModelRegistryItem<T>;
  }

  /// Gets the model name for the specified model type [T].
  ///
  /// - [T]: The model type.
  /// - Returns: The name of the model in Odoo.
  static String getModelName<T>() => get<T>().modelName;

  /// Gets the list of fields for the specified model type [T].
  ///
  /// - [T]: The model type.
  /// - Returns: A list of [OdooField] associated with the model.
  static List<OdooField> getFields<T>() => get<T>().fields.values.toList();

  /// Gets the list of field names for the specified model type [T].
  ///
  /// - [T]: The model type.
  /// - Returns: A list of field names associated with the model.
  static List<String> getFieldNames<T>() => get<T>().fields.keys.toList();

  /// Gets the parser function for the specified model type [T].
  ///
  /// - [T]: The model type.
  /// - Returns: A function that parses JSON data into an instance of the model.
  static T? Function(Map<String, dynamic> json) getParser<T>() =>
      get<T>().parser;

  /// Parses a JSON map into an instance of the model type [T].
  ///
  /// - [T]: The model type.
  /// - [json]: The JSON map to parse.
  /// - Returns: An instance of the model type [T], or `null` if parsing fails.
  static T? parse<T>(Map json) {
    json = Map<String, dynamic>.from(json).clean();

    return getParser<T>()({
      for (final field in ModelRegistry.getFields<T>())
        field.name: field.parse(json[field.name]),
    });
  }
}

class ModelRegistryItem<T> {
  /// The name of the model in Odoo.
  final String modelName;

  /// A map of field names to their corresponding [OdooField] definitions.
  final Map<String, OdooField> fields;

  /// A function to parse JSON data into an instance of the model.
  final T? Function(Map<String, dynamic> json) parser;

  const ModelRegistryItem({
    required this.modelName,
    required this.fields,
    required this.parser,
  });
}
