// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransferRecipientsAdapter extends TypeAdapter<TransferRecipients> {
  @override
  final int typeId = 7;

  @override
  TransferRecipients read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransferRecipients(
      toAddr: fields[0] as String,
      amount: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransferRecipients obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.toAddr)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferRecipientsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 8;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      hash: fields[0] as String,
      fromAddress: fields[1] as String,
      recipients: (fields[2] as List).cast<TransferRecipients>(),
      timeStamp: fields[3] as DateTime,
      transactionDirection: fields[4] as TransactionDirection,
      fees: fields[5] as String,
      coinSymbol: fields[6] as String,
      transactionStatus: fields[7] as TransactionStatus,
      isSGNUS: fields[8] as bool?,
      type: fields[9] as TransactionType?,
      fromIconUrl: fields[10] as String?,
      fromAmount: fields[11] as String?,
      toIconUrl: fields[12] as String?,
      toAmount: fields[13] as String?,
      exchangeRate: fields[14] as String?,
      fromSymbol: fields[15] as String?,
      toSymbol: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.fromAddress)
      ..writeByte(2)
      ..write(obj.recipients)
      ..writeByte(3)
      ..write(obj.timeStamp)
      ..writeByte(4)
      ..write(obj.transactionDirection)
      ..writeByte(5)
      ..write(obj.fees)
      ..writeByte(6)
      ..write(obj.coinSymbol)
      ..writeByte(7)
      ..write(obj.transactionStatus)
      ..writeByte(8)
      ..write(obj.isSGNUS)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.fromIconUrl)
      ..writeByte(11)
      ..write(obj.fromAmount)
      ..writeByte(12)
      ..write(obj.toIconUrl)
      ..writeByte(13)
      ..write(obj.toAmount)
      ..writeByte(14)
      ..write(obj.exchangeRate)
      ..writeByte(15)
      ..write(obj.fromSymbol)
      ..writeByte(16)
      ..write(obj.toSymbol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionDirectionAdapter extends TypeAdapter<TransactionDirection> {
  @override
  final int typeId = 4;

  @override
  TransactionDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionDirection.sent;
      case 1:
        return TransactionDirection.received;
      default:
        return TransactionDirection.sent;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionDirection obj) {
    switch (obj) {
      case TransactionDirection.sent:
        writer.writeByte(0);
        break;
      case TransactionDirection.received:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionStatusAdapter extends TypeAdapter<TransactionStatus> {
  @override
  final int typeId = 5;

  @override
  TransactionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionStatus.pending;
      case 1:
        return TransactionStatus.cancelled;
      case 2:
        return TransactionStatus.completed;
      case 3:
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionStatus obj) {
    switch (obj) {
      case TransactionStatus.pending:
        writer.writeByte(0);
        break;
      case TransactionStatus.cancelled:
        writer.writeByte(1);
        break;
      case TransactionStatus.completed:
        writer.writeByte(2);
        break;
      case TransactionStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 6;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.transfer;
      case 1:
        return TransactionType.mint;
      case 2:
        return TransactionType.escrow;
      case 3:
        return TransactionType.process;
      case 4:
        return TransactionType.escrowRelease;
      case 5:
        return TransactionType.purchase;
      case 6:
        return TransactionType.swap;
      default:
        return TransactionType.transfer;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.transfer:
        writer.writeByte(0);
        break;
      case TransactionType.mint:
        writer.writeByte(1);
        break;
      case TransactionType.escrow:
        writer.writeByte(2);
        break;
      case TransactionType.process:
        writer.writeByte(3);
        break;
      case TransactionType.escrowRelease:
        writer.writeByte(4);
        break;
      case TransactionType.purchase:
        writer.writeByte(5);
        break;
      case TransactionType.swap:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
