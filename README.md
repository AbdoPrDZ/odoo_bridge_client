# Odoo Bridge Client

A comprehensive Flutter package that provides seamless integration with Odoo ERP systems through RPC API calls. This package offers type-safe, code-generated models and a complete set of CRUD operations for efficient Odoo data management in Flutter applications.

## 🚀 Features

### 🔐 **Authentication & Connection**
- Secure authentication with Odoo servers using username/password
- Token-based session management
- Connection testing and validation
- Support for custom Odoo server URLs and target names

### 📊 **Complete CRUD Operations** 
- **Create**: Add new records with type-safe field validation
- **Read**: Retrieve records by ID or search criteria
- **Update**: Modify existing records with selective field updates
- **Delete**: Remove records with proper error handling
- **Search**: Advanced search with Odoo domain syntax support
- **Copy**: Duplicate records with custom default values

### 🏗️ **Code Generation & Type Safety**
- Automatic model generation from annotated Dart classes
- Type-safe field definitions with nullable and default value support
- JSON serialization/deserialization helpers
- Model registry with automatic field mapping
- Build-time validation and error checking

### 🎯 **Advanced Features**
- Generic API client supporting any Odoo model
- Comprehensive error handling and response validation
- Flexible field type system (Integer, Char, DateTime, Boolean, etc.)
- Domain-based search queries with complex criteria
- Pagination and counting support
- Record existence checking

## 📦 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  odoo_bridge_client: ^0.0.1

dev_dependencies:
  build_runner: ^2.10.3
```

## 🛠️ Setup

### 1. Configure Build System

Create a `build.yaml` file in your project root:

```yaml
targets:
  $default:
    builders:
      odoo_bridge_client|odoo_model_generator:
        enabled: true
      odoo_bridge_client|odoo_model_registry_builder:
        enabled: true
        generate_for:
          - lib/models/models.dart
```

### 2. Define Your Models

Create model classes with proper annotations:

```dart
// lib/models/res_partner.dart
import 'package:odoo_bridge_client/odoo_field.dart';
import 'package:odoo_bridge_client/odoo_model.dart';

part 'res_partner.model_helper.g.dart';

@OdooModel('res.partner')
class ResPartner {
  @OdooIntegerField('id')
  int? id;

  @OdooCharField('name')
  String name;

  @OdooCharField('email', nullable: true)
  String? email;

  @OdooCharField('phone', nullable: true)
  String? phone;

  @OdooDateTimeField('create_date', nullable: true)
  DateTime? createDate;

  @OdooDateTimeField('write_date', nullable: true)
  DateTime? writeDate;

  @OdooIntegerField('create_uid', nullable: true, defaultValue: 1)
  int? createUid;

  @OdooIntegerField('write_uid', nullable: true, defaultValue: 1)  
  int? writeUid;

  ResPartner({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.createDate,
    this.writeDate,
    this.createUid,
    this.writeUid,
  });
}
```

### 3. Create Model Registry

```dart
// lib/models/models.dart
import 'package:odoo_bridge_client/model_registry.dart';
import 'package:odoo_bridge_client/odoo_field.dart';
import 'res_partner.dart';
import 'res_users.dart';
import 'res_company.dart';

part 'models.registry.g.dart';

void initializeModels() {
  BaseOdooModelsRegistry.registerAll();
}
```

### 4. Generate Code

Run the build runner to generate helper classes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 💻 Usage

### Initialize & Connect

```dart
import 'package:odoo_bridge_client/odoo_bridge_client.dart';
import 'models/models.dart';

void main() {
  // Initialize model registry
  initializeModels();
  
  runApp(MyApp());
}

// Create Odoo client
final odoo = Odoo(
  baseUrl: 'https://your-server.odoo.com',
  targetName: 'your-database-name',
);

// Test connection
final isConnected = await odoo.test();

// Authenticate
final authResponse = await odoo.authenticate('username', 'password');
if (authResponse.success) {
  print('Authenticated as: ${authResponse.value?.name}');
}
```

### CRUD Operations

#### **Create Records**
```dart
final response = await Odoo.create<ResPartner>(odoo, {
  'name': 'John Doe',
  'email': 'john@example.com',
  'phone': '+1-234-567-8900',
});

if (response.success) {
  print('Created partner with ID: ${response.value}');
}
```

#### **Search Records**
```dart
// Search with domain criteria
final partners = await Odoo.search<ResPartner>(odoo, [
  '|',
  ['name', 'ilike', 'John'],
  ['email', 'ilike', 'john@example.com'],
]);

if (partners.success) {
  for (var partner in partners.value!) {
    print('Found: ${partner.name} (${partner.email})');
  }
}
```

#### **Read Records by ID**
```dart
final response = await Odoo.read<ResPartner>(odoo, [1, 2, 3]);
if (response.success) {
  final partners = response.value!;
  // Use your partners data
}
```

#### **Update Records**
```dart
final response = await Odoo.write<ResPartner>(odoo, [1], {
  'name': 'Updated Name',
  'email': 'newemail@example.com',
});

if (response.success) {
  print('Partner updated successfully');
}
```

#### **Delete Records**
```dart
final response = await Odoo.unlink<ResPartner>(odoo, [1, 2, 3]);
if (response.success) {
  print('Partners deleted successfully');
}
```

#### **Copy Records**
```dart
final response = await Odoo.copy<ResPartner>(odoo, 1, 
  defaults: {'name': 'Copy of John Doe'}
);

if (response.success) {
  print('Partner copied with new ID: ${response.value}');
}
```

### Advanced Search Operations

#### **Count Records**
```dart
final count = await Odoo.searchCount<ResPartner>(odoo, [
  ['active', '=', true],
]);
print('Active partners: ${count.value}');
```

#### **Check Existence**
```dart
final exists = await Odoo.exists<ResPartner>(odoo, [
  ['email', '=', 'john@example.com'],
]);
print('Partner exists: ${exists.value}');
```

#### **Search IDs Only**
```dart
final ids = await Odoo.searchIds<ResPartner>(odoo, [
  ['create_date', '>=', '2024-01-01'],
]);
print('Found ${ids.value?.length} partner IDs');
```

## 🔍 Odoo Domain Format

Odoo uses a specific domain format for search criteria:

```dart
// Simple criteria: [field, operator, value]
['name', '=', 'John Doe']

// Multiple criteria with AND (implicit)
[
  ['name', 'ilike', 'John'],
  ['email', '!=', false],
]

// OR criteria using '|' prefix  
[
  '|',
  ['name', 'ilike', 'John'],
  ['email', 'ilike', 'john@example.com'],
]

// Complex criteria with AND/OR combinations
[
  '|',
  ['name', 'ilike', 'John'],
  '&',
  ['email', '!=', false], 
  ['active', '=', true],
]

// Empty domain [] means "get all records"
[]
```

**Common Operators:**
- `=`, `!=` : equals, not equals
- `>`, `>=`, `<`, `<=` : comparisons
- `like`, `ilike` : pattern matching (case sensitive/insensitive)
- `in`, `not in` : list membership
- `=like`, `=ilike` : exact pattern matching

## 🏗️ Field Types

The package supports all major Odoo field types:

```dart
@OdooIntegerField('id')
int? id;

@OdooCharField('name', nullable: false)
String name;

@OdooCharField('email', nullable: true, defaultValue: '')
String? email;

@OdooDateTimeField('create_date', nullable: true)
DateTime? createDate;

@OdooBooleanField('active', defaultValue: true)
bool active;

@OdooFloatField('price', nullable: true)
double? price;
```

### Field Attributes
- `nullable: true/false` - Whether field can be null
- `defaultValue: value` - Default value for the field
- Field name mapping to Odoo field names

## 🔧 Error Handling

All operations return `APIResponse<T>` objects with comprehensive error information:

```dart
final response = await Odoo.create<ResPartner>(odoo, data);

if (response.success) {
  // Handle success
  final partnerId = response.value!;
} else {
  // Handle errors
  print('Error: ${response.message}');
  print('Status Code: ${response.statusCode}');
  if (response.errors != null) {
    for (var error in response.errors!) {
      print('Field Error: $error');
    }
  }
}
```

## 📱 Example App

The package includes a complete example Flutter app demonstrating:
- Multi-model support (Users, Companies, Partners)
- Dynamic model selection
- All CRUD operations with real-time UI
- Form validation and error handling
- Professional UI with Material Design 3

Run the example:
```bash
cd example
flutter run
```

## 🏭 Production Considerations

### Security
- Always use HTTPS in production
- Implement proper token storage and refresh mechanisms
- Validate user input before sending to Odoo
- Use environment variables for sensitive configuration

### Performance
- Implement caching for frequently accessed data
- Use pagination for large datasets
- Consider offline functionality with local storage
- Monitor network usage and implement retry mechanisms

### Error Handling
- Implement comprehensive error logging
- Provide user-friendly error messages
- Handle network timeouts and connection issues
- Implement proper fallback mechanisms

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## 📄 License

This package is released under the MIT License. See LICENSE file for details.

## 🆘 Support

For issues, questions, or contributions:
- Create issues on GitHub
- Check the example app for implementation patterns
- Review the API documentation for detailed method signatures

---

**Built with ❤️ for the Flutter and Odoo communities**
