part of 'transaction_details_cubit.dart';

class TransactionDetailsState extends Equatable {
  final Transaction selectedTransaction;
  const TransactionDetailsState({
    required this.selectedTransaction,
  });

  @override
  List<Object> get props => [selectedTransaction];
}
