import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:authoros_core/archive/authoros_archive.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:test/test.dart';

void main() {
  const service = AuthorOsArchiveService();

  test('extension documents round trip, keyed by extension and project', () {
    final bytes = _export(service, extensionDocuments: [
      {
        'extension': 'language-forge',
        'projectId': 'world-b',
        'document': {
          'schemaVersion': 4,
          'workspace': {
            'ignoredWords': ['aran']
          },
        },
      },
      {
        'extension': 'hearts-and-tensions',
        'projectId': 'world-a',
        'document': {'anything': true},
      },
      {
        'extension': 'language-forge',
        'projectId': 'world-a',
        'document': {'schemaVersion': 4, 'workspace': <String, Object?>{}},
      },
    ]);

    final contents = service.importArchive(bytes);
    // Sorted by `"$extension:$projectId"`, and the synthesised id is not
    // handed back: it is the file's sort key, not the extension's data.
    expect(
      [
        for (final entry in contents.extensionDocuments)
          '${entry['extension']}:${entry['projectId']}',
      ],
      [
        'hearts-and-tensions:world-a',
        'language-forge:world-a',
        'language-forge:world-b',
      ],
    );
    expect(contents.extensionDocuments.first.containsKey('id'), isFalse);
    expect(contents.extensionDocumentsFor('language-forge'), {
      'world-a': {'schemaVersion': 4, 'workspace': <String, Object?>{}},
      'world-b': {
        'schemaVersion': 4,
        'workspace': {
          'ignoredWords': ['aran'],
        },
      },
    });
    expect(contents.extensionDocumentsFor('unheard-of'), isEmpty);

    final manifest = _manifest(bytes);
    final entry = (manifest['entries'] as List).cast<Map>().singleWhere(
        (each) => each['path'] == 'data/extension-documents.jsonl');
    expect(entry['role'], 'extension-documents');
    expect(entry['recordCount'], 3);
  });

  test('an archive without extension documents is byte-identical', () {
    final without = _export(service);
    final withEmpty = _export(service, extensionDocuments: const []);
    expect(withEmpty, without);
    expect(
      ZipDecoder().decodeBytes(without).find('data/extension-documents.jsonl'),
      isNull,
    );
    // And reads back as saying nothing, not as an error.
    expect(service.importArchive(without).extensionDocuments, isEmpty);
  });

  test('an entry without its extension or project fails the export', () {
    expect(
      () => _export(service, extensionDocuments: [
        {'projectId': 'world-a', 'document': const {}},
      ]),
      throwsArgumentError,
    );
    expect(
      () => _export(service, extensionDocuments: [
        {'extension': 'language-forge', 'document': const {}},
      ]),
      throwsArgumentError,
    );
    expect(
      () => _export(service, extensionDocuments: [
        {'extension': ' ', 'projectId': 'world-a', 'document': const {}},
      ]),
      throwsArgumentError,
    );
  });

  test('a flipped byte in the entry is rejected', () {
    final bytes = _export(service, extensionDocuments: [
      {
        'extension': 'language-forge',
        'projectId': 'world-a',
        'document': {'schemaVersion': 4},
      },
    ]);
    final archive = ZipDecoder().decodeBytes(bytes);
    final rebuilt = Archive();
    for (final file in archive) {
      var content = file.readBytes()!;
      if (file.name == 'data/extension-documents.jsonl') {
        content = Uint8List.fromList(
            utf8.encode(utf8.decode(content).replaceAll('4', '5')));
      }
      rebuilt.add(ArchiveFile.bytes(file.name, content));
    }
    expect(
      () => service.importArchive(ZipEncoder().encodeBytes(rebuilt)),
      throwsFormatException,
    );
  });
}

Uint8List _export(
  AuthorOsArchiveService service, {
  Iterable<Map<String, Object?>> extensionDocuments = const [],
}) =>
    service.exportSnapshot(
      _snapshot(),
      archiveId: 'archive-1',
      rootId: 'world-a',
      applicationVersion: '0.16.0',
      platform: 'test',
      createdAt: DateTime.utc(2026, 10, 11),
      extensionDocuments: extensionDocuments,
    );

Map<String, dynamic> _manifest(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  return Map<String, dynamic>.from(
    jsonDecode(utf8.decode(archive.find('manifest.json')!.readBytes()!)) as Map,
  );
}

ConnectedDomainSnapshot _snapshot() {
  final timestamp = DateTime.utc(2026, 10, 11);
  return ConnectedDomainSnapshot(
    records: [
      AuthorRecord(
        id: 'language-vaelic',
        typeId: 'language',
        scopeType: RecordScopeType.project,
        scopeId: 'world-a',
        title: 'Old Vaelic',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
    manuscriptNodes: const [],
    links: const [],
  );
}
