import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:genius_wallet/services/coin_telegraph/coin_telegraph_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'news_card.dart';

class CryptoNewsScreen extends StatefulWidget {
  const CryptoNewsScreen({Key? key}) : super(key: key);

  @override
  State<CryptoNewsScreen> createState() => _CryptoNewsScreenState();
}

class _CryptoNewsScreenState extends State<CryptoNewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;
  final Random _random = Random();

  // Precomputed layout data
  final List<_CardLayoutData> _layoutData = [];

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchCoinTelegraphNews().then((articles) {
      _generateLayoutData(articles.length);
      return articles;
    });
  }

  // Re-run the news fetch (used by both the error-retry button and
  // pull-to-refresh), regenerating layout data the same way initState does.
  void _retryNews() {
    setState(() {
      _newsFuture = fetchCoinTelegraphNews().then((articles) {
        _generateLayoutData(articles.length);
        return articles;
      });
    });
  }

  void _generateLayoutData(int itemCount) {
    _layoutData.clear();
    for (int i = 0; i < itemCount; i++) {
      final type = _random.nextInt(3);
      _layoutData.add(_CardLayoutData(type: type, height: 350));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GeniusWalletConsts.space4),
              Text(
                'Crypto News',
                style: TextStyle(
                  color: GeniusWalletColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space12),
              Expanded(
                child: FutureStateWidget<List<NewsArticle>>(
                  future: _newsFuture,
                  // No custom `error:` override — falls through to the branded
                  // GWErrorState(onRetry: onRetry) with a working retry button.
                  onRetry: _retryNews,
                  onData: (articles) {
                    if (articles.isEmpty) {
                      return const Center(child: Text('No news found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _retryNews(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth <= 800;
                          final columns = getResponsiveColumnCount(
                            constraints.maxWidth,
                          );

                          if (_layoutData.length != articles.length) {
                            _generateLayoutData(articles.length);
                          }

                          return MasonryGridView.count(
                            crossAxisCount: columns,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              final layout = _layoutData[index];

                              Widget card;

                              if (isMobile) {
                                card = NewsCard(article: article);
                                return card;
                              } else {
                                switch (layout.type) {
                                  case 0:
                                  case 1:
                                  case 2:
                                    card = NewsCard(article: article);
                                    break;
                                  default:
                                    card = NewsCard(article: article);
                                }
                                return AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: card,
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space8),
            ],
          ),
        ),
      ),
    );
  }
}

int getResponsiveColumnCount(double width) {
  if (width < 400) {
    return 1;
  } else if (width < 800) {
    return 2;
  } else if (width < 900) {
    return 3;
  } else if (width < 1200) {
    return 4;
  } else if (width < 1500) {
    return 5;
  } else {
    return 6;
  }
}

class _CardLayoutData {
  final int type;
  final double height;

  _CardLayoutData({required this.type, required this.height});
}
