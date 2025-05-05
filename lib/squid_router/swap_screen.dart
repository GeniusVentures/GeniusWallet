import 'package:flutter/material.dart';
import 'package:genius_wallet/squid_router/squid_token_service.dart';
import 'package:genius_wallet/squid_router/squid_token_info.dart';
import 'package:genius_wallet/squid_router/token_selector_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

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
  String fromAmount = '';
  String toAmount = '';
  double rotationTurns = 0;

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
      setState(() => isLoading = false);
      debugPrint('Token fetch failed: $e');
    }
  }

  void _flipTokens() {
    setState(() {
      final tempToken = fromToken;
      fromToken = toToken;
      toToken = tempToken;

      final tempAmount = fromAmount;
      fromAmount = toAmount;
      toAmount = tempAmount;

      rotationTurns += 1;
    });
  }

  Widget _buildSwapField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    required SquidTokenInfo? selectedToken,
    required bool isSelectingFrom,
  }) {
    return Card(
      color: GeniusWalletColors.deepBlueCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: "0.0",
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onChanged: onChanged,
                    controller: TextEditingController(text: value),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    TokenSelectorDrawer.show(
                      context: context,
                      tokens: tokens,
                      onTokenSelected: (token) {
                        setState(() {
                          if (isSelectingFrom) {
                            fromToken = token;
                          } else {
                            toToken = token;
                          }
                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (selectedToken != null)
                          ClipOval(
                            child: Image.network(
                              selectedToken.logoURI,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 36,
                                  height: 36,
                                  color: Colors.grey[700],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white70, size: 16),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          selectedToken?.symbol ?? "Select",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text("Swap Tokens",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  _buildSwapField(
                    label: "You Pay",
                    value: fromAmount,
                    onChanged: (val) => setState(() => fromAmount = val),
                    selectedToken: fromToken,
                    isSelectingFrom: true,
                  ),
                  _buildSwapField(
                    label: "You Receive",
                    value: toAmount,
                    onChanged: (val) => setState(() => toAmount = val),
                    selectedToken: toToken,
                    isSelectingFrom: false,
                  ),
                  // Flip Button
                  Transform.translate(
                    offset: const Offset(0, -170),
                    child: AnimatedRotation(
                      turns: rotationTurns,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: FloatingActionButton(
                        onPressed: _flipTokens,
                        mini: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        backgroundColor: Colors.greenAccent,
                        child: const Icon(Icons.swap_vert,
                            color: GeniusWalletColors.deepBlueTertiary),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
