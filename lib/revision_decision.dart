/// What the author decided about a finding — the domain layer.
///
/// Five separate pieces of work needed this and each deferred it with almost
/// the same sentence.
/// [ADR-0011](../../docs/architecture/ADR-0011-author-decisions-about-findings.md)
/// settled where it goes, and the answer was already in the tree: **a decision
/// is operational data.** It lives in one table beside `writing_session_rows`,
/// travels in `ConnectedDomainSnapshot`, and is held outside the story graph by
/// invariant I-16. No new record type. No new store.
///
/// ## What this is not
///
/// It is **not the finding.** A `RevisionFinding` has no id and is never
/// written; invariant I-9 is untouched and this file does not reopen it. Only
/// the author's *answer* is stored, and an answer is an assertion rather than a
/// derived observation.
///
/// It is **not a node.** A 120,000-word manuscript produces thousands of
/// findings, and a dismissal that were an `AuthorRecord` would be Lock 3's
/// two-thousand-trees failure with a different noun. Nothing here has an entity
/// row, and nothing may take one as the endpoint of a `RecordLink`.
///
/// It is **not `continuity_resolution_rows`.** That table is per-install
/// evidence that a warning was closed, kept for progression and deliberately
/// not archived. A decision is the opposite on both counts: it is the author's
/// standing intent about their book, and it travels.
///
/// ## Nothing here imports Flutter
///
/// Lock 12, and Lock 8 as well. Nothing here imports anything at all: the
/// snapshot that carries a decision is inside the provocation engine's import
/// closure, which Lock 8 holds to three entries. The keying grammar — which
/// needs `dart:convert` and `package:crypto` — lives beside this file in
/// `revision_decision_subject.dart`, so `lib/revision/` can derive a key from
/// a finding without this file ever learning what a finding is, and without
/// widening what AOS Unblocked can reach.
library;

/// The kinds of decision an author makes about a finding.
///
/// One enum for all five call sites, because the author's *act* is the same in
/// each — they looked at something the software noticed and said what they
/// think of it — and only its subject differs. Five local vocabularies were the
/// failure mode ADR-0011 exists to prevent.
///
/// Stored as [Enum.name] rather than an index, for the reason every other
/// enum in this codebase is: a stored index re-labels history the day somebody
/// reorders the enum.
enum RevisionDecisionKind {
  /// *I have seen this one.* Per-rule and per-instance suppression — risk V-3's
  /// load-bearing mitigation, and the reason a wall of findings becomes a list
  /// an author can work through.
  dismissal,

  /// *Must fix / consider / not for this book.* The sort authors already do by
  /// hand, in a spreadsheet.
  triage,

  /// *The developmental pass is done.* What turns Editor mode from a reordering
  /// into a workflow.
  passComplete,

  /// *This book spells it* Aeryn. An accepted style-sheet entry, so the Copy
  /// lens can report against the sheet rather than against raw counts.
  styleDecision,

  /// *These two sound alike on purpose.* A mimic, a liar, twins.
  ///
  /// `RecordLink` carries a metadata map and could have held this, and it is
  /// here instead: the author's act is dismissing a finding in both cases, and
  /// splitting one kind of action across two homes buys nothing. The style
  /// sheet **reads** these rather than the author asserting them twice.
  voicePair,
}

/// The values the closed kinds use.
///
/// [RevisionDecisionKind.styleDecision] is the open one — its value is the
/// spelling the author accepted, in their own characters — so it has no
/// constant here. Everything else answers from a fixed set, and a fixed set
/// written down once is a fixed set two call sites cannot spell differently.
class RevisionDecisionValues {
  const RevisionDecisionValues._();

  /// [RevisionDecisionKind.dismissal].
  static const dismissed = 'dismissed';

  /// [RevisionDecisionKind.triage], in the order an author works them.
  static const mustFix = 'must-fix';
  static const consider = 'consider';
  static const notForThisBook = 'not-for-this-book';

  /// [RevisionDecisionKind.passComplete].
  static const complete = 'complete';

  /// [RevisionDecisionKind.voicePair].
  static const deliberate = 'deliberate';

  /// The triage answers, in author order. The one place that ordering lives.
  static const triage = [mustFix, consider, notForThisBook];
}

/// Identity for a decision, derived from what the decision is *about*.
///
/// Every other id in AuthorOS is minted from a clock and a counter, and this
/// one is not, which is the single place this table departs from the
/// writing-session precedent it otherwise mirrors. The reason is that the two
/// hold different kinds of truth:
///
/// * A session is **what happened**. Recording it twice would be two events, so
///   sessions are append-only and written insert-or-ignore.
/// * A decision is **what the author currently thinks**. Changing triage from
///   *consider* to *must-fix* is not a second decision, it is the same one
///   revised, and a clock-minted id would leave both rows in the table with
///   nothing to say which is current.
///
/// Deriving the id from `(projectId, kind, subject)` makes re-deciding an
/// update by construction, and makes two devices that decided the same thing
/// produce one row rather than a conflict.
class RevisionDecisionId {
  const RevisionDecisionId._();

  /// The three parts, joined by a unit separator.
  ///
  /// Composed rather than hashed, and both halves of that are deliberate. It
  /// is legible, so a row in an archive says which decision it is; and it
  /// needs no `dart:convert` and no `package:crypto`, which matters because
  /// this file travels inside `ConnectedDomainSnapshot` and the snapshot is
  /// inside the AOS Unblocked provocation engine's import closure — a closure
  /// Lock 8 holds to three entries so that *"no model wrote these questions"*
  /// is enforced rather than promised. The hashing the subject grammar needs
  /// lives in `revision_decision_subject.dart`, out of that reach.
  ///
  /// The separator is a unit separator rather than a printable character, so
  /// nothing an author can type into a term or an accepted spelling can forge
  /// a boundary between the parts.
  static String create({
    required String projectId,
    required RevisionDecisionKind kind,
    required String subject,
  }) =>
      'revision_decision_$projectId\u001f${kind.name}\u001f$subject';
}

/// One thing the author decided about one finding.
class RevisionDecision {
  /// Creates a decision, minting the id from its own subject.
  ///
  /// There is no way to supply an id that disagrees with the subject, which is
  /// what makes "the same decision, revised" impossible to store as a second
  /// row by accident.
  factory RevisionDecision({
    required String projectId,
    required RevisionDecisionKind kind,
    required String subject,
    required String value,
    required DateTime decidedAt,
    String? sceneId,
    String? chapterId,
  }) =>
      RevisionDecision._(
        id: RevisionDecisionId.create(
          projectId: projectId,
          kind: kind,
          subject: subject,
        ),
        projectId: projectId,
        kind: kind,
        subject: subject,
        value: value,
        decidedAt: decidedAt,
        sceneId: sceneId,
        chapterId: chapterId,
      );

  const RevisionDecision._({
    required this.id,
    required this.projectId,
    required this.kind,
    required this.subject,
    required this.value,
    required this.decidedAt,
    this.sceneId,
    this.chapterId,
  });

  final String id;
  final String projectId;
  final RevisionDecisionKind kind;

  /// What the decision is about. See [RevisionDecisionSubject].
  final String subject;

  /// The decision itself — one of [RevisionDecisionValues], or the spelling the
  /// author accepted.
  final String value;

  /// When the author said so. Last write wins: two devices that decided the
  /// same subject differently keep the later answer, because a decision is a
  /// current intent and the later one is what the author thinks now.
  final DateTime decidedAt;

  /// Where the decision was made, when it was made somewhere.
  ///
  /// **Nullable soft pointers with no foreign key**, exactly as a session's
  /// are. Proximity without participation — invariant I-16, and the shape the
  /// Universal Story Graph prescribes for every operational subsystem. A scene
  /// deleted out from under a decision leaves a dangling string and breaks
  /// nothing, which is the whole point of not making it an edge.
  final String? sceneId;
  final String? chapterId;

  /// The same decision with a new answer, re-timed.
  ///
  /// Neither the subject nor the kind can be changed: those two are the
  /// identity, and a caller who wants a different subject wants a different
  /// decision.
  RevisionDecision revised({
    required String value,
    required DateTime decidedAt,
  }) =>
      RevisionDecision._(
        id: id,
        projectId: projectId,
        kind: kind,
        subject: subject,
        value: value,
        decidedAt: decidedAt,
        sceneId: sceneId,
        chapterId: chapterId,
      );

  /// Timestamps serialize as UTC ISO-8601, matching every other AuthorOS
  /// record.
  Map<String, Object?> toJson() => {
        'id': id,
        'projectId': projectId,
        'kind': kind.name,
        'subject': subject,
        'value': value,
        'decidedAt': decidedAt.toUtc().toIso8601String(),
        // Omitted when absent rather than written as null, so a restored
        // archive keeps the distinction between "decided nowhere in
        // particular" and "a scene was recorded and lost".
        if (sceneId != null) 'sceneId': sceneId,
        if (chapterId != null) 'chapterId': chapterId,
      };

  /// Reads a decision back.
  ///
  /// A row whose `kind` is a word this build does not know is **skipped by the
  /// caller**, not coerced: [kindFromName] returns null rather than guessing.
  /// An archive written by a later version that added a sixth kind imports its
  /// other five instead of failing, and inventing a kind for the sixth would be
  /// inventing a decision the author never made.
  static RevisionDecision? fromJson(Map<String, dynamic> json) {
    final kind = kindFromName(json['kind'] as String?);
    if (kind == null) return null;
    return RevisionDecision(
      projectId: (json['projectId'] as String?) ?? '',
      kind: kind,
      subject: (json['subject'] as String?) ?? '',
      value: (json['value'] as String?) ?? '',
      decidedAt: DateTime.parse(json['decidedAt'] as String).toLocal(),
      sceneId: json['sceneId'] as String?,
      chapterId: json['chapterId'] as String?,
    );
  }

  /// The kind that word names, or null where no kind does.
  static RevisionDecisionKind? kindFromName(String? name) {
    for (final kind in RevisionDecisionKind.values) {
      if (kind.name == name) return kind;
    }
    return null;
  }

  @override
  String toString() =>
      'RevisionDecision(${kind.name}, $subject, $value, $projectId)';
}
