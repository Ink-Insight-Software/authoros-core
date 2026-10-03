import 'calendar_bible.dart';

export 'calendar_bible.dart';

enum TimelinePrecision { exact, approximate, range, relative, unknown }

class TimelineDate {
  const TimelineDate({
    required this.calendarId,
    this.era,
    this.year,
    this.month,
    this.day,
    this.time,
    this.timeZone,
    this.precision = TimelinePrecision.exact,
    this.approximate = false,
    this.displayFormat,
  });

  final String calendarId;
  final String? era;
  final int? year;
  final int? month;
  final int? day;
  final String? time;
  final String? timeZone;
  final TimelinePrecision precision;
  final bool approximate;
  final String? displayFormat;

  bool get isDated => year != null;

  Map<String, Object?> toJson() => {
        'calendarId': calendarId,
        'era': era,
        'year': year,
        'month': month,
        'day': day,
        'time': time,
        'timeZone': timeZone,
        'precision': precision.name,
        'approximate': approximate,
        'displayFormat': displayFormat,
      };

  factory TimelineDate.fromJson(Map<String, Object?> json) => TimelineDate(
        calendarId: json['calendarId'] as String? ?? '',
        era: json['era'] as String?,
        year: json['year'] as int?,
        month: json['month'] as int?,
        day: json['day'] as int?,
        time: json['time'] as String?,
        timeZone: json['timeZone'] as String?,
        precision: TimelinePrecision.values.firstWhere(
          (value) => value.name == json['precision'],
          orElse: () => TimelinePrecision.unknown,
        ),
        approximate: json['approximate'] as bool? ?? false,
        displayFormat: json['displayFormat'] as String?,
      );
}

class TimelineDateRange {
  const TimelineDateRange({this.start, this.end});

  final TimelineDate? start;
  final TimelineDate? end;

  Map<String, Object?> toJson() => {
        'start': start?.toJson(),
        'end': end?.toJson(),
      };
}

class RelativeTimelineDate {
  const RelativeTimelineDate({
    required this.anchorRecordId,
    required this.relation,
    this.offset = 0,
    this.unit = 'day',
    this.description = '',
  });

  final String anchorRecordId;
  final String relation;
  final int offset;
  final String unit;
  final String description;

  Map<String, Object?> toJson() => {
        'anchorRecordId': anchorRecordId,
        'relation': relation,
        'offset': offset,
        'unit': unit,
        'description': description,
      };
}

class TimelineCalendarMonth {
  const TimelineCalendarMonth({
    required this.name,
    required this.length,
    this.lore = const CalendarMonthLore(),
  });

  final String name;

  /// Days in the month, or 0 where the author has not fixed it. A calendar
  /// with any month of unknown length can still name and write dates; it
  /// cannot count days between them (see [TimelineCalendar.canCount]).
  final int length;

  /// What the month means. Empty for a month that is only a name.
  final CalendarMonthLore lore;

  Map<String, Object?> toJson() =>
      {'name': name, 'length': length, ...lore.toJson()};
}

class TimelineCalendar {
  const TimelineCalendar({
    required this.id,
    required this.name,
    required this.months,
    this.weekDays = const [],
    this.eraNames = const [],
    this.epoch = const {},
    this.dateFormat = '{year}-{month}-{day}',
    this.hasYearZero = true,
    this.yearsCountBackward = false,
    this.conversionMetadata = const {},
    this.weekdayDetails = const [],
    this.dateFormats = const [],
    this.specialDates = const [],
    this.signs = const [],
    this.readingParts = const [],
  });

  final String id;
  final String name;
  final List<TimelineCalendarMonth> months;
  final List<String> weekDays;
  final List<String> eraNames;
  final Map<String, Object?> epoch;
  final String dateFormat;
  final bool hasYearZero;
  final bool yearsCountBackward;
  final Map<String, Object?> conversionMetadata;

  /// The week with what each day is for. Empty when the week was written as
  /// bare names, which [weekdays] still reads.
  final List<TimelineWeekday> weekdayDetails;

  /// Named ways of writing a date, beside [dateFormat], which stays the one a
  /// date uses when nothing asks for another.
  final List<TimelineDateFormat> dateFormats;
  final List<CalendarSpecialDate> specialDates;
  final List<CalendarSign> signs;

  /// The parts of a birth reading beyond its month, in order — "Dominant
  /// star", "Moon House", "Omen mark". Names the [CalendarSign.part]s.
  final List<String> readingParts;

  int get yearLength => months.fold(0, (sum, month) => sum + month.length);

  /// The week, as days with meanings, whichever way it was stored.
  List<TimelineWeekday> get weekdays => weekdayDetails.isNotEmpty
      ? weekdayDetails
      : [for (final name in weekDays) TimelineWeekday(name: name)];

  /// Whether days can be counted: every month has a length. Weekdays,
  /// conversion and the distance between two dates all need it; naming and
  /// writing a date does not.
  bool get canCount =>
      months.isNotEmpty && months.every((month) => month.length > 0);

  /// The weekday of the calendar's first day — year 1 (or 0), month 1, day 1
  /// — as an index into [weekdays]. Kept in [epoch], which is where a
  /// calendar says where it starts.
  int get firstWeekday => _int(epoch['firstWeekday']) ?? 0;

  /// The day this calendar's first day falls on in the project's shared
  /// count of days, so two calendars of one world can be converted. Two
  /// calendars that both leave it at 0 begin on the same day.
  int get worldDayOffset => _int(epoch['worldDay']) ?? 0;

  int ordinal(TimelineDate date) {
    validate(date);
    final year = date.year!;
    final normalizedYear = hasYearZero || year < 0 ? year : year - 1;
    final yearOffset = yearsCountBackward ? -normalizedYear : normalizedYear;
    final precedingMonths = date.month == null
        ? 0
        : months.take(date.month! - 1).fold<int>(
              0,
              (sum, month) => sum + month.length,
            );
    return yearOffset * yearLength + precedingMonths + (date.day ?? 1) - 1;
  }

  /// Renders [date] through this calendar's [dateFormat] template, or
  /// [template] when one is given.
  ///
  /// Tokens: `{year}`, `{month}`, `{day}`, `{monthName}`, `{era}`, `{time}`,
  /// and since 0.6.0 `{weekday}` (the day of the week, where the calendar can
  /// count), `{monthSymbol}` and `{season}` (from the month's lore). A token
  /// the date or calendar cannot answer collapses cleanly instead of printing,
  /// with the separator beside it. An explicit [TimelineDate.displayFormat] on
  /// the date wins over the calendar's template, but not over [template].
  String format(TimelineDate date, {String? template}) {
    if (!date.isDated) return 'Undated';
    final month =
        date.month != null && date.month! >= 1 && date.month! <= months.length
            ? months[date.month! - 1]
            : null;
    var text = template ?? date.displayFormat ?? dateFormat;
    final replacements = <String, String>{
      '{year}': '${date.year}',
      '{monthName}': month?.name ?? '',
      '{monthSymbol}': month?.lore.symbol ?? '',
      '{month}': date.month == null ? '' : '${date.month}',
      '{weekday}': weekdayOf(date)?.name ?? '',
      '{season}': month?.lore.season ?? '',
      '{day}': date.day == null ? '' : '${date.day}',
      '{era}': date.era ?? '',
      '{time}': date.time ?? '',
    };
    replacements.forEach((token, value) {
      text = text.replaceAll(token, value);
    });
    // Collapse separators left behind by missing components: at either end,
    // doubled in the middle (", ,"), and runs of spaces.
    text = text
        .replaceAll(RegExp(r'[-/.,:\s]+$'), '')
        .replaceAll(RegExp(r'^[,.:/\s]+'), '')
        .replaceAll(RegExp(r'(--)+'), '-')
        .replaceAll(RegExp(r'\s*,(\s*,)+'), ',')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    if (text.isEmpty) return 'Year ${date.year}';
    return date.approximate ? '~$text' : text;
  }

  /// The day of the week [date] falls on, or null where it cannot be known:
  /// no week, a month of unknown length, or no day.
  TimelineWeekday? weekdayOf(TimelineDate date) {
    final week = weekdays;
    if (week.isEmpty || !canCount || date.day == null || date.month == null) {
      return null;
    }
    try {
      final index = (ordinal(date) + firstWeekday) % week.length;
      return week[index < 0 ? index + week.length : index];
    } on ArgumentError {
      return null;
    }
  }

  /// The special dates that fall on [date].
  List<CalendarSpecialDate> specialDatesOn(TimelineDate date) => [
        for (final special in specialDates)
          if (special.fallsOn(date.month, date.day)) special,
      ];

  /// The date on day [ordinal] of this calendar's own count — the inverse of
  /// [ordinal]. Null where the calendar cannot count.
  TimelineDate? dateAt(int ordinal, {String? era}) {
    if (!canCount) return null;
    final length = yearLength;
    final yearOffset = (ordinal / length).floor();
    var remainder = ordinal - yearOffset * length;
    final normalized = yearsCountBackward ? -yearOffset : yearOffset;
    final year = hasYearZero || normalized < 0 ? normalized : normalized + 1;
    var month = 1;
    for (final candidate in months) {
      if (remainder < candidate.length) break;
      remainder -= candidate.length;
      month++;
    }
    return TimelineDate(
      calendarId: id,
      era: era ?? (eraNames.isEmpty ? null : eraNames.first),
      year: year,
      month: month,
      day: remainder + 1,
    );
  }

  /// [date]'s day in the project's shared count, for conversion; null where
  /// the calendar cannot count or the date is not a day.
  int? worldDayOf(TimelineDate date) {
    if (!canCount || date.day == null || date.month == null) return null;
    try {
      return ordinal(date) + worldDayOffset;
    } on ArgumentError {
      return null;
    }
  }

  /// The date on shared day [worldDay].
  TimelineDate? dateAtWorldDay(int worldDay, {String? era}) =>
      dateAt(worldDay - worldDayOffset, era: era);

  /// The real-world date this calendar's [anchorOrdinal] falls on, where the
  /// author has tied the two — a story set beside our own history, or a
  /// writer planning by today's date. Kept in [conversionMetadata] as
  /// `{gregorian: "2024-03-12", ordinal: 0}`, one story day to one Earth day.
  DateTime? get gregorianAnchor {
    final text = conversionMetadata['gregorian'];
    return text is String ? DateTime.tryParse(text) : null;
  }

  int get anchorOrdinal => _int(conversionMetadata['ordinal']) ?? 0;

  /// The story date on real-world [day], or null with no anchor.
  TimelineDate? fromGregorian(DateTime day) {
    final anchor = gregorianAnchor;
    if (anchor == null) return null;
    final days = DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(anchor.year, anchor.month, anchor.day))
        .inDays;
    return dateAt(anchorOrdinal + days);
  }

  /// The real-world day [date] falls on, or null with no anchor.
  DateTime? toGregorian(TimelineDate date) {
    final anchor = gregorianAnchor;
    if (anchor == null || !canCount || date.day == null) return null;
    try {
      return DateTime.utc(anchor.year, anchor.month, anchor.day)
          .add(Duration(days: ordinal(date) - anchorOrdinal));
    } on ArgumentError {
      return null;
    }
  }

  void validate(TimelineDate date) {
    if (date.calendarId != id) {
      throw ArgumentError('Date uses ${date.calendarId}, not calendar $id.');
    }
    if (!date.isDated) return;
    if (!hasYearZero && date.year == 0) {
      throw ArgumentError('Calendar $id does not have year zero.');
    }
    final month = date.month;
    if (month != null && (month < 1 || month > months.length)) {
      throw ArgumentError('Month $month is invalid for calendar $id.');
    }
    final day = date.day;
    if (day != null) {
      if (month == null) {
        throw ArgumentError('A day requires a month.');
      }
      // A month of unknown length (0) takes any day from 1: the author has
      // not said how long it is, so no day can be past its end.
      final length = months[month - 1].length;
      if (day < 1 || (length > 0 && day > length)) {
        throw ArgumentError('Day $day is invalid for month $month.');
      }
    }
  }

  Map<String, Object?> toFields() => {
        'summary': name,
        'months': months.map((month) => month.toJson()).toList(),
        'weekStructure': weekdayDetails.isNotEmpty
            ? weekdayDetails.map((day) => day.toJson()).toList()
            : weekDays,
        'yearLength': yearLength,
        'eraNames': eraNames,
        'epoch': [if (epoch.isNotEmpty) epoch],
        'dateFormat': dateFormat,
        'hasYearZero': hasYearZero,
        'yearDirection': yearsCountBackward ? 'backward' : 'forward',
        'conversionMetadata': [
          if (conversionMetadata.isNotEmpty) conversionMetadata,
        ],
        if (dateFormats.isNotEmpty)
          'dateFormats': dateFormats.map((item) => item.toJson()).toList(),
        if (specialDates.isNotEmpty)
          'specialDates': specialDates.map((item) => item.toJson()).toList(),
        if (signs.isNotEmpty)
          'signs': signs.map((item) => item.toJson()).toList(),
        if (readingParts.isNotEmpty) 'readingParts': readingParts,
      };
}

class TimelineValidationIssue {
  const TimelineValidationIssue({
    required this.code,
    required this.message,
    this.isError = true,
  });

  final String code;
  final String message;
  final bool isError;
}

/// Converts [date] from calendar [from] into calendar [to], through the
/// project's shared count of days. Null where either cannot count.
TimelineDate? convertTimelineDate(
  TimelineDate date, {
  required TimelineCalendar from,
  required TimelineCalendar to,
  String? era,
}) {
  final worldDay = from.worldDayOf(date);
  return worldDay == null ? null : to.dateAtWorldDay(worldDay, era: era);
}

int? _int(Object? value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : value is String
            ? int.tryParse(value)
            : null;
