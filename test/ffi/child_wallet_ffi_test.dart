// Pins the native struct layout against the SDK header, and proves the
// registrations wrapper copies every field before it frees anything, frees a
// non-null array exactly once, and never touches memory when the count is
// zero or the array pointer is null.
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';

/// Writes [value] into a 131-byte native char array, zero-padded -- the same
/// shape [GeniusAddress.address] holds.
void _writeAddress(ffi.Array<ffi.Char> field, String value) {
  for (var i = 0; i < 131; i++) {
    field[i] = i < value.length ? value.codeUnitAt(i) : 0;
  }
}

/// A native entry array of [count] registrations, each with a distinct
/// child/main address and sequence, so return order is provable.
ffi.Pointer<GeniusRegistrationDiscoveryEntry> _buildEntries(int count) {
  final entries = calloc<GeniusRegistrationDiscoveryEntry>(count);
  for (var i = 0; i < count; i++) {
    final entry = entries[i];
    _writeAddress(entry.child_address.address, 'child$i');
    _writeAddress(entry.main_address.address, 'main$i');
    entry.sequence = i;
  }
  return entries;
}

/// Writes [value] as UTF-8 bytes plus a NUL terminator into a metadata char
/// array field, mirroring how the native side fills a registration's strings.
void _writeMetadataField(ffi.Array<ffi.Char> field, String value) {
  final bytes = utf8.encode(value);
  for (var i = 0; i < bytes.length; i++) {
    field[i] = bytes[i];
  }
  field[bytes.length] = 0;
}

/// Reads a null-terminated char array back as UTF-8, byte-masked the same
/// way the production reader is -- so a byte above 0x7F never throws.
String _readField(ffi.Array<ffi.Char> field, int maxLength) {
  final units = <int>[];
  for (var i = 0; i < maxLength; i++) {
    final c = field[i];
    if (c == 0) {
      break;
    }
    units.add(c & 0xFF);
  }
  return utf8.decode(units, allowMalformed: true);
}

/// A `query` double that ignores the requested address and always reports
/// the scripted [entries]/[count]/[returnCode] -- driving every branch of
/// the wrapper without a live SDK.
int Function(
  ffi.Pointer<ffi.Char>,
  ffi.Pointer<ffi.Pointer<GeniusRegistrationDiscoveryEntry>>,
  ffi.Pointer<ffi.Uint64>,
)
_scriptedQuery({
  required ffi.Pointer<GeniusRegistrationDiscoveryEntry> entries,
  required int count,
  required int returnCode,
}) {
  return (_, outEntries, outCount) {
    outEntries.value = entries;
    outCount.value = count;
    return returnCode;
  };
}

void main() {
  group('struct layout', () {
    test('GeniusRegistrationMetadata is 392 bytes', () {
      expect(ffi.sizeOf<GeniusRegistrationMetadata>(), 392);
    });

    test('GeniusRegistrationDiscoveryEntry is 664 bytes', () {
      expect(ffi.sizeOf<GeniusRegistrationDiscoveryEntry>(), 664);
    });
  });

  group('registrations free contract', () {
    test('three entries come back in SDK order, copied before the free', () {
      final entries = _buildEntries(3);
      final freed = <ffi.Pointer<ffi.Void>>[];

      final result = collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: entries,
          count: 3,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: (ptr) {
          freed.add(ptr);
          calloc.free(ptr);
        },
      );

      expect(result.result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(result.entries.map((e) => e.childAddress), [
        'child0',
        'child1',
        'child2',
      ]);
      expect(result.entries.map((e) => e.mainAddress), [
        'main0',
        'main1',
        'main2',
      ]);
      expect(result.entries.map((e) => e.sequence), [0, 1, 2]);
      expect(freed, [entries.cast<ffi.Void>()]);
    });

    test('RET_OK with null entries and count 0 is empty, with no free', () {
      final freed = <ffi.Pointer<ffi.Void>>[];

      final result = collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: ffi.nullptr,
          count: 0,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: (ptr) {
          freed.add(ptr);
          calloc.free(ptr);
        },
      );

      expect(result.result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(result.entries, isEmpty);
      expect(freed, isEmpty);
    });

    test(
      'a non-OK code with a non-null array is empty, freed exactly once',
      () {
        final entries = _buildEntries(1);
        final freed = <ffi.Pointer<ffi.Void>>[];

        final result = collectChildRegistrations(
          'main',
          query: _scriptedQuery(entries: entries, count: 1, returnCode: 7),
          free: (ptr) {
            freed.add(ptr);
            calloc.free(ptr);
          },
        );

        expect(result.result, isNot(GeniusNodeReturnValue.GENIUS_NODE_RET_OK));
        expect(result.entries, isEmpty);
        expect(freed, [entries.cast<ffi.Void>()]);
      },
    );

    test('count 2 with a null array is empty, with no free', () {
      final freed = <ffi.Pointer<ffi.Void>>[];

      final result = collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: ffi.nullptr,
          count: 2,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: (ptr) {
          freed.add(ptr);
          calloc.free(ptr);
        },
      );

      expect(result.entries, isEmpty);
      expect(freed, isEmpty);
    });

    test('two consecutive calls each free only their own array, once', () {
      final firstEntries = _buildEntries(1);
      final secondEntries = _buildEntries(1);
      final freed = <ffi.Pointer<ffi.Void>>[];
      void free(ffi.Pointer<ffi.Void> ptr) {
        freed.add(ptr);
        calloc.free(ptr);
      }

      collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: firstEntries,
          count: 1,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: free,
      );
      collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: secondEntries,
          count: 1,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: free,
      );

      expect(freed, [
        firstEntries.cast<ffi.Void>(),
        secondEntries.cast<ffi.Void>(),
      ]);
    });

    test('the freed pointer is the exact one the query wrote', () {
      final entries = _buildEntries(1);
      ffi.Pointer<ffi.Void>? freedPointer;

      collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: entries,
          count: 1,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: (ptr) {
          freedPointer = ptr;
          calloc.free(ptr);
        },
      );

      expect(freedPointer, entries.cast<ffi.Void>());
    });

    test('entries carry metadata, a non-ASCII game id included', () {
      final entries = calloc<GeniusRegistrationDiscoveryEntry>(1);
      _writeAddress(entries[0].child_address.address, 'child0');
      _writeAddress(entries[0].main_address.address, 'main0');
      entries[0].sequence = 5;
      _writeMetadataField(entries[0].metadata.game_id, 'gamé');
      _writeMetadataField(entries[0].metadata.publisher_id, 'pub');
      _writeMetadataField(entries[0].metadata.dev_wallet, 'wallet');
      entries[0].metadata.peers_cut = 9;

      final result = collectChildRegistrations(
        'main',
        query: _scriptedQuery(
          entries: entries,
          count: 1,
          returnCode: GeniusNodeReturnValue.GENIUS_NODE_RET_OK.value,
        ),
        free: (ptr) => calloc.free(ptr),
      );

      final metadata = result.entries.single.metadata;
      expect(metadata.gameId, 'gamé');
      expect(metadata.publisherId, 'pub');
      expect(metadata.devWallet, 'wallet');
      expect(metadata.peersCut, 9);
    });
  });

  group('writeRegistrationMetadata', () {
    test('round-trips ASCII and non-ASCII fields', () {
      final out = calloc<GeniusRegistrationMetadata>();
      try {
        final ok = writeRegistrationMetadata(
          out,
          const ChildRegistrationMetadata(
            gameId: 'gamé',
            publisherId: 'pub',
            devWallet: 'wallet',
            peersCut: 42,
          ),
        );
        expect(ok, isTrue);
        expect(_readField(out.ref.game_id, 128), 'gamé');
        expect(_readField(out.ref.publisher_id, 128), 'pub');
        expect(_readField(out.ref.dev_wallet, 128), 'wallet');
        expect(out.ref.peers_cut, 42);
      } finally {
        calloc.free(out);
      }
    });

    test('a 127-byte field is accepted', () {
      final out = calloc<GeniusRegistrationMetadata>();
      try {
        final gameId = List.filled(127, 'a').join();
        final ok = writeRegistrationMetadata(
          out,
          ChildRegistrationMetadata(gameId: gameId),
        );
        expect(ok, isTrue);
        expect(_readField(out.ref.game_id, 128), gameId);
      } finally {
        calloc.free(out);
      }
    });

    test('a 128-byte non-ASCII field is rejected, struct stays zeroed', () {
      final out = calloc<GeniusRegistrationMetadata>();
      try {
        final gameId = List.filled(64, 'é').join(); // 128 UTF-8 bytes
        final ok = writeRegistrationMetadata(
          out,
          ChildRegistrationMetadata(gameId: gameId, peersCut: 7),
        );
        expect(ok, isFalse);
        expect(out.ref.game_id[0], 0);
        expect(out.ref.peers_cut, 0);
      } finally {
        calloc.free(out);
      }
    });

    test('peersCut -1 round-trips as -1', () {
      final out = calloc<GeniusRegistrationMetadata>();
      try {
        final ok = writeRegistrationMetadata(
          out,
          const ChildRegistrationMetadata(peersCut: -1),
        );
        expect(ok, isTrue);
        expect(out.ref.peers_cut, -1);
      } finally {
        calloc.free(out);
      }
    });
  });

  group('writeTokenValue', () {
    test('accepts a plain GNUS amount string', () {
      final out = calloc<GeniusTokenValue>();
      try {
        expect(writeTokenValue(out, '12.345678'), isTrue);
        expect(_readField(out.ref.value, 22), '12.345678');
      } finally {
        calloc.free(out);
      }
    });

    test('accepts a 21-byte string, rejects 22 bytes', () {
      final out = calloc<GeniusTokenValue>();
      try {
        expect(writeTokenValue(out, List.filled(21, '1').join()), isTrue);
        expect(writeTokenValue(out, List.filled(22, '1').join()), isFalse);
      } finally {
        calloc.free(out);
      }
    });
  });

  group('uint64Arg', () {
    test('accepts the full uint64 range, rejects outside it', () {
      expect(uint64Arg(BigInt.zero), 0);
      expect(uint64Arg((BigInt.one << 64) - BigInt.one), -1);
      expect(uint64Arg(-BigInt.one), isNull);
      expect(uint64Arg(BigInt.one << 64), isNull);
    });
  });

  group('writeHexAscii', () {
    test('matches lowercase hex and NUL-terminates', () {
      final key = Uint8List.fromList([0x00, 0x0f, 0xa5, 0xff, 0x10]);
      final out = Uint8List(key.length * 2 + 1)..fillRange(0, 11, 0x78);
      writeHexAscii(key, out);
      expect(ascii.decode(out.sublist(0, 10)), '000fa5ff10');
      expect(out[10], 0);
    });
  });

  group('writeTokenId', () {
    test('an odd-length hex id is padded, not truncated or thrown on', () {
      final out = calloc<GeniusTokenID>();
      try {
        writeTokenId(out, 'abc');
        expect(out.ref.data[0], 0x0a);
        expect(out.ref.data[1], 0xbc);
      } finally {
        calloc.free(out);
      }
    });

    test('null writes the all-zero default token', () {
      final out = calloc<GeniusTokenID>();
      try {
        out.ref.data[0] = 1;
        writeTokenId(out, null);
        expect(out.ref.data[0], 0);
      } finally {
        calloc.free(out);
      }
    });
  });
}
