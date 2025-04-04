// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historical_price_cache_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoricalPriceCacheEntryAdapter
    extends TypeAdapter<HistoricalPriceCacheEntry> {
  @override
  final int typeId = 2;

  @override
  HistoricalPriceCacheEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoricalPriceCacheEntry(
      data: (fields[0] as Map).cast<String, double>(),
      timestamp: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HistoricalPriceCacheEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoricalPriceCacheEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
