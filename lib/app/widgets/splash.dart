import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatefulWidget {
  final String onCompletion;
  const Splash({super.key, required this.onCompletion});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    //TODO: Make this future-based
    Future.delayed(
      const Duration(seconds: 2),
      () => context.go(widget.onCompletion),
    );
    return Scaffold(
      body: AppScreenView(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Image.asset(
              'assets/images/logo_and_title.png',
              package: 'genius_wallet',
            ),
          ),
        ),
      ),
    );
  }
}
