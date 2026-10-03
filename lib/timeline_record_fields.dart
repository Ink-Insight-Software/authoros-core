/// Timeline records' temporal fields, read as the timeline's domain model.
///
/// Moved out of `timeline_service.dart` on September 29, 2026, so the
/// Continuity Engine's timeline detector can read the calendars and dates in
/// records it already holds from the shared core, without importing the
/// service that writes them (`PLAN.md` §3.33). The service forwards here, so
/// there is still one parser for each field shape. Timeline Studio owns the
/// shapes.
library;

import 'connected_domain.dart';
import 'timeline_domain.dart';

/// Projects a calendar-definition [record] into a [TimelineCalendar].
TimelineCalendar timelineCalendarFromRecord(AuthorRecord record) {
  final week = record.fields['weekStructure'];
  final weekdays = week is List
      ? [for (final day in week) TimelineWeekday.fromJson(day)]
          .where((day) => day.name.isNotEmpty)
          .toList()
      : const <TimelineWeekday>[];
  return TimelineCalendar(
    id: record.id,
    name: record.title,
    months: _objectList(record.fields['months'])
        .map((month) => TimelineCalendarMonth(
              name: month['name'] as String? ?? '',
              length: (month['length'] as num?)?.toInt() ?? 0,
              lore: CalendarMonthLore.fromJson(month),
            ))
        .toList(),
    weekDays: [for (final day in weekdays) day.name],
    // Kept only where a day says more than its name, so a calendar written
    // before weekdays had meanings reads exactly as it did.
    weekdayDetails: weekdays.any((day) => day.toJson().length > 1)
        ? weekdays
        : const [],
    eraNames: _strings(record.fields['eraNames']),
    epoch: _firstObject(record.fields['epoch']) ?? const {},
    dateFormat:
        record.fields['dateFormat'] as String? ?? '{year}-{month}-{day}',
    hasYearZero: record.fields['hasYearZero'] as bool? ?? true,
    yearsCountBackward: record.fields['yearDirection'] == 'backward',
    conversionMetadata:
        _firstObject(record.fields['conversionMetadata']) ?? const {},
    dateFormats: _objectList(record.fields['dateFormats'])
        .map(TimelineDateFormat.fromJson)
        .where((format) => format.template.isNotEmpty)
        .toList(),
    specialDates: _objectList(record.fields['specialDates'])
        .map(CalendarSpecialDate.fromJson)
        .where((special) => special.name.isNotEmpty)
        .toList(),
    signs: _objectList(record.fields['signs'])
        .map(CalendarSign.fromJson)
        .where((sign) => sign.name.isNotEmpty)
        .toList(),
    readingParts: _strings(record.fields['readingParts']),
  );
}

/// Reads a `start`/`end` temporal field into a [TimelineDate].
TimelineDate? timelineDateFrom(Object? value) {
  final json = _firstObject(value);
  return json == null || (json['calendarId'] as String? ?? '').isEmpty
      ? null
      : TimelineDate.fromJson(json);
}

Map<String, Object?>? _firstObject(Object? value) =>
    value is List && value.isNotEmpty
        ? _objectMap(value.first)
        : _objectMap(value);

Map<String, Object?>? _objectMap(Object? value) =>
    value is Map ? Map<String, Object?>.from(value) : null;

List<Map<String, Object?>> _objectList(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, Object?>.from(item))
        .toList()
    : const [];

List<String> _strings(Object? value) =>
    value is List ? value.map((item) => item.toString()).toList() : const [];
