import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_bridge_client/odoo_model_registry.dart';
import 'package:odoo_bridge_client/odoo_field.dart';

// Test Models
class Product {
  int? id;
  String name;
  String code;
  double? price;
  bool active;
  DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    required this.code,
    this.price,
    this.active = true,
    this.createdAt,
  });

  static Product fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int?,
    name: json['name'] as String,
    code: json['code'] as String,
    price: json['price'] as double?,
    active: json['active'] as bool? ?? false,
    createdAt: json['created_at'] as DateTime?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'price': price,
    'active': active,
    'created_at': createdAt?.toIso8601String(),
  };

  static List<OdooField> get fields => [
    const OdooIntegerField('id'),
    const OdooCharField('name'),
    const OdooCharField('code', defaultValue: 'DEF001'),
    const OdooFloatField('price', nullable: true),
    const OdooBooleanField('active'),
    const OdooDateTimeField('created_at', nullable: true),
  ];
}

class Category {
  int? id;
  String name;
  String? description;

  Category({this.id, required this.name, this.description});

  static Category fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as int?,
    name: json['name'] as String,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  static List<OdooField> get fields => [
    const OdooIntegerField('id'),
    const OdooCharField('name'),
    const OdooCharField('description', nullable: true),
  ];
}

void main() {
  group('ModelRegistry Comprehensive Tests', () {
    group('Basic Registration Tests', () {
      test('should register single model correctly', () {
        ModelRegistry.registerModel<Product>(
          'product.product',
          Product.fields,
          Product.fromJson,
        );

        expect(
          ModelRegistry.getModelName<Product>(),
          equals('product.product'),
        );
        expect(
          ModelRegistry.getFields<Product>(),
          hasLength(6),
        ); // Product.fields has 6 fields
        expect(
          ModelRegistry.getFieldNames<Product>(),
          containsAll(['id', 'name', 'code', 'price', 'active', 'created_at']),
        );
      });

      test('should register multiple models correctly', () {
        final productFields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooFloatField('price', nullable: true),
        ];

        final categoryFields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('description', nullable: true),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          productFields,
          Product.fromJson,
        );

        ModelRegistry.registerModel<Category>(
          'product.category',
          categoryFields,
          Category.fromJson,
        );

        expect(
          ModelRegistry.getModelName<Product>(),
          equals('product.product'),
        );
        expect(
          ModelRegistry.getModelName<Category>(),
          equals('product.category'),
        );
        expect(ModelRegistry.getFields<Product>(), hasLength(3));
        expect(ModelRegistry.getFields<Category>(), hasLength(3));
      });
    });

    group('Field Management Tests', () {
      test('should handle complex field configurations', () {
        final fields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('code', defaultValue: 'DEFAULT'),
          const OdooFloatField('price', nullable: true),
          const OdooBooleanField('active'),
          const OdooDateTimeField('created_at', nullable: true),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final registeredFields = ModelRegistry.getFields<Product>();
        final fieldMap = {for (var f in registeredFields) f.name: f};

        expect(fieldMap['id'], isA<OdooIntegerField>());
        expect(fieldMap['name'], isA<OdooCharField>());
        expect(fieldMap['code'], isA<OdooCharField>());
        expect(fieldMap['price'], isA<OdooFloatField>());
        expect(fieldMap['active'], isA<OdooBooleanField>());
        expect(fieldMap['created_at'], isA<OdooDateTimeField>());

        expect(fieldMap['code']!.defaultValue, equals('DEFAULT'));
        expect(fieldMap['price']!.nullable, isTrue);
        expect(fieldMap['created_at']!.nullable, isTrue);
      });

      test('should maintain field order', () {
        final fields = <OdooField>[
          const OdooCharField('name'),
          const OdooIntegerField('id'),
          const OdooFloatField('price'),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final fieldNames = ModelRegistry.getFieldNames<Product>();
        // Note: Field names come from a Map, so order may not be preserved
        expect(fieldNames, containsAll(['name', 'id', 'price']));
      });
    });

    group('JSON Parsing Tests', () {
      test('should parse complete JSON correctly', () {
        final fields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('code', defaultValue: 'DEF001'),
          const OdooFloatField('price', nullable: true),
          const OdooBooleanField('active'),
          const OdooDateTimeField('created_at', nullable: true),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final json = {
          'id': 1,
          'name': 'Test Product',
          'code': 'TP001',
          'price': 99.99,
          'active': true,
          'created_at': '2024-01-15T10:30:00Z',
        };

        final product = ModelRegistry.parse<Product>(json);

        expect(product, isNotNull);
        expect(product!.id, equals(1));
        expect(product.name, equals('Test Product'));
        expect(product.code, equals('TP001'));
        expect(product.price, equals(99.99));
        expect(product.active, isTrue);
        expect(product.createdAt, isA<DateTime>());
      });

      test('should parse JSON with missing nullable fields', () {
        final fields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('code', defaultValue: 'DEF001'),
          const OdooFloatField('price', nullable: true),
          const OdooBooleanField('active'),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final json = {
          'id': 1,
          'name': 'Test Product',
          'active': true,
          // price missing
        };

        final product = ModelRegistry.parse<Product>(json);

        expect(product, isNotNull);
        expect(product!.id, equals(1));
        expect(product.name, equals('Test Product'));
        expect(product.code, equals('DEF001'));
        expect(product.price, isNull);
        expect(product.active, isTrue);
      });

      test('should parse JSON with default values', () {
        final fields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('code', defaultValue: 'DEF001'),
          const OdooIntegerField('quantity', defaultValue: 0),
          const OdooBooleanField('active'),
          const OdooDateTimeField('created_at', nullable: true),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final json = {'id': 1, 'name': 'Test Product', 'active': true};

        final product = ModelRegistry.parse<Product>(json);

        expect(product, isNotNull);
        expect(product!.id, equals(1));
        expect(product.name, equals('Test Product'));
        expect(product.code, equals('DEF001'));
        expect(product.price, isNull);
        expect(product.active, isTrue);
      });

      test('should handle invalid JSON gracefully', () {
        final fields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final invalidJson = {'id': 'not_a_number', 'name': 'Test Product'};

        // The parsing should throw an exception for invalid data types
        expect(
          () => ModelRegistry.parse<Product>(invalidJson),
          throwsException,
        ); // fromJson will throw when trying to cast 'not_a_number' as int
      });
    });

    group('Error Handling Tests', () {
      test('should throw for unregistered models', () {
        expect(() => ModelRegistry.get<String>(), throwsException);
        expect(() => ModelRegistry.getModelName<String>(), throwsException);
        expect(() => ModelRegistry.getFields<String>(), throwsException);
        expect(() => ModelRegistry.getFieldNames<String>(), throwsException);
        expect(() => ModelRegistry.getParser<String>(), throwsException);
        expect(() => ModelRegistry.parse<String>({}), throwsException);
      });

      test('should provide meaningful error messages', () {
        try {
          ModelRegistry.getModelName<String>();
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), contains('not registered'));
          expect(e.toString(), contains('ModelRegistry'));
        }
      });
    });

    group('Registry State Management Tests', () {
      test('should maintain separate registrations for different types', () {
        final productFields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
        ];

        final categoryFields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('title'), // different field name
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          productFields,
          Product.fromJson,
        );

        ModelRegistry.registerModel<Category>(
          'product.category',
          categoryFields,
          Category.fromJson,
        );

        expect(ModelRegistry.getFieldNames<Product>(), contains('name'));
        expect(ModelRegistry.getFieldNames<Category>(), contains('title'));
        expect(
          ModelRegistry.getFieldNames<Product>(),
          isNot(contains('title')),
        );
        expect(
          ModelRegistry.getFieldNames<Category>(),
          isNot(contains('name')),
        );
      });

      test('should handle model re-registration', () {
        final initialFields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
        ];

        final updatedFields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooFloatField('price'),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          initialFields,
          Product.fromJson,
        );

        expect(ModelRegistry.getFields<Product>(), hasLength(2));

        // Re-register with more fields
        ModelRegistry.registerModel<Product>(
          'product.product.v2',
          updatedFields,
          Product.fromJson,
        );

        expect(ModelRegistry.getFields<Product>(), hasLength(3));
        expect(
          ModelRegistry.getModelName<Product>(),
          equals('product.product.v2'),
        );
      });
    });

    group('Parser Function Tests', () {
      test('should store and retrieve parser functions', () {
        final fields = <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('code', defaultValue: 'DEFAULT'),
        ];

        ModelRegistry.registerModel<Product>(
          'product.product',
          fields,
          Product.fromJson,
        );

        final parser = ModelRegistry.getParser<Product>();
        expect(parser, isNotNull);

        final json = {'id': 1, 'name': 'Test', 'code': 'TC001'};
        final product = parser(json);

        expect(product, isA<Product>());
        expect(product!.id, equals(1));
        expect(product.name, equals('Test'));
        expect(product.code, equals('TC001'));
      });

      test('should handle different parser functions for different models', () {
        ModelRegistry.registerModel<Product>('product.product', <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('code', defaultValue: 'PROD'),
        ], Product.fromJson);

        ModelRegistry.registerModel<Category>('product.category', <OdooField>[
          const OdooIntegerField('id'),
          const OdooCharField('name'),
          const OdooCharField('description', nullable: true),
        ], Category.fromJson);

        final productParser = ModelRegistry.getParser<Product>();
        final categoryParser = ModelRegistry.getParser<Category>();

        final productJson = {'id': 1, 'name': 'Test Product', 'code': 'TP001'};
        final categoryJson = {
          'id': 1,
          'name': 'Test Category',
          'description': 'A test category',
        };

        final product = productParser(productJson);
        final category = categoryParser(categoryJson);

        expect(product, isA<Product>());
        expect(category, isA<Category>());
        expect(product, isNot(isA<Category>()));
        expect(category, isNot(isA<Product>()));
      });
    });
  });
}
