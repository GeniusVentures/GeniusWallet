import 'dart:developer' as developer;

/// Banxa order diagnostics. Callers pass ids, status words and amounts only:
/// never keys, emails, card data or full addresses.
void banxaLog(String message) => developer.log(message, name: 'banxa');
