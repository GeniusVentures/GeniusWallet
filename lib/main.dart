import 'package:flutter/material.dart';
import 'package:genius_wallet/navigation/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme
            .dark(), //TODO: replace this once we have theme generated
      ),
      routerConfig: geniusWalletRouter,
    );
  }
}
