// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_gecko_market_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoinGeckoMarketDataAdapter extends TypeAdapter<CoinGeckoMarketData> {
  @override
  final typeId = 1;

  @override
  CoinGeckoMarketData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinGeckoMarketData(
      id: fields[0] as String,
      symbol: fields[1] as String,
      name: fields[2] as String,
      imageUrl: fields[3] as String,
      currentPrice: (fields[4] as num).toDouble(),
      marketCap: (fields[5] as num).toDouble(),
      marketCapRank: (fields[6] as num).toInt(),
      fullyDilutedValuation: (fields[7] as num).toDouble(),
      totalVolume: (fields[8] as num).toDouble(),
      high24h: (fields[9] as num).toDouble(),
      low24h: (fields[10] as num).toDouble(),
      priceChange24h: (fields[11] as num).toDouble(),
      priceChangePercentage24h: (fields[12] as num).toDouble(),
      marketCapChange24h: (fields[13] as num).toDouble(),
      marketCapChangePercentage24h: (fields[14] as num).toDouble(),
      circulatingSupply: (fields[15] as num).toDouble(),
      totalSupply: (fields[16] as num).toDouble(),
      maxSupply: (fields[17] as num?)?.toDouble(),
      ath: (fields[18] as num).toDouble(),
      athChangePercentage: (fields[19] as num).toDouble(),
      athDate: fields[20] as DateTime,
      atl: (fields[21] as num).toDouble(),
      atlChangePercentage: (fields[22] as num).toDouble(),
      atlDate: fields[23] as DateTime,
      lastUpdated: fields[24] as DateTime,
      sparkline: (fields[25] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, CoinGeckoMarketData obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.currentPrice)
      ..writeByte(5)
      ..write(obj.marketCap)
      ..writeByte(6)
      ..write(obj.marketCapRank)
      ..writeByte(7)
      ..write(obj.fullyDilutedValuation)
      ..writeByte(8)
      ..write(obj.totalVolume)
      ..writeByte(9)
      ..write(obj.high24h)
      ..writeByte(10)
      ..write(obj.low24h)
      ..writeByte(11)
      ..write(obj.priceChange24h)
      ..writeByte(12)
      ..write(obj.priceChangePercentage24h)
      ..writeByte(13)
      ..write(obj.marketCapChange24h)
      ..writeByte(14)
      ..write(obj.marketCapChangePercentage24h)
      ..writeByte(15)
      ..write(obj.circulatingSupply)
      ..writeByte(16)
      ..write(obj.totalSupply)
      ..writeByte(17)
      ..write(obj.maxSupply)
      ..writeByte(18)
      ..write(obj.ath)
      ..writeByte(19)
      ..write(obj.athChangePercentage)
      ..writeByte(20)
      ..write(obj.athDate)
      ..writeByte(21)
      ..write(obj.atl)
      ..writeByte(22)
      ..write(obj.atlChangePercentage)
      ..writeByte(23)
      ..write(obj.atlDate)
      ..writeByte(24)
      ..write(obj.lastUpdated)
      ..writeByte(25)
      ..write(obj.sparkline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinGeckoMarketDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
