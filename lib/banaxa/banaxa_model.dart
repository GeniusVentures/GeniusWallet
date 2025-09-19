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
  final String? externalId;
  final String? externalCustomerId;
  final String? country;
  final String? orderStatusUrl;
  final String orderType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String fiatCurrency;
  final double fiatAmount;

  final String cryptoCurrency;
  final String blockchain;
  final String? walletAddress;
  final String? walletAddressTag;
  final double? cryptoAmount;

  final String? paymentMethodId;
  final String? paymentMethodName;
  final double? processingFee;
  final double? networkFee;
  final String? transactionHash;
  final String? metadata;

  OrderStatus({
    required this.orderId,
    this.externalId,
    this.externalCustomerId,
    this.country,
    this.orderStatusUrl,
    required this.orderType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.fiatCurrency,
    required this.fiatAmount,
    required this.cryptoCurrency,
    required this.blockchain,
    this.walletAddress,
    this.walletAddressTag,
    this.cryptoAmount,
    this.paymentMethodId,
    this.paymentMethodName,
    this.processingFee,
    this.networkFee,
    this.transactionHash,
    this.metadata,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      orderId: json['id'] ?? '',
      externalId: json['externalId'],
      externalCustomerId: json['externalCustomerId'],
      country: json['country'],
      orderStatusUrl: json['orderStatusUrl'],
      orderType: json['orderType'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      fiatCurrency: json['fiat'] ?? '',
      fiatAmount: double.tryParse(json['fiatAmount']?.toString() ?? '') ?? 0.0,
      cryptoCurrency: json['crypto']?['id'] ?? '',
      blockchain: json['crypto']?['blockchain'] ?? '',
      walletAddress: json['walletAddress'],
      walletAddressTag: json['walletAddressTag'],
      cryptoAmount: double.tryParse(json['cryptoAmount']?.toString() ?? ''),
      paymentMethodId: json['paymentMethodId'],
      paymentMethodName: json['paymentMethodName'],
      processingFee: double.tryParse(json['processingFee']?.toString() ?? ''),
      networkFee: double.tryParse(json['networkFee']?.toString() ?? ''),
      transactionHash: json['transactionHash'],
      metadata: json['metadata']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': orderId,
      'externalId': externalId,
      'externalCustomerId': externalCustomerId,
      'country': country,
      'orderStatusUrl': orderStatusUrl,
      'orderType': orderType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fiat': fiatCurrency,
      'fiatAmount': fiatAmount,
      'crypto': {
        'id': cryptoCurrency,
        'blockchain': blockchain,
      },
      'walletAddress': walletAddress,
      'walletAddressTag': walletAddressTag,
      'cryptoAmount': cryptoAmount,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'processingFee': processingFee,
      'networkFee': networkFee,
      'transactionHash': transactionHash,
      'metadata': metadata,
    };
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

class OrdersResponse {
  final List<Order> orders;
  final int total;
  final int pageTotal;

  OrdersResponse({
    required this.orders,
    required this.total,
    required this.pageTotal,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      pageTotal: json['pageTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((e) => e.toJson()).toList(),
      'total': total,
      'pageTotal': pageTotal,
    };
  }
}

class Order {
  final String id;
  final String externalId;
  final String externalCustomerId;
  final String? country;
  final String orderStatusUrl;
  final String orderType;
  final Crypto crypto;
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
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.externalId,
    required this.externalCustomerId,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      externalId: json['externalOrderId'], // matches API field
      externalCustomerId: json['externalCustomerId'],
      country: json['country'],
      orderStatusUrl: json['orderStatusUrl'],
      orderType: json['orderType'],
      crypto: Crypto.fromJson(json['crypto']),
      fiat: json['fiat'],
      fiatAmount: json['fiatAmount'],
      cryptoAmount: json['cryptoAmount'],
      paymentMethodId: json['paymentMethodId'],
      paymentMethodName: json['paymentMethodName'],
      processingFee: json['processingFee'],
      networkFee: json['networkFee'],
      transactionHash: json['transactionHash'],
      walletAddress: json['walletAddress'],
      walletAddressTag: json['walletAddressTag'],
      status: json['status'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalOrderId': externalId,
      'externalCustomerId': externalCustomerId,
      'country': country,
      'orderStatusUrl': orderStatusUrl,
      'orderType': orderType,
      'crypto': crypto.toJson(),
      'fiat': fiat,
      'fiatAmount': fiatAmount,
      'cryptoAmount': cryptoAmount,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'processingFee': processingFee,
      'networkFee': networkFee,
      'transactionHash': transactionHash,
      'walletAddress': walletAddress,
      'walletAddressTag': walletAddressTag,
      'status': status,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Crypto {
  final String id; // e.g. "BTC" / "ETH"
  final String blockchain; // e.g. "BTC" / "ETH"
  final String? address; // may be null
  final String network; // may be "" (empty) in sandbox

  Crypto({
    required this.id,
    required this.blockchain,
    this.address,
    required this.network,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: (json['id'] ?? '') as String,
      blockchain: (json['blockchain'] ?? '') as String,
      address: json['address'] as String?, 
      network: (json['network'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blockchain': blockchain,
      'address': address,
      'network': network,
    };
  }
}

class BanxaKycResponse {
  final String accountId;
  final String accountReference;

  BanxaKycResponse({
    required this.accountId,
    required this.accountReference,
  });

  factory BanxaKycResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final account = data['account'] ?? {};
    return BanxaKycResponse(
      accountId: account['account_id'] ?? '',
      accountReference: account['account_reference'] ?? '',
    );
  }
}
