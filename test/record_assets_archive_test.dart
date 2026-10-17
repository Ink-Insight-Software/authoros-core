import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:authoros_core/archive/archive_inspection.dart';
import 'package:authoros_core/archive/authoros_archive.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/record_asset.dart';
import 'package:test/test.dart';

void main() {
  const service = AuthorOsArchiveService();
  final at = DateTime.utc(2026, 10, 16, 9);
  final png = Uint8List.fromList(
      [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3]);
  final pdf = Uint8List.fromList(utf8.encode('%PDF-1.7 a map of the coast'));

  RecordAsset asset(String recordId, String role, Uint8List bytes,
          {String mediaType = 'image/png', String projectId = 'world-a'}) =>
      RecordAsset(
        projectId: projectId,
        recordId: recordId,
        role: role,
        mediaType: mediaType,
        bytes: bytes,
        width: mediaType == 'image/png' ? 40 : null,
        height: mediaType == 'image/png' ? 30 : null,
        updatedAt: at,
        extension: const {'note': 'kept'},
      );

  test('record assets round trip, every role, bytes stored once', () {
    final bytes = _export(service, recordAssets: [
      asset('reference-coast', 'reference', pdf, mediaType: 'application/pdf'),
      asset('reference-face', 'reference', png),
      // The same picture again, as an avatar elsewhere: one blob.
      asset('character-aran', 'avatar', png, projectId: 'world-b'),
      asset('idea-1', 'some-later-role', png),
    ]);

    final contents = service.importArchive(bytes);
    expect(contents.carriesRecordAssets, isTrue);
    expect([
      for (final each in contents.recordAssets) each.key
    ], [
      'world-a|idea-1|some-later-role',
      'world-a|reference-coast|reference',
      'world-a|reference-face|reference',
      'world-b|character-aran|avatar',
    ]);
    final coast = contents.recordAssets[1];
    expect(coast.mediaType, 'application/pdf');
    expect(coast.bytes, pdf);
    expect(coast.width, isNull);
    expect(coast.updatedAt, at);
    expect(coast.extension, {'note': 'kept'});
    final face = contents.recordAssets[2];
    expect(face.bytes, png);
    expect((face.width, face.height), (40, 30));

    final archive = ZipDecoder().decodeBytes(bytes);
    final blobs = [
      for (final file in archive)
        if (file.name.startsWith('assets/sha256/')) file.name,
    ];
    expect(blobs, hasLength(2), reason: 'the PNG travels once');

    final entries = (_manifest(bytes)['entries'] as List).cast<Map>();
    final described = entries
        .singleWhere((each) => each['path'] == 'data/record-assets.jsonl');
    expect(described['role'], 'record-assets');
    expect(described['recordCount'], 4);
    final pdfEntry = entries.singleWhere((each) =>
        (each['path'] as String).startsWith('assets/') &&
        each['mediaType'] == 'application/pdf');
    expect(pdfEntry['role'], 'record-asset-content');
    expect(pdfEntry.containsKey('recordCount'), isFalse);

    expect(inspectionOf(contents).attachedFiles, 4);
    expect(inspectionOf(contents).summary, contains('4 attached files'));
  });

  test('an archive without assets is byte-identical and says nothing', () {
    final without = _export(service);
    final withEmpty = _export(service, recordAssets: const []);
    expect(withEmpty, without);
    expect(ZipDecoder().decodeBytes(without).find('data/record-assets.jsonl'),
        isNull);
    final contents = service.importArchive(without);
    expect(contents.recordAssets, isEmpty);
    expect(contents.carriesRecordAssets, isFalse);
  });

  test('the same assets give the same bytes', () {
    final first = _export(service, recordAssets: [
      asset('b', 'reference', pdf, mediaType: 'application/pdf'),
      asset('a', 'reference', png),
    ]);
    final second = _export(service, recordAssets: [
      asset('a', 'reference', png),
      asset('b', 'reference', pdf, mediaType: 'application/pdf'),
    ]);
    expect(second, first);
  });

  test('an asset the archive could not read back is never written', () {
    expect(
      () => _export(service, recordAssets: [
        asset('a', 'reference', png),
        asset('a', 'reference', pdf, mediaType: 'application/pdf'),
      ]),
      throwsArgumentError,
      reason: 'two assets under one key',
    );
    expect(
      () => _export(service, recordAssets: [asset('a', ' ', png)]),
      throwsArgumentError,
    );
    const small = AuthorOsArchiveService(
      limits: AuthorOsArchiveLimits(maximumEntryBytes: 8),
    );
    expect(
      () => _export(small, recordAssets: [asset('a', 'reference', png)]),
      throwsArgumentError,
    );
  });

  test('a changed or missing file is refused', () {
    final bytes = _export(service, recordAssets: [
      asset('a', 'reference', pdf, mediaType: 'application/pdf'),
    ]);
    Uint8List rebuilt({bool drop = false}) {
      final archive = ZipDecoder().decodeBytes(bytes);
      final out = Archive();
      for (final file in archive) {
        var content = file.readBytes()!;
        if (file.name.startsWith('assets/')) {
          if (drop) continue;
          content = Uint8List.fromList([...content]..[0] ^= 0xFF);
        }
        out.add(ArchiveFile.bytes(file.name, content));
      }
      return ZipEncoder().encodeBytes(out);
    }

    expect(() => service.importArchive(rebuilt()), throwsFormatException);
    expect(() => service.importArchive(rebuilt(drop: true)),
        throwsFormatException);
  });
}

Uint8List _export(
  AuthorOsArchiveService service, {
  Iterable<RecordAsset> recordAssets = const [],
}) =>
    service.exportSnapshot(
      _snapshot(),
      archiveId: 'archive-1',
      rootId: 'world-a',
      applicationVersion: '0.20.0',
      platform: 'test',
      createdAt: DateTime.utc(2026, 10, 16),
      recordAssets: recordAssets,
    );

Map<String, dynamic> _manifest(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  return Map<String, dynamic>.from(
    jsonDecode(utf8.decode(archive.find('manifest.json')!.readBytes()!)) as Map,
  );
}

ConnectedDomainSnapshot _snapshot() {
  final timestamp = DateTime.utc(2026, 10, 16);
  return ConnectedDomainSnapshot(
    records: [
      AuthorRecord(
        id: 'reference-face',
        typeId: 'research-entry',
        scopeType: RecordScopeType.project,
        scopeId: 'world-a',
        title: 'A face',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
    manuscriptNodes: const [],
    links: const [],
  );
}
