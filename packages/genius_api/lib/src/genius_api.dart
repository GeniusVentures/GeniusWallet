import 'dart:async';

class GeniusApi {
  const GeniusApi();
  Future<List<String>> getRecoveryPhrase() async {
    ///TODO: Implement recovery phrase generation here with API or proper gen.
    return List.generate(16, (index) => 'word${index + 1}');
  }
}
