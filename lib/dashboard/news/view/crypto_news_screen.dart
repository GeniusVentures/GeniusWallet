import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:genius_wallet/services/coin_telegraph/coin_telegraph_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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

  void _generateLayoutData(int itemCount) {
    _layoutData.clear();
    for (int i = 0; i < itemCount; i++) {
      final type = _random.nextInt(3); // 0, 1, 2
      _layoutData.add(_CardLayoutData(type: type, height: 350));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Crypto News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                  child: FutureBuilder<List<NewsArticle>>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final articles = snapshot.data;

                  if (articles == null || articles.isEmpty) {
                    return const Center(child: Text('No news found.'));
                  }

                  // Only pass to LayoutBuilder AFTER all null/empty checks
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth <= 800;
                      final columns =
                          getResponsiveColumnCount(constraints.maxWidth);

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
                            // Mobile layout - always show mobile cards
                            card = NewsCard(article: article);
                            return card;
                          } else {
                            // Desktop layout with variation
                            switch (layout.type) {
                              case 0: // Theres also a WideNewsCard that is a full image with text..
                                card = NewsCard(article: article);
                                break;
                              case 1:
                                card = NewsCard(article: article);
                                break;
                              case 2:
                                card = NewsCard(article: article);
                                break;
                              default:
                                card = NewsCard(article: article);
                            }

                            // return ConstrainedBox(
                            //   constraints: BoxConstraints(
                            //     minHeight: 300,
                            //     maxHeight: layout.height,
                            //   ),
                            //   child: card,
                            // );
                            return AspectRatio(
                              aspectRatio: 16 / 9, // or 4 / 3
                              child: card,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              )),
              const SizedBox(height: 16)
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
