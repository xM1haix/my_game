import "package:flutter/material.dart";

extension ExtensionOnBuildContext on BuildContext {
  void back<T>([T? result]) => Navigator.pop(this, result);

  Future<T?> nav<T>(Widget location, {bool pushReplacement = false}) {
    final route = MaterialPageRoute<T>(builder: (context) => location);
    return pushReplacement
        ? Navigator.pushReplacement(this, route)
        : Navigator.push(this, route);
  }
}
