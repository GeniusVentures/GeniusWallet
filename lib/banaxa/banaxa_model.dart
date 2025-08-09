class FiatCurrency {
  final String code;
  final String name;
  final String symbol;
  final List<PaymentMethod> supportedPaymentMethods;

  FiatCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.supportedPaymentMethods,
  });

  factory FiatCurrency.fromJson(Map<String, dynamic> json) {
    final List<PaymentMethod> methods =
        (json['supportedPaymentMethods'] as List<dynamic>?)
                ?.map((m) => PaymentMethod.fromJson(m))
                .toList() ??
            [];

    return FiatCurrency(
      code: json['id'] ?? '',
      name: json['description'] ?? '',
      symbol: json['symbol'] ?? '',
      supportedPaymentMethods: methods,
    );
  }

  @override
  String toString() => '$name ($code)';
}

class CryptoCurrency {
  final String code;
  final String name;
  final List<Blockchain> blockchains;

  CryptoCurrency({
    required this.code,
    required this.name,
    required this.blockchains,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    final List<Blockchain> chains = (json['blockchains'] as List<dynamic>?)
            ?.map((b) => Blockchain.fromJson(b))
            .toList() ??
        [];

    return CryptoCurrency(
      code: json['id'] ?? '',
      name: json['description'] ?? '',
      blockchains: chains,
    );
  }

  Blockchain? get defaultBlockchain {
    if (blockchains.isEmpty) return null;
    return blockchains.firstWhere(
      (b) => b.isDefault,
      orElse: () => blockchains.first,
    );
  }

  @override
  String toString() => '$name ($code)';
}

class PaymentMethod {
  final String id;
  final String name;
  final double minimum;
  final double maximum;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.minimum,
    required this.maximum,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      minimum: (json['minimum'] != null)
          ? double.tryParse(json['minimum'].toString()) ?? 0.0
          : 0.0,
      maximum: (json['maximum'] != null)
          ? double.tryParse(json['maximum'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class OrderResponse {
  final String orderId;
  final String checkoutUrl;
  OrderResponse({required this.orderId, required this.checkoutUrl});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['id'] ?? '',
      checkoutUrl: json['checkoutUrl'] ?? '',
    );
  }
}

class OrderStatus {
  final String orderId;
  final String status;
  final double fiatAmount;
  final double cryptoAmount;
  final String fiatCurrency;
  final String cryptoCurrency;
  OrderStatus({
    required this.orderId,
    required this.status,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.fiatCurrency,
    required this.cryptoCurrency,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      orderId: json['id'] ?? '',
      status: json['status'] ?? '',
      fiatAmount: (json['fiat_amount'] is num)
          ? (json['fiat_amount'] as num).toDouble()
          : 0.0,
      cryptoAmount: (json['coin_amount'] is num)
          ? (json['coin_amount'] as num).toDouble()
          : 0.0,
      fiatCurrency: json['fiat_code'] ?? '',
      cryptoCurrency: json['coin_code'] ?? '',
    );
  }
}

class Blockchain {
  final String id;
  final String description;
  final bool isDefault;
  final String? address;
  final String? network;
  final double minimum;

  Blockchain({
    required this.id,
    required this.description,
    required this.isDefault,
    this.address,
    this.network,
    required this.minimum,
  });

  factory Blockchain.fromJson(Map<String, dynamic> json) {
    return Blockchain(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      isDefault: json['isDefaultBlockchain'] ?? false,
      address: json['address'],
      network: json['network'],
      minimum: (json['minimum'] != null)
          ? double.tryParse(json['minimum'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class Quote {
  final String paymentMethodId;
  final String cryptoAmount;
  final String fiatAmount;
  final String processingFee;
  final String networkFee;

  Quote({
    required this.paymentMethodId,
    required this.cryptoAmount,
    required this.fiatAmount,
    required this.processingFee,
    required this.networkFee,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      paymentMethodId: json['paymentMethodId'] as String,
      cryptoAmount: json['cryptoAmount'] as String,
      fiatAmount: json['fiatAmount'] as String,
      processingFee: json['processingFee'] as String,
      networkFee: json['networkFee'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodId': paymentMethodId,
      'cryptoAmount': cryptoAmount,
      'fiatAmount': fiatAmount,
      'processingFee': processingFee,
      'networkFee': networkFee,
    };
  }
}


class CryptoInfo {
  final String id;
  final String blockchain;
  final String? address;
  final String network;

  CryptoInfo({
    required this.id,
    required this.blockchain,
    this.address,
    required this.network,
  });

  factory CryptoInfo.fromJson(Map<String, dynamic> json) {
    return CryptoInfo(
      id: json['id'] as String,
      blockchain: json['blockchain'] as String,
      address: json['address'] as String?,
      network: json['network'] as String,
    );
  }
}

class OrderResponseModel {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String? externalId;
  final String? externalCustomerId;
  final String? country;
  final String orderStatusUrl;
  final String orderType;
  final CryptoInfo crypto;
  final String fiat;
  final String fiatAmount;
  final String cryptoAmount;
  final String paymentMethodId;
  final String paymentMethodName;
  final String processingFee;
  final String networkFee;
  final String? transactionHash;
  final String walletAddress;
  final String? walletAddressTag;
  final String status;
  final dynamic metadata;

  OrderResponseModel({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.externalId,
    this.externalCustomerId,
    this.country,
    required this.orderStatusUrl,
    required this.orderType,
    required this.crypto,
    required this.fiat,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.processingFee,
    required this.networkFee,
    this.transactionHash,
    required this.walletAddress,
    this.walletAddressTag,
    required this.status,
    this.metadata,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      id: json['id'] as String,
      externalId: json['externalId'] as String?,
      externalCustomerId: json['externalCustomerId'] as String?,
      country: json['country'] as String?,
      orderStatusUrl: json['orderStatusUrl'] as String,
      orderType: json['orderType'] as String,
      crypto: CryptoInfo.fromJson(json['crypto'] as Map<String, dynamic>),
      fiat: json['fiat'] as String,
      fiatAmount: json['fiatAmount'] as String,
      cryptoAmount: json['cryptoAmount'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      paymentMethodName: json['paymentMethodName'] as String,
      processingFee: json['processingFee'] as String,
      networkFee: json['networkFee'] as String,
      transactionHash: json['transactionHash'] as String?,
      walletAddress: json['walletAddress'] as String,
      walletAddressTag: json['walletAddressTag'] as String?,
      status: json['status'] as String,
      metadata: json['metadata'],
    );
  }
}
