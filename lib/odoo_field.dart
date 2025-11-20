import 'package:odoo_bridge_client/odoo_bridge_client.dart';

part 'odoo_field_parser.dart';

class OdooField<T> {
  final String name;
  final T? defaultValue;
  final bool nullable;
  final String parser;

  const OdooField(
    this.name, {
    this.defaultValue,
    this.nullable = false,
    required this.parser,
  });

  T? checkDefaultValue() {
    if (!nullable && defaultValue == null) {
      throw Exception(
        'OdooField $name is not nullable and has no default value',
      );
    }
    return defaultValue;
  }

  T? parse(dynamic rawValue) {
    if (rawValue == null) {
      return checkDefaultValue();
    }

    return OdooFieldParser.getParser(parser).parse(this, rawValue);
  }

  JT toJsonValue<JT>(JT value) {
    if (value == null) {
      if (!nullable && defaultValue == null) {
        throw Exception(
          'OdooField $name is not nullable and cannot be null in toJsonValue',
        );
      }
      return defaultValue as JT;
    }

    return OdooFieldParser.getParser(parser).toJsonValue(this, value);
  }
}

class OdooIntegerField extends OdooField<int> {
  const OdooIntegerField(super.name, {super.defaultValue, super.nullable})
    : super(parser: 'int');
}

class OdooCharField extends OdooField<String> {
  const OdooCharField(super.name, {super.defaultValue, super.nullable = false})
    : super(parser: 'char');
}

class OdooFloatField extends OdooField<double> {
  const OdooFloatField(super.name, {super.defaultValue, super.nullable = false})
    : super(parser: 'float');
}

class OdooBooleanField extends OdooField<bool> {
  const OdooBooleanField(super.name) : super(parser: 'bool');
}

class OdooDateTimeField extends OdooField<DateTime> {
  const OdooDateTimeField(
    super.name, {
    super.defaultValue,
    super.nullable = false,
  }) : super(parser: 'datetime');
}

class OdooOne2ManyField extends OdooField<List<OdooModelItem>> {
  final String relatedModel;

  const OdooOne2ManyField(
    super.name, {
    super.defaultValue,
    super.nullable = false,
    required this.relatedModel,
  }) : super(parser: 'one2many');
}

class OdooMany2OneField extends OdooField<OdooModelItem> {
  final String relatedModel;

  const OdooMany2OneField(
    super.name, {
    super.defaultValue,
    super.nullable = false,
    required this.relatedModel,
  }) : super(parser: 'many2one');
}
