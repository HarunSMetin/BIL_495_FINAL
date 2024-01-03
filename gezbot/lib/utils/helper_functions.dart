/// The HelperFunctions class in Dart provides a static method to wrap a widget with an AnimatedBuilder
/// and FractionalTranslation.
import 'package:flutter/material.dart';

class HelperFunctions {
  static Widget wrapWithAnimatedBuilder({
    required Animation<Offset> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => FractionalTranslation(
        translation: animation.value,
        child: child,
      ),
    );
  }
}
