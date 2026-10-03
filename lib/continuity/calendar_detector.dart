/// Dates that the world's own calendar says cannot be right (AOS-Write
/// PLAN.md §3.45).
///
/// Four questions the Calendar Bible makes answerable, each asked only where
/// the author has given the calendar enough to answer it, and each silent
/// where they have not — a calendar of months with no lengths, an event with
/// no date, a character with no birth on file are unfinished, not wrong.
///
/// 1. **A day the calendar does not have** — the thirtieth of a month of
///    twenty-eight. The timeline detector skips these; this one says so.
/// 2. **Before they were born** — an event that involves a character dated
///    before their birth, read from the birth reading's true record first
///    and its public one second.
/// 3. **A festival on the wrong day** — an event named for one of the
///    calendar's placed festivals ("The Saintfall Vigil") dated away from it.
/// 4. **The prose names another month** — a scene whose story date is in one
///    month and whose words name a different month or festival of the same
///    calendar and not its own. A notice, not a warning: a character may well
///    speak of another month, and only the author can tell which this is.
library;

import 'dart:convert';

import '../connected_domain.dart';
import '../continuity_domain.dart';
import '../entity_recognition.dart';
import '../story_clock_links.dart';
import '../timeline_domain.dart';
import '../timeline_record_fields.dart';
import '../timeline_record_types.dart';
import 'continuity_models.dart';
import 'project_survey.dart';

/// Names shorter than this are never matched in prose, as for mentions.
const _shortestName = kMinimumMentionLength;

List<StructuralFinding> detectCalendarConflicts(ProjectSurvey survey) {
  final calendars = <String, TimelineCalendar>{
    for (final record
        in survey.recordsOfTypes(const {TimelineRecordTypes.calendarTypeId}))
      record.id: timelineCalendarFromRecord(record),
  };
  if (calendars.isEmpty) return const [];

  final findings = <StructuralFinding>[];
  final dated = <String, (AuthorRecord, TimelineDate, TimelineCalendar)>{};

  for (final record
      in survey.recordsOfTypes(TimelineRecordTypes.recordTypeIds.toSet())) {
    if (record.typeId == TimelineRecordTypes.calendarTypeId) continue;
    final start = timelineDateFrom(record.fields['start']);
    if (start == null || !start.isDated) continue;
    final calendar = calendars[start.calendarId];
    if (calendar == null) continue;
    try {
      calendar.validate(start);
    } on ArgumentError catch (error) {
      findings.add(StructuralFinding(
        condition: StructuralCondition.calendarConflict,
        severity: ContinuitySeverity.warning,
        title: '${record.title} is dated on a day ${calendar.name} does not '
            'have',
        detail: '${error.message}',
        recommendation: 'Change the date in Timeline, or give the month more '
            'days in the Calendar Bible.',
        entityIds: [record.id],
      ));
      continue;
    }
    dated[record.id] = (record, start, calendar);
    findings.addAll(_festivalTiming(record, start, calendar));
  }

  findings.addAll(_beforeBirth(survey, dated, calendars));
  findings.addAll(_proseNamesAnotherMonth(survey, dated));
  return findings;
}

/// An event named for a placed festival, dated away from it.
Iterable<StructuralFinding> _festivalTiming(
  AuthorRecord record,
  TimelineDate start,
  TimelineCalendar calendar,
) sync* {
  final title = record.title.toLowerCase();
  for (final special in calendar.specialDates) {
    if (!special.isPlaced || special.name.length < _shortestName) continue;
    if (!mentionsName(title, special.name.toLowerCase())) continue;
    if (special.fallsOn(start.month, start.day)) continue;
    final kept = special.day == null
        ? 'the whole of ${_monthName(calendar, special.month)}'
        : '${special.day} ${_monthName(calendar, special.month)}';
    yield StructuralFinding(
      condition: StructuralCondition.calendarConflict,
      severity: ContinuitySeverity.warning,
      title: '${record.title} is not on ${special.name}',
      detail: 'It is dated ${calendar.format(start)}; ${calendar.name} keeps '
          '${special.name} on $kept.',
      recommendation: 'Move the event to the festival, or rename it if it is '
          'only remembered then.',
      entityIds: [record.id],
    );
  }
}

/// Events that involve a character before their birth.
Iterable<StructuralFinding> _beforeBirth(
  ProjectSurvey survey,
  Map<String, (AuthorRecord, TimelineDate, TimelineCalendar)> dated,
  Map<String, TimelineCalendar> calendars,
) sync* {
  for (final character in survey.characters) {
    final birth = _birthOf(character);
    if (birth == null) continue;
    final birthCalendar = calendars[birth.calendarId];
    if (birthCalendar == null) continue;
    for (final link in survey.linksOf(character.id)) {
      if (link.typeId != 'involves') continue;
      final eventId =
          link.sourceId == character.id ? link.targetId : link.sourceId;
      final entry = dated[eventId];
      if (entry == null) continue;
      final (event, start, calendar) = entry;
      final eventDay = calendar.worldDayOf(start) ??
          (calendar.id == birthCalendar.id ? _yearOnly(calendar, start) : null);
      final birthDay = birthCalendar.worldDayOf(birth) ??
          (calendar.id == birthCalendar.id
              ? _yearOnly(birthCalendar, birth)
              : null);
      if (eventDay == null || birthDay == null || eventDay >= birthDay) {
        continue;
      }
      yield StructuralFinding(
        condition: StructuralCondition.calendarConflict,
        severity: ContinuitySeverity.warning,
        title: '${event.title} happens before ${character.title} is born',
        detail: '${event.title} is dated ${calendar.format(start)}; '
            '${character.title} is born ${birthCalendar.format(birth)}.',
        recommendation: 'Check the event\'s date, the birth reading, or '
            'whether ${character.title} is really there.',
        entityIds: [event.id, character.id],
      );
    }
  }
}

/// A year-level day for calendars that cannot count days: years compare,
/// and within a year, months do.
int? _yearOnly(TimelineCalendar calendar, TimelineDate date) =>
    date.year == null ? null : date.year! * 10000 + (date.month ?? 0) * 100 +
        (date.day ?? 0);

/// The character's birth date: the true record first, then the public one.
TimelineDate? _birthOf(AuthorRecord character) {
  for (final field in const ['birth.trueDate', 'birth.publicDate']) {
    final value = character.fields[field];
    Object? json = value;
    if (value is String && value.trim().startsWith('{')) {
      try {
        json = jsonDecode(value);
      } on FormatException {
        json = null;
      }
    }
    final date = timelineDateFrom(json);
    if (date != null && date.isDated) return date;
  }
  return null;
}

/// Scenes whose words name another month (or festival) than their own.
Iterable<StructuralFinding> _proseNamesAnotherMonth(
  ProjectSurvey survey,
  Map<String, (AuthorRecord, TimelineDate, TimelineCalendar)> dated,
) sync* {
  for (final scene in survey.scenes) {
    final entry = _sceneDate(survey, scene.id, dated);
    if (entry == null) continue;
    final (_, start, calendar) = entry;
    final month = start.month;
    if (month == null || month < 1 || month > calendar.months.length) continue;
    final prose = survey.proseOfScene(scene);
    final own = calendar.months[month - 1].name.toLowerCase();
    if (own.length >= _shortestName && mentionsName(prose, own)) continue;
    final named = <String>[
      for (final (index, other) in calendar.months.indexed)
        if (index + 1 != month &&
            other.name.length >= _shortestName &&
            mentionsName(prose, other.name.toLowerCase()))
          other.name,
      for (final special in calendar.specialDates)
        if (special.isPlaced &&
            special.month != month &&
            special.name.length >= _shortestName &&
            mentionsName(prose, special.name.toLowerCase()))
          special.name,
    ];
    if (named.isEmpty) continue;
    yield StructuralFinding(
      condition: StructuralCondition.calendarConflict,
      severity: ContinuitySeverity.notice,
      title: '${scene.title} names ${named.join(', ')}',
      detail: 'Its story date is ${calendar.format(start)}, in '
          '${calendar.months[month - 1].name}, and its words never name '
          'that month.',
      recommendation: 'If the scene is set then, check its timeline event; '
          'if a character only speaks of another month, there is nothing to '
          'fix.',
      entityIds: [scene.id],
    );
  }
}

/// The scene's story date: the earliest dated event it is linked to by the
/// Story Clock's edges.
(AuthorRecord, TimelineDate, TimelineCalendar)? _sceneDate(
  ProjectSurvey survey,
  String sceneId,
  Map<String, (AuthorRecord, TimelineDate, TimelineCalendar)> dated,
) {
  (AuthorRecord, TimelineDate, TimelineCalendar)? earliest;
  int? earliestKey;
  for (final link in survey.linksOf(sceneId)) {
    final String eventId;
    if (StoryClockLinks.fromScene.contains(link.typeId) &&
        link.sourceId == sceneId) {
      eventId = link.targetId;
    } else if (StoryClockLinks.toScene.contains(link.typeId) &&
        link.targetId == sceneId) {
      eventId = link.sourceId;
    } else {
      continue;
    }
    final entry = dated[eventId];
    if (entry == null) continue;
    final key = _yearOnly(entry.$3, entry.$2) ?? 0;
    if (earliestKey == null || key < earliestKey) {
      earliest = entry;
      earliestKey = key;
    }
  }
  return earliest;
}

String _monthName(TimelineCalendar calendar, int? month) =>
    month != null && month >= 1 && month <= calendar.months.length
        ? calendar.months[month - 1].name
        : 'month $month';
