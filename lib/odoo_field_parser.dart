part of 'odoo_field.dart';

class OdooFieldParser {
  final String name;
  // final Type type;

  const OdooFieldParser(this.name);

  dynamic parse(OdooField field, dynamic rawValue) {
    throw UnimplementedError('Parse method not implemented for $name');
  }

  dynamic toJsonValue(OdooField field, dynamic value) {
    throw UnimplementedError('toJsonValue method not implemented for $name');
  }

  static final Map<String, OdooFieldParser> _parsers = {
    'int': const OdooIntegerFieldParser(),
    'char': const OdooCharFieldParser(),
    'double': const OdooFloatFieldParser(),
    'bool': const OdooBooleanFieldParser(),
    'datetime': const OdooDateTimeFieldParser(),
    'one2many': const OdooOne2ManyFieldParser(),
    'many2one': const OdooMany2OneFieldParser(),
  };

  static OdooFieldParser getParser(String parserType) {
    if (!_parsers.containsKey(parserType)) {
      throw Exception('No parser registered for type $parserType');
    }

    return _parsers[parserType]!;
  }

  static void registerParser(OdooFieldParser parser) {
    _parsers[parser.name] = parser;
  }
}

class OdooIntegerFieldParser extends OdooFieldParser {
  const OdooIntegerFieldParser() : super('int');

  @override
  int parse(OdooField field, dynamic rawValue) {
    if (rawValue is int) {
      return rawValue;
    } else if (rawValue is String) {
      return int.parse(rawValue);
    } else {
      throw Exception('Invalid raw value for OdooIntegerField');
    }
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (value is int) {
      return value;
    } else {
      throw Exception('Invalid value for OdooIntegerField toJsonValue');
    }
  }
}

class OdooCharFieldParser extends OdooFieldParser {
  const OdooCharFieldParser() : super('char');

  @override
  String parse(OdooField field, dynamic rawValue) {
    if (rawValue is String) {
      return rawValue;
    } else {
      throw Exception('Invalid raw value for OdooCharField');
    }
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (value is String) {
      return value;
    } else {
      throw Exception('Invalid value for OdooCharField toJsonValue');
    }
  }
}

class OdooFloatFieldParser extends OdooFieldParser {
  const OdooFloatFieldParser() : super('float');

  @override
  double parse(OdooField field, dynamic rawValue) {
    if (rawValue is double) {
      return rawValue;
    } else if (rawValue is int) {
      return rawValue.toDouble();
    } else if (rawValue is String) {
      return double.parse(rawValue);
    } else {
      throw Exception('Invalid raw value for OdooFloatField');
    }
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (value is double) {
      return value;
    } else {
      throw Exception('Invalid value for OdooFloatField toJsonValue');
    }
  }
}

class OdooBooleanFieldParser extends OdooFieldParser {
  const OdooBooleanFieldParser() : super('bool');

  @override
  bool parse(OdooField field, dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    } else if (rawValue is String &&
        ['true', 'false'].contains(rawValue.toLowerCase())) {
      return rawValue.toLowerCase() == 'true';
    } else if (rawValue is int) {
      return rawValue != 0;
    } else {
      throw Exception('Invalid raw value for OdooBooleanField');
    }
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (value is bool) {
      return value;
    } else {
      throw Exception('Invalid value for OdooBooleanField toJsonValue');
    }
  }
}

class OdooDateTimeFieldParser extends OdooFieldParser {
  const OdooDateTimeFieldParser() : super('datetime');

  @override
  DateTime parse(OdooField field, dynamic rawValue) {
    if (rawValue is DateTime) {
      return rawValue;
    } else if (rawValue is String) {
      return DateTime.parse(rawValue);
    } else {
      throw Exception('Invalid raw value for OdooDateTimeField');
    }
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    } else {
      throw Exception('Invalid value for OdooDateTimeField toJsonValue');
    }
  }
}

class OdooOne2ManyFieldParser extends OdooFieldParser {
  const OdooOne2ManyFieldParser() : super('one2many');

  @override
  List<OdooModelItem> parse(OdooField field, dynamic rawValue) {
    if (field is! OdooOne2ManyField) {
      throw Exception('Field is not of type OdooOne2ManyField');
    }

    if (rawValue is List) {
      return rawValue.map((e) {
        int? id;
        String? name;

        dynamic rawId = e;
        if (e is List && e.isNotEmpty) {
          name = e.length > 1 ? e[1].toString() : null;
          rawId = e[0];
        }

        if (rawId is int) {
          id = rawId;
        } else if (rawId is String) {
          id = int.parse(rawId);
        } else if (rawId != null) {
          throw Exception('Invalid item in One2Many field list item $rawId');
        }

        return OdooModelItem(
          id: id,
          odooModel: field.relatedModel,
          displayName: name ?? '${field.relatedModel}($id)',
        );
      }).toList();
    } else {
      throw Exception('Invalid raw value for OdooOne2ManyField');
    }
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (field is! OdooOne2ManyField) {
      throw Exception('Field is not of type OdooOne2ManyField');
    }

    if (value is List<OdooModelItem>) {
      return value.map((item) => item.id).toList();
    } else {
      throw Exception('Invalid value for OdooOne2ManyField toJsonValue');
    }
  }
}

class OdooMany2OneFieldParser extends OdooFieldParser {
  const OdooMany2OneFieldParser() : super('many2one');

  @override
  OdooModelItem parse(OdooField field, dynamic rawValue) {
    if (field is! OdooMany2OneField) {
      throw Exception('Field is not of type OdooMany2OneField');
    }

    dynamic rawId = rawValue;
    int? id;
    String? name;

    if (rawValue is List && rawValue.isNotEmpty) {
      rawId = rawValue[0];
      if (rawValue.length > 1) {
        name = rawValue[1].toString();
      }
    }

    if (rawId is int) {
      id = rawId;
    } else if (rawId is String) {
      id = int.parse(rawId);
    } else {
      throw Exception('Invalid id value in Many2One field item');
    }

    return OdooModelItem(
      id: id,
      odooModel: field.relatedModel,
      displayName: name ?? '${field.relatedModel}($id)',
    );
  }

  @override
  dynamic toJsonValue(OdooField field, dynamic value) {
    if (value is OdooModelItem) {
      return value.id;
    } else {
      throw Exception('Invalid value for OdooMany2OneField toJsonValue');
    }
  }
}

class OdooModelItem {
  final int? id;
  final String odooModel;
  final String displayName;

  const OdooModelItem({
    this.id,
    required this.odooModel,
    required this.displayName,
  });

  Future<MT> fetchValue<MT>(Odoo odoo) async {
    if (id == null) {
      throw Exception('Cannot fetch value for $odooModel with null id');
    }

    final response = await odoo.read<MT>([id!]);
    if (response.success &&
        response.value != null &&
        response.value!.isNotEmpty) {
      return response.value!.first;
    } else {
      throw Exception('Failed to fetch value for $odooModel with id $id');
    }
  }

  @override
  String toString() => displayName;
}

extension OdooModelItemsExtension on List<OdooModelItem> {
  Future<APIResponse<List<MT>>> fetchValues<MT>(Odoo odoo) =>
      odoo.read<MT>(map((e) => e.id!).toList());
}
