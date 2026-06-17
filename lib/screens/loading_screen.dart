import 'package:flutter/material.dart';
import 'package:genius_wallet/components/loading.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Loading());
  }
}
