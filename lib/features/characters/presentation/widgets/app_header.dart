import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const AppHeader({super.key, this.onBackPressed, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 100 + statusBarHeight,
      color: AppColors.backgroundDark,
      padding: EdgeInsets.only(top: statusBarHeight + 47, bottom: 14),
      child: Stack(
        children: [
          Center(child: Image.asset('assets/images/logo.png')),

          if (showBackButton)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
