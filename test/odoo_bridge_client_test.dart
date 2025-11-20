import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_bridge_client/odoo_bridge_client.dart';

// Mock Models for Testing
class TestUser {
  int? id;
  String name;
  String? email;
  int age;
  bool active;
  DateTime? createdAt;
  double? score;

  TestUser({
    this.id,
    required this.name,
    this.email,
    this.age = 0,
    this.active = true,
    this.createdAt,
    this.score,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'age': age,
    'active': active,
    'created_at': createdAt?.toIso8601String(),
    'score': score,
  };

  static TestUser fromJson(Map<String, dynamic> json) => TestUser(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'],
    age: json['age'] ?? 0,
    active: json['active'] ?? true,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    score: json['score']?.toDouble(),
  );
}

void main() {
  group('OdooField Tests', () {
    group('OdooIntegerField', () {
      test('should parse valid integer values correctly', () {
        const field = OdooIntegerField('test_field');

        expect(field.parse(42), equals(42));
        expect(field.parse('123'), equals(123));
      });

      test('should return null for null values when nullable', () {
        const field = OdooIntegerField('test_field', nullable: true);

        expect(field.parse(null), isNull);
      });

      test('should return default value for null when not nullable', () {
        const field = OdooIntegerField('test_field', defaultValue: 100);

        expect(field.parse(null), equals(100));
      });

      test(
        'should throw exception for null when not nullable and no default',
        () {
          const field = OdooIntegerField('test_field');

          expect(() => field.parse(null), throwsException);
        },
      );

      test('should throw exception for invalid values', () {
        const field = OdooIntegerField('test_field');

        expect(() => field.parse('invalid'), throwsException);
        expect(() => field.parse(true), throwsException);
        expect(() => field.parse([1, 2, 3]), throwsException);
      });

      test('should store field properties correctly', () {
        const field = OdooIntegerField(
          'custom_name',
          defaultValue: 42,
          nullable: true,
        );

        expect(field.name, equals('custom_name'));
        expect(field.defaultValue, equals(42));
        expect(field.nullable, isTrue);
      });
    });

    group('OdooCharField', () {
      test('should parse valid string values correctly', () {
        const field = OdooCharField('test_field');

        expect(field.parse('hello'), equals('hello'));
        expect(field.parse(''), equals(''));
      });

      test('should return null for null values when nullable', () {
        const field = OdooCharField('test_field', nullable: true);

        expect(field.parse(null), isNull);
      });

      test('should return default value for null when not nullable', () {
        const field = OdooCharField('test_field', defaultValue: 'default');

        expect(field.parse(null), equals('default'));
      });

      test('should throw exception for boolean false (not supported)', () {
        const field = OdooCharField('test_field', nullable: true);

        // OdooCharField doesn't handle boolean false - it only handles strings
        expect(() => field.parse(false), throwsException);
      });
      test(
        'should throw exception for null when not nullable and no default',
        () {
          const field = OdooCharField('test_field');

          expect(() => field.parse(null), throwsException);
        },
      );
    });

    group('OdooBooleanField', () {
      test('should parse boolean values correctly', () {
        const field = OdooBooleanField('test_field');

        expect(field.parse(true), isTrue);
        expect(field.parse(false), isFalse);
      });

      test('should parse integer values correctly', () {
        const field = OdooBooleanField('test_field');

        expect(field.parse(1), isTrue);
        expect(field.parse(0), isFalse);
        expect(field.parse(42), isTrue);
      });

      test('should parse string values correctly', () {
        const field = OdooBooleanField('test_field');

        expect(field.parse('true'), isTrue);
        expect(field.parse('false'), isFalse);
        expect(field.parse('TRUE'), isTrue);
        expect(field.parse('FALSE'), isFalse);
      });

      test('should return null for null values', () {
        const field = OdooBooleanField('test_field');

        expect(field.parse(null), isNull);
      });

      test('should throw exception for invalid values', () {
        const field = OdooBooleanField('test_field');

        expect(() => field.parse('invalid'), throwsException);
        expect(() => field.parse([true, false]), throwsException);
      });
    });

    group('OdooFloatField', () {
      test('should parse float values correctly', () {
        const field = OdooFloatField('test_field');

        expect(field.parse(3.14), equals(3.14));
        expect(field.parse(42), equals(42.0));
        expect(field.parse('3.14'), equals(3.14));
      });

      test('should return null for null values when nullable', () {
        const field = OdooFloatField('test_field', nullable: true);

        expect(field.parse(null), isNull);
      });

      test('should return default value for null when not nullable', () {
        const field = OdooFloatField('test_field', defaultValue: 0.0);

        expect(field.parse(null), equals(0.0));
      });

      test('should throw exception for invalid values', () {
        const field = OdooFloatField('test_field');

        expect(() => field.parse('invalid'), throwsException);
      });
    });

    group('OdooDateTimeField', () {
      test('should parse DateTime values correctly', () {
        const field = OdooDateTimeField('test_field');
        final now = DateTime.now();

        expect(field.parse(now), equals(now));
      });

      test('should parse ISO8601 string values correctly', () {
        const field = OdooDateTimeField('test_field');
        final dateString = '2024-01-15T10:30:00Z';
        final expectedDate = DateTime.parse(dateString);

        expect(field.parse(dateString), equals(expectedDate));
      });

      test('should return null for null values when nullable', () {
        const field = OdooDateTimeField('test_field', nullable: true);

        expect(field.parse(null), isNull);
      });

      test('should return default value when provided', () {
        final defaultDate = DateTime(2024, 1, 1);
        final field = OdooDateTimeField(
          'test_field',
          defaultValue: defaultDate,
        );

        expect(field.parse(null), equals(defaultDate));
      });

      test('should throw exception for invalid string formats', () {
        const field = OdooDateTimeField('test_field');

        expect(() => field.parse('not-a-valid-date-format'), throwsException);
        expect(() => field.parse('completely-invalid'), throwsException);
      });
    });

    // TODO: Fix this test or remove it
    // group('OdooField Base Class', () {
    //   test('should throw exception when calling parse on base class', () {
    //     const field = OdooField<String>('test_field');

    //     expect(() => field.parse('test'), throwsException);
    //   });

    //   test('should handle checkDefaultValue correctly', () {
    //     const nullableField = OdooField<String>('test', nullable: true);
    //     const fieldWithDefault = OdooField<String>(
    //       'test',
    //       defaultValue: 'default',
    //     );
    //     const nonNullableField = OdooField<String>('test', nullable: false);

    //     expect(nullableField.checkDefaultValue(), isNull);
    //     expect(fieldWithDefault.checkDefaultValue(), equals('default'));
    //     expect(() => nonNullableField.checkDefaultValue(), throwsException);
    //   });
    // });
  });

  group('ModelRegistry Tests', () {
    test('should register and retrieve models correctly', () {
      final fields = <OdooField>[
        const OdooIntegerField('id'),
        const OdooCharField('name'),
        const OdooCharField('email', nullable: true),
      ];

      ModelRegistry.registerModel<TestUser>(
        'test.user',
        fields,
        TestUser.fromJson,
      );

      expect(ModelRegistry.getModelName<TestUser>(), equals('test.user'));
      expect(ModelRegistry.getFields<TestUser>(), hasLength(3));
      expect(ModelRegistry.getFieldNames<TestUser>(), contains('id'));
      expect(ModelRegistry.getFieldNames<TestUser>(), contains('name'));
      expect(ModelRegistry.getFieldNames<TestUser>(), contains('email'));
    });

    test('should throw exception for unregistered models', () {
      expect(() => ModelRegistry.getModelName<String>(), throwsException);
      expect(() => ModelRegistry.getFields<String>(), throwsException);
      expect(() => ModelRegistry.getFieldNames<String>(), throwsException);
    });

    test('should parse JSON correctly with registered model', () {
      final fields = <OdooField>[
        const OdooIntegerField('id'),
        const OdooCharField('name'),
        const OdooCharField('email', nullable: true),
        const OdooIntegerField('age', defaultValue: 0),
      ];

      ModelRegistry.registerModel<TestUser>(
        'test.user',
        fields,
        TestUser.fromJson,
      );

      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 25,
      };

      final user = ModelRegistry.parse<TestUser>(json);

      expect(user, isNotNull);
      expect(user!.id, equals(1));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.age, equals(25));
    });

    test('should handle JSON with missing fields correctly', () {
      final fields = <OdooField>[
        const OdooIntegerField('id'),
        const OdooCharField('name'),
        const OdooCharField('email', nullable: true),
        const OdooIntegerField('age', defaultValue: 0),
      ];

      ModelRegistry.registerModel<TestUser>(
        'test.user',
        fields,
        TestUser.fromJson,
      );

      final json = {
        'id': 1,
        'name': 'John Doe',
        // missing email and age
      };

      final user = ModelRegistry.parse<TestUser>(json);

      expect(user, isNotNull);
      expect(user!.id, equals(1));
      expect(user.name, equals('John Doe'));
      expect(user.email, isNull);
      expect(user.age, equals(0)); // default value
    });
  });

  group('APIResponse Tests', () {
    test('should create successful response correctly', () {
      const response = APIResponse<String>(
        true,
        'Success',
        200,
        value: 'test data',
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Success'));
      expect(response.statusCode, equals(200));
      expect(response.value, equals('test data'));
      expect(response.errors, isNull);
    });

    test('should create error response correctly', () {
      const errors = {'field1': 'Error message'};
      const response = APIResponse<String>(
        false,
        'Error occurred',
        400,
        errors: errors,
      );

      expect(response.success, isFalse);
      expect(response.message, equals('Error occurred'));
      expect(response.statusCode, equals(400));
      expect(response.value, isNull);
      expect(response.errors, equals(errors));
    });

    test('should handle response with body data', () {
      const bodyData = {'key': 'value'};
      const response = APIResponse<String>(
        true,
        'Success',
        200,
        value: 'test',
        body: bodyData,
      );

      expect(response.body, equals(bodyData));
    });

    test('should handle response with headers', () {
      const headers = {'Content-Type': 'application/json'};
      const response = APIResponse<String>(
        true,
        'Success',
        200,
        headers: headers,
      );

      expect(response.headers, equals(headers));
    });
  });

  group('Odoo Client Tests', () {
    late Odoo odoo;

    setUp(() {
      odoo = Odoo(
        baseUrl: 'https://test.odoo.com',
        targetName: 'test-db',
        version: 1,
      );
    });

    test('should initialize with correct parameters', () {
      expect(odoo.baseUrl, equals('https://test.odoo.com'));
      expect(odoo.targetName, equals('test-db'));
      expect(odoo.version, equals(1));
      expect(odoo.isAuthenticated, isFalse);
    });

    test('should initialize with default version', () {
      final defaultOdoo = Odoo(
        baseUrl: 'https://test.odoo.com',
        targetName: 'test-db',
      );

      expect(defaultOdoo.version, equals(1));
    });

    test(
      'should throw exception when accessing token without authentication',
      () {
        expect(() => odoo.token, throwsException);

        try {
          odoo.token;
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), contains('Not authenticated'));
        }
      },
    );
  });

  group('Domain Format Tests', () {
    test('should handle empty domain correctly', () {
      const domain = <dynamic>[];
      expect(domain, isEmpty);
    });

    test('should handle simple criteria correctly', () {
      const domain = [
        ['name', '=', 'John Doe'],
      ];
      expect(domain, hasLength(1));
      expect(domain[0], equals(['name', '=', 'John Doe']));
    });

    test('should handle multiple AND criteria correctly', () {
      const domain = [
        ['name', 'ilike', 'John'],
        ['email', '!=', false],
        ['active', '=', true],
      ];
      expect(domain, hasLength(3));
      expect(domain[0], equals(['name', 'ilike', 'John']));
      expect(domain[1], equals(['email', '!=', false]));
      expect(domain[2], equals(['active', '=', true]));
    });

    test('should handle OR criteria correctly', () {
      const domain = [
        '|',
        ['name', 'ilike', 'John'],
        ['email', 'ilike', 'john@example.com'],
      ];
      expect(domain, hasLength(3));
      expect(domain[0], equals('|'));
      expect(domain[1], equals(['name', 'ilike', 'John']));
      expect(domain[2], equals(['email', 'ilike', 'john@example.com']));
    });

    test('should handle complex AND/OR criteria correctly', () {
      const domain = [
        '|',
        ['name', 'ilike', 'John'],
        '&',
        ['email', '!=', false],
        ['active', '=', true],
      ];
      expect(domain, hasLength(5));
      expect(domain[0], equals('|'));
      expect(domain[1], equals(['name', 'ilike', 'John']));
      expect(domain[2], equals('&'));
      expect(domain[3], equals(['email', '!=', false]));
      expect(domain[4], equals(['active', '=', true]));
    });

    test('should handle nested boolean operators', () {
      const domain = [
        '&',
        '|',
        ['name', 'ilike', 'John'],
        ['name', 'ilike', 'Jane'],
        ['active', '=', true],
      ];
      expect(domain, hasLength(5));
      expect(domain[0], equals('&'));
      expect(domain[1], equals('|'));
    });

    test('should handle comparison operators correctly', () {
      const domain = [
        ['age', '>=', 18],
        ['score', '>', 75.5],
        ['created_date', '<', '2024-01-01'],
        [
          'name',
          'in',
          ['John', 'Jane', 'Bob'],
        ],
        [
          'email',
          'not in',
          ['test@example.com'],
        ],
      ];
      expect(domain, hasLength(5));
      expect(domain[0], equals(['age', '>=', 18]));
      expect(domain[1], equals(['score', '>', 75.5]));
    });
  });

  group('Field Validation Tests', () {
    test('should validate nullable field constraints', () {
      const nullableField = OdooIntegerField('test', nullable: true);
      const nonNullableField = OdooIntegerField('test', nullable: false);

      expect(nullableField.nullable, isTrue);
      expect(nonNullableField.nullable, isFalse);
      expect(() => nullableField.parse(null), returnsNormally);
      expect(() => nonNullableField.parse(null), throwsException);
    });

    test('should validate default value behavior', () {
      const fieldWithDefault = OdooIntegerField('test', defaultValue: 42);
      const fieldWithoutDefault = OdooIntegerField('test');

      expect(fieldWithDefault.defaultValue, equals(42));
      expect(fieldWithoutDefault.defaultValue, isNull);
      expect(fieldWithDefault.parse(null), equals(42));
      expect(() => fieldWithoutDefault.parse(null), throwsException);
    });

    test('should validate field name mapping', () {
      const field = OdooIntegerField('custom_field_name');

      expect(field.name, equals('custom_field_name'));
    });

    test('should validate field combinations correctly', () {
      const field = OdooCharField(
        'test',
        nullable: true,
        defaultValue: 'default',
      );

      expect(field.nullable, isTrue);
      expect(field.defaultValue, equals('default'));
      expect(field.name, equals('test'));
    });
  });

  group('Type Safety Tests', () {
    test('should maintain type safety for different field types', () {
      const intField = OdooIntegerField('int_field');
      const stringField = OdooCharField('string_field');
      const boolField = OdooBooleanField('bool_field');
      const floatField = OdooFloatField('float_field');
      const dateField = OdooDateTimeField('date_field');

      expect(intField.parse(42), isA<int>());
      expect(stringField.parse('test'), isA<String>());
      expect(boolField.parse(true), isA<bool>());
      expect(floatField.parse(3.14), isA<double>());
      expect(dateField.parse(DateTime.now()), isA<DateTime>());
    });

    test('should handle nullable return types correctly', () {
      const nullableInt = OdooIntegerField('test', nullable: true);
      const nullableString = OdooCharField('test', nullable: true);
      const nullableFloat = OdooFloatField('test', nullable: true);
      const nullableDate = OdooDateTimeField('test', nullable: true);

      expect(nullableInt.parse(null), isNull);
      expect(nullableString.parse(null), isNull);
      expect(nullableFloat.parse(null), isNull);
      expect(nullableDate.parse(null), isNull);
    });
  });

  group('Error Handling Tests', () {
    test('should handle invalid field types gracefully', () {
      const field = OdooIntegerField('test_field');

      expect(() => field.parse('not_a_number'), throwsException);
      expect(() => field.parse([1, 2, 3]), throwsException);
      expect(() => field.parse({'key': 'value'}), throwsException);
    });

    test('should provide meaningful error messages', () {
      const field = OdooIntegerField('test_field');

      try {
        field.parse('invalid');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('FormatException'));
        expect(e.toString(), contains('Invalid'));
      }
    });

    test('should handle nullable constraints with clear messages', () {
      const field = OdooIntegerField('test_field', nullable: false);

      try {
        field.checkDefaultValue();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('is not nullable'));
        expect(e.toString(), contains('has no default value'));
        expect(e.toString(), contains('test_field'));
      }
    });

    test('should handle parsing errors for each field type', () {
      const intField = OdooIntegerField('int_field');
      const charField = OdooCharField('char_field');
      const floatField = OdooFloatField('float_field');
      const dateField = OdooDateTimeField('date_field');
      const boolField = OdooBooleanField('bool_field');

      // Test invalid values for each field type
      expect(() => intField.parse('not_int'), throwsException);
      expect(() => charField.parse(null), throwsException); // not nullable
      expect(() => floatField.parse('not_float'), throwsException);
      expect(() => dateField.parse('invalid_date'), throwsException);
      expect(() => boolField.parse('maybe'), throwsException);
    });
  });

  group('Data Type Conversion Tests', () {
    test('should handle integer field conversions correctly', () {
      const field = OdooIntegerField('test');

      expect(field.parse(42), equals(42));
      expect(field.parse('42'), equals(42));
      expect(field.parse('-10'), equals(-10));
      expect(field.parse('0'), equals(0));
    });

    test('should handle float field conversions correctly', () {
      const field = OdooFloatField('test');

      expect(field.parse(3.14), equals(3.14));
      expect(field.parse(42), equals(42.0));
      expect(field.parse('3.14'), equals(3.14));
      expect(field.parse('-2.5'), equals(-2.5));
      expect(field.parse('0.0'), equals(0.0));
    });

    test('should handle string field conversions correctly', () {
      const field = OdooCharField('test');

      expect(field.parse('hello world'), equals('hello world'));
      expect(field.parse(''), equals(''));
      expect(field.parse('123'), equals('123'));
    });

    test('should handle boolean field conversions correctly', () {
      const field = OdooBooleanField('test');

      expect(field.parse(true), isTrue);
      expect(field.parse(false), isFalse);
      expect(field.parse(1), isTrue);
      expect(field.parse(0), isFalse);
      expect(field.parse(-1), isTrue);
      expect(field.parse('true'), isTrue);
      expect(field.parse('false'), isFalse);
    });

    test('should handle datetime field conversions correctly', () {
      const field = OdooDateTimeField('test');
      final testDate = DateTime(2024, 1, 15, 10, 30, 0);

      expect(field.parse(testDate), equals(testDate));
      expect(field.parse('2024-01-15T10:30:00Z'), isA<DateTime>());
      expect(field.parse('2024-01-15T10:30:00'), isA<DateTime>());
    });
  });
}
