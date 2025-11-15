# 🧪 Test Suite Documentation

This directory contains comprehensive test coverage for the `odoo_bridge_client` package. All tests are organized by functionality and feature complete documentation of the package's capabilities.

## 📊 Test Statistics

- **Total Tests**: 112 tests across 4 test files
- **Pass Rate**: 100% ✅
- **Coverage Areas**: Field parsing, Model registry, API handling, Error scenarios

## 📁 Test Files Overview

### 🔧 Core Functionality Tests

| Test File | Tests | Description |
|-----------|--------|-------------|
| [`odoo_bridge_client_test.dart`](./odoo_bridge_client_test.dart) | 60 | Main comprehensive test suite |
| [`model_registry_test.dart`](./model_registry_test.dart) | 14 | ModelRegistry specialized tests |
| [`api_test.dart`](./api_test.dart) | 12 | API components testing |
| [`field_test.dart`](./field_test.dart) | 26 | Advanced field behavior tests |

---

## 📋 Detailed Test Catalog

### 🎯 [`odoo_bridge_client_test.dart`](./odoo_bridge_client_test.dart) - Main Test Suite

#### 🔢 OdooField Tests - Integer Field
- [**Parse valid integer values correctly**](./odoo_bridge_client_test.dart#L53) - Validates integer parsing from various input types
- [**Return null for null values when nullable**](./odoo_bridge_client_test.dart#L60) - Tests nullable field behavior
- [**Return default value for null when not nullable**](./odoo_bridge_client_test.dart#L66) - Validates default value handling
- [**Throw exception for invalid values**](./odoo_bridge_client_test.dart#L81) - Error handling for invalid input
- [**Store field properties correctly**](./odoo_bridge_client_test.dart#L89) - Field metadata validation

#### 📝 OdooField Tests - Character Field
- [**Parse valid string values correctly**](./odoo_bridge_client_test.dart#L103) - String value parsing validation
- [**Return null for null values when nullable**](./odoo_bridge_client_test.dart#L110) - Nullable string field behavior
- [**Return default value for null when not nullable**](./odoo_bridge_client_test.dart#L116) - Default string value handling
- [**Throw exception for boolean false (not supported)**](./odoo_bridge_client_test.dart#L122) - Invalid input error handling

#### ✅ OdooField Tests - Boolean Field
- [**Parse boolean values correctly**](./odoo_bridge_client_test.dart#L139) - Boolean parsing validation
- [**Parse integer values correctly**](./odoo_bridge_client_test.dart#L146) - Integer to boolean conversion
- [**Parse string values correctly**](./odoo_bridge_client_test.dart#L154) - String to boolean conversion
- [**Return null for null values**](./odoo_bridge_client_test.dart#L163) - Nullable boolean behavior
- [**Throw exception for invalid values**](./odoo_bridge_client_test.dart#L169) - Invalid boolean input handling

#### 🔢 OdooField Tests - Float Field
- [**Parse float values correctly**](./odoo_bridge_client_test.dart#L178) - Float value parsing
- [**Return null for null values when nullable**](./odoo_bridge_client_test.dart#L186) - Nullable float behavior
- [**Return default value for null when not nullable**](./odoo_bridge_client_test.dart#L192) - Float default values
- [**Throw exception for invalid values**](./odoo_bridge_client_test.dart#L198) - Invalid float input handling

#### 📅 OdooField Tests - DateTime Field
- [**Parse DateTime values correctly**](./odoo_bridge_client_test.dart#L206) - DateTime object parsing
- [**Parse ISO8601 string values correctly**](./odoo_bridge_client_test.dart#L213) - ISO string to DateTime conversion
- [**Return null for null values when nullable**](./odoo_bridge_client_test.dart#L221) - Nullable DateTime behavior
- [**Return default value when provided**](./odoo_bridge_client_test.dart#L227) - DateTime default values
- [**Throw exception for invalid string formats**](./odoo_bridge_client_test.dart#L237) - Invalid date format handling

#### 🏗️ OdooField Tests - Base Class
- [**Throw exception when calling parse on base class**](./odoo_bridge_client_test.dart#L246) - Abstract base class behavior
- [**Handle checkDefaultValue correctly**](./odoo_bridge_client_test.dart#L252) - Default value validation logic

#### 📚 ModelRegistry Tests
- [**Register and retrieve models correctly**](./odoo_bridge_client_test.dart#L268) - Model registration functionality
- [**Throw exception for unregistered models**](./odoo_bridge_client_test.dart#L288) - Unregistered model error handling
- [**Parse JSON correctly with registered model**](./odoo_bridge_client_test.dart#L294) - JSON to model parsing
- [**Handle JSON with missing fields correctly**](./odoo_bridge_client_test.dart#L324) - Partial JSON parsing

#### 🌐 APIResponse Tests
- [**Create successful response correctly**](./odoo_bridge_client_test.dart#L355) - Successful API response creation
- [**Create error response correctly**](./odoo_bridge_client_test.dart#L370) - Error response handling
- [**Handle response with body data**](./odoo_bridge_client_test.dart#L386) - Response body processing
- [**Handle response with headers**](./odoo_bridge_client_test.dart#L399) - HTTP headers handling

#### 🔌 Odoo Client Tests
- [**Initialize with correct parameters**](./odoo_bridge_client_test.dart#L423) - Client initialization validation
- [**Initialize with default version**](./odoo_bridge_client_test.dart#L430) - Default version behavior

#### 🔍 Domain Format Tests
- [**Handle empty domain correctly**](./odoo_bridge_client_test.dart#L455) - Empty search domain
- [**Handle simple criteria correctly**](./odoo_bridge_client_test.dart#L460) - Basic search criteria
- [**Handle multiple AND criteria correctly**](./odoo_bridge_client_test.dart#L468) - Complex AND logic
- [**Handle OR criteria correctly**](./odoo_bridge_client_test.dart#L480) - OR logic in search
- [**Handle complex AND/OR criteria correctly**](./odoo_bridge_client_test.dart#L492) - Mixed boolean logic
- [**Handle nested boolean operators**](./odoo_bridge_client_test.dart#L508) - Nested search expressions
- [**Handle comparison operators correctly**](./odoo_bridge_client_test.dart#L521) - Comparison operators validation

#### ✔️ Field Validation Tests
- [**Validate nullable field constraints**](./odoo_bridge_client_test.dart#L544) - Nullable field validation
- [**Validate default value behavior**](./odoo_bridge_client_test.dart#L554) - Default value constraints
- [**Validate field name mapping**](./odoo_bridge_client_test.dart#L564) - Field name validation
- [**Validate field combinations correctly**](./odoo_bridge_client_test.dart#L570) - Field combination validation

#### 🛡️ Type Safety Tests
- [**Maintain type safety for different field types**](./odoo_bridge_client_test.dart#L584) - Type safety validation
- [**Handle nullable return types correctly**](./odoo_bridge_client_test.dart#L598) - Nullable type handling

#### ❌ Error Handling Tests
- [**Handle invalid field types gracefully**](./odoo_bridge_client_test.dart#L612) - Invalid type error handling
- [**Provide meaningful error messages**](./odoo_bridge_client_test.dart#L620) - Error message validation
- [**Handle nullable constraints with clear messages**](./odoo_bridge_client_test.dart#L632) - Nullable constraint errors
- [**Handle parsing errors for each field type**](./odoo_bridge_client_test.dart#L645) - Field-specific error handling

#### 🔄 Data Type Conversion Tests
- [**Handle integer field conversions correctly**](./odoo_bridge_client_test.dart#L662) - Integer conversion validation
- [**Handle float field conversions correctly**](./odoo_bridge_client_test.dart#L671) - Float conversion validation
- [**Handle string field conversions correctly**](./odoo_bridge_client_test.dart#L681) - String conversion validation
- [**Handle boolean field conversions correctly**](./odoo_bridge_client_test.dart#L689) - Boolean conversion validation
- [**Handle datetime field conversions correctly**](./odoo_bridge_client_test.dart#L701) - DateTime conversion validation

---

### 📊 [`model_registry_test.dart`](./model_registry_test.dart) - ModelRegistry Specialized Tests

#### 🔧 Basic Registration Tests
- [**Register single model correctly**](./model_registry_test.dart#L80) - Single model registration with Product.fields
- [**Register multiple models correctly**](./model_registry_test.dart#L101) - Multiple model registration with Product and Category

#### ⚙️ Field Management Tests
- [**Handle complex field configurations**](./model_registry_test.dart#L140) - Complex field setup validation
- [**Maintain field order**](./model_registry_test.dart#L171) - Field order preservation testing

#### 📄 JSON Parsing Tests
- [**Parse complete JSON correctly**](./model_registry_test.dart#L191) - Full JSON parsing with all fields
- [**Parse JSON with missing nullable fields**](./model_registry_test.dart#L227) - Partial JSON with nullable fields
- [**Parse JSON with default values**](./model_registry_test.dart#L259) - Default value application in JSON
- [**Handle invalid JSON gracefully**](./model_registry_test.dart#L287) - Invalid JSON error handling

#### 🚨 Error Handling Tests
- [**Throw for unregistered models**](./model_registry_test.dart#L310) - Unregistered model error validation
- [**Provide meaningful error messages**](./model_registry_test.dart#L319) - Error message quality testing

#### 🔄 Registry State Management Tests
- [**Maintain separate registrations for different types**](./model_registry_test.dart#L331) - Type isolation validation
- [**Handle model re-registration**](./model_registry_test.dart#L366) - Model re-registration behavior

#### 🔗 Parser Function Tests
- [**Store and retrieve parser functions**](./model_registry_test.dart#L402) - Parser function management
- [**Handle different parser functions for different models**](./model_registry_test.dart#L427) - Multi-model parser handling

---

### 🌐 [`api_test.dart`](./api_test.dart) - API Components Testing

#### 🔌 API Tests
- [**Initialize API with correct parameters**](./api_test.dart#L12) - API client initialization
- [**Initialize with default parameters**](./api_test.dart#L17) - Default API configuration
- [**Initialize with headers callback**](./api_test.dart#L25) - Custom headers callback setup
- [**Handle logging configuration**](./api_test.dart#L42) - Logging configuration validation

#### 📡 APIResponse Tests
- [**Create successful response with all parameters**](./api_test.dart#L50) - Complete success response
- [**Create error response with validation errors**](./api_test.dart#L70) - Error response with validation details
- [**Handle different status codes correctly**](./api_test.dart#L90) - HTTP status code handling
- [**Handle null values correctly**](./api_test.dart#L110) - Null value processing
- [**Handle empty headers correctly**](./api_test.dart#L124) - Empty headers handling
- [**Handle response without body**](./api_test.dart#L130) - No-body response processing

#### 📋 RequestType Tests
- [**Handle all request types**](./api_test.dart#L145) - Request type enum validation
- [**Have different enum values**](./api_test.dart#L153) - Enum value uniqueness

---

### 🔬 [`field_test.dart`](./field_test.dart) - Advanced Field Behavior Tests

#### 🔢 OdooIntegerField Advanced Tests
- [**Handle edge cases for integer parsing**](./field_test.dart#L7) - Integer edge case handling
- [**Throw for decimal strings**](./field_test.dart#L16) - Decimal string rejection
- [**Handle whitespace in strings**](./field_test.dart#L23) - Whitespace handling in parsing
- [**Validate nullable and default value combinations**](./field_test.dart#L30) - Complex nullable/default scenarios

#### 📝 OdooCharField Advanced Tests
- [**Handle special characters and encoding**](./field_test.dart#L49) - Unicode and special character support
- [**Handle very long strings**](./field_test.dart#L58) - Large string processing
- [**Handle special escape sequences**](./field_test.dart#L67) - Escape sequence processing

#### ✅ OdooBooleanField Advanced Tests
- [**Handle string representations correctly**](./field_test.dart#L81) - String to boolean advanced conversion
- [**Handle numeric representations correctly**](./field_test.dart#L92) - Numeric to boolean conversion
- [**Return null for null input**](./field_test.dart#L102) - Null input handling
- [**Throw for invalid string values**](./field_test.dart#L108) - Invalid string rejection
- [**Throw for invalid types**](./field_test.dart#L118) - Invalid type rejection

#### 🔢 OdooFloatField Advanced Tests
- [**Handle various number formats**](./field_test.dart#L128) - Multiple number format support
- [**Handle string number formats**](./field_test.dart#L137) - String number conversion
- [**Handle scientific notation**](./field_test.dart#L147) - Scientific notation support
- [**Handle special float values**](./field_test.dart#L155) - Special values (Infinity, NaN, etc.)
- [**Throw for invalid string formats**](./field_test.dart#L167) - Invalid float string handling

#### 📅 OdooDateTimeField Advanced Tests
- [**Handle various ISO8601 formats**](./field_test.dart#L177) - Multiple ISO8601 format support
- [**Preserve timezone information**](./field_test.dart#L193) - Timezone preservation
- [**Handle edge cases**](./field_test.dart#L204) - DateTime edge cases
- [**Throw for invalid date formats**](./field_test.dart#L216) - Invalid date format handling
- [**Handle DateTime objects directly**](./field_test.dart#L223) - Direct DateTime object processing

#### 📊 Field Properties and Metadata Tests
- [**Store and retrieve field properties correctly**](./field_test.dart#L234) - Field property management
- [**Handle checkDefaultValue method correctly**](./field_test.dart#L271) - Default value checking logic

#### 🏗️ Field Inheritance and Polymorphism Tests
- [**Maintain type hierarchy correctly**](./field_test.dart#L295) - Type hierarchy validation
- [**Handle generic field operations**](./field_test.dart#L309) - Generic field operations

---

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/odoo_bridge_client_test.dart
flutter test test/model_registry_test.dart
flutter test test/api_test.dart
flutter test test/field_test.dart
```

### Run with Expanded Output
```bash
flutter test --reporter expanded
```

### Run Specific Test by Name
```bash
flutter test -n "should parse valid integer values correctly"
```

---

## 🔍 Test Patterns and Best Practices

### 🎯 Testing Approach
- **Comprehensive Coverage**: Every field type and operation is tested
- **Edge Case Validation**: Special values, null handling, and error scenarios
- **Type Safety**: Ensuring proper Dart type safety throughout
- **Error Handling**: Meaningful error messages and proper exception handling

### 📋 Test Organization
- **Grouped by Functionality**: Tests are organized in logical groups
- **Descriptive Names**: Each test clearly describes what it validates
- **Consistent Patterns**: Similar testing patterns across all test files
- **Isolated Tests**: Each test is independent and can run in isolation

### 🛠️ Mock Models Used
- **TestUser**: Complete user model with all field types for comprehensive testing
- **Product**: Standardized model using `Product.fields` (6 fields: id, name, code, price, active, created_at)
- **Category**: Standardized model using `Category.fields` (3 fields: id, name, description)

---

## ✅ Test Results Summary

All 112 tests pass successfully, providing confidence in:
- ✅ Field parsing and validation
- ✅ Model registration and retrieval
- ✅ JSON serialization/deserialization
- ✅ API response handling
- ✅ Error scenarios and edge cases
- ✅ Type safety enforcement
- ✅ Null safety compliance

*Generated on November 16, 2025*
