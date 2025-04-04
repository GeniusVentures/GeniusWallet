// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_gecko_coin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoinGeckoCoinAdapter extends TypeAdapter<CoinGeckoCoin> {
  @override
  final int typeId = 0;

  @override
  CoinGeckoCoin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinGeckoCoin(
      id: fields[0] as String,
      symbol: fields[1] as String,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CoinGeckoCoin obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinGeckoCoinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
