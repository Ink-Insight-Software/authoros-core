import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../connected_domain.dart';
import '../connection_types.dart';
import '../record_types.dart';
import '../scene_prose.dart';
import '../branch_domain.dart';
import '../version_audit.dart';
import '../revision_decision.dart';
import '../writing_session.dart';
import '../project_roster_entry.dart';
import '../writing_series.dart';

class AuthorOsArchiveLimits {
  const AuthorOsArchiveLimits({
    this.maximumEntries = 100000,
    this.maximumTotalBytes = 4 * 1024 * 1024 * 1024,
    this.maximumEntryBytes = 16 * 1024 * 1024,
  });

  final int maximumEntries;
  final int maximumTotalBytes;
  final int maximumEntryBytes;
}

/// Everything an archive carries.
///
/// The graph travels in [snapshot]. Manuscript prose does not: scene content
/// lives in the Manuscript Studio's own store, not in the database, so it
/// arrives here as already-serialised [ManuscriptProjectSummary] JSON. Keeping
/// it untyped is deliberate — the archive is a serialisation layer, and
/// importing the store's model would drag `shared_preferences` into it.
class AuthorOsArchiveContents {
  const AuthorOsArchiveContents({
    required this.snapshot,
    this.manuscripts = const [],
    this.projects = const [],
    this.series = const [],
    this.sceneAuthorship = const [],
    this.cartographerDocuments = const [],
  });

  final ConnectedDomainSnapshot snapshot;

  /// Raw `ManuscriptProjectSummary.toJson()` maps, prose included. Empty for
  /// an archive written before manuscripts were carried.
  final List<Map<String, dynamic>> manuscripts;

  /// The project roster: each project's title, type, genre, word goal, series
  /// place and archived state. Empty for an archive written before the roster
  /// was carried, which a restore must read as *"this file says nothing about
  /// the roster"*, not as *"there are no projects"*.
  final List<ProjectRosterEntry> projects;

  /// The series the roster's books belong to. Empty on the same terms.
  final List<WritingSeries> series;

  /// Each scene's authorship record — where its characters came from — as
  /// the application wrote it. Opaque here, like [manuscripts]: what an
  /// origin *is* belongs to the application, and each map carries the digest
  /// of the text it describes, so a record that no longer matches its prose
  /// is recognised there rather than trusted. Empty for an archive written
  /// before records were carried.
  final List<Map<String, dynamic>> sceneAuthorship;

  /// One spatial document per project, as Cartographer writes it: its places,
  /// maps, layers and the geometry depicting them.
  ///
  /// Opaque here, like [manuscripts], and for the same reason: maps and plans
  /// belong to Cartographer (Casebook ADR-0001, rule 4), and importing its
  /// document model would put a second description of a place in the core.
  /// What travels is the document the engine wrote, keyed by project.
  ///
  /// Carried so that a project is one file. The alternative was a package
  /// beside the project that an author has to keep alongside it, which is how
  /// projects lose their maps.
  ///
  /// Each document must carry its own `projectId`: entries are keyed and
  /// sorted by id, so a document without one fails the export rather than
  /// landing somewhere unpredictable.
  ///
  /// Empty for an archive written before documents were carried — which a
  /// restore must read as *"this file says nothing about a map"*, never as
  /// *"this project has no map"*.
  final List<Map<String, dynamic>> cartographerDocuments;

  /// Whether this archive carries a roster at all.
  bool get carriesRoster => projects.isNotEmpty;
}

class AuthorOsArchiveService {
  const AuthorOsArchiveService({
    this.limits = const AuthorOsArchiveLimits(),
  });

  final AuthorOsArchiveLimits limits;

  Uint8List exportSnapshot(
    ConnectedDomainSnapshot snapshot, {
    required String archiveId,
    required String rootId,
    required String applicationVersion,
    required String platform,
    required DateTime createdAt,
    Iterable<Map<String, Object?>> manuscripts = const [],
    Iterable<ProjectRosterEntry> projects = const [],
    Iterable<WritingSeries> series = const [],
    Iterable<Map<String, Object?>> sceneAuthorship = const [],
    Iterable<Map<String, Object?>> cartographerDocuments = const [],
  }) {
    InMemoryConnectedDomainRepository(initial: snapshot);
    final entries = <String, Uint8List>{
      'data/records.jsonl': _jsonLines(
        snapshot.records.map((record) => record.toJson()),
      ),
      'data/manuscript-nodes.jsonl': _jsonLines(
        snapshot.manuscriptNodes.map((node) => node.toJson()),
      ),
      'data/links.jsonl': _jsonLines(
        snapshot.links.map((link) => link.toJson()),
      ),
      'data/record-types.jsonl': _jsonLines(
        snapshot.recordTypeDefinitions.map((definition) => definition.toJson()),
      ),
      'data/connection-types.jsonl': _jsonLines(
        snapshot.connectionTypeDefinitions
            .map((definition) => definition.toJson()),
      ),
      'data/branches.jsonl': _jsonLines(
        snapshot.branches.map((branch) => branch.toJson()),
      ),
      'data/branch-record-overlays.jsonl': _jsonLines(
        snapshot.branchRecordOverlays.map((overlay) => {
              'id': '${overlay.branchId}|${overlay.recordId}',
              ...overlay.toJson(),
            }),
      ),
      'data/branch-link-overlays.jsonl': _jsonLines(
        snapshot.branchLinkOverlays.map((overlay) => {
              'id': '${overlay.branchId}|${overlay.linkId}',
              ...overlay.toJson(),
            }),
      ),
      'data/versions.jsonl': _jsonLines(
        snapshot.versions.map((version) => version.toJson()),
      ),
      'data/audit-events.jsonl': _jsonLines(
        snapshot.auditEvents.map((event) => event.toJson()),
      ),
      // Sessions and prose are emitted only when there is something to say.
      // An archive of a project with neither is byte-identical to one written
      // before these entries existed, so nothing that already reads the format
      // has to change.
      if (snapshot.writingSessions.isNotEmpty)
        'data/writing-sessions.jsonl': _jsonLines(
          snapshot.writingSessions.map((session) => session.toJson()),
        ),
      // Author decisions about findings, on the same terms: written only when
      // the author has made one, so an archive from a project where nobody
      // dismissed anything is byte-identical to one written before this entry
      // existed.
      if (snapshot.revisionDecisions.isNotEmpty)
        'data/revision-decisions.jsonl': _jsonLines(
          snapshot.revisionDecisions.map((decision) => decision.toJson()),
        ),
      // Under content/, not data/: this is the book, not the graph that
      // describes it. `data/manuscripts.jsonl` below carries the other half --
      // the chapter and scene tree, which lives outside the database. The two
      // do not overlap, because ManuscriptStore writes its blob with
      // `includeProse: false`.
      if (snapshot.sceneProse.isNotEmpty)
        'content/scene-prose.jsonl': _jsonLines(
          snapshot.sceneProse.map((prose) => {
                'id': prose.sceneId,
                ...prose.toJson(),
              }),
        ),
      // The roster: which projects exist, and each one's title, type, genre,
      // word goal, series place and archived state. It lives in its own table
      // rather than the graph, so until September 29, 2026 it was not written
      // at all, and a restore into an empty installation brought back every
      // record and manuscript and no projects. Written only when there is a
      // roster, so an archive without one stays byte-identical to one written
      // before these entries existed.
      if (projects.isNotEmpty)
        'data/projects.jsonl': _jsonLines(
          projects.map((entry) => entry.toJson()),
        ),
      if (series.isNotEmpty)
        'data/series.jsonl': _jsonLines(
          series.map((one) => one.toJson()),
        ),
      // Where the book's words came from, beside the book. Written only when
      // there is a record, so an archive without one is byte-identical to one
      // written before this entry existed; each line carries an `id` (the
      // scene), as every other entry does.
      if (sceneAuthorship.isNotEmpty)
        'content/scene-authorship.jsonl': _jsonLines(sceneAuthorship),
      if (manuscripts.isNotEmpty)
        'data/manuscripts.jsonl': _jsonLines(
          // `_jsonLines` sorts on `id`, and a manuscript is keyed by its
          // project. Synthesising one mirrors what the branch overlays above
          // already do.
          manuscripts.map((manuscript) => {
                'id': manuscript['projectId'],
                ...manuscript,
              }),
        ),
      // Under data/, not content/: a spatial document is a graph of places,
      // not the book. Keyed by project like `manuscripts`, and written only
      // when there is one, so an archive from a project with no map stays
      // byte-identical to one written before this entry existed.
      if (cartographerDocuments.isNotEmpty)
        'data/cartographer-documents.jsonl': _jsonLines(
          cartographerDocuments.map((document) => {
                'id': document['projectId'],
                ...document,
              }),
        ),
    };
    final contentFingerprint = _contentFingerprint(entries);
    final entryMetadata = [
      for (final entry in entries.entries)
        {
          'path': entry.key,
          'role': _roleFor(entry.key),
          'mediaType': 'application/x-ndjson',
          'bytes': entry.value.length,
          'sha256': _digest(entry.value),
          'recordCount': _lineCount(entry.value),
        },
    ]..sort((left, right) =>
        (left['path'] as String).compareTo(right['path'] as String));
    final checksums = {
      'algorithm': 'SHA-256',
      'entries': {
        for (final entry in entryMetadata)
          entry['path'] as String: entry['sha256'] as String,
      },
      'contentFingerprint': contentFingerprint,
    };
    final manifest = {
      'archiveFormat': 'authoros',
      'archiveVersion': 1,
      'archiveId': archiveId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'createdBy': {
        'application': 'AuthorOS',
        'version': applicationVersion,
        'platform': platform,
      },
      'contentScope': 'project',
      'rootIds': [rootId],
      'schemaVersions': const {
        'connectedDomain': 2,
        'recordTypeDefinition': 1,
        'connectionTypeDefinition': 1,
        'scopeCanonBranch': 1,
        'versionAudit': 1,
      },
      'entries': entryMetadata,
      'contentFingerprint': contentFingerprint,
    };

    final archive = Archive();
    for (final entry in entries.entries) {
      archive.add(ArchiveFile.bytes(entry.key, entry.value));
    }
    archive.add(
      ArchiveFile.string('checksums.json', _canonicalJson(checksums)),
    );
    archive.add(
      ArchiveFile.string('manifest.json', _canonicalJson(manifest)),
    );
    return ZipEncoder().encodeBytes(
      archive,
      modified: DateTime.utc(2000),
    );
  }

  /// Reads an archive whole, prose and sessions included.
  AuthorOsArchiveContents importArchive(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    if (archive.length > limits.maximumEntries) {
      throw const FormatException('Archive contains too many entries.');
    }

    final files = <String, Uint8List>{};
    final caseFoldedPaths = <String>{};
    var totalBytes = 0;
    for (final entry in archive) {
      if (!entry.isFile || entry.isSymbolicLink) {
        throw const FormatException(
          'Directories and symbolic links are not supported.',
        );
      }
      _validatePath(entry.name);
      if (!caseFoldedPaths.add(entry.name.toLowerCase())) {
        throw FormatException('Duplicate archive path: ${entry.name}');
      }
      final content = entry.readBytes() ?? Uint8List(0);
      if (content.length > limits.maximumEntryBytes) {
        throw FormatException('Archive entry is too large: ${entry.name}');
      }
      totalBytes += content.length;
      if (totalBytes > limits.maximumTotalBytes) {
        throw const FormatException('Archive is too large.');
      }
      files[entry.name] = content;
    }

    final manifest = _jsonObject(files['manifest.json'], 'manifest.json');
    final checksums = _jsonObject(files['checksums.json'], 'checksums.json');
    if (manifest['archiveFormat'] != 'authoros' ||
        manifest['archiveVersion'] != 1) {
      throw const FormatException('Unsupported AuthorOS archive.');
    }
    if (checksums['algorithm'] != 'SHA-256') {
      throw const FormatException('Unsupported checksum algorithm.');
    }

    final declared = <String, Map<String, dynamic>>{};
    final rawEntries = manifest['entries'];
    if (rawEntries is! List) {
      throw const FormatException('Manifest entries are required.');
    }
    for (final value in rawEntries) {
      final entry = Map<String, dynamic>.from(value as Map);
      final path = entry['path'] as String? ?? '';
      _validatePath(path);
      if (declared.putIfAbsent(path, () => entry) != entry) {
        throw FormatException('Duplicate manifest path: $path');
      }
    }
    final expectedPaths = {...declared.keys, 'manifest.json', 'checksums.json'};
    if (files.keys.toSet().difference(expectedPaths).isNotEmpty ||
        expectedPaths.difference(files.keys.toSet()).isNotEmpty) {
      throw const FormatException('Archive entries do not match the manifest.');
    }

    final checksumEntries = checksums['entries'];
    if (checksumEntries is! Map) {
      throw const FormatException('Checksum entries are required.');
    }
    for (final entry in declared.entries) {
      final content = files[entry.key]!;
      final digest = _digest(content);
      if (entry.value['bytes'] != content.length ||
          entry.value['sha256'] != digest ||
          checksumEntries[entry.key] != digest) {
        throw FormatException('Integrity check failed: ${entry.key}');
      }
    }
    final dataEntries = {
      for (final path in declared.keys) path: files[path]!,
    };
    final fingerprint = _contentFingerprint(dataEntries);
    if (manifest['contentFingerprint'] != fingerprint ||
        checksums['contentFingerprint'] != fingerprint) {
      throw const FormatException('Content fingerprint does not match.');
    }

    final snapshot = ConnectedDomainSnapshot(
      records: _decodeJsonLines(files['data/records.jsonl'])
          .map(AuthorRecord.fromJson)
          .toList(),
      manuscriptNodes: _decodeJsonLines(files['data/manuscript-nodes.jsonl'])
          .map(ManuscriptNodeReference.fromJson)
          .toList(),
      links: _decodeJsonLines(files['data/links.jsonl'])
          .map(RecordLink.fromJson)
          .toList(),
      recordTypeDefinitions: files.containsKey('data/record-types.jsonl')
          ? _decodeJsonLines(files['data/record-types.jsonl'])
              .map(RecordTypeDefinition.fromJson)
              .toList()
          : const [],
      connectionTypeDefinitions:
          files.containsKey('data/connection-types.jsonl')
              ? _decodeJsonLines(files['data/connection-types.jsonl'])
                  .map(ConnectionTypeDefinition.fromJson)
                  .toList()
              : const [],
      branches: files.containsKey('data/branches.jsonl')
          ? _decodeJsonLines(files['data/branches.jsonl'])
              .map(StoryBranch.fromJson)
              .toList()
          : const [],
      branchRecordOverlays:
          files.containsKey('data/branch-record-overlays.jsonl')
              ? _decodeJsonLines(files['data/branch-record-overlays.jsonl'])
                  .map(BranchRecordOverlay.fromJson)
                  .toList()
              : const [],
      branchLinkOverlays: files.containsKey('data/branch-link-overlays.jsonl')
          ? _decodeJsonLines(files['data/branch-link-overlays.jsonl'])
              .map(BranchLinkOverlay.fromJson)
              .toList()
          : const [],
      versions: files.containsKey('data/versions.jsonl')
          ? _decodeJsonLines(files['data/versions.jsonl'])
              .map(RecordVersion.fromJson)
              .toList()
          : const [],
      auditEvents: files.containsKey('data/audit-events.jsonl')
          ? _decodeJsonLines(files['data/audit-events.jsonl'])
              .map(AuditEvent.fromJson)
              .toList()
          : const [],
      // Optional, so an archive written before sessions were carried still
      // imports rather than failing on a missing entry.
      writingSessions: files.containsKey('data/writing-sessions.jsonl')
          ? _decodeJsonLines(files['data/writing-sessions.jsonl'])
              .map(WritingSession.fromJson)
              .toList()
          : const [],
      // Optional on read for the same reason, and a decision whose kind this
      // build does not know is dropped rather than failing the import.
      revisionDecisions: files.containsKey('data/revision-decisions.jsonl')
          ? _decodeJsonLines(files['data/revision-decisions.jsonl'])
              .map(RevisionDecision.fromJson)
              .whereType<RevisionDecision>()
              .toList()
          : const [],
      // Optional on read too: archives written before prose moved into the
      // database do not carry this entry, and must still restore.
      sceneProse: files.containsKey('content/scene-prose.jsonl')
          ? _decodeJsonLines(files['content/scene-prose.jsonl'])
              .map(SceneProse.fromJson)
              .toList()
          : const [],
    );
    InMemoryConnectedDomainRepository(initial: snapshot);
    return AuthorOsArchiveContents(
      snapshot: snapshot,
      manuscripts: files.containsKey('data/manuscripts.jsonl')
          ? _decodeJsonLines(files['data/manuscripts.jsonl'])
          : const [],
      // Optional on read, like every entry added after the first archives:
      // a file written before the roster was carried still restores.
      projects: files.containsKey('data/projects.jsonl')
          ? _decodeJsonLines(files['data/projects.jsonl'])
              .map(ProjectRosterEntry.fromJson)
              .toList()
          : const [],
      series: files.containsKey('data/series.jsonl')
          ? _decodeJsonLines(files['data/series.jsonl'])
              .map(WritingSeries.fromJson)
              .toList()
          : const [],
      sceneAuthorship: files.containsKey('content/scene-authorship.jsonl')
          ? _decodeJsonLines(files['content/scene-authorship.jsonl'])
          : const [],
      cartographerDocuments:
          files.containsKey('data/cartographer-documents.jsonl')
              ? _decodeJsonLines(files['data/cartographer-documents.jsonl'])
              : const [],
    );
  }

  /// The graph half of [importArchive], for callers that only need it.
  ConnectedDomainSnapshot importSnapshot(Uint8List bytes) =>
      importArchive(bytes).snapshot;

  Future<ConnectedDomainSnapshot> importAndCommit(
    Uint8List bytes,
    Future<void> Function(ConnectedDomainSnapshot snapshot) commit,
  ) async {
    final snapshot = importSnapshot(bytes);
    await commit(snapshot);
    return snapshot;
  }
}

Uint8List _jsonLines(Iterable<Map<String, Object?>> values) {
  final sorted = values.toList()
    ..sort((left, right) =>
        (left['id'] as String).compareTo(right['id'] as String));
  final encoded = sorted.map(_canonicalJson).join('\n');
  return Uint8List.fromList(utf8.encode(encoded.isEmpty ? '' : '$encoded\n'));
}

List<Map<String, dynamic>> _decodeJsonLines(Uint8List? bytes) {
  if (bytes == null) {
    throw const FormatException('Required data entry is missing.');
  }
  final content = utf8.decode(bytes, allowMalformed: false);
  return [
    for (final line in const LineSplitter().convert(content))
      if (line.trim().isNotEmpty)
        Map<String, dynamic>.from(jsonDecode(line) as Map),
  ];
}

Map<String, dynamic> _jsonObject(Uint8List? bytes, String path) {
  if (bytes == null) {
    throw FormatException('$path is missing.');
  }
  try {
    return Map<String, dynamic>.from(
      jsonDecode(utf8.decode(bytes, allowMalformed: false)) as Map,
    );
  } catch (_) {
    throw FormatException('$path is invalid.');
  }
}

void _validatePath(String path) {
  if (path.isEmpty ||
      path.contains('\\') ||
      path.contains('\u0000') ||
      path.startsWith('/') ||
      RegExp(r'^[A-Za-z]:').hasMatch(path) ||
      path.split('/').any((segment) => segment.isEmpty || segment == '..')) {
    throw FormatException('Unsafe archive path: $path');
  }
}

String _contentFingerprint(Map<String, Uint8List> entries) {
  final buffer = BytesBuilder(copy: false);
  final paths = entries.keys.toList()..sort();
  for (final path in paths) {
    buffer.add(utf8.encode(path));
    buffer.addByte(0);
    buffer.add(utf8.encode(_digest(entries[path]!)));
    buffer.addByte(10);
  }
  return _digest(buffer.takeBytes());
}

String _digest(List<int> bytes) => sha256.convert(bytes).toString();

int _lineCount(Uint8List bytes) =>
    const LineSplitter().convert(utf8.decode(bytes)).length;

String _roleFor(String path) => switch (path) {
      'data/writing-sessions.jsonl' => 'writing-sessions',
      'data/revision-decisions.jsonl' => 'revision-decisions',
      'data/manuscripts.jsonl' => 'manuscripts',
      'data/cartographer-documents.jsonl' => 'cartographer-documents',
      'data/projects.jsonl' => 'projects',
      'data/series.jsonl' => 'series',
      'content/scene-prose.jsonl' => 'scene-content',
      'content/scene-authorship.jsonl' => 'scene-authorship',
      'data/records.jsonl' => 'records',
      'data/manuscript-nodes.jsonl' => 'manuscript-nodes',
      'data/links.jsonl' => 'links',
      'data/record-types.jsonl' => 'record-type-definitions',
      'data/connection-types.jsonl' => 'connection-type-definitions',
      'data/branches.jsonl' => 'branches',
      'data/branch-record-overlays.jsonl' => 'branch-record-overlays',
      'data/branch-link-overlays.jsonl' => 'branch-link-overlays',
      'data/versions.jsonl' => 'record-versions',
      'data/audit-events.jsonl' => 'audit-events',
      _ => throw ArgumentError.value(path, 'path', 'Unknown archive role'),
    };

String _canonicalJson(Object? value) => jsonEncode(_canonicalValue(value));

Object? _canonicalValue(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {
      for (final key in keys) key: _canonicalValue(value[key]),
    };
  }
  if (value is Iterable) {
    return value.map(_canonicalValue).toList();
  }
  return value;
}
