import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';

class MarketSearchBar extends StatefulWidget {
  final VoidCallback? onCoinPressed;

  const MarketSearchBar({Key? key, this.onCoinPressed}) : super(key: key);

  @override
  State<MarketSearchBar> createState() => _MarketSearchBarState();
}

class _MarketSearchBarState extends State<MarketSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<CoinGeckoCoin> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Called when the user types into the search field.
  /// Triggers a search only after the user stops typing for 500ms.
  void _onSearchChanged(String query) {
    // Cancel any active debounce timers
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      // If the query is empty, clear results immediately
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      setState(() => _isSearching = true);

      try {
        // Fetch search results (limit to 30 results)
        final results = await searchCoinsByName(query, maxResults: 30);

        if (!mounted) return;

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  /// Called when a coin is selected from the search results.
  Future<void> _onCoinTap(CoinGeckoCoin coin) async {
    setState(() => _isSearching = true);

    try {
      final marketDataMap = await fetchCoinsMarketData(coinIds: [coin.id]);
      final marketData = marketDataMap[coin.symbol.toLowerCase()];

      if (!mounted) return;

      if (marketData == null) {
        showAppSnackBar(context, 'Market data not found for ${coin.name}');

        setState(() => _isSearching = false);
        return;
      }

      // Navigate to token info screen
      context.push(
        '/token-info',
        extra: {
          "securityInfo": "Coming Soon",
          "transactionHistory": ["Coming Soon"],
          "marketData": marketData,
          "coin": coin,
        },
      );

      // Trigger the callback if provided (e.g., close drawer)
      widget.onCoinPressed?.call();

      setState(() {
        _searchResults = [];
        _controller.clear();
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSearching = false);
      showAppSnackBar(context, 'Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search Input Field
        // Replace SearchBar with this TextField for custom style
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white), // White input text
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search Coins...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[900], // Very dark background for input
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white24, // Subtle dark border
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Colors.white38,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: GeniusWalletColors.lightGreenPrimary,
                width: 2,
              ),
            ),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : const Icon(Icons.search, color: Colors.white38)),
          ),
        ),

        const SizedBox(height: 8),

        if (_searchResults.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final coin = _searchResults[index];
              return SlidingDrawerButton(
                label: coin.name,
                onPressed: () => _onCoinTap(coin),
              );
            },
          ),
      ],
    );
  }
}
