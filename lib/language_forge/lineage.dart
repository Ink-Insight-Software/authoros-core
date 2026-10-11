/// Language Forge Phase 5 — language families and word histories.
///
/// Both trees are read, never kept. A language's parent is an
/// `originatedFrom` link to another language, or a dialect's `parentLanguage`
/// field; a borrowing is an `influences` link. A word's ancestor is an
/// `originatedFrom` link to another Lexicon Entry. All of these are the
/// language system's own relationship types, declared in AOS Write and made in
/// the Codex; the Study draws them.
///
/// ## Direction, as the Codex makes it
///
/// `originatedFrom` runs from the younger to the older: *Coastal Elvish
/// originated from Old Elvish*. `influences` runs from the lender to the
/// borrower: *Old Dwarvish influences Coastal Elvish*.
///
/// ## Cycles
///
/// Nothing in the Codex stops an author linking A to B and B to A, and a tree
/// that recursed forever over that would take the room down with it. Every walk
/// here keeps the path it is on, stops where it would revisit, and marks the
/// row, so the loop is shown to the author rather than hidden or crashed on.
library;

enum LineageKind {
  /// Younger from older: `originatedFrom`.
  descent,

  /// A dialect of its language: the `parentLanguage` field.
  dialect,

  /// Lender to borrower: `influences`.
  borrowing,
}

class LineageLink {
  const LineageLink({
    required this.childId,
    required this.parentId,
    required this.kind,
  });

  /// The younger language or word, or the borrower.
  final String childId;

  /// The older language or word, or the lender.
  final String parentId;

  final LineageKind kind;
}

/// One row of a drawn tree, in reading order.
class LineageRow {
  const LineageRow({
    required this.id,
    required this.depth,
    this.kind,
    this.loops = false,
  });

  final String id;
  final int depth;

  /// How this row descends from the one above it; null at a root.
  final LineageKind? kind;

  /// The row closes a loop in the links; its children are not drawn again.
  final bool loops;
}

class Lineage {
  Lineage(Iterable<String> ids, Iterable<LineageLink> links)
      : _ids = ids.toList() {
    final known = _ids.toSet();
    for (final link in links) {
      if (!known.contains(link.childId) || !known.contains(link.parentId)) {
        continue;
      }
      if (link.childId == link.parentId) continue;
      if (link.kind == LineageKind.borrowing) {
        (_lentTo[link.parentId] ??= []).add(link.childId);
        (_borrowedFrom[link.childId] ??= []).add(link.parentId);
      } else {
        (_children[link.parentId] ??= []).add((link.childId, link.kind));
        (_parents[link.childId] ??= []).add((link.parentId, link.kind));
      }
    }
  }

  final List<String> _ids;
  final Map<String, List<(String, LineageKind)>> _children = {};
  final Map<String, List<(String, LineageKind)>> _parents = {};
  final Map<String, List<String>> _lentTo = {};
  final Map<String, List<String>> _borrowedFrom = {};

  List<String> parentsOf(String id) => [
        for (final (parent, _)
            in _parents[id] ?? const <(String, LineageKind)>[])
          parent
      ];

  List<String> childrenOf(String id) => [
        for (final (child, _)
            in _children[id] ?? const <(String, LineageKind)>[])
          child
      ];

  List<String> borrowedFrom(String id) => _borrowedFrom[id] ?? const [];

  List<String> lentTo(String id) => _lentTo[id] ?? const [];

  /// No parent, no child, no borrowing: a language isolate.
  bool isIsolate(String id) =>
      parentsOf(id).isEmpty &&
      childrenOf(id).isEmpty &&
      borrowedFrom(id).isEmpty &&
      lentTo(id).isEmpty;

  /// Everything without a parent, in the order given. A member of a pure
  /// loop has a parent and would never be reached from a root, so each loop
  /// contributes its first member as a root of its own.
  List<String> get roots {
    final roots = [
      for (final id in _ids)
        if (parentsOf(id).isEmpty) id
    ];
    final reached = <String>{};
    for (final root in roots) {
      _collect(root, reached);
    }
    for (final id in _ids) {
      if (reached.contains(id)) continue;
      roots.add(id);
      _collect(id, reached);
    }
    return roots;
  }

  void _collect(String id, Set<String> reached) {
    if (!reached.add(id)) return;
    for (final child in childrenOf(id)) {
      _collect(child, reached);
    }
  }

  /// The whole forest, preorder, one row per appearance. A language with two
  /// parents appears under both.
  List<LineageRow> forest() => [
        for (final root in roots) ...descendantsOf(root),
      ];

  /// [id] and everything descended from it, preorder.
  List<LineageRow> descendantsOf(String id) {
    final rows = <LineageRow>[];
    void walk(String node, int depth, LineageKind? kind, Set<String> path) {
      if (path.contains(node)) {
        rows.add(LineageRow(id: node, depth: depth, kind: kind, loops: true));
        return;
      }
      rows.add(LineageRow(id: node, depth: depth, kind: kind));
      final next = {...path, node};
      for (final (child, childKind)
          in _children[node] ?? const <(String, LineageKind)>[]) {
        walk(child, depth + 1, childKind, next);
      }
    }

    walk(id, 0, null, const {});
    return rows;
  }

  /// [id]'s line of ancestors, nearest first, following the first parent at
  /// each step. Stops before repeating itself.
  List<String> ancestryOf(String id) {
    final line = <String>[];
    final seen = {id};
    var current = id;
    while (true) {
      final parents = parentsOf(current);
      if (parents.isEmpty) break;
      final parent = parents.first;
      if (!seen.add(parent)) break;
      line.add(parent);
      current = parent;
    }
    return line;
  }
}
