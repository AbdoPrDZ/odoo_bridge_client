import 'map.dart';

extension ListExtensions on List {
  List clean() {
    return map((e) {
      if (e is Map<String, dynamic>) {
        return e.clean();
      } else if (e is List) {
        return e.clean();
      } else {
        return e == false ? null : e;
      }
    }).toList();
  }
}
