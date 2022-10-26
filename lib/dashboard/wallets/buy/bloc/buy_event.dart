abstract class BuyEvent {}

class ConvertCurrency extends BuyEvent {
  String amount;

  ConvertCurrency({required this.amount});
}
