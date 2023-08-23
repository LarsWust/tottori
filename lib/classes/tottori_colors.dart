import 'package:flutter/material.dart';

class TottoriColors {
  late Color greenContainer;
  late Color green;

  TottoriColors(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      green = const Color.fromARGB(255, 45, 178, 85);
      greenContainer = const Color.fromARGB(255, 151, 204, 167);
    } else {
      green = const Color.fromARGB(255, 39, 167, 77);
      greenContainer = const Color.fromARGB(255, 54, 76, 60);
    }
  }
}
