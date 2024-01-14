import 'package:flutter/material.dart';

import '../components/login_content.dart';

class ChangeScreenAnimation {
  static late AnimationController topTextController;
  static late Animation<Offset> topTextAnimation;

  static late AnimationController bottomTextController;
  static late Animation<Offset> bottomTextAnimation;

  static List<AnimationController> createAccountControllers = [];
  static List<Animation<Offset>> createAccountAnimations = [];

  static List<AnimationController> loginControllers = [];
  static List<Animation<Offset>> loginAnimations = [];

  static var isPlaying = false;
  static bool isInitialized = false;
  static var currentScreen = Screens.createAccount;

  static Animation<Offset> _createAnimation({
    required Offset begin,
    required Offset end,
    required AnimationController parent,
  }) {
    return Tween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: parent,
        curve: Curves.easeInOut,
      ),
    );
  }

  static void initialize({
    required TickerProvider vsync,
    required int createAccountItems,
    required int loginItems,
  }) {
    if (isInitialized) {
      return;
    }
    topTextController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );

    topTextAnimation = _createAnimation(
      begin: Offset.zero,
      end: const Offset(-1.2, 0),
      parent: topTextController,
    );

    bottomTextController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );

    bottomTextAnimation = _createAnimation(
      begin: Offset.zero,
      end: const Offset(0, 1.7),
      parent: bottomTextController,
    );

    for (var i = 0; i < createAccountItems; i++) {
      createAccountControllers.add(
        AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 200),
        ),
      );

      createAccountAnimations.add(
        _createAnimation(
          begin: Offset.zero,
          end: const Offset(-1, 0),
          parent: createAccountControllers[i],
        ),
      );
    }

    for (var i = 0; i < loginItems; i++) {
      loginControllers.add(
        AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 200),
        ),
      );

      loginAnimations.add(
        _createAnimation(
          begin: const Offset(1, 0),
          end: Offset.zero,
          parent: loginControllers[i],
        ),
      );
    }
    isInitialized = true;
  }

  static void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void dispose() {
    for (final controller in [
      topTextController,
      bottomTextController,
      ...createAccountControllers,
      ...loginControllers,
    ]) {
      controller.dispose();
    }
    isInitialized = false;
  }

  static Future<void> forward() async {
    isPlaying = true;

    topTextController.forward();
    await bottomTextController.forward();

    for (final controller in [
      ...createAccountControllers,
      ...loginControllers,
    ]) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    bottomTextController.reverse();
    await topTextController.reverse();

    isPlaying = false;
  }

  static Future<void> reverse() async {
    isPlaying = true;

    topTextController.forward();
    await bottomTextController.forward();

    for (final controller in [
      ...loginControllers.reversed,
      ...createAccountControllers.reversed,
    ]) {
      controller.reverse();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    bottomTextController.reverse();
    await topTextController.reverse();

    isPlaying = false;
  }
}
