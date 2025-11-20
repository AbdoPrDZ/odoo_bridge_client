import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../odoo_model.dart';
import 'metadata.dart';

Builder odooModelHelperGeneratorFactory(BuilderOptions options) =>
    LibraryBuilder(
      const OdooModelHelperGenerator(),
      generatedExtension: '.model_helper.g.dart',
    );

class OdooModelHelperGenerator extends GeneratorForAnnotation<OdooModel> {
  const OdooModelHelperGenerator();

  @override
  FutureOr<String?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final name = element.name ?? '<unknown>';
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`. @OdooModel can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name!;

    // Collect fields annotated with any odoo field annotation subclasses
    final fields = <FieldInfo>[];
    for (final field in element.fields) {
      if (field.isStatic) continue;
      // look for metadata matching our odoo field annotation types
      for (final meta in field.metadata.annotations) {
        final obj = meta.computeConstantValue();
        if (obj == null || obj.constructorInvocation == null) continue;
        // print(meta.element!.displayName);

        if (obj.type != null && FieldInfo.isOdooFieldAnnotation(obj)) {
          fields.add(FieldInfo.fromConstructorInvocation(field, meta, obj));
          break;
        }
      }
    }

    String odooModelName = annotation.read('modelName').stringValue;

    final buffer = StringBuffer();

    // Write header
    final sourceFile = buildStep.inputId.pathSegments.last;
    buffer.writeln("part of '$sourceFile';");
    buffer.writeln("");

    buffer.writeln(
      'extension ${getHelperClassName(className)} on $className {',
    );

    // Generate getOdooModelItem function
    buffer.writeln(_generateGetOdooModelItemFunction(odooModelName));

    // Generate parser (fromJson) static function
    buffer.writeln(_generateFromJsonFunction(className, fields));

    // Generate toJson function
    buffer.writeln(_generateToJsonFunction(className, fields));

    // Generate searchRead static function
    buffer.writeln(_generateSearchReadFunction(className, fields));

    // Generate read static function
    buffer.writeln(_generateReadFunction(className, fields));

    // Generate create static function
    buffer.writeln(_generateCreateFunction(className, fields));

    // Generate exists function
    buffer.writeln(_generateExistsFunction(className, fields));

    // Generate save function
    buffer.writeln(_generateSaveFunction(className, fields));

    // Generate unlink function
    buffer.writeln(_generateUnlinkFunction(className, fields));

    buffer.writeln('}');

    return buffer.toString();
  }

  String getHelperClassName(String className) => '${className}Helper';

  String _generateGetOdooModelItemFunction(String odooModelName) {
    final buffer = StringBuffer();
    buffer.writeln('OdooModelItem toOdooModelItem() => OdooModelItem(');
    buffer.writeln("  id: id!,");
    buffer.writeln("  displayName: name,");
    buffer.writeln("  odooModel: '$odooModelName',");
    buffer.writeln(');');
    return buffer.toString();
  }

  /// Generates the `fromJson` extension that constructs the model using
  /// the model constructor and simple `as` casts like:
  ///
  ///   static ResUsers fromJson(Map<String, dynamic> json) => ResUsers(
  ///     id: json['id'] as int?,
  ///     name: json['name'] as String,
  ///     ...
  ///   );
  String _generateFromJsonFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();

    buffer.writeln('static $className fromJson(Map<String, dynamic> json) =>');
    buffer.writeln('    $className(');

    for (final f in fields) {
      // Normalize dart type and preserve nullability
      final declared = f.dartType.trim();
      // Some analyzer outputs include library prefixes; just keep last identifier portion
      // e.g. "core.String?" or "String?" -> we want "String?" (but keep '?')
      final simpleType = declared.split('.').last;
      final nullable = simpleType.endsWith('?') ? '?' : '';
      final baseType = simpleType.replaceAll('?', '');

      // If user expects DateTime typed cast exactly as in example use direct cast
      // (we DO NOT automatically parse strings to DateTime here; we follow your requested format).
      final castType = '$baseType$nullable';

      buffer.writeln(
        '      ${f.dartName}: json[\'${f.odooName}\'] as $castType,',
      );
    }

    buffer.writeln('    );');

    return buffer.toString();
  }

  String _generateToJsonFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('Map<String, dynamic> toJson() => {');
    for (final f in fields) {
      final valueExpr = _generateEncodeExpression(className, f);
      buffer.writeln("   '${f.odooName}': $valueExpr,");
    }
    buffer.writeln('};');
    return buffer.toString();
  }

  String _generateEncodeExpression(String className, FieldInfo field) {
    final buffer = StringBuffer();
    buffer.write('ModelRegistry.toJsonValue<$className>(');
    buffer.write("'${field.odooName}', ${field.dartName})");
    return buffer.toString();
  }

  String _generateSearchReadFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('static Future<APIResponse<List<$className>>> searchRead(');
    buffer.writeln('  Odoo odoo, {');
    buffer.writeln('  List<dynamic> domain = const [],');
    buffer.writeln('  List<String>? fields,');
    buffer.writeln('  int? limit,');
    buffer.writeln('  int offset = 0,');
    buffer.writeln('  String? order,');
    buffer.writeln('}) => odoo.searchRead<$className>(');
    buffer.writeln('  domain: domain,');
    buffer.writeln('  fields: fields,');
    buffer.writeln('  limit: limit,');
    buffer.writeln('  offset: offset,');
    buffer.writeln('  order: order,');
    buffer.writeln(');');
    return buffer.toString();
  }

  String _generateReadFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('static Future<APIResponse<List<$className>>> read(');
    buffer.writeln('  Odoo odoo,');
    buffer.writeln('  List<int> ids, {');
    buffer.writeln('  List<String>? fields,');
    buffer.writeln('  int offset = 0,');
    buffer.writeln('  int? limit,');
    buffer.writeln('  String? order,');
    buffer.writeln('}) => odoo.read<$className>(');
    buffer.writeln('  ids,');
    buffer.writeln('  fields: fields,');
    buffer.writeln('  offset: offset,');
    buffer.writeln('  limit: limit,');
    buffer.writeln('  order: order,');
    buffer.writeln(');');
    return buffer.toString();
  }

  String _generateExistsFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('Future<bool> exists(Odoo odoo) async {');
    buffer.writeln('  if (id == null) {');
    buffer.writeln('    return false;');
    buffer.writeln('  }');
    buffer.writeln('  final response = await odoo.exists<$className>([id!]);');
    buffer.writeln('  return response.success && response.value == true;');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateCreateFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('static Future<APIResponse<List<$className>>> create(');
    buffer.writeln('  Odoo odoo,');
    buffer.writeln('  $className item,');
    buffer.writeln(') => odoo.create<$className>(item.toJson());');
    return buffer.toString();
  }

  String _generateSaveFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('Future<APIResponse<bool>> save(Odoo odoo) async {');
    buffer.writeln('  if (id == null) {');
    buffer.writeln('    final response = await create(odoo, this);');
    buffer.writeln(
      '    return response.copyWith<bool>(value: response.success);',
    );
    buffer.writeln('  } else {');
    buffer.writeln('    return await odoo.write<$className>([id!], toJson());');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateUnlinkFunction(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('Future<APIResponse<bool>> unlink(Odoo odoo) =>');
    buffer.writeln('    odoo.unlink<$className>([id!]);');
    return buffer.toString();
  }
}
