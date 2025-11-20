import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';

import 'metadata.dart';

/// Global collector to gather all models/field parsers across all build steps
final _collectedModels = <ModelMeta>[];
final _collectedParsers = <ClassElement>{};

Builder odooModelRegisterGeneratorFactory(BuilderOptions options) =>
    _OdooRegistryBuilder();

class _OdooRegistryBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    '.dart': ['.registry.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Clear previous collections
    _collectedModels.clear();
    _collectedParsers.clear();

    // Extract model assets from exports
    final modelsAssets = await _extractModelAssetsFromExports(buildStep);

    // Scan assets for model classes
    await _scanAssetsForModels(buildStep, modelsAssets);

    // Generate registry file
    await _generateRegistryFile(buildStep);
  }

  /// Extracts model asset IDs from export statements in the input file
  Future<List<AssetId>> _extractModelAssetsFromExports(
    BuildStep buildStep,
  ) async {
    final modelsAssets = <AssetId>[];
    final source = await buildStep.readAsString(buildStep.inputId);
    final lines = source.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('export ') && trimmedLine.contains('.dart')) {
        final exportPath = _extractExportPath(trimmedLine);
        if (exportPath != null) {
          final assetId = _resolveAssetId(buildStep, exportPath);
          modelsAssets.add(assetId);
        }
      }
    }

    return modelsAssets;
  }

  /// Extracts the file path from an export statement line
  String? _extractExportPath(String line) {
    // Simple string extraction for export path
    final singleQuoteStart = line.indexOf("'");
    final doubleQuoteStart = line.indexOf('"');

    if (singleQuoteStart != -1) {
      final endQuote = line.indexOf("'", singleQuoteStart + 1);
      if (endQuote != -1) {
        final exportPath = line.substring(singleQuoteStart + 1, endQuote);
        return exportPath.endsWith('.dart') ? exportPath : null;
      }
    } else if (doubleQuoteStart != -1) {
      final endQuote = line.indexOf('"', doubleQuoteStart + 1);
      if (endQuote != -1) {
        final exportPath = line.substring(doubleQuoteStart + 1, endQuote);
        return exportPath.endsWith('.dart') ? exportPath : null;
      }
    }

    return null;
  }

  /// Resolves a relative export path to an absolute AssetId
  AssetId _resolveAssetId(BuildStep buildStep, String exportPath) {
    final currentDir = buildStep.inputId.path.split('/');
    currentDir.removeLast(); // Remove filename
    final resolvedPath = '${currentDir.join('/')}/$exportPath';
    return AssetId(buildStep.inputId.package, resolvedPath);
  }

  /// Scans the provided assets for model classes and collects their metadata
  Future<void> _scanAssetsForModels(
    BuildStep buildStep,
    List<AssetId> modelsAssets,
  ) async {
    for (final asset in modelsAssets) {
      try {
        final lib = await buildStep.resolver.libraryFor(asset);
        await _scanLibraryForModels(lib);
        await _scanLibraryForFieldParsers(lib);
      } catch (e) {
        // Skip assets that can't be resolved (e.g., Dart SDK libraries)
        continue;
      }
    }
  }

  /// Scans a library for model classes and adds them to the collection
  Future<void> _scanLibraryForModels(LibraryElement lib) async {
    for (final classElement in lib.classes) {
      final modelMeta = _extractModelMetadata(classElement);
      if (modelMeta != null) {
        _collectedModels.add(modelMeta);
      }
    }
  }

  /// Scans a library for field parser classes and adds them to the collection
  Future<void> _scanLibraryForFieldParsers(LibraryElement lib) async {
    for (final classElement in lib.classes) {
      final parserElement = _extractFieldParserElement(classElement);
      if (parserElement != null) {
        _collectedParsers.add(parserElement);
      }
    }
  }

  /// Extracts model metadata from a class element, returns null if not a model
  ModelMeta? _extractModelMetadata(ClassElement classElement) {
    final modelAnn = _getModelAnnotation(classElement);
    if (modelAnn == null) return null;

    final modelName = modelAnn.getField('modelName')?.toStringValue();
    if (modelName == null) return null;

    final fields = _extractFieldMetadata(classElement);

    if (fields.isEmpty) return null;

    final className = classElement.name;
    return ModelMeta(className!, modelName, fields, "${className}Helper");
  }

  /// Extracts field parser metadata from a class element, returns null if not a parser
  ClassElement? _extractFieldParserElement(ClassElement classElement) {
    final parserAnn = _getParserAnnotation(classElement);
    if (parserAnn == null) return null;

    return classElement;
  }

  /// Extracts field metadata from a class element
  List<FieldInfo> _extractFieldMetadata(ClassElement classElement) {
    final fields = <FieldInfo>[];

    for (final field in classElement.fields) {
      if (field.isStatic) continue;

      for (final meta in field.metadata.annotations) {
        final obj = meta.computeConstantValue();
        if (obj == null || obj.constructorInvocation == null) continue;

        if (obj.type != null && FieldInfo.isOdooFieldAnnotation(obj)) {
          fields.add(FieldInfo.fromConstructorInvocation(field, meta, obj));
          break;
        }
      }
    }

    return fields;
  }

  /// Generates the registry file with all collected models
  Future<void> _generateRegistryFile(BuildStep buildStep) async {
    final inputPath = buildStep.inputId.path;
    final output = buildStep.inputId.changeExtension('.registry.g.dart');

    final buffer = StringBuffer();
    _writeFileHeader(buffer, inputPath);
    _writeRegistryClass(buffer);

    await buildStep.writeAsString(output, buffer.toString());
  }

  /// Writes the file header and part declaration
  void _writeFileHeader(StringBuffer buffer, String inputPath) {
    buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    buffer.writeln("// Auto-generated registry for all Odoo models");
    buffer.writeln();
    buffer.writeln("part of '${inputPath.split('/').last}';");
    buffer.writeln();
  }

  /// Writes the registry class with all model registrations
  void _writeRegistryClass(StringBuffer buffer) {
    buffer.writeln("class OdooModelsRegistry {");
    buffer.writeln("  static void registerAll() {");

    _writeCustomFieldParsersRegistration(buffer);
    _writeModelsRegistration(buffer);

    buffer.writeln("  }");
    buffer.writeln("}");
  }

  /// Writes registration code for custom field parsers
  void _writeCustomFieldParsersRegistration(StringBuffer buffer) {
    if (_collectedParsers.isEmpty) return;

    buffer.writeln("    // Register custom field parsers");
    for (final element in _collectedParsers) {
      buffer.writeln("    OdooFieldParser.registerParser(${element.name}());");
    }
  }

  void _writeModelsRegistration(StringBuffer buffer) {
    if (_collectedModels.isEmpty) return;

    buffer.writeln();
    buffer.writeln("    // Register Odoo models");
    for (final m in _collectedModels) {
      _writeModelRegistration(buffer, m);
    }
  }

  /// Writes a single model registration
  void _writeModelRegistration(StringBuffer buffer, ModelMeta model) {
    buffer.writeln("    // Register model: ${model.modelName}");
    buffer.writeln(
      "    ModelRegistry.registerModel<${model.className}>('${model.modelName}', [",
    );

    for (final field in model.fields) {
      buffer.writeln("      ${field.fieldCtor()},");
    }

    buffer.writeln("    ], ${model.helperClass}.fromJson);");
    buffer.writeln();
  }

  DartObject? _getModelAnnotation(Element e) {
    for (final meta in e.metadata.annotations) {
      final obj = meta.computeConstantValue();
      if (obj?.type?.getDisplayString() == 'OdooModel') return obj;
    }
    return null;
  }

  DartObject? _getParserAnnotation(Element e) {
    for (final meta in e.metadata.annotations) {
      final obj = meta.computeConstantValue();
      if (obj?.type?.getDisplayString() == 'OdooFieldParser') return obj;
    }
    return null;
  }
}
