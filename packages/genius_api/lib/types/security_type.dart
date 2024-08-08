enum SecurityType { unknown, passphrase, keystore, privateKey, address }

SecurityType getSecurityTypeFromTab(String tab) {
  if (tab == 'Phrase') {
    return SecurityType.passphrase;
  }

  if (tab == 'Keystore') {
    return SecurityType.keystore;
  }

  if (tab == 'Private Key') {
    return SecurityType.privateKey;
  }

  if (tab == 'Address') {
    return SecurityType.address;
  }

  return SecurityType.unknown;
}
