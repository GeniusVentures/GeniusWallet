class OrderLinker {
  static final OrderLinker instance = OrderLinker._();
  OrderLinker._();

  final Map<String, String> _byExt = {};
  void put(String extOrderId, String orderId) => _byExt[extOrderId] = orderId;
  String? get(String extOrderId) => _byExt[extOrderId];
}
