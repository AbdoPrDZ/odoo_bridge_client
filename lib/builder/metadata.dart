import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

class ModelMeta {
  final String className;
  final String modelName;
  final List<FieldInfo> fields;
  final String helperClass;

  ModelMeta(this.className, this.modelName, this.fields, this.helperClass);
}

class FieldInfo {
  final String dartName;
  final String odooName;
  final String dartType;
  final bool nullable;
  final dynamic defaultValue;
  final FieldKind fieldKind;

  FieldInfo({
    required this.dartName,
    required this.odooName,
    required this.dartType,
    required this.nullable,
    required this.defaultValue,
    required this.fieldKind,
  });
}

enum FieldKind {
  integer,
  float,
  dateTime,
  boolean,
  char;

  static bool isOdooFieldAnnotation(String typeStr) =>
      typeStr.endsWith('OdooIntegerField') ||
      typeStr.endsWith('OdooCharField') ||
      typeStr.endsWith('OdooFloatField') ||
      typeStr.endsWith('OdooDateTimeField') ||
      typeStr.endsWith('OdooBooleanField');

  static FieldKind detectFieldKind(DartObject obj) {
    final type = obj.type?.getDisplayString() ?? '';
    if (type.endsWith('OdooIntegerField')) return integer;
    if (type.endsWith('OdooCharField')) return char;
    if (type.endsWith('OdooFloatField')) return float;
    if (type.endsWith('OdooDateTimeField')) return dateTime;
    if (type.endsWith('OdooBooleanField')) return boolean;

    throw Exception('Unknown field kind for type: $type');
  }

  String fieldCtor(
    String odooName, {
    bool nullable = false,
    dynamic defaultValue,
  }) {
    final nullableParam = nullable ? ', nullable: true' : '';
    final defaultValueParam = defaultValue != null
        ? ', defaultValue: ${_formatDefaultValue(defaultValue)}'
        : '';

    switch (this) {
      case integer:
        return "OdooIntegerField('$odooName'$defaultValueParam$nullableParam)";
      case char:
        return "OdooCharField('$odooName'$defaultValueParam$nullableParam)";
      case float:
        return "OdooFloatField('$odooName'$defaultValueParam$nullableParam)";
      case dateTime:
        return "OdooDateTimeField('$odooName'$defaultValueParam$nullableParam)";
      case boolean:
        return "OdooBooleanField('$odooName'$defaultValueParam$nullableParam)";
    }
  }

  String _formatDefaultValue(dynamic value) {
    if (value is String) {
      return "'$value'";
    } else if (value is bool || value is int || value is double) {
      return value.toString();
    } else {
      return value.toString();
    }
  }

  @override
  String toString() {
    switch (this) {
      case integer:
        return 'OdooIntegerField';
      case float:
        return 'OdooFloatField';
      case dateTime:
        return 'OdooDateTimeField';
      case boolean:
        return 'OdooBooleanField';
      case char:
        return 'OdooCharField';
    }
  }
}

/// Helper function to create FieldInfo from annotation metadata
FieldInfo? createFieldInfoFromAnnotation(
  FieldElement field,
  ElementAnnotation meta,
  DartObject annotationValue,
) {
  final typeStr = annotationValue.type?.getDisplayString() ?? '';
  if (!FieldKind.isOdooFieldAnnotation(typeStr)) {
    return null;
  }

  // Extract field name from annotation
  String? annotationFieldName;

  // Method 1: Try constant value extraction
  final constantName = annotationValue.getField('name')?.toStringValue();
  if (constantName != null) {
    annotationFieldName = constantName;
  } else {
    // Method 2: Parse the annotation source directly
    final source = meta.toSource();
    // Extract the string from @OdooXxxField('string_value') or @OdooXxxField('string_value', ...)
    final match = RegExp(r"@Odoo\w+Field\('([^']+)'").firstMatch(source);
    if (match != null) {
      annotationFieldName = match.group(1);
    }
  }

  final odooName = annotationFieldName ?? field.name!;

  // Extract nullable from annotation
  bool nullable = false;
  final nullableField = annotationValue.getField('nullable');
  if (nullableField != null && !nullableField.isNull) {
    nullable = nullableField.toBoolValue() ?? false;
  } else {
    // Try to parse from source as fallback
    final source = meta.toSource();
    if (source.contains('nullable: true')) {
      nullable = true;
    }
  }

  // Extract defaultValue from annotation
  dynamic defaultValue;
  final defaultValueField = annotationValue.getField('defaultValue');
  if (defaultValueField != null && !defaultValueField.isNull) {
    // Try to extract the appropriate type based on field kind
    final fieldKind = FieldKind.detectFieldKind(annotationValue);
    switch (fieldKind) {
      case FieldKind.integer:
        defaultValue = defaultValueField.toIntValue();
        break;
      case FieldKind.float:
        defaultValue = defaultValueField.toDoubleValue();
        break;
      case FieldKind.char:
        defaultValue = defaultValueField.toStringValue();
        break;
      case FieldKind.boolean:
        defaultValue = defaultValueField.toBoolValue();
        break;
      case FieldKind.dateTime:
        // DateTime defaults are typically null or handled by DateTime.now()
        // For now, we'll leave this as null since DateTime constants are complex
        defaultValue = null;
        break;
    }
  } else {
    // Try to parse from source as fallback
    final source = meta.toSource();
    final defaultValueMatch = RegExp(
      r'defaultValue:\s*([^,\)]+)',
    ).firstMatch(source);
    if (defaultValueMatch != null) {
      final valueStr = defaultValueMatch.group(1)?.trim();
      if (valueStr != null) {
        // Try to parse different types
        if (valueStr == 'true' || valueStr == 'false') {
          defaultValue = valueStr == 'true';
        } else if (RegExp(r'^\d+$').hasMatch(valueStr)) {
          defaultValue = int.tryParse(valueStr);
        } else if (RegExp(r'^\d+\.\d+$').hasMatch(valueStr)) {
          defaultValue = double.tryParse(valueStr);
        } else if (valueStr.startsWith("'") && valueStr.endsWith("'")) {
          defaultValue = valueStr.substring(1, valueStr.length - 1);
        }
      }
    }
  }

  return FieldInfo(
    dartName: field.name!,
    odooName: odooName,
    dartType: field.type.getDisplayString(),
    nullable: nullable,
    defaultValue: defaultValue,
    fieldKind: FieldKind.detectFieldKind(annotationValue),
  );
}
