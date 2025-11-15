import 'list.dart';

extension MapExtensions on Map<String, dynamic> {
  Map<String, dynamic> clean() {
    return map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, value.clean());
      } else if (value is List) {
        return MapEntry(key, value.clean());
      } else {
        return MapEntry(key, value == false ? null : value);
      }
    });
  }
}
