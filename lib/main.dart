import 'package:flutter/material.dart';
import 'package:genius_wallet/landing/view/backup_phrase_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme
            .dark(), //TODO: replace this once we have theme generated
      ),
      home: const BackupPhraseScreen(),
    );
  }
}
