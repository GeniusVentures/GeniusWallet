// Pins the native struct layout against the SDK header, and proves the
// registrations wrapper copies every field before it frees anything, frees a
// non-null array exactly once, and never touches memory when the count is
// zero or the array pointer is null.
import 'dart:ffi' as ffi;

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
  });
}
