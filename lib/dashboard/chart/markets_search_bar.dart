import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Market data not found for ${coin.name}')),
        );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search Input Field
        SearchBar(
          controller: _controller,
          hintText: 'Search Coins...',
          onChanged: _onSearchChanged,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          trailing: [
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _searchResults = [];
                  });
                },
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Search Results List (as SlidingDrawerButtons)
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
