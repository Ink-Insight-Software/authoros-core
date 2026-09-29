/// Where a world record sits: its parent, children, ancestors and root.
///
/// Pure Dart over records and links already read. It moved out of
/// `lib/services/world_service.dart` on September 29, 2026 so that World
/// Continuity, which asks whether a route's two ends share a world, can live in
/// the shared core with the rest of the continuity engine (`PLAN.md` §3.33).
/// `world_service.dart` exports it, so no import changed.
library;

import 'connected_domain.dart';

/// The link types that point from a place to the place that holds it. A
/// `contains` link points the other way. `WorldService` reads the same set.
const worldChildToParentLinkTypes = <String>{'locatedIn', 'partOf', 'inside'};

class WorldHierarchyException implements Exception {
  const WorldHierarchyException(this.message);

  final String message;

  @override
  String toString() => 'WorldHierarchyException: $message';
}

class WorldHierarchy {
  WorldHierarchy({
    required Iterable<AuthorRecord> records,
    required Iterable<RecordLink> links,
  })  : records = {for (final record in records) record.id: record},
        links = links.toList();

  final Map<String, AuthorRecord> records;
  final List<RecordLink> links;

  AuthorRecord? record(String id) => records[id];

  AuthorRecord? parentOf(String id) {
    final parentId = _parentId(id);
    return parentId == null ? null : records[parentId];
  }

  List<AuthorRecord> childrenOf(String id) => _childIds(id)
      .map((childId) => records[childId])
      .whereType<AuthorRecord>()
      .toList()
    ..sort(_byTitle);

  List<AuthorRecord> siblingsOf(String id) {
    final parent = parentOf(id);
    if (parent == null) return const [];
    return childrenOf(parent.id).where((record) => record.id != id).toList();
  }

  List<AuthorRecord> ancestorsOf(String id) {
    final result = <AuthorRecord>[];
    final visited = <String>{id};
    var currentId = id;
    while (true) {
      final parentId = _parentId(currentId);
      if (parentId == null || !visited.add(parentId)) break;
      final parent = records[parentId];
      if (parent == null) break;
      result.add(parent);
      currentId = parentId;
    }
    return result;
  }

  List<AuthorRecord> descendantsOf(String id) {
    final result = <AuthorRecord>[];
    final visited = <String>{id};
    final pending = <String>[id];
    while (pending.isNotEmpty) {
      final currentId = pending.removeAt(0);
      for (final childId in _childIds(currentId)) {
        if (!visited.add(childId)) continue;
        final child = records[childId];
        if (child != null) {
          result.add(child);
          pending.add(childId);
        }
      }
    }
    return result;
  }

  AuthorRecord? rootOf(String id) {
    final ancestors = ancestorsOf(id);
    return ancestors.isEmpty ? records[id] : ancestors.last;
  }

  AuthorRecord? rootUniverseOf(String id) =>
      ancestorsOf(id).where((record) => record.typeId == 'universe').lastOrNull;

  AuthorRecord? rootWorldOf(String id) {
    final lineage = [records[id], ...ancestorsOf(id)].whereType<AuthorRecord>();
    return lineage.where((record) => record.typeId == 'world').lastOrNull;
  }

  String? _parentId(String id) {
    for (final link in links) {
      if (worldChildToParentLinkTypes.contains(link.typeId) && link.sourceId == id) {
        return link.targetId;
      }
      if (link.typeId == 'contains' && link.targetId == id) {
        return link.sourceId;
      }
    }
    return null;
  }

  Set<String> _childIds(String id) {
    final result = <String>{};
    for (final link in links) {
      if (worldChildToParentLinkTypes.contains(link.typeId) && link.targetId == id) {
        result.add(link.sourceId);
      }
      if (link.typeId == 'contains' && link.sourceId == id) {
        result.add(link.targetId);
      }
    }
    return result;
  }
}

int _byTitle(AuthorRecord left, AuthorRecord right) =>
    left.title.toLowerCase().compareTo(right.title.toLowerCase());
