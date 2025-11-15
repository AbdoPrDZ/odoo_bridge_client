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
    Element classElement,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (classElement is! ClassElement) {
      final name = classElement.name ?? '<unknown>';
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`. @OdooModel can only be applied to classes.',
        element: classElement,
      );
    }

    final className = classElement.name;

    // Collect fields annotated with any odoo field annotation subclasses
    final fields = <FieldInfo>[];
    for (final field in classElement.fields) {
      if (field.isStatic) continue;
      // look for metadata matching our odoo field annotation types
      for (final meta in field.metadata.annotations) {
        final value = meta.computeConstantValue();
        if (value == null) continue;
        final typeStr = value.type?.getDisplayString() ?? '';
        if (FieldKind.isOdooFieldAnnotation(typeStr)) {
          final fieldInfo = createFieldInfoFromAnnotation(field, meta, value);
          if (fieldInfo != null) {
            fields.add(fieldInfo);
          }
          break;
        }
      }
    }

    final buffer = StringBuffer();

    // Write header
    final sourceFile = buildStep.inputId.pathSegments.last;
    buffer.writeln("part of '$sourceFile';");
    buffer.writeln("");

    // Generate parser (fromJson)
    buffer.writeln(_generateFromJsonExtension(className!, fields));

    // Generate toJson
    buffer.writeln(_generateToJsonExtension(className, fields));

    return buffer.toString();
  }

  String getHelperClassName(String className) => '${className}Helper';

  /// Generates the `fromJson` extension that constructs the model using
  /// the model constructor and simple `as` casts like:
  ///
  ///   static ResUsers fromJson(Map<String, dynamic> json) => ResUsers(
  ///     id: json['id'] as int?,
  ///     name: json['name'] as String,
  ///     ...
  ///   );
  String _generateFromJsonExtension(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();

    buffer.writeln(
      'extension ${getHelperClassName(className)} on $className {',
    );
    buffer.writeln(
      '  static $className fromJson(Map<String, dynamic> json) =>',
    );
    buffer.writeln('      $className(');

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
        '        ${f.dartName}: json[\'${f.odooName}\'] as $castType,',
      );
    }

    buffer.writeln('      );');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateToJsonExtension(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('extension ${className}JsonEncoding on $className {');
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return <String, dynamic>{');
    for (final f in fields) {
      final valueExpr = _generateEncodeExpression(
        f.dartName,
        f.fieldKind,
        f.dartType,
      );
      buffer.writeln("      '${f.odooName}': $valueExpr,");
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateEncodeExpression(
    String srcExpr,
    FieldKind kind,
    String dartType,
  ) {
    // For Odoo, dates should be strings in 'yyyy-MM-dd HH:mm:ss' if needed; we leave default to toIso8601String()
    switch (kind) {
      case FieldKind.dateTime:
        return "($srcExpr == null) ? null : $srcExpr!.toIso8601String()";
      default:
        return srcExpr;
    }
  }
}
