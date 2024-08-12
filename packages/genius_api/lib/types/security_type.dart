enum SecurityType { unknown, passphrase, keystore, privateKey, address }

SecurityType getSecurityTypeFromTab(String tab) {
  if (tab.toLowerCase() == 'phrase') {
    return SecurityType.passphrase;
  }

  if (tab.toLowerCase() == 'keystore') {
    return SecurityType.keystore;
  }

  if (tab.toLowerCase() == 'private key') {
    return SecurityType.privateKey;
  }

  if (tab.toLowerCase() == 'address') {
    return SecurityType.address;
  }

  return SecurityType.unknown;
}
