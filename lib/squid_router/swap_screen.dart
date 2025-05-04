import 'package:flutter/material.dart';
import 'package:genius_wallet/squid_router/squid_router_service.dart';
import 'package:genius_wallet/squid_router/squid_token_info.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  List<SquidTokenInfo> tokens = [];
  SquidTokenInfo? fromToken;
  SquidTokenInfo? toToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    try {
      final result = await SquidTokenService.fetchTokens();
      setState(() {
        tokens = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Token fetch failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<SquidTokenInfo>(
              value: fromToken,
              hint: const Text("Swap From",
                  style: TextStyle(color: Colors.white)),
              items: tokens.map((token) {
                return DropdownMenuItem<SquidTokenInfo>(
                  value: token,
                  child: Text(token.display),
                );
              }).toList(),
              onChanged: (value) => setState(() => fromToken = value),
            ),
            const SizedBox(height: 16),
            DropdownButton<SquidTokenInfo>(
              value: toToken,
              hint: const Text("Swap To"),
              items: tokens.map((token) {
                return DropdownMenuItem<SquidTokenInfo>(
                  value: token,
                  child: Text(token.display),
                );
              }).toList(),
              onChanged: (value) => setState(() => toToken = value),
            ),
          ],
        ),
      ),
    );
  }
}
