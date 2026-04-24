import 'package:flutter/foundation.dart';

class LocationNotifier {
  static final ValueNotifier<int> refresh =
  ValueNotifier<int>(0);

  static void notify() {
    refresh.value++;
  }
}
