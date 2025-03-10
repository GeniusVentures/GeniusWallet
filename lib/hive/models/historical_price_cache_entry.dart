import 'package:hive/hive.dart';

part 'historical_price_cache_entry.g.dart'; // Will generate this adapter

@HiveType(typeId: 2)
class HistoricalPriceCacheEntry {
  @HiveField(0)
  final Map<String, double> data; // Map<String, double> for Hive compatibility

  @HiveField(1)
  final int timestamp; // UNIX timestamp (seconds)

  HistoricalPriceCacheEntry({
    required this.data,
    required this.timestamp,
  });

  /// Convert from Map<int, double> to Map<String, double>
  factory HistoricalPriceCacheEntry.fromIntMap(
      Map<int, double> intMap, int timestamp) {
    final stringMap =
        intMap.map((key, value) => MapEntry(key.toString(), value));
    return HistoricalPriceCacheEntry(data: stringMap, timestamp: timestamp);
  }

  /// Convert to Map<int, double> for app use
  Map<int, double> toIntMap() {
    return data.map((key, value) => MapEntry(int.parse(key), value));
  }
}
