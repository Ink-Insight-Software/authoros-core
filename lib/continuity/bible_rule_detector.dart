/// The rules an author wrote about their world, checked against the records
/// (AOS-Write `PLAN.md` §3.58).
///
/// A rule lives on the bible that states it (`BibleRules`, `_bible.rules`)
/// and speaks in the records' own terms — a type, a field, a value, a link —
/// so every finding names the records on both sides and nothing is guessed.
/// Prose is never read, the rule this engine was built on. A rule left
/// half-written, or switched off, asks nothing.
library;

import '../bible.dart';
import '../connected_domain.dart';
import '../continuity_domain.dart';
import '../timeline_domain.dart';
import '../timeline_record_fields.dart';
import 'calendar_detector.dart';
import 'continuity_models.dart';
import 'project_survey.dart';

List<StructuralFinding> detectBibleRules(ProjectSurvey survey) {
  final findings = <StructuralFinding>[];
  for (final bible in survey.records) {
    for (final rule in BibleRules.of(bible.fields)) {
      if (!rule.enabled || !rule.isComplete) continue;
      findings.addAll(switch (rule.kind) {
        BibleRuleKind.required => _required(survey, bible, rule),
        BibleRuleKind.unique => _unique(survey, bible, rule),
        BibleRuleKind.oneLink => _oneLink(survey, bible, rule),
        BibleRuleKind.neverTogether => _neverTogether(survey, bible, rule),
        BibleRuleKind.before => _before(survey, bible, rule),
      });
    }
  }
  return findings;
}

/// The records a rule is about. A rule about `character` covers every
/// character, however it was typed.
List<AuthorRecord> _subjects(ProjectSurvey survey, String typeId) =>
    typeId == 'character'
        ? survey.characters
        : survey.recordsOfTypes({typeId});

String _said(AuthorRecord bible, BibleRule rule, String fallback) =>
    rule.statement.trim().isEmpty ? fallback : rule.statement.trim();

StructuralFinding _finding(
  AuthorRecord bible,
  BibleRule rule, {
  required String title,
  required String detail,
  required List<String> entityIds,
}) =>
    StructuralFinding(
      condition: StructuralCondition.bibleRule,
      severity: ContinuitySeverity.warning,
      title: title,
      detail: '$detail ${bible.title} says: '
          '"${_said(bible, rule, rule.kind.label)}"',
      recommendation: 'Change the record, or the rule in ${bible.title} if '
          'the world has changed.',
      entityIds: [...entityIds, bible.id],
    );

String _text(Object? value) {
  if (value == null) return '';
  if (value is Iterable) return value.map((item) => '$item').join(', ');
  return '$value';
}

bool _holds(Object? value, String wanted) {
  final want = wanted.trim().toLowerCase();
  if (value is Iterable) {
    return value.any((item) => '$item'.trim().toLowerCase() == want);
  }
  return _text(value).trim().toLowerCase() == want;
}

Iterable<StructuralFinding> _required(
    ProjectSurvey survey, AuthorRecord bible, BibleRule rule) sync* {
  for (final record in _subjects(survey, rule.typeId)) {
    if (_text(record.fields[rule.fieldId]).trim().isNotEmpty) continue;
    yield _finding(bible, rule,
        title: '${record.title} has no ${rule.fieldId}',
        detail: 'Every ${rule.typeId} should fill ${rule.fieldId}.',
        entityIds: [record.id]);
  }
}

Iterable<StructuralFinding> _unique(
    ProjectSurvey survey, AuthorRecord bible, BibleRule rule) sync* {
  final byValue = <String, List<AuthorRecord>>{};
  for (final record in _subjects(survey, rule.typeId)) {
    final value = _text(record.fields[rule.fieldId]).trim().toLowerCase();
    if (value.isEmpty) continue;
    byValue.putIfAbsent(value, () => []).add(record);
  }
  for (final group in byValue.values) {
    if (group.length < 2) continue;
    final value = _text(group.first.fields[rule.fieldId]).trim();
    yield _finding(bible, rule,
        title: '${group.map((r) => r.title).join(' and ')} share '
            '${rule.fieldId} "$value"',
        detail: 'No two should.',
        entityIds: [for (final record in group) record.id]);
  }
}

Iterable<StructuralFinding> _oneLink(
    ProjectSurvey survey, AuthorRecord bible, BibleRule rule) sync* {
  final byTarget = <String, List<RecordLink>>{};
  for (final link in survey.links) {
    if (link.typeId != rule.linkTypeId) continue;
    byTarget.putIfAbsent(link.targetId, () => []).add(link);
  }
  final titles = {for (final record in survey.records) record.id: record.title};
  for (final entry in byTarget.entries) {
    final sources = {for (final link in entry.value) link.sourceId};
    if (sources.length < 2) continue;
    final target = titles[entry.key] ?? entry.key;
    yield _finding(bible, rule,
        title: '$target has ${sources.length} "${rule.linkTypeId}" links',
        detail: '${sources.map((id) => titles[id] ?? id).join(', ')} all '
            'link to $target as ${rule.linkTypeId}, and only one should.',
        entityIds: [entry.key, ...sources]);
  }
}

Iterable<StructuralFinding> _neverTogether(
    ProjectSurvey survey, AuthorRecord bible, BibleRule rule) sync* {
  for (final record in _subjects(survey, rule.typeId)) {
    if (!_holds(record.fields[rule.fieldId], rule.value)) continue;
    if (!_holds(record.fields[rule.otherFieldId], rule.otherValue)) continue;
    yield _finding(bible, rule,
        title: '${record.title} is both ${rule.value} and ${rule.otherValue}',
        detail: '${rule.fieldId} is ${rule.value} and ${rule.otherFieldId} '
            'is ${rule.otherValue}, which should never go together.',
        entityIds: [record.id]);
  }
}

/// A record's date: a timeline record's start, a character's birth.
TimelineDate? _dateOf(AuthorRecord record) {
  final start = timelineDateFrom(record.fields['start']);
  if (start != null && start.isDated) return start;
  return characterBirthDate(record);
}

/// A sortable key within one calendar.
int? _key(TimelineDate date) => date.year == null
    ? null
    : date.year! * 10000 + (date.month ?? 0) * 100 + (date.day ?? 0);

Iterable<StructuralFinding> _before(
    ProjectSurvey survey, AuthorRecord bible, BibleRule rule) sync* {
  final byId = {for (final record in survey.records) record.id: record};
  for (final link in survey.links) {
    if (link.typeId != rule.linkTypeId) continue;
    final source = byId[link.sourceId];
    final target = byId[link.targetId];
    if (source == null || target == null) continue;
    final first = _dateOf(source);
    final second = _dateOf(target);
    // Comparable only within one calendar; across calendars the Calendar
    // Bible's converter would be needed, and a rule that guessed would be
    // wrong in exactly the worlds that keep two.
    if (first == null ||
        second == null ||
        first.calendarId != second.calendarId) {
      continue;
    }
    final a = _key(first);
    final b = _key(second);
    if (a == null || b == null || a < b) continue;
    yield _finding(bible, rule,
        title: '${source.title} is not before ${target.title}',
        detail: '${source.title} (${first.year}) should come before '
            '${target.title} (${second.year}) along ${rule.linkTypeId}.',
        entityIds: [source.id, target.id]);
  }
}
