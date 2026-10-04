/// The parts of a calendar that carry story meaning, not arithmetic.
///
/// A calendar in AuthorOS has always been able to count — months and their
/// lengths, eras, a format. What it could not hold is what an author's
/// calendar is *for*: that a month is feared, that a day is for courts, that
/// a festival hides a rescue network, that a child born under one star is
/// marked. These are the values that hold it, each read from and written to
/// the `calendar-definition` record's fields (`timeline_record_fields.dart`).
///
/// Everything here is optional and nothing here is required to count. A month
/// with no meaning still counts; a meaning on a month with no length is still
/// worth having. Every value also carries [CalendarDetails]: whatever else the
/// author wants to say about it, under labels they choose, so the shapes are a
/// floor and never a ceiling.
library;

/// The author's own labelled details on a calendar value, in their order.
///
/// Stored as a list of `{label, value}` maps rather than a map, so the order
/// the author wrote them in is the order they come back.
class CalendarDetails {
  const CalendarDetails([this.entries = const []]);

  final List<MapEntry<String, String>> entries;

  bool get isEmpty => entries.isEmpty;

  /// The value under [label], or empty.
  String operator [](String label) =>
      entries.where((entry) => entry.key == label).firstOrNull?.value ?? '';

  List<Map<String, Object?>> toJson() => [
        for (final entry in entries)
          if (entry.key.trim().isNotEmpty)
            {'label': entry.key, 'value': entry.value},
      ];

  factory CalendarDetails.fromJson(Object? value) => value is List
      ? CalendarDetails([
          for (final item in value)
            if (item is Map && item['label'] is String)
              MapEntry(item['label'] as String, '${item['value'] ?? ''}'),
        ])
      : const CalendarDetails();
}

/// What a month or cycle means, beyond its name and length.
///
/// The Endovier calendar's thirteenth month is the model: *Starless* — symbol
/// the Empty Sky; meaning death, silence, erasure; publicly a cursed month;
/// truly the month the Noxmere birth records were erased; no bells are rung;
/// any scene in it should carry tension. Each of those is a field below.
class CalendarMonthLore {
  const CalendarMonthLore({
    this.symbol = '',
    this.meaning = '',
    this.season = '',
    this.associations = const [],
    this.publicBelief = '',
    this.hiddenTruth = '',
    this.rituals = '',
    this.storyMeaning = '',
    this.plotUses = '',
    this.details = const CalendarDetails(),
  });

  final String symbol;
  final String meaning;
  final String season;

  /// Houses, factions, gods, peoples — whatever the month belongs to.
  final List<String> associations;
  final String publicBelief;
  final String hiddenTruth;
  final String rituals;

  /// How a scene set in this month should feel. The difference between a
  /// calendar that decorates and one a writer can use.
  final String storyMeaning;
  final String plotUses;
  final CalendarDetails details;

  bool get isEmpty =>
      symbol.isEmpty &&
      meaning.isEmpty &&
      season.isEmpty &&
      associations.isEmpty &&
      publicBelief.isEmpty &&
      hiddenTruth.isEmpty &&
      rituals.isEmpty &&
      storyMeaning.isEmpty &&
      plotUses.isEmpty &&
      details.isEmpty;

  Map<String, Object?> toJson() => {
        if (symbol.isNotEmpty) 'symbol': symbol,
        if (meaning.isNotEmpty) 'meaning': meaning,
        if (season.isNotEmpty) 'season': season,
        if (associations.isNotEmpty) 'associations': associations,
        if (publicBelief.isNotEmpty) 'publicBelief': publicBelief,
        if (hiddenTruth.isNotEmpty) 'hiddenTruth': hiddenTruth,
        if (rituals.isNotEmpty) 'rituals': rituals,
        if (storyMeaning.isNotEmpty) 'storyMeaning': storyMeaning,
        if (plotUses.isNotEmpty) 'plotUses': plotUses,
        if (!details.isEmpty) 'details': details.toJson(),
      };

  factory CalendarMonthLore.fromJson(Map<String, Object?> json) =>
      CalendarMonthLore(
        symbol: _text(json['symbol']),
        meaning: _text(json['meaning']),
        season: _text(json['season']),
        associations: _strings(json['associations']),
        publicBelief: _text(json['publicBelief']),
        hiddenTruth: _text(json['hiddenTruth']),
        rituals: _text(json['rituals']),
        storyMeaning: _text(json['storyMeaning']),
        plotUses: _text(json['plotUses']),
        details: CalendarDetails.fromJson(json['details']),
      );
}

/// One day of the week, with what it is for.
class TimelineWeekday {
  const TimelineWeekday({
    required this.name,
    this.meaning = '',
    this.kind = '',
    this.storyUse = '',
    this.details = const CalendarDetails(),
  });

  final String name;
  final String meaning;

  /// Work, rest, holy, market — the author's word, free.
  final String kind;
  final String storyUse;
  final CalendarDetails details;

  Map<String, Object?> toJson() => {
        'name': name,
        if (meaning.isNotEmpty) 'meaning': meaning,
        if (kind.isNotEmpty) 'kind': kind,
        if (storyUse.isNotEmpty) 'storyUse': storyUse,
        if (!details.isEmpty) 'details': details.toJson(),
      };

  /// A weekday is stored as a map now and as a bare name before; both read.
  factory TimelineWeekday.fromJson(Object? value) => value is Map
      ? TimelineWeekday(
          name: _text(value['name']),
          meaning: _text(value['meaning']),
          kind: _text(value['kind']),
          storyUse: _text(value['storyUse']),
          details: CalendarDetails.fromJson(value['details']),
        )
      : TimelineWeekday(name: '${value ?? ''}');
}

/// A named way of writing a date, for one use.
///
/// *13 Starless 247 AR* for archives, *Veilday, 2 Starveil* for dialogue: one
/// calendar is written several ways, and which way is a choice about where
/// the date appears.
class TimelineDateFormat {
  const TimelineDateFormat({
    required this.name,
    required this.template,
    this.use = '',
  });

  final String name;

  /// The template, in [TimelineCalendar.format]'s tokens.
  final String template;
  final String use;

  Map<String, Object?> toJson() => {
        'name': name,
        'template': template,
        if (use.isNotEmpty) 'use': use,
      };

  factory TimelineDateFormat.fromJson(Map<String, Object?> json) =>
      TimelineDateFormat(
        name: _text(json['name']),
        template: _text(json['template']),
        use: _text(json['use']),
      );
}

/// What kind of day a special date is. The author may use any word; these
/// are the ones the Calendar Bible offers first.
const calendarSpecialDateKinds = <String>[
  'Festival',
  'Holy day',
  'Mourning day',
  'Political date',
  'Dangerous date',
  'Secret date',
  'Seasonal ritual',
  'Anniversary',
  'Deadline',
];

/// A festival, holy day, dangerous night or secret anniversary.
///
/// Placed by [month] and [day] where the calendar fixes it, and by [timing]
/// in words where it does not: Bellturn falls *when the first Saint Star is
/// seen*, and no day number says that. A date with a month but no day lasts
/// the month — a season of galas rather than a night.
class CalendarSpecialDate {
  const CalendarSpecialDate({
    required this.name,
    this.kind = '',
    this.month,
    this.day,
    this.timing = '',
    this.publicMeaning = '',
    this.hiddenMeaning = '',
    this.rituals = '',
    this.characters = const [],
    this.sceneIdeas = '',
    this.details = const CalendarDetails(),
  });

  final String name;
  final String kind;

  /// One-based, as [TimelineDate.month].
  final int? month;
  final int? day;
  final String timing;
  final String publicMeaning;
  final String hiddenMeaning;
  final String rituals;

  /// The people it matters to, by name or record id.
  final List<String> characters;
  final String sceneIdeas;
  final CalendarDetails details;

  /// Whether it is placed in the calendar at all, rather than only described.
  bool get isPlaced => month != null;

  /// Whether a date in [month]/[day] falls on this one.
  bool fallsOn(int? month, int? day) {
    if (this.month == null || month == null || this.month != month) {
      return false;
    }
    return this.day == null || this.day == day;
  }

  Map<String, Object?> toJson() => {
        'name': name,
        if (kind.isNotEmpty) 'kind': kind,
        if (month != null) 'month': month,
        if (day != null) 'day': day,
        if (timing.isNotEmpty) 'timing': timing,
        if (publicMeaning.isNotEmpty) 'publicMeaning': publicMeaning,
        if (hiddenMeaning.isNotEmpty) 'hiddenMeaning': hiddenMeaning,
        if (rituals.isNotEmpty) 'rituals': rituals,
        if (characters.isNotEmpty) 'characters': characters,
        if (sceneIdeas.isNotEmpty) 'sceneIdeas': sceneIdeas,
        if (!details.isEmpty) 'details': details.toJson(),
      };

  factory CalendarSpecialDate.fromJson(Map<String, Object?> json) =>
      CalendarSpecialDate(
        name: _text(json['name']),
        kind: _text(json['kind']),
        month: _int(json['month']),
        day: _int(json['day']),
        timing: _text(json['timing']),
        publicMeaning: _text(json['publicMeaning']),
        hiddenMeaning: _text(json['hiddenMeaning']),
        rituals: _text(json['rituals']),
        characters: _strings(json['characters']),
        sceneIdeas: _text(json['sceneIdeas']),
        details: CalendarDetails.fromJson(json['details']),
      );
}

/// A sign in the calendar's sky: a dominant star, an omen mark, a moon house,
/// a constellation — whatever a birth reading in this world is made of.
///
/// [part] names which part of a reading it answers (`Dominant star`, `Omen
/// mark`, `Moon House`), in the author's words, so a world with a different
/// astrology simply names different parts. The birth month is always a part
/// and is the calendar's own months, so it has no entries here.
class CalendarSign {
  const CalendarSign({
    required this.name,
    this.part = '',
    this.meaning = '',
    this.association = '',
    this.publicTreatment = '',
    this.canonNote = '',
    this.details = const CalendarDetails(),
  });

  final String name;
  final String part;
  final String meaning;

  /// The House, faction or people it belongs to.
  final String association;
  final String publicTreatment;
  final String canonNote;
  final CalendarDetails details;

  Map<String, Object?> toJson() => {
        'name': name,
        if (part.isNotEmpty) 'part': part,
        if (meaning.isNotEmpty) 'meaning': meaning,
        if (association.isNotEmpty) 'association': association,
        if (publicTreatment.isNotEmpty) 'publicTreatment': publicTreatment,
        if (canonNote.isNotEmpty) 'canonNote': canonNote,
        if (!details.isEmpty) 'details': details.toJson(),
      };

  factory CalendarSign.fromJson(Map<String, Object?> json) => CalendarSign(
        name: _text(json['name']),
        part: _text(json['part']),
        meaning: _text(json['meaning']),
        association: _text(json['association']),
        publicTreatment: _text(json['publicTreatment']),
        canonNote: _text(json['canonNote']),
        details: CalendarDetails.fromJson(json['details']),
      );
}

String _text(Object? value) => value is String ? value : '';

int? _int(Object? value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : value is String
            ? int.tryParse(value.trim())
            : null;

List<String> _strings(Object? value) => value is List
    ? value.map((item) => '$item').where((item) => item.isNotEmpty).toList()
    : value is String && value.trim().isNotEmpty
        ? value.split(',').map((item) => item.trim()).toList()
        : const [];
