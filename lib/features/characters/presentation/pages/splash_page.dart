import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection/injection.dart' as di;
import '../../../navigation/navigation.dart';
import '../presentation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _startAnimation();
  }

  void _startAnimation() async {
    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      await AppNavigator.replaceWith(
        context,
        BlocProvider(
          create: (context) => di.sl<CharacterBloc>(),
          child: const CharactersPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}
