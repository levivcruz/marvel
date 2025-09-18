import 'package:flutter/material.dart';

import '../characters/domain/domain.dart';
import '../characters/presentation/presentation.dart';

class AppNavigator {
  static Future<void> toCharacterDetail(
    BuildContext context,
    Character character,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CharacterDetailPage(character: character),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static Future<void> replaceWith(
    BuildContext context,
    Widget page, {
    Duration transitionDuration = const Duration(milliseconds: 500),
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: transitionDuration,
      ),
    );
  }

  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
