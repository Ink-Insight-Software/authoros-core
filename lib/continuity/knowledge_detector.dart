/// Who knows what, and how old they are, checked against the records
/// (AOS-Write `PLAN.md` §3.47).
///
/// Two conditions, each asked only where the author has said enough to
/// answer it:
///
/// **Knowledge conflict**
/// 1. *Contradiction* — the sheet and a `knows` link disagree outright: one
///    says the character has the truth (knows, lies about, conceals), the
///    other that they do not (doesn't know, has forgotten), and neither says
///    when it changed.
/// 2. *Named before it is learned* — a scene the character is in names the
///    subject, earlier in the book than the scene they learn it in. A
///    notice: they may only be hearing the name.
///
/// **Age conflict**
/// 3. *Parent and child* — along `parentOf`, a parent born after their
///    child, or fewer than twelve years before them.
/// 4. *The sheet's age* — a character's stated age that none of their dated
///    events, read against their birth, would give them.
///
/// Dates compare only within one calendar, by year — the same restraint
/// the calendar check takes. Prose is read only for names, by the one
/// definition of a mention.
library;

import '../manuscript_model.dart';
import '../continuity_domain.dart';
import '../entity_recognition.dart';
import '../knowledge_ledger.dart';
import '../story_clock_links.dart';
import '../timeline_domain.dart';
import '../timeline_record_fields.dart';
import 'calendar_detector.dart';
import 'continuity_models.dart';
import 'project_survey.dart';

/// The youngest a parent is taken to be at a child's birth.
const minimumParentAge = 12;

List<StructuralFinding> detectKnowledgeConflicts(ProjectSurvey survey) {
  final ledger =
      KnowledgeLedger.read(records: survey.records, links: survey.links);
  final titles = {for (final record in survey.records) record.id: record.title};
  return [
    ..._contradictions(ledger, titles),
    ..._namedBeforeLearned(survey, ledger, titles),
  ];
}

Iterable<StructuralFinding> _contradictions(
    KnowledgeLedger ledger, Map<String, String> titles) sync* {
  final seen = <String>{};
  for (final fact in ledger.facts) {
    if (!fact.fromSheet || fact.subjectId == null) continue;
    for (final other in ledger.heldBy(fact.knowerId)) {
      if (other.fromSheet || other.subjectId != fact.subjectId) continue;
      final clash = (fact.state.holdsTruth && other.state.lacksTruth) ||
          (fact.state.lacksTruth && other.state.holdsTruth);
      if (!clash || other.learnedInId != null) continue;
      if (!seen.add('${fact.knowerId}|${fact.subjectId}')) continue;
      final who = titles[fact.knowerId] ?? fact.knowerId;
      yield StructuralFinding(
        condition: StructuralCondition.knowledgeConflict,
        severity: ContinuitySeverity.warning,
        title: '$who both ${_says(fact.state)} and ${_says(other.state)} '
            '${fact.subjectLabel}',
        detail: '$who\'s sheet says "${fact.state.label}"; their link to '
            '${fact.subjectLabel} says "${other.state.label}", and neither '
            'says when it changed.',
        recommendation: 'Change one, or say in which scene they learn it.',
        entityIds: [fact.knowerId, fact.subjectId!],
      );
    }
  }
}

String _says(KnowledgeState state) => switch (state) {
      KnowledgeState.knows => 'knows',
      KnowledgeState.doesNotKnow => "doesn't know",
      KnowledgeState.hasForgotten => 'has forgotten',
      KnowledgeState.liesAbout => 'lies about',
      KnowledgeState.conceals => 'conceals',
      KnowledgeState.suspects => 'suspects',
      KnowledgeState.believes => 'believes',
      KnowledgeState.misunderstands => 'misunderstands',
    };

/// Every scene in reading order: chapters by their order, scenes by theirs.
List<ManuscriptScene> scenesInReadingOrder(ProjectSurvey survey) {
  final chapters = [...survey.manuscript.chapters]
    ..sort((a, b) => a.order.compareTo(b.order));
  return [
    for (final chapter in chapters)
      ...([...chapter.scenes]..sort((a, b) => a.order.compareTo(b.order))),
  ];
}

/// Where [id] — a scene, or an event a scene depicts — falls in reading
/// order, or null when it cannot be placed.
int? Function(String id) readingPosition(ProjectSurvey survey) {
  final order = scenesInReadingOrder(survey);
  final index = {for (final (i, scene) in order.indexed) scene.id: i};
  return (id) {
    if (index[id] case final at?) return at;
    int? earliest;
    for (final link in survey.linksOf(id)) {
      final String scene;
      if (StoryClockLinks.toScene.contains(link.typeId) && link.sourceId == id) {
        scene = link.targetId;
      } else if (StoryClockLinks.fromScene.contains(link.typeId) &&
          link.targetId == id) {
        scene = link.sourceId;
      } else {
        continue;
      }
      final at = index[scene];
      if (at != null && (earliest == null || at < earliest)) earliest = at;
    }
    return earliest;
  };
}

Iterable<StructuralFinding> _namedBeforeLearned(ProjectSurvey survey,
    KnowledgeLedger ledger, Map<String, String> titles) sync* {
  final order = scenesInReadingOrder(survey);
  final position = readingPosition(survey);
  for (final fact in ledger.facts) {
    final learned = fact.learnedInId;
    final subject = fact.subjectId;
    if (learned == null || subject == null) continue;
    final at = position(learned);
    if (at == null) continue;
    final who = titles[fact.knowerId];
    final what = titles[subject];
    if (who == null || what == null) continue;
    for (final scene in order.take(at)) {
      final present = survey.linksOf(scene.id).any((link) =>
          link.sourceId == fact.knowerId || link.targetId == fact.knowerId);
      if (!present) continue;
      if (!mentionsName(survey.proseOfScene(scene), what)) continue;
      yield StructuralFinding(
        condition: StructuralCondition.knowledgeConflict,
        severity: ContinuitySeverity.notice,
        title: '${scene.title} names $what before $who learns of it',
        detail: '$who is in ${scene.title}, which names $what; they learn it '
            'in ${order[at].title}.',
        recommendation: 'If $who only hears the name here, there is nothing '
            'to fix; otherwise move when they learn it.',
        entityIds: [scene.id, fact.knowerId, subject],
      );
      break;
    }
  }
}

List<StructuralFinding> detectAgeConflicts(ProjectSurvey survey) {
  final births = <String, TimelineDate>{
    for (final character in survey.characters)
      if (characterBirthDate(character) case final birth?)
        if (birth.year != null) character.id: birth,
  };
  if (births.isEmpty) return const [];
  final byId = {for (final record in survey.records) record.id: record};
  final findings = <StructuralFinding>[];

  // Parents and children.
  for (final link in survey.links) {
    if (link.typeId != 'parentOf') continue;
    final parent = births[link.sourceId];
    final child = births[link.targetId];
    if (parent == null || child == null) continue;
    if (parent.calendarId != child.calendarId) continue;
    final gap = child.year! - parent.year!;
    if (gap >= minimumParentAge) continue;
    final p = byId[link.sourceId]?.title ?? link.sourceId;
    final c = byId[link.targetId]?.title ?? link.targetId;
    findings.add(StructuralFinding(
      condition: StructuralCondition.ageConflict,
      severity: ContinuitySeverity.warning,
      title: gap <= 0
          ? '$p is born after their child $c'
          : '$p is $gap when their child $c is born',
      detail: '$p is born in ${parent.year}, $c in ${child.year}.',
      recommendation: 'Check either birth, or whether $p is really $c\'s '
          'parent.',
      entityIds: [link.sourceId, link.targetId],
    ));
  }

  // The sheet's age against the dated events a character is in.
  for (final character in survey.characters) {
    final birth = births[character.id];
    final stated = character.fields['identity.age'];
    if (birth == null || stated is! num) continue;
    final ages = <int>[];
    for (final link in survey.linksOf(character.id)) {
      final otherId =
          link.sourceId == character.id ? link.targetId : link.sourceId;
      final event = byId[otherId];
      if (event == null) continue;
      final start = timelineDateFrom(event.fields['start']);
      if (start == null || start.year == null) continue;
      if (start.calendarId != birth.calendarId) continue;
      ages.add(start.year! - birth.year!);
    }
    if (ages.isEmpty) continue;
    ages.sort();
    final age = stated.toInt();
    if (age >= ages.first - 1 && age <= ages.last + 1) continue;
    final span = ages.first == ages.last
        ? '${ages.first}'
        : '${ages.first} to ${ages.last}';
    findings.add(StructuralFinding(
      condition: StructuralCondition.ageConflict,
      severity: ContinuitySeverity.notice,
      title: '${character.title} is $age on their sheet, $span in their '
          'events',
      detail: 'Born in ${birth.year}, ${character.title} is $span across the '
          'dated events they are in — never $age.',
      recommendation: 'Change the age on the sheet, the birth, or the dates.',
      entityIds: [character.id],
    ));
  }
  return findings;
}
