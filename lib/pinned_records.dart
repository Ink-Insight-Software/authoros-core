/// Where a project keeps the records its author pinned.
///
/// One record per project, `codex-collection-pinned-<projectId>`: a Story
/// Codex collection (`codexCollection`) of kind `pinned`, listing the pinned
/// record ids in pin order. Moved out of AOS-Write's `StoryCodexService` on
/// October 6, 2026, so AOS Worldsmith pins with the same record rather than a
/// second model (Lock 1), and so pins travel with a project's records into
/// its archive.
///
/// **Why the id names the project.** AOS-Write first kept one record,
/// `codex-collection-pinned`, for every project. Records are written by
/// upsert and a project's foundation writes its pinned collection when its
/// own scope lacks one, so opening a second project's Codex took the record
/// over, empty, and the first project's pins were lost. Worldsmith holds many
/// worlds in one database, where that would happen every time. The same
/// pattern as `CodexDismissals`, `codex-suggestions-<projectId>`, fixes it.
///
/// **The record that came before.** A project whose `codex-collection-pinned`
/// is still scoped to it keeps reading and writing that record
/// ([collectionIn]); nothing is migrated or rewritten. A project without one
/// gets its own.
library;

import 'connected_domain.dart';

abstract final class PinnedRecords {
  /// The record type a pinned collection is: a Story Codex collection.
  /// Organisational metadata over record ids, not graph truth: it takes no
  /// links and is not in the record type registry.
  static const String typeId = 'codexCollection';

  /// The value of the collection's `kind` field.
  static const String kind = 'pinned';

  /// The collection's own id, the same for every project. Readers that key
  /// collections by it (AOS-Write's Codex does) are unaffected by which
  /// record holds it.
  static const String collectionId = 'codex-collection-pinned';

  /// The one record every AOS-Write project shared before October 6, 2026.
  static const String legacyRecordId = 'codex-collection-pinned';

  /// The field the pinned ids are stored in, in pin order.
  static const String field = 'recordIds';

  /// The id of the record [projectId]'s pins live on, when it has its own.
  static String recordIdFor(String projectId) =>
      'codex-collection-pinned-$projectId';

  /// Whether [record] is a pinned collection.
  static bool isCollection(AuthorRecord record) =>
      record.typeId == typeId && record.fields['kind'] == kind;

  /// [projectId]'s pinned collection among [records]: its own record first,
  /// then the shared one while that is still scoped to it, else null.
  static AuthorRecord? collectionIn(
    Iterable<AuthorRecord> records,
    String projectId,
  ) {
    final own = recordIdFor(projectId);
    AuthorRecord? legacy;
    for (final record in records) {
      if (!isCollection(record)) continue;
      if (record.id == own) return record;
      if (record.id == legacyRecordId && record.scopeId == projectId) {
        legacy = record;
      }
    }
    return legacy;
  }

  /// The ids [projectId] has pinned among [records], in pin order.
  static List<String> idsIn(Iterable<AuthorRecord> records, String projectId) {
    final collection = collectionIn(records, projectId);
    return collection == null ? const [] : idsFrom(collection.fields[field]);
  }

  /// The ids in a stored [field] value, in order, once each, ignoring blanks
  /// and anything that is not a list.
  static List<String> idsFrom(Object? stored) {
    if (stored is! List) return const [];
    final seen = <String>{};
    return [
      for (final id in stored)
        if (id.toString().trim().isNotEmpty && seen.add(id.toString()))
          id.toString(),
    ];
  }

  /// A new, empty pinned collection for [projectId].
  static AuthorRecord newCollection(String projectId, DateTime now) =>
      AuthorRecord(
        id: recordIdFor(projectId),
        typeId: typeId,
        scopeType: RecordScopeType.project,
        scopeId: projectId,
        projectId: projectId,
        title: 'Pinned Entries',
        fields: const {
          'collectionId': collectionId,
          'kind': kind,
          field: <String>[],
          'filter': <String, Object?>{},
        },
        createdAt: now,
        updatedAt: now,
      );

  /// [collection] with [recordId] pinned (added last) or unpinned. Returns
  /// [collection] itself when nothing changes, so a caller can skip the
  /// write.
  static AuthorRecord withPinned(
    AuthorRecord collection,
    String recordId,
    bool pinned,
    DateTime now,
  ) {
    final ids = idsFrom(collection.fields[field]);
    if (ids.contains(recordId) == pinned) return collection;
    return collection.copyWith(
      fields: {
        ...collection.fields,
        field: pinned
            ? [...ids, recordId]
            : [for (final id in ids) if (id != recordId) id],
      },
      revision: collection.revision + 1,
      updatedAt: now,
    );
  }
}
