import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> _dartFiles(String dir) {
  return Directory(dir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

String _code(File file) {
  return file
      .readAsLinesSync()
      .where((line) => !line.trim().startsWith('//'))
      .join('\n');
}

String _name(File file) => file.path.replaceAll('\\', '/');

void main() {
  final libFiles = _dartFiles('lib');

  test('no 40-character hex string literal anywhere in lib', () {
    final literal = RegExp('[\'"][0-9a-fA-F]{40}[\'"]');
    final hits = [
      for (final f in libFiles)
        if (literal.hasMatch(_code(f))) _name(f),
    ];
    expect(hits, isEmpty);
  });

  test('the key header is named in one file only', () {
    final hits = [
      for (final f in libFiles)
        if (_code(f).contains('x-api-key')) _name(f),
    ];
    expect(hits.length, 1);
    expect(hits.single, endsWith('lib/banxa/banxa_api_services.dart'));
  });

  test('the key define is read in one file only', () {
    final hits = [
      for (final f in libFiles)
        if (_code(f).contains('GW_BANXA_API_KEY')) _name(f),
    ];
    expect(hits.length, 1);
    expect(hits.single, endsWith('lib/banxa/banxa_env.dart'));
  });
}
