<<<<<<< HEAD
/// The HelperFunctions class in Dart provides a static method to wrap a widget with an AnimatedBuilder
/// and FractionalTranslation.
=======
>>>>>>> 7de1de7662b6b44ed7fa4f0335512cdf4860bbe6
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
