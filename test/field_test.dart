import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_bridge_client/odoo_field.dart';

void main() {
  group('OdooField Comprehensive Tests', () {
    group('OdooIntegerField Advanced Tests', () {
      test('should handle edge cases for integer parsing', () {
        const field = OdooIntegerField('test');

        expect(field.parse(0), equals(0));
        expect(field.parse(-1), equals(-1));
        expect(field.parse(2147483647), equals(2147483647)); // max int32
        expect(field.parse('-2147483648'), equals(-2147483648)); // min int32
      });

      test('should throw for decimal strings', () {
        const field = OdooIntegerField('test');

        expect(() => field.parse('3.14'), throwsException);
        expect(() => field.parse('1.0'), throwsException);
      });

      test('should handle whitespace in strings', () {
        const field = OdooIntegerField('test');

        expect(field.parse('  42  '), equals(42));
        expect(field.parse('\t123\n'), equals(123));
      });

      test('should validate nullable and default value combinations', () {
        const nullableWithDefault = OdooIntegerField(
          'test',
          nullable: true,
          defaultValue: 42,
        );
        const nullableWithoutDefault = OdooIntegerField('test', nullable: true);
        const nonNullableWithDefault = OdooIntegerField(
          'test',
          defaultValue: 42,
        );

        expect(nullableWithDefault.parse(null), equals(42));
        expect(nullableWithoutDefault.parse(null), isNull);
        expect(nonNullableWithDefault.parse(null), equals(42));
      });
    });

    group('OdooCharField Advanced Tests', () {
      test('should handle special characters and encoding', () {
        const field = OdooCharField('test');

        expect(field.parse('Hello 🌍'), equals('Hello 🌍'));
        expect(field.parse('Café'), equals('Café'));
        expect(field.parse('日本語'), equals('日本語'));
        expect(field.parse('Русский'), equals('Русский'));
      });

      test('should handle very long strings', () {
        const field = OdooCharField('test');
        final longString = 'A' * 10000;

        final result = field.parse(longString);
        expect(result, equals(longString));
        expect(result!.length, equals(10000));
      });

      test('should handle special escape sequences', () {
        const field = OdooCharField('test');

        expect(field.parse('Line 1\nLine 2'), equals('Line 1\nLine 2'));
        expect(field.parse('Tab\tSeparated'), equals('Tab\tSeparated'));
        expect(field.parse('Quote: "Hello"'), equals('Quote: "Hello"'));
        expect(
          field.parse("Apostrophe: 'World'"),
          equals("Apostrophe: 'World'"),
        );
      });
    });

    group('OdooBooleanField Advanced Tests', () {
      test('should handle string representations correctly', () {
        const field = OdooBooleanField('test');

        expect(field.parse('true'), isTrue);
        expect(field.parse('false'), isFalse);
        expect(field.parse('TRUE'), isTrue);
        expect(field.parse('FALSE'), isFalse);
        expect(field.parse('True'), isTrue);
        expect(field.parse('False'), isFalse);
      });

      test('should handle numeric representations correctly', () {
        const field = OdooBooleanField('test');

        expect(field.parse(1), isTrue);
        expect(field.parse(0), isFalse);
        expect(field.parse(42), isTrue);
        expect(field.parse(-1), isTrue);
        expect(field.parse(-100), isTrue);
      });

      test('should return null for null input', () {
        const field = OdooBooleanField('test');

        expect(field.parse(null), isNull);
      });

      test('should throw for invalid string values', () {
        const field = OdooBooleanField('test');

        expect(() => field.parse('yes'), throwsException);
        expect(() => field.parse('no'), throwsException);
        expect(() => field.parse('1'), throwsException);
        expect(() => field.parse('0'), throwsException);
        expect(() => field.parse('maybe'), throwsException);
      });

      test('should throw for invalid types', () {
        const field = OdooBooleanField('test');

        expect(() => field.parse([true]), throwsException);
        expect(() => field.parse({'bool': true}), throwsException);
        expect(() => field.parse(3.14), throwsException);
      });
    });

    group('OdooFloatField Advanced Tests', () {
      test('should handle various number formats', () {
        const field = OdooFloatField('test');

        expect(field.parse(3.14159), equals(3.14159));
        expect(field.parse(42), equals(42.0));
        expect(field.parse(0), equals(0.0));
        expect(field.parse(-2.5), equals(-2.5));
      });

      test('should handle string number formats', () {
        const field = OdooFloatField('test');

        expect(field.parse('3.14'), equals(3.14));
        expect(field.parse('42'), equals(42.0));
        expect(field.parse('-2.5'), equals(-2.5));
        expect(field.parse('0.0'), equals(0.0));
        expect(field.parse('.5'), equals(0.5));
      });

      test('should handle scientific notation', () {
        const field = OdooFloatField('test');

        expect(field.parse('1e2'), equals(100.0));
        expect(field.parse('2.5e-3'), equals(0.0025));
        expect(field.parse('1E+6'), equals(1000000.0));
      });

      test('should handle special float values', () {
        const field = OdooFloatField('test');

        expect(field.parse(double.infinity), equals(double.infinity));
        expect(
          field.parse(double.negativeInfinity),
          equals(double.negativeInfinity),
        );
        final nanResult = field.parse(double.nan);
        expect(nanResult!.isNaN, isTrue);
      });

      test('should throw for invalid string formats', () {
        const field = OdooFloatField('test');

        expect(() => field.parse('not_a_number'), throwsException);
        expect(() => field.parse('3.14.159'), throwsException);
        expect(() => field.parse(''), throwsException);
      });
    });

    group('OdooDateTimeField Advanced Tests', () {
      test('should handle various ISO8601 formats', () {
        const field = OdooDateTimeField('test');

        final formats = [
          '2024-01-15T10:30:00Z',
          '2024-01-15T10:30:00+00:00',
          '2024-01-15T10:30:00.123Z',
          '2024-01-15T10:30:00.123456Z',
          '2024-01-15 10:30:00',
        ];

        for (final format in formats) {
          expect(field.parse(format), isA<DateTime>());
        }
      });

      test('should preserve timezone information', () {
        const field = OdooDateTimeField('test');

        final utcDate = field.parse('2024-01-15T10:30:00Z');
        final offsetDate = field.parse('2024-01-15T10:30:00+02:00');

        expect(utcDate, isA<DateTime>());
        expect(offsetDate, isA<DateTime>());
        expect(utcDate!.isUtc || offsetDate!.isUtc, isTrue);
      });

      test('should handle edge cases', () {
        const field = OdooDateTimeField('test');

        final leapYear = field.parse('2024-02-29T00:00:00Z');
        final endOfYear = field.parse('2023-12-31T23:59:59Z');
        final startOfYear = field.parse('2024-01-01T00:00:00Z');

        expect(leapYear, isA<DateTime>());
        expect(endOfYear, isA<DateTime>());
        expect(startOfYear, isA<DateTime>());
      });

      test('should throw for invalid date formats', () {
        const field = OdooDateTimeField('test');

        expect(() => field.parse('invalid'), throwsException);
        expect(() => field.parse('not-a-date'), throwsException);
      });

      test('should handle DateTime objects directly', () {
        const field = OdooDateTimeField('test');
        final now = DateTime.now();
        final utc = DateTime.utc(2024, 1, 15, 10, 30);

        expect(field.parse(now), equals(now));
        expect(field.parse(utc), equals(utc));
      });
    });

    group('Field Properties and Metadata Tests', () {
      test('should store and retrieve field properties correctly', () {
        const intField = OdooIntegerField(
          'int_field',
          defaultValue: 42,
          nullable: true,
        );
        const charField = OdooCharField(
          'char_field',
          defaultValue: 'default',
          nullable: false,
        );
        const floatField = OdooFloatField(
          'float_field',
          defaultValue: 3.14,
          nullable: true,
        );
        const dateField = OdooDateTimeField('date_field', nullable: true);
        const boolField = OdooBooleanField('bool_field');

        expect(intField.name, equals('int_field'));
        expect(intField.defaultValue, equals(42));
        expect(intField.nullable, isTrue);

        expect(charField.name, equals('char_field'));
        expect(charField.defaultValue, equals('default'));
        expect(charField.nullable, isFalse);

        expect(floatField.name, equals('float_field'));
        expect(floatField.defaultValue, equals(3.14));
        expect(floatField.nullable, isTrue);

        expect(dateField.name, equals('date_field'));
        expect(dateField.nullable, isTrue);

        expect(boolField.name, equals('bool_field'));
      });

      test('should handle checkDefaultValue method correctly', () {
        const nullableWithDefault = OdooIntegerField(
          'test',
          nullable: true,
          defaultValue: 42,
        );
        const nullableWithoutDefault = OdooIntegerField('test', nullable: true);
        const nonNullableWithDefault = OdooIntegerField(
          'test',
          defaultValue: 42,
        );
        const nonNullableWithoutDefault = OdooIntegerField('test');

        expect(nullableWithDefault.checkDefaultValue(), equals(42));
        expect(nullableWithoutDefault.checkDefaultValue(), isNull);
        expect(nonNullableWithDefault.checkDefaultValue(), equals(42));
        expect(
          () => nonNullableWithoutDefault.checkDefaultValue(),
          throwsException,
        );
      });
    });

    group('Field Inheritance and Polymorphism Tests', () {
      test('should maintain type hierarchy correctly', () {
        const intField = OdooIntegerField('int');
        const charField = OdooCharField('char');
        const boolField = OdooBooleanField('bool');
        const floatField = OdooFloatField('float');
        const dateField = OdooDateTimeField('date');

        expect(intField, isA<OdooField<int>>());
        expect(charField, isA<OdooField<String>>());
        expect(boolField, isA<OdooField<bool>>());
        expect(floatField, isA<OdooField<double>>());
        expect(dateField, isA<OdooField<DateTime>>());
      });

      test('should handle generic field operations', () {
        const fields = <OdooField>[
          OdooIntegerField('int'),
          OdooCharField('char'),
          OdooBooleanField('bool'),
          OdooFloatField('float'),
          OdooDateTimeField('date'),
        ];

        for (final field in fields) {
          expect(field.name, isNotEmpty);
          expect(field.nullable, isA<bool>());
        }
      });
    });
  });
}
