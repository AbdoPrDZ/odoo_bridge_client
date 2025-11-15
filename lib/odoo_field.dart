class OdooField<T> {
  final String name;
  final T? defaultValue;
  final bool nullable;

  const OdooField(this.name, {this.defaultValue, this.nullable = false});

  T? checkDefaultValue() {
    if (!nullable && defaultValue == null) {
      throw Exception(
        'OdooField $name is not nullable and has no default value',
      );
    }
    return defaultValue;
  }

  T? parse(dynamic rawValue) {
    throw Exception('parse() not implemented for OdooField');
  }
}

class OdooIntegerField extends OdooField<int> {
  const OdooIntegerField(super.name, {super.defaultValue, super.nullable});

  @override
  int? parse(dynamic rawValue) {
    if (rawValue == null) {
      return checkDefaultValue();
    }

    if (rawValue is int) {
      return rawValue;
    } else if (rawValue is String) {
      return int.parse(rawValue);
    } else {
      throw Exception('Invalid raw value for OdooIntegerField');
    }
  }
}

class OdooCharField extends OdooField<String> {
  const OdooCharField(super.name, {super.defaultValue, super.nullable = false});

  @override
  String? parse(dynamic rawValue) {
    if (rawValue == null) {
      return checkDefaultValue();
    }

    if (rawValue is String) {
      return rawValue;
    } else {
      throw Exception('Invalid raw value for OdooCharField');
    }
  }
}

class OdooFloatField extends OdooField<double> {
  const OdooFloatField(
    super.name, {
    super.defaultValue,
    super.nullable = false,
  });

  @override
  double? parse(dynamic rawValue) {
    if (rawValue == null) {
      return checkDefaultValue();
    }

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
}

class OdooBooleanField extends OdooField<bool> {
  const OdooBooleanField(super.name);

  @override
  bool? parse(dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    } else if (rawValue is String &&
        ['true', 'false'].contains(rawValue.toLowerCase())) {
      return rawValue.toLowerCase() == 'true';
    } else if (rawValue is int) {
      return rawValue != 0;
    } else if (rawValue == null) {
      return null;
    } else {
      throw Exception('Invalid raw value for OdooBooleanField');
    }
  }
}

class OdooDateTimeField extends OdooField<DateTime> {
  const OdooDateTimeField(
    super.name, {
    super.defaultValue,
    super.nullable = false,
  });

  @override
  DateTime? parse(dynamic rawValue) {
    if (rawValue == null) {
      return checkDefaultValue();
    }

    if (rawValue is DateTime) {
      return rawValue;
    } else if (rawValue is String) {
      return DateTime.parse(rawValue);
    } else {
      throw Exception('Invalid raw value for OdooDateTimeField');
    }
  }
}
