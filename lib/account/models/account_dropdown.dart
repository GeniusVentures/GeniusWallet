class AccountDropdown {
  final String name;
  final String balance;
  final bool isWatched;

  AccountDropdown({
    required this.name,
    required this.balance,
    this.isWatched = false,
  });
}
