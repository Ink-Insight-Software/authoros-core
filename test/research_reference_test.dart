import 'dart:convert';
import 'dart:typed_data';

import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/built_in_connection_types.dart';
import 'package:authoros_core/built_in_record_types.dart';
import 'package:authoros_core/record_types.dart';
import 'package:authoros_core/record_validation.dart';
import 'package:authoros_core/research_reference.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 16);
  final png = Uint8List.fromList(
      [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0]);
  final pdf = Uint8List.fromList(utf8.encode('%PDF-1.4\n...'));

  test('a reference is an image or a PDF, read from its bytes', () {
    expect(ResearchReferences.sniff(png), 'image/png');
    expect(ResearchReferences.sniff(pdf), 'application/pdf');
    expect(ResearchReferences.sniff(Uint8List.fromList(utf8.encode('%PD'))),
        isNull);
    expect(ResearchReferences.sniff(Uint8List.fromList(utf8.encode('<svg>'))),
        isNull);
    expect(ResearchReferences.isImage('image/png'), isTrue);
    expect(ResearchReferences.isImage('application/pdf'), isFalse);
  });

  test('empty, too large and unknown files are refused, with a reason', () {
    expect(ResearchReferences.rejection(Uint8List(0)),
        ResearchReferenceRejection.empty);
    final big = Uint8List(ResearchReferences.maxBytes + 1)
      ..setAll(0, utf8.encode('%PDF-'));
    expect(
        ResearchReferences.rejection(big), ResearchReferenceRejection.tooLarge);
    expect(ResearchReferences.rejection(Uint8List.fromList([1, 2, 3])),
        ResearchReferenceRejection.unsupportedType);
    expect(ResearchReferences.rejection(pdf), isNull);
    expect(ResearchReferenceRejection.tooLarge.message, contains('10 MB'));
    // Every file a world accepts is one its backup can read back.
    expect(ResearchReferences.maxBytes, lessThan(16 * 1024 * 1024));
  });

  test('a reference is a valid, non-canon research entry of kind Reference',
      () {
    final reference = ResearchReferences.newRecord(
      id: 'reference-chart',
      projectId: 'world-a',
      title: ' Admiralty chart ',
      caption: 'The harbour in 1820',
      notes: 'Depths in fathoms.',
      credit: 'UK Hydrographic Office',
      now: now,
    );
    expect(reference.canonStatus, CanonStatus.nonCanon);
    expect(reference.typeId, 'research-entry');
    expect(reference.title, 'Admiralty chart');
    expect(ResearchReferences.isReference(reference), isTrue);
    expect(ResearchReferences.captionOf(reference), 'The harbour in 1820');
    expect(ResearchReferences.notesOf(reference), 'Depths in fathoms.');
    expect(ResearchReferences.creditOf(reference), 'UK Hydrographic Office');
    expect(ResearchReferences.sourceUrlOf(reference), '');
    expect(reference.fields.containsKey('sourceUrl'), isFalse);

    final types = RecordTypeRegistry(BuiltInRecordTypes.definitions);
    final result = RecordValidator(types).validate(
      reference,
      projectId: 'world-a',
    );
    expect(result.isValid, isTrue, reason: '${result.issues}');
  });

  test(
      'documenting is a documents connection from the reference, a type '
      'research already uses', () {
    final link = ResearchReferences.documentsLink(
      id: 'link-1',
      referenceId: 'reference-chart',
      recordId: 'place-harbour',
      scopeId: 'world-a',
      now: now,
    );
    expect(
      (link.typeId, link.sourceId, link.targetId),
      ('documents', 'reference-chart', 'place-harbour'),
    );
    final documents = BuiltInConnectionTypes.definitions
        .singleWhere((type) => type.id == link.typeId);
    expect(documents.sourceTypeIds, contains('research-entry'));
    expect(documents.targetTypeIds, ['*']);
    expect(documents.inverseLabel, 'Documented by');
  });

  test('editing keeps fields another studio wrote', () {
    final fields = ResearchReferences.fields(
      title: 'Chart',
      sourceUrl: 'https://example.org/chart',
      existing: const {'researchCategory': 'Geography', 'custom': 1},
    );
    expect(fields['researchCategory'], 'Geography');
    expect(fields['custom'], 1);
    expect(fields['sourceUrl'], 'https://example.org/chart');
    expect(
      ResearchReferences.fields(
        title: 'Chart',
        existing: {'sourceUrl': 'https://example.org/chart'},
      ).containsKey('sourceUrl'),
      isFalse,
      reason: 'clearing the link removes it',
    );
  });
}
