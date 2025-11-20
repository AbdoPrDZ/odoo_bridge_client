import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

class ModelMeta {
  final String className;
  final String modelName;
  final List<FieldInfo> fields;
  final String helperClass;

  const ModelMeta(
    this.className,
    this.modelName,
    this.fields,
    this.helperClass,
  );
}

class FieldInfo {
  final ElementAnnotation meta;
  final String dartName;
  final String odooName;
  final String dartType;
  final bool nullable;
  final dynamic defaultValue;
  final Map<String, dynamic> extraParams;

  FieldInfo({
    required this.meta,
    required this.dartName,
    required this.odooName,
    required this.dartType,
    required this.nullable,
    required this.defaultValue,
    required this.extraParams,
  });

  static FieldInfo fromConstructorInvocation(
    FieldElement element,
    ElementAnnotation meta,
    DartObject value,
  ) {
    final invocation = value.constructorInvocation!;
    final odooName =
        value.getField('name')?.toStringValue() ??
        invocation.positionalArguments.firstOrNull?.toStringValue() ??
        invocation.namedArguments['name']?.toStringValue();
    final nullable =
        value.getField('nullable')?.toBoolValue() ??
        invocation.namedArguments['nullable']?.toBoolValue() ??
        false;
    final defaultValue =
        value.getField('defaultValue') ??
        invocation.namedArguments['defaultValue'];

    if (odooName == null) {
      throw Exception('Odoo field name is required for field: ${element.name}');
    }

    return FieldInfo(
      meta: meta,
      dartName: element.name!,
      odooName: odooName,
      dartType: element.type.getDisplayString(),
      nullable: nullable,
      defaultValue: defaultValue?.toAnyValue(),
      extraParams: {
        for (final entry in invocation.namedArguments.entries)
          if (!['name', 'nullable', 'defaultValue'].contains(entry.key))
            entry.key: entry.value.toAnyValue(),
      },
    );
  }

  static bool isOdooFieldAnnotation(DartObject obj) {
    final typeStr = obj.type!.getDisplayString();
    final result =
        typeStr.startsWith('OdooField') ||
        typeStr.startsWith('OdooIntegerField') ||
        typeStr.startsWith('OdooCharField') ||
        typeStr.startsWith('OdooFloatField') ||
        typeStr.startsWith('OdooDateTimeField') ||
        typeStr.startsWith('OdooBooleanField') ||
        typeStr.startsWith('OdooMany2OneField') ||
        typeStr.startsWith('OdooOne2ManyField');
    return result;
  }

  String fieldCtor() {
    final nullableParam = nullable ? ', nullable: true' : '';
    final defaultValueParam = defaultValue != null
        ? ', defaultValue: ${_formatDefaultValue(defaultValue)}'
        : '';

    String extraParamsStr = '';
    extraParams.forEach((key, value) {
      extraParamsStr += ', $key: ${_formatDefaultValue(value)}';
    });

    return "${meta.element!.displayName}('$odooName'$defaultValueParam$nullableParam$extraParamsStr)";
  }

  String _formatDefaultValue(dynamic value) {
    if (value is String) {
      return "'$value'";
    } else {
      return value.toString();
    }
  }
}

extension DartObjectExtension on DartObject {
  dynamic toAnyValue() =>
      toStringValue() ??
      toBoolValue() ??
      toIntValue() ??
      toDoubleValue() ??
      toListValue()?.cast<dynamic>() ??
      toMapValue()?.cast<dynamic, dynamic>() ??
      toSetValue()?.cast<dynamic>() ??
      toRecordValue() ??
      toTypeValue() ??
      toSymbolValue() ??
      toFunctionValue();
}
