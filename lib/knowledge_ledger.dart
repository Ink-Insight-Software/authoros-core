/// Who knows what, and since when (AOS-Write `PLAN.md` §3.57).
///
/// Read, never stored: the facts are the `knows` links a character holds —
/// with their state, their private flag and the scene or event they were
/// learned in — and the rows of each character's *Character knowledge*
/// table. Nothing here is a second store of knowledge; it is a reading of the
/// two places AuthorOS already keeps it, so the sheet and the graph cannot
/// disagree about a fact without the ledger showing both.
library;

import 'dart:convert';

import 'connected_domain.dart';

/// What a character holds about something.
enum KnowledgeState {
  knows('Knows'),
  doesNotKnow("Doesn't Know"),
  suspects('Suspects'),
  believes('Believes'),
  misunderstands('Misunderstands'),
  hasForgotten('Has Forgotten'),
  liesAbout('Lies About'),
  conceals('Conceals');

  const KnowledgeState(this.label);

  /// The option as the `knows` edge stores it.
  final String label;

  /// Whether this state means the character has the truth.
  bool get holdsTruth =>
      this == knows || this == liesAbout || this == conceals;

  /// Whether this state means the character does not have it.
  bool get lacksTruth => this == doesNotKnow || this == hasForgotten;

  /// Whether what they say is not what they know.
  bool get isDeceit => this == liesAbout || this == conceals;

  /// The state a stored label names, forgiving case and spacing. Null for a
  /// label nobody recognises.
  static KnowledgeState? parse(Object? raw) {
    final text = '${raw ?? ''}'.trim().toLowerCase().replaceAll('’', "'");
    if (text.isEmpty) return null;
    for (final state in values) {
      if (state.label.toLowerCase() == text || state.name.toLowerCase() == text) {
        return state;
      }
    }
    return switch (text) {
      'unknown' || 'does not know' || 'doesnt know' => doesNotKnow,
      'forgotten' => hasForgotten,
      'lies' || 'lying' => liesAbout,
      'hides' || 'hidden' => conceals,
      _ => null,
    };
  }
}

/// One thing one character holds about one subject.
class KnowledgeFact {
  const KnowledgeFact({
    required this.knowerId,
    required this.subjectLabel,
    required this.state,
    this.subjectId,
    this.isPrivate = false,
    this.learnedInId,
    this.linkId,
  });

  final String knowerId;

  /// The record the fact is about, or null for a sheet row that names a
  /// subject only in words.
  final String? subjectId;
  final String subjectLabel;
  final KnowledgeState state;
  final bool isPrivate;

  /// The scene or event in which it was learned, when the author said.
  final String? learnedInId;

  /// The `knows` link this fact is, or null for a sheet row.
  final String? linkId;

  bool get fromSheet => linkId == null;

  /// The subject's key for grouping: its record, or its words.
  String get subjectKey =>
      subjectId ?? 'text:${subjectLabel.trim().toLowerCase()}';
}

/// Every fact in a project, grouped two ways.
class KnowledgeLedger {
  KnowledgeLedger(this.facts);

  final List<KnowledgeFact> facts;

  /// The ledger [records] and [links] describe. A sheet row whose subject is
  /// a record's title is read as being about that record, so the sheet and a
  /// `knows` link about the same thing land in the same row.
  factory KnowledgeLedger.read({
    required Iterable<AuthorRecord> records,
    required Iterable<RecordLink> links,
  }) {
    final byId = {for (final record in records) record.id: record};
    final byTitle = <String, String>{
      for (final record in records)
        if (record.title.trim().isNotEmpty)
          record.title.trim().toLowerCase(): record.id,
    };
    final facts = <KnowledgeFact>[];
    for (final link in links) {
      if (link.typeId != 'knows') continue;
      final state = KnowledgeState.parse(link.metadata['knowledgeState']) ??
          KnowledgeState.knows;
      final learned = '${link.metadata['learnedIn'] ?? ''}'.trim();
      facts.add(KnowledgeFact(
        knowerId: link.sourceId,
        subjectId: link.targetId,
        subjectLabel: byId[link.targetId]?.title ?? link.targetId,
        state: state,
        isPrivate: link.metadata['private'] == true,
        learnedInId: learned.isEmpty ? null : learned,
        linkId: link.id,
      ));
    }
    for (final record in records) {
      for (final row in sheetKnowledgeRows(record.fields['knowledge.entries'])) {
        final subject = '${row['subject'] ?? ''}'.trim();
        if (subject.isEmpty) continue;
        final state = KnowledgeState.parse(row['state']);
        if (state == null) continue;
        facts.add(KnowledgeFact(
          knowerId: record.id,
          subjectId: byTitle[subject.toLowerCase()],
          subjectLabel: subject,
          state: state,
        ));
      }
    }
    return KnowledgeLedger(facts);
  }

  /// Every knower, by id.
  Set<String> get knowerIds => {for (final fact in facts) fact.knowerId};

  /// Every subject key, with the label to show for it.
  Map<String, String> get subjects => {
        for (final fact in facts) fact.subjectKey: fact.subjectLabel,
      };

  List<KnowledgeFact> about(String subjectKey) => [
        for (final fact in facts)
          if (fact.subjectKey == subjectKey) fact,
      ];

  List<KnowledgeFact> heldBy(String knowerId) => [
        for (final fact in facts)
          if (fact.knowerId == knowerId) fact,
      ];

  /// The facts visible as of the moment at [position], where [positionOf]
  /// places a scene or event in reading order. A fact learned somewhere this
  /// cannot place — or never said — is visible throughout: not knowing when
  /// is not the same as not knowing.
  KnowledgeLedger asOf(int position, int? Function(String id) positionOf) =>
      KnowledgeLedger([
        for (final fact in facts)
          if (fact.learnedInId == null ||
              (positionOf(fact.learnedInId!) ?? -1) <= position)
            fact,
      ]);
}

/// The rows of a *Character knowledge* table, however they were stored: a
/// list of maps, or the JSON text Character Studio writes.
List<Map<String, Object?>> sheetKnowledgeRows(Object? value) {
  Object? decoded = value;
  if (value is String && value.trim().startsWith('[')) {
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return const [];
    }
  }
  if (decoded is! List) return const [];
  return [
    for (final row in decoded)
      if (row is Map) Map<String, Object?>.from(row),
  ];
}
