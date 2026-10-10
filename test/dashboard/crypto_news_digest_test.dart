import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/news/view/crypto_news_screen.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:hive_ce/hive.dart';

import '../banxa/gw_pump.dart';

/// At phone width the feed is one hero story then ONE digest panel; refresh
/// shows on mouse platforms only. The feed is seeded into the Hive cache so
/// `fetchCoinTelegraphNews` never touches the network.
void main() {
  late Directory dir;
  final articles = [
    for (var i = 0; i < 6; i++)
      NewsArticle(
        title: 'Headline number $i',
        link: 'https://example.com/$i',
        description: 'Dek number $i',
        pubDate: DateTime.now().toUtc().toIso8601String(),
      ),
  ];

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('gw_news_digest');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NewsArticleAdapter());
    }
    final news = await Hive.openBox<NewsArticle>(coinTelegraphNewsBox);
    final stamp = await Hive.openBox<String>(coinTelegraphTimestampBox);
    await news.addAll(articles);
    await stamp.put('timestamp', DateTime.now().toIso8601String());
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(coinTelegraphNewsBox);
    await Hive.deleteBoxFromDisk(coinTelegraphTimestampBox);
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<void> pumpScreen(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(gwHost(const CryptoNewsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The image placeholders and error fallbacks are not under test.
    tester.takeException();
  }

  Future<void> end(WidgetTester tester) async {
    // No image timer may outlive the test.
    await tester.pumpWidget(const SizedBox());
    tester.takeException();
  }

  testWidgets('phone: one hero, then every other story in ONE digest panel', (
    tester,
  ) async {
    await pumpScreen(tester, const Size(390, 844));

    // The hero is article 0, and it is the only place its title appears.
    expect(find.text(articles[0].title), findsOneWidget);

    final panel = find.byType(DashboardScrollContainer);
    expect(panel, findsOneWidget);
    for (var i = 1; i < articles.length; i++) {
      expect(
        find.descendant(of: panel, matching: find.text(articles[i].title)),
        findsOneWidget,
        reason: 'story $i is a row in the digest',
      );
    }
    expect(
      find.descendant(of: panel, matching: find.text(articles[0].title)),
      findsNothing,
      reason: 'the hero is not repeated in the digest',
    );
    // The search field moved into the panel.
    expect(
      find.descendant(of: panel, matching: find.byType(TextField)),
      findsOneWidget,
    );

    expect(find.text('Next up'), findsNothing);
    expect(find.byTooltip('Refresh'), findsNothing);

    await end(tester);
  });

  testWidgets('phone: a search matching only the hero counts it', (
    tester,
  ) async {
    await pumpScreen(tester, const Size(390, 844));

    await tester.enterText(find.byType(TextField), articles[0].title);
    await tester.pump(const Duration(milliseconds: 300));
    tester.takeException();

    expect(find.text('1 RESULTS'), findsOneWidget);
    expect(find.textContaining('No headlines match'), findsNothing);

    await end(tester);
  });

  for (final size in const [Size(1280, 900), Size(390, 844)]) {
    testWidgets('desktop at ${size.width.toInt()}px keeps the refresh glyph', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await pumpScreen(tester, size);

      expect(find.byTooltip('Refresh'), findsOneWidget);

      await end(tester);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
