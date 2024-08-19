/// Wallet Types
/// - tracking   - a Wallet that is tracked, only has address
/// - privateKey - a Wallet imported with private key, mnemonic won't be known, not an HDWallet
/// - menmonic   - a HD Wallet imported with mnemonic, private key can be derived
/// - keystore   - a Wallet imported with keystore, private key derived from password, mnemonic won't be known
enum WalletType { tracking, privateKey, mnemonic, keystore }
