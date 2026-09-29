import 'connected_domain.dart';
import 'continuity_domain.dart';
import 'entity_recognition.dart';
import 'manuscript_model.dart';

/// One record the manuscript could be connected to, flattened so the
/// intelligence stays free of repository access and easy to test.
class ManuscriptKnownRecord {
  const ManuscriptKnownRecord({
    required this.id,
    required this.typeId,
    required this.title,
    this.aliases = const [],
    this.chronology,
  });

  final String id;
  final String typeId;
  final String title;

  /// Alternative names that should also count as a mention.
  final List<String> aliases;

  /// A comparable position on the project's timeline, when this record is a
  /// dated timeline event. Supplied by the caller from the existing timeline
  /// services rather than recomputed here.
  final num? chronology;

  List<String> get names => [title, ...aliases];

  bool get isCharacter => typeId == 'character';

  bool get isPlace => const {
        'location',
        'place',
        'region',
        'country',
        'city',
        'settlement',
        'district',
        'building',
      }.contains(typeId);
}

/// Manuscript-side inputs and resolution parameters for one Continuity
/// recommendation.
///
/// The Manuscript workspace does not implement a second continuity engine. It
/// derives [ContinuityWarning]s from manuscript nodes and Universal Record
/// data, hands them to the existing [ContinuityAnalyzer], and hands resolution
/// back to the existing `ContinuityActionService` (create and link) or to
/// `ManuscriptService` (review). This class only carries the extra identifiers
/// those services need.
class ManuscriptContinuityFinding {
  const ManuscriptContinuityFinding({
    required this.warning,
    required this.nodeId,
    this.targetId,
    this.missingName = '',
    this.connectionTypeId = 'appearsIn',
    this.reviewField = '',
    this.reviewValue = '',
  });

  final ContinuityWarning warning;

  /// The chapter or scene node the recommendation is anchored to.
  final String nodeId;

  /// The record a `link` recommendation should connect [nodeId] to.
  final String? targetId;

  /// The name a `create` recommendation should use.
  final String missingName;

  /// The connection type a `link` recommendation should create.
  final String connectionTypeId;

  /// The scene metadata field a `review` recommendation would change.
  final String reviewField;

  /// The value a `review` recommendation proposes for [reviewField].
  final String reviewValue;

  ContinuityActionKind get actionKind => switch (warning.type) {
        ContinuityWarningType.unknownCharacter ||
        ContinuityWarningType.unknownLocation =>
          ContinuityActionKind.create,
        ContinuityWarningType.missingRelationship => ContinuityActionKind.link,
        _ => ContinuityActionKind.review,
      };
}

/// A manuscript node's continuity findings plus the integrity summary
/// produced by the existing [ContinuityAnalyzer].
class ManuscriptContinuityReport {
  const ManuscriptContinuityReport({
    required this.summary,
    required this.findings,
  });

  static const empty = ManuscriptContinuityReport(
    summary: ContinuityIntegritySummary(
      score: 100,
      criticalCount: 0,
      warningCount: 0,
      noticeCount: 0,
      issues: [],
    ),
    findings: [],
  );

  final ContinuityIntegritySummary summary;

  /// Parallel to [ContinuityIntegritySummary.issues]: index `i` of one matches
  /// index `i` of the other, because `summaryFor` maps warnings in order.
  final List<ManuscriptContinuityFinding> findings;

  bool get isClean => findings.isEmpty;

  ManuscriptContinuityFinding? findingFor(ContinuityIntegrityIssue issue) {
    final index = summary.issues.indexOf(issue);
    return index >= 0 && index < findings.length ? findings[index] : null;
  }
}

/// Derives the Continuity recommendations that apply while
/// drafting a manuscript.
///
/// One rule applies to a **chapter**:
///
/// * **Unlinked mention** - the chapter's prose names a record but no
///   connection records the relationship. Resolved with a `link` action.
///   Raised once per record per chapter, however many times the chapter names
///   them, and never against a scene.
///
/// Four rules apply to a **scene**, none of which proposes a link from prose:
///
/// * **Unknown POV character** - the scene's POV names someone with no record
///   anywhere in the project. Resolved with a `create` action.
/// * **Unknown location** - the scene's location has no record. Resolved with
///   a `create` action.
/// * **POV not present** - the POV character has a record but is not connected
///   to the scene. Resolved with a `review` action that links them. This is
///   the author's own declared POV field missing its connection, not a name
///   recognised in prose, which is why it stays with the scene that declares
///   it.
/// * **Chronology conflict** - two scenes are connected to dated timeline
///   events whose order contradicts the narrative order. Resolved with a
///   `review` action.
///
/// ### Why mentions are chapter-scoped
///
/// A recognised name is evidence that a record belongs to this part of the
/// book, not evidence about one scene break. Scoping the rule to the scene
/// meant a character carried through six scenes produced six identical
/// recommendations, each of which the author had to answer separately, and
/// each of which came back the moment the prose moved across a scene
/// boundary. The chapter is the smallest unit where "this record is in this
/// stretch of the book" is a claim worth making once.
class ManuscriptContinuity {
  const ManuscriptContinuity({
    this.maxFindingsPerScene = 6,
    this.maxMentionsPerChapter = 12,
    this.minimumMentionLength = 4,
  });

  final int maxFindingsPerScene;

  /// A ceiling on the unlinked-mention rule, so a long chapter naming a large
  /// cast produces a readable list rather than a wall.
  final int maxMentionsPerChapter;

  /// Names shorter than this are ignored so common words produce no noise.
  final int minimumMentionLength;

  /// Analyses [scene] against the rest of the project.
  ///
  /// [records] is every record the scene could be connected to, [connectedIds]
  /// the entity ids already connected to the scene, and [knownNames] every
  /// record title and alias in the project so a name owned by another Studio
  /// is never reported as missing. [chronology] maps a scene id to the
  /// comparable timeline position of the events it is connected to.
  ///
  /// Never proposes a link from a name in the prose: that rule belongs to
  /// [analyzeChapter]. [records] is still required because the POV rules ask
  /// it whether the point-of-view character exists.
  ManuscriptContinuityReport analyzeScene({
    required ManuscriptScene scene,
    required ManuscriptChapter chapter,
    required List<ManuscriptKnownRecord> records,
    required Set<String> connectedIds,
    required Set<String> knownNames,
    ManuscriptScene? previousScene,
    Map<String, num> chronology = const {},
  }) {
    final findings = <ManuscriptContinuityFinding>[];
    final normalizedKnown = <String>{
      for (final name in knownNames) name.trim().toLowerCase(),
    }..remove('');

    // 1. POV: unknown character, or a known character who is not connected.
    final pov = scene.pov.trim().isEmpty ? chapter.pov.trim() : scene.pov.trim();
    if (pov.isNotEmpty && findings.length < maxFindingsPerScene) {
      final povRecord = records
          .where((record) => record.isCharacter)
          .where((record) => record.names.any(
                (name) => name.trim().toLowerCase() == pov.toLowerCase(),
              ))
          .firstOrNull;
      if (povRecord == null && !normalizedKnown.contains(pov.toLowerCase())) {
        findings.add(ManuscriptContinuityFinding(
          nodeId: scene.id,
          missingName: pov,
          warning: ContinuityWarning(
            type: ContinuityWarningType.unknownCharacter,
            severity: ContinuitySeverity.warning,
            title: 'Missing record for $pov',
            message: '${scene.title} is written from "$pov" POV, but no '
                'character record with that name exists in this project.',
            eventIds: [scene.id],
          ),
        ));
      } else if (povRecord != null && !connectedIds.contains(povRecord.id)) {
        findings.add(ManuscriptContinuityFinding(
          nodeId: scene.id,
          targetId: povRecord.id,
          connectionTypeId: 'appearsIn',
          reviewField: 'pov',
          reviewValue: povRecord.title,
          warning: ContinuityWarning(
            type: ContinuityWarningType.missingPovPresence,
            severity: ContinuitySeverity.warning,
            title: '${povRecord.title} is not present in ${scene.title}',
            message: '${scene.title} is written from ${povRecord.title}\'s POV '
                'but the character is not connected to the scene.',
            eventIds: [scene.id, povRecord.id],
          ),
        ));
      }
    }

    // 2. Unknown location.
    final location = scene.location.trim();
    if (location.isNotEmpty &&
        location.length >= minimumMentionLength &&
        findings.length < maxFindingsPerScene &&
        !normalizedKnown.contains(location.toLowerCase())) {
      findings.add(ManuscriptContinuityFinding(
        nodeId: scene.id,
        missingName: location,
        warning: ContinuityWarning(
          type: ContinuityWarningType.unknownLocation,
          severity: ContinuitySeverity.warning,
          title: 'Missing record for $location',
          message: '${scene.title} is set in "$location", but no record with '
              'that name exists in this project.',
          eventIds: [scene.id],
        ),
      ));
    }

    // 3. Chronology conflict against the previous scene in narrative order.
    final here = chronology[scene.id];
    final before = previousScene == null ? null : chronology[previousScene.id];
    if (here != null &&
        before != null &&
        here < before &&
        findings.length < maxFindingsPerScene) {
      findings.add(ManuscriptContinuityFinding(
        nodeId: scene.id,
        reviewField: 'order',
        reviewValue: '${scene.order}',
        warning: ContinuityWarning(
          type: ContinuityWarningType.impossibleSequence,
          severity: ContinuitySeverity.critical,
          title: 'Chronology conflict in ${scene.title}',
          message: '${scene.title} is connected to an event that happens '
              'before the event in ${previousScene!.title}, but it comes '
              'later in the manuscript.',
          eventIds: [previousScene.id, scene.id],
        ),
      ));
    }

    if (findings.isEmpty) return ManuscriptContinuityReport.empty;
    return ManuscriptContinuityReport(
      summary: ContinuityAnalyzer.summaryFor(
        findings.map((finding) => finding.warning).toList(),
      ),
      findings: findings,
    );
  }

  /// Analyses a whole chapter: its own unlinked mentions, then its scenes'
  /// reports folded together.
  ///
  /// [connectedIds] is keyed by node id and should carry an entry for the
  /// chapter as well as for each scene. The mention rule reads all of them:
  /// a record connected to any scene in the chapter is already accounted for
  /// and is not raised again against the chapter.
  ///
  /// [dismissedKeys] are the mentions the author has already waved away, keyed
  /// by [MentionDismissal.keyFor]. Passing them in keeps this class pure — the
  /// caller owns the store — while letting one dismissal silence the same
  /// mention wherever it is raised.
  ManuscriptContinuityReport analyzeChapter({
    required ManuscriptChapter chapter,
    required List<ManuscriptKnownRecord> records,
    required Map<String, Set<String>> connectedIds,
    required Set<String> knownNames,
    Map<String, num> chronology = const {},
    Set<String> dismissedKeys = const {},
  }) {
    final findings = <ManuscriptContinuityFinding>[
      ..._unlinkedMentions(
        chapter: chapter,
        records: records,
        connectedIds: connectedIds,
        dismissedKeys: dismissedKeys,
      ),
    ];
    final ordered = [...chapter.scenes]
      ..sort((left, right) => left.order.compareTo(right.order));
    for (var index = 0; index < ordered.length; index++) {
      final report = analyzeScene(
        scene: ordered[index],
        chapter: chapter,
        records: records,
        connectedIds: connectedIds[ordered[index].id] ?? const {},
        knownNames: knownNames,
        previousScene: index == 0 ? null : ordered[index - 1],
        chronology: chronology,
      );
      findings.addAll(report.findings);
    }
    if (findings.isEmpty) return ManuscriptContinuityReport.empty;
    return ManuscriptContinuityReport(
      summary: ContinuityAnalyzer.summaryFor(
        findings.map((finding) => finding.warning).toList(),
      ),
      findings: findings,
    );
  }

  /// The records this chapter names but does not connect to.
  ///
  /// One finding per record, however many times the chapter names them, and
  /// anchored to the chapter rather than to the scene the name happened to
  /// fall in.
  List<ManuscriptContinuityFinding> _unlinkedMentions({
    required ManuscriptChapter chapter,
    required List<ManuscriptKnownRecord> records,
    required Map<String, Set<String>> connectedIds,
    required Set<String> dismissedKeys,
  }) {
    final prose = chapterProse(chapter).toLowerCase();
    if (prose.trim().isEmpty) return const [];
    // Connected anywhere in the chapter counts as connected. An author who
    // linked a character to one scene has answered the question for the
    // chapter, and asking it again is the noise this rule exists to remove.
    final connected = <String>{
      ...?connectedIds[chapter.id],
      for (final scene in chapter.scenes) ...?connectedIds[scene.id],
    };
    final findings = <ManuscriptContinuityFinding>[];
    for (final record in records) {
      if (findings.length >= maxMentionsPerChapter) break;
      if (connected.contains(record.id)) continue;
      if (dismissedKeys.contains(MentionDismissal.keyFor(
        chapterId: chapter.id,
        entityId: record.id,
      ))) {
        continue;
      }
      final mention = firstMention(
        prose,
        record.names,
        minimumLength: minimumMentionLength,
      );
      if (mention == null) continue;
      findings.add(ManuscriptContinuityFinding(
        nodeId: chapter.id,
        targetId: record.id,
        connectionTypeId: 'appearsIn',
        warning: ContinuityWarning(
          type: ContinuityWarningType.missingRelationship,
          severity: ContinuitySeverity.notice,
          title: 'Unlinked mention of ${record.title}',
          message: '${chapter.title} refers to "$mention" but no connection '
              'records the relationship.',
          eventIds: [chapter.id, record.id],
        ),
      ));
    }
    return findings;
  }

  /// Everything a chapter has written in it, as one stretch of prose.
  ///
  /// The chapter's own title and summary, then each scene's title, body, notes
  /// and time label — the same parts the per-scene rules always read, joined so
  /// recognition sees the chapter the way a reader does.
  static String chapterProse(ManuscriptChapter chapter) => [
        chapter.title,
        chapter.summary,
        for (final scene in chapter.scenes) ...[
          scene.title,
          scene.content,
          scene.notes,
          scene.timeLabel,
        ],
      ].where((part) => part.trim().isNotEmpty).join('\n');

  /// Every title and alias that exists in the project, for missing-record
  /// checks. Accepts raw Universal Records so a name owned by another Studio
  /// counts as known.
  static Set<String> knownNames(Iterable<AuthorRecord> records) => <String>{
        for (final record in records) ...[
          record.title.trim(),
          ...aliasesOf(record).map((alias) => alias.trim()),
        ],
      }..remove('');

  /// Records flattened for [analyzeScene], preserving each record's aliases.
  static List<ManuscriptKnownRecord> knownRecords(
    Iterable<AuthorRecord> records, {
    Map<String, num> chronology = const {},
  }) =>
      [
        for (final record in records)
          ManuscriptKnownRecord(
            id: record.id,
            typeId: record.typeId,
            title: record.title,
            aliases: aliasesOf(record),
            chronology: chronology[record.id],
          ),
      ];

  static List<String> aliasesOf(AuthorRecord record) =>
      EntityNames.aliasesOf(record);
}
