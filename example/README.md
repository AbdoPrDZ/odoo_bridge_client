# Odoo Bridge Client Example

This example demonstrates a comprehensive Flutter application that connects to any Odoo server and performs all major RPC operations.

## Features

### 🔐 **Authentication & Connection**
- Connect to any Odoo server with custom URL and target name
- Test connection before authentication
- Secure authentication with login/password
- Real-time connection status and error handling

### 📊 **Complete CRUD Operations**
- **Create**: Add new partner records with name and email
- **Read**: Search and retrieve partner records
- **Update**: Modify existing partner information
- **Delete**: Remove partner records with confirmation

### 🔍 **Advanced Search & Operations**
- Search partners by name or email
- Get all partners with pagination support
- Count total records in database
- Copy existing records with modifications
- Check if records exist

### 🎯 **Professional UI/UX**
- Material Design 3 interface
- Form validation and error handling
- Loading states and progress indicators
- Confirmation dialogs for destructive actions
- Detailed record information display

## Setup

This example uses its own `build.yaml` configuration to generate model helpers and registry automatically.

### 1. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  odoo_bridge_client:
    path: ../

dev_dependencies:
  build_runner: ^2.4.13
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### 2. Build Configuration

The `build.yaml` file configures automatic code generation:

```yaml
targets:
  $default:
    builders:
      odoo_bridge_client|odoo_model_helper:
        generate_for:
          - lib/models/**.dart
      odoo_bridge_client|odoo_models_registry:
        generate_for:
          - lib/models/models.dart
```

### 3. Model Structure

```
lib/models/
├── models.dart              # Main export file with registry
├── res_partner.dart         # Example Odoo model class
├── models.registry.g.dart   # Generated registry (auto-generated)
└── res_partner.model_helper.g.dart  # Generated helpers (auto-generated)
```

## Usage Guide

### 1. **Connection Setup**
1. Launch the app
2. Enter your Odoo server details:
   - **Base URL**: Your Odoo server URL (e.g., `https://your-server.odoo.com`)
   - **Target Name**: Your Odoo target/database name
   - **Login**: Your Odoo username
   - **Password**: Your Odoo password

### 2. **Test Connection**
- Click "Test Connection" to verify server accessibility
- Green status indicates successful connection

### 3. **Authenticate**
- Click "Connect & Authenticate" to log in
- Success shows user information and unlocks operations

### 4. **Explore Operations**
- Click "Explore Odoo Operations" to access the main interface
- Perform various CRUD operations on partner records

## Available Operations

### **Odoo Domain Format**

Odoo uses a specific domain format for searching records. Domains are lists of criteria:

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
- `=` : equals
- `!=` : not equals
- `>`, `>=`, `<`, `<=` : comparisons
- `like`, `ilike` : pattern matching (case sensitive/insensitive)
- `in`, `not in` : list membership
- `=like`, `=ilike` : exact pattern matching

### **Search Operations**
```dart
// Search by criteria (using Odoo domain format)
final partners = await Odoo.search<ResPartner>(odoo, [
  '|',
  ['name', 'ilike', 'John'],
  ['email', 'ilike', 'john@example.com'],
]);

// Search IDs only
final ids = await Odoo.searchIds<ResPartner>(odoo, [
  ['name', '!=', false],
]);

// Count records
final count = await Odoo.searchCount<ResPartner>(odoo, []);

// Check existence
final exists = await Odoo.exists<ResPartner>(odoo, [
  ['email', '=', 'john@example.com'],
]);
```

### **CRUD Operations**
```dart
// Create record
final id = await Odoo.create<ResPartner>(odoo, {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Read records
final partners = await Odoo.read<ResPartner>(odoo, [1, 2, 3]);

// Update records
await Odoo.write<ResPartner>(odoo, [1], {
  'name': 'Updated Name',
});

// Delete records
await Odoo.unlink<ResPartner>(odoo, [1]);

// Copy record
final newId = await Odoo.copy<ResPartner>(odoo, 1, 
  defaults: {'name': 'Copy of John'});
```

### **Advanced Operations**
```dart
// Get model fields information
final fields = await Odoo.getFields<ResPartner>(odoo);

// Call custom methods
final result = await Odoo.callMethod<ResPartner>(
  odoo, [1], 'custom_method', 
  args: ['param1'], 
  kwargs: {'key': 'value'}
);
```

## Model Definition

Example of a properly annotated Odoo model:

```dart
import 'package:odoo_bridge_client/odoo_field.dart';
import 'package:odoo_bridge_client/odoo_model.dart';

part 'res_partner.model_helper.g.dart';

@OdooModel('res.partner')
class ResPartner {
  @OdooIntegerField('id')
  int? id;

  @OdooCharField('name')
  String name;

  @OdooCharField('email')
  String email;

  @OdooDateTimeField('create_date')
  DateTime? createDate;

  @OdooDateTimeField('write_date')
  DateTime? writeDate;

  @OdooIntegerField('create_uid')
  int? createUid;

  @OdooIntegerField('write_uid')
  int? writeUid;

  ResPartner({
    this.id,
    required this.name,
    required this.email,
    this.createDate,
    this.writeDate,
    this.createUid,
    this.writeUid,
  });
}
```

## Build Commands

```bash
# Generate code
dart run build_runner build

# Generate code and delete conflicting outputs
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and rebuild automatically
dart run build_runner watch

# Clean generated files
dart run build_runner clean
```

## Professional Features

### **Error Handling**
- Comprehensive try-catch blocks
- User-friendly error messages
- Network error handling
- Validation feedback

### **Loading States**
- Loading indicators during operations
- Disabled buttons during processing
- Progress feedback for long operations

### **Data Management**
- Automatic list refresh after modifications
- Real-time status updates
- Efficient memory management

### **Security**
- Secure password input
- Token-based authentication
- Connection validation

## Production Considerations

1. **Environment Configuration**: Use different configs for dev/prod
2. **Error Logging**: Implement proper logging for production
3. **Caching**: Add caching for frequently accessed data
4. **Offline Support**: Consider offline data storage
5. **Performance**: Implement pagination for large datasets

This example provides a complete foundation for building professional Odoo-integrated Flutter applications! 🚀

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
