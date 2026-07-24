import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/logs/submit_logs_screen.dart';

/// Smallest check that fails if the two non-trivial bits of the Feedback tab
/// break: the FeedbackType → Sentry-tag mapping and the attachment disposition
/// (whole / tail / skip-empty) that BOTH the send path and the receipt chips
/// derive from. No widget pump, no Hive, no fixtures — exactly the shape of
/// test/markets_sort_test.dart.
void main() {
  const mib = 1024 * 1024;

  test('FeedbackType.tag maps bug/idea/question', () {
    expect(FeedbackType.bug.tag, 'bug');
    expect(FeedbackType.idea.tag, 'idea');
    expect(FeedbackType.question.tag, 'question');
  });

  test('each FeedbackType has a distinct label and placeholder', () {
    final labels = {for (final t in FeedbackType.values) t.label};
    final placeholders = {for (final t in FeedbackType.values) t.placeholder};
    expect(labels, {'Bug', 'Idea', 'Question'});
    // Distinct placeholders — the chooser genuinely swaps the field hint.
    expect(placeholders.length, FeedbackType.values.length);
  });

  test('a small non-empty file is attached whole under its own name', () {
    final d = attachmentDispositionFor(size: 500, maxBytes: mib, payloadLength: 500);
    expect(d, AttachmentDisposition.whole);
    expect(attachmentNameFor('sgnslog.log', d), 'sgnslog.log');
  });

  test('an over-cap file is tail-trimmed and renamed', () {
    final d =
        attachmentDispositionFor(size: 2 * mib, maxBytes: mib, payloadLength: mib);
    expect(d, AttachmentDisposition.tail);
    expect(attachmentNameFor('sgnslog.log', d), 'sgnslog.log.tail.log');
  });

  test('a zero-byte file is skipped (Android native-envelope guard, M-01)', () {
    // whole-sized but empty, and over-cap but empty — both skip.
    expect(
      attachmentDispositionFor(size: 0, maxBytes: mib, payloadLength: 0),
      AttachmentDisposition.skipEmpty,
    );
    expect(
      attachmentDispositionFor(size: 5 * mib, maxBytes: mib, payloadLength: 0),
      AttachmentDisposition.skipEmpty,
    );
    // skipEmpty never gets the tail suffix.
    expect(
      attachmentNameFor('sgnslog.log', AttachmentDisposition.skipEmpty),
      'sgnslog.log',
    );
  });
}
