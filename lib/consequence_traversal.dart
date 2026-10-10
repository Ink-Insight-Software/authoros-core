/// Which records a change may affect, and why (AOS Worldsmith build plan,
/// Phase 8: consequence traversal, the Observatory's engine).
///
/// Given a changed record, the traversal walks typed edges outward by rules
/// declared **per edge type**: `governedBy` carries a change from a
/// government to what it governs, `dependsOn` carries a scarcity from what is
/// depended on to what depends on it, and `hasCulture` carries nothing. Every
/// record it reaches comes back with the **path** that reached it, so every
/// answer can say *why*.
///
/// It is deterministic and invents nothing (Lock 8): no weights, no
/// likelihoods, no simulation. It reads records and links and returns a
/// list; it writes nothing, so running it can never change canon.
library;

import 'connected_domain.dart';

/// How a change crosses one kind of edge.
class PropagationRule {
  const PropagationRule({
    required this.edgeTypeId,
    this.fromSource = '',
    this.fromTarget = '',
  });

  final String edgeTypeId;

  /// Said of the target when a change at the edge's source reaches it
  /// ("is ruled by"), or empty when a change at the source goes no further.
  final String fromSource;

  /// Said of the source when a change at the edge's target reaches it
  /// ("is governed by"), or empty when it does not.
  final String fromTarget;

  bool get propagates => fromSource.isNotEmpty || fromTarget.isNotEmpty;
}

/// One step on the way to an affected record.
class ConsequenceStep {
  const ConsequenceStep({
    required this.link,
    required this.from,
    required this.to,
    required this.reason,
  });

  final RecordLink link;
  final AuthorRecord from;
  final AuthorRecord to;

  /// Why [to] is affected by [from], in the rule's words.
  final String reason;
}

/// A record the change may affect, and the shortest path that reaches it.
class ConsequenceReach {
  const ConsequenceReach({required this.record, required this.path});

  final AuthorRecord record;

  /// From the changed record to [record], one step per edge.
  final List<ConsequenceStep> path;

  int get depth => path.length;

  /// The path in words: "The Ember Crown → Lord Chancellor (is governed by)".
  String get explanation => [
        path.first.from.title,
        for (final step in path) '${step.to.title} (${step.reason})',
      ].join(' → ');
}

/// What a change reaches.
class ConsequenceReport {
  const ConsequenceReport({required this.changed, required this.reached});

  final AuthorRecord changed;

  /// Nearest first, then by title.
  final List<ConsequenceReach> reached;

  bool get isEmpty => reached.isEmpty;

  ConsequenceReach? reachOf(String recordId) {
    for (final reach in reached) {
      if (reach.record.id == recordId) return reach;
    }
    return null;
  }
}

abstract final class ConsequenceTraversal {
  /// How far from the change the walk goes. A consequence four steps away is
  /// still one an author may want to review; past that, everything touches
  /// everything.
  static const defaultMaxDepth = 4;

  /// The rules for the built-in edges a world's systems are joined by. An
  /// edge with no rule carries nothing.
  static const defaultRules = <PropagationRule>[
    PropagationRule(edgeTypeId: 'governedBy', fromTarget: 'is governed by'),
    PropagationRule(edgeTypeId: 'rules', fromSource: 'is ruled by'),
    PropagationRule(edgeTypeId: 'controls', fromSource: 'is controlled by'),
    PropagationRule(edgeTypeId: 'dependsOn', fromTarget: 'depends on'),
    PropagationRule(edgeTypeId: 'produces', fromSource: 'is produced by'),
    PropagationRule(
      edgeTypeId: 'tradesWith',
      fromSource: 'trades with',
      fromTarget: 'trades with',
    ),
    PropagationRule(edgeTypeId: 'memberOf', fromTarget: 'is a member of'),
    PropagationRule(edgeTypeId: 'partOf', fromTarget: 'is part of'),
    PropagationRule(edgeTypeId: 'parentOf', fromSource: 'is a child of'),
    PropagationRule(edgeTypeId: 'worships', fromTarget: 'worships'),
    PropagationRule(edgeTypeId: 'locatedIn', fromTarget: 'is located in'),
    PropagationRule(
      edgeTypeId: 'atWarWith',
      fromSource: 'is at war with',
      fromTarget: 'is at war with',
    ),
    PropagationRule(
      edgeTypeId: 'alliedWith',
      fromSource: 'is allied with',
      fromTarget: 'is allied with',
    ),
    // Named so the absence is a decision: a culture or a language changing
    // does not, by itself, change the people who hold it.
    PropagationRule(edgeTypeId: 'hasCulture'),
    PropagationRule(edgeTypeId: 'speaks'),
  ];

  /// Walks out from [changedId] through [links] among [records].
  ///
  /// Breadth first, links in id order, so the path reported for each record
  /// is the shortest, and the same world always gives the same answer.
  /// Put-away records are neither reached nor walked through.
  static ConsequenceReport traverse({
    required String changedId,
    required List<AuthorRecord> records,
    required List<RecordLink> links,
    List<PropagationRule> rules = defaultRules,
    int maxDepth = defaultMaxDepth,
  }) {
    final byId = {
      for (final r in records)
        if (r.status == AuthorRecordStatus.active) r.id: r,
    };
    final changed = byId[changedId];
    if (changed == null) {
      throw ArgumentError.value(changedId, 'changedId', 'no such record');
    }
    final ruleOf = {for (final rule in rules) rule.edgeTypeId: rule};

    // Record id -> the steps that leave it.
    final out = <String, List<(RecordLink, String, String)>>{};
    for (final link in [...links]..sort((a, b) => a.id.compareTo(b.id))) {
      final rule = ruleOf[link.typeId];
      if (rule == null || !rule.propagates) continue;
      if (!byId.containsKey(link.sourceId) ||
          !byId.containsKey(link.targetId) ||
          link.sourceId == link.targetId) {
        continue;
      }
      final undirected = link.direction == RecordLinkDirection.undirected;
      if (rule.fromSource.isNotEmpty || undirected) {
        final reason =
            rule.fromSource.isNotEmpty ? rule.fromSource : rule.fromTarget;
        out
            .putIfAbsent(link.sourceId, () => [])
            .add((link, link.targetId, reason));
      }
      if (rule.fromTarget.isNotEmpty || undirected) {
        final reason =
            rule.fromTarget.isNotEmpty ? rule.fromTarget : rule.fromSource;
        out
            .putIfAbsent(link.targetId, () => [])
            .add((link, link.sourceId, reason));
      }
    }

    final paths = <String, List<ConsequenceStep>>{changedId: const []};
    var frontier = [changedId];
    for (var depth = 0; depth < maxDepth && frontier.isNotEmpty; depth++) {
      final next = <String>[];
      for (final id in frontier) {
        for (final (link, to, reason)
            in out[id] ?? const <(RecordLink, String, String)>[]) {
          if (paths.containsKey(to)) continue;
          paths[to] = [
            ...paths[id]!,
            ConsequenceStep(
              link: link,
              from: byId[id]!,
              to: byId[to]!,
              reason: reason,
            ),
          ];
          next.add(to);
        }
      }
      frontier = next;
    }

    final reached = [
      for (final MapEntry(key: id, value: path) in paths.entries)
        if (id != changedId) ConsequenceReach(record: byId[id]!, path: path),
    ]..sort((a, b) {
        final byDepth = a.depth.compareTo(b.depth);
        if (byDepth != 0) return byDepth;
        return a.record.title
            .toLowerCase()
            .compareTo(b.record.title.toLowerCase());
      });
    return ConsequenceReport(changed: changed, reached: reached);
  }
}
