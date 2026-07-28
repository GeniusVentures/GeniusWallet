import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:hive_ce/hive.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

const Duration cacheDuration = Duration(minutes: 2);

Future<List<NewsArticle>> fetchCoinTelegraphNews() async {
  const rssUrl = 'https://cointelegraph.com/rss';

  // Open separate boxes for news articles and timestamp
  final Box<NewsArticle> newsBox = Hive.box<NewsArticle>(coinTelegraphNewsBox);
  final Box<String> timestampBox = Hive.box<String>(coinTelegraphTimestampBox);

  final cachedNews = newsBox.values.toList();
  final cachedTimestamp = timestampBox.get('timestamp');

  final now = DateTime.now();

  // If cache exists and is less than 2 minutes old, return it
  if (cachedNews.isNotEmpty && cachedTimestamp != null) {
    final cacheAge = now.difference(DateTime.parse(cachedTimestamp));
    if (cacheAge < cacheDuration) {
      // debugPrint('✅ Returning cached news');
      return cachedNews;
    }
  }

  try {
    final response = await http.get(Uri.parse(rssUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load RSS feed');
    }

    final document = XmlDocument.parse(utf8.decode(response.bodyBytes));
    final items = document.findAllElements('item');

    final newsList = items.map((node) {
      final unescape = HtmlUnescape();
      final title = unescape.convert(
        node.getElement('title')?.text ?? 'No title',
      );
      final link = node.getElement('link')?.text ?? '';
      final description = unescape.convert(
        node.getElement('description')?.text ?? '',
      );
      final rawDate = node.getElement('pubDate')?.text ?? '';

      DateTime? parsedDate;
      try {
        parsedDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(rawDate);
      } catch (e) {
        parsedDate = null;
      }

      // Store the INSTANT (ISO-8601), not a formatted "2 hours ago" string:
      // the label is now rendered from this at read time (NewsArticle.relative
      // Time), so a cached article's age advances instead of freezing at fetch.
      // Fall back to the raw RSS date when unparseable — relativeTime shows it
      // verbatim rather than an empty timestamp.
      final String storedDate =
          parsedDate?.toUtc().toIso8601String() ?? rawDate;

      String? imageUrl;

      final enclosure = node.getElement('enclosure');
      if (enclosure != null &&
          enclosure.getAttribute('type')?.contains('image') == true) {
        imageUrl = enclosure.getAttribute('url');
      }

      if (imageUrl == null && description.contains('<img')) {
        final regex = RegExp(r'<img.*?src="(.*?)"');
        final match = regex.firstMatch(description);
        if (match != null) {
          imageUrl = match.group(1);
        }
      }

      return NewsArticle(
        title: title,
        link: link,
        description: description,
        pubDate: storedDate,
        imageUrl: imageUrl,
      );
    }).toList();

    // Clear old cache before inserting new
    await newsBox.clear();
    await newsBox.addAll(newsList);
    await timestampBox.put('timestamp', now.toIso8601String());

    //debugPrint('🆕 Returning fresh news and updating cache');

    return newsList;
  } catch (e) {
    debugPrint('❌ Failed fetching news: $e');

    if (cachedNews.isNotEmpty) {
      debugPrint('‼️ Returning cached news data due to API failure');
      return cachedNews;
    }

    return [];
  }
}
