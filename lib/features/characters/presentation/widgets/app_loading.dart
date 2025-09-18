import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class AppLoading extends StatelessWidget {
  final double size;

  const AppLoading({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.textPrimaryLight,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
