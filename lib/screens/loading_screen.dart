import 'package:flutter/material.dart';
import 'package:genius_wallet/components/loading/loading.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Loading(),
    );
  }
}
