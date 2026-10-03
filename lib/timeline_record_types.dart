import 'craft/craft_library.dart';
import 'record_types.dart';

class TimelineRecordTypes {
  const TimelineRecordTypes._();

  static const baseTypeId = 'timeline-record';
  static const eventTypeId = 'timeline-event';
  static const calendarTypeId = 'calendar-definition';
  static const eraTypeId = 'timeline-era';

  /// The two types that are an era under another name.
  ///
  /// They declare nothing of their own and inherit [eraTypeId], so the fields
  /// are written once and the distinction stays what it always was: a word an
  /// author prefers. An age is an era a world is proud of; a historical period
  /// is an era a historian named. Neither records anything different.
  static const eraChildTypeIds = <String>[
    'timeline-age',
    'timeline-historical-period',
  ];

  static const List<String> recordTypeIds = [
    'timeline',
    'timeline-era',
    'timeline-age',
    'timeline-historical-period',
    'timeline-event',
    'timeline-event-group',
    'timeline-date',
    'timeline-date-range',
    'timeline-milestone',
    'timeline-turning-point',
    'timeline-historical-record',
    'timeline-war',
    'timeline-battle',
    'timeline-disaster',
    'timeline-political-event',
    'timeline-birth',
    'timeline-death',
    'timeline-discovery',
    'timeline-invention',
    'timeline-founding',
    'timeline-destruction',
    'timeline-migration',
    'timeline-journey',
    'timeline-relationship-event',
    'timeline-character-event',
    'timeline-world-event',
    'timeline-custom-event',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _base,
    _calendar,
    _era,
    ..._children,
  ];

  static final List<RecordTypeDefinition> _children = _timelineTypes.entries
      // The era declares fields of its own, so it is written out below rather
      // than generated bare here.
      .where((entry) => entry.key != eraTypeId)
      .map(
        (entry) => RecordTypeDefinition(
          id: entry.key,
          name: entry.value,
          description: '${entry.value} represented in Timeline Studio.',
          icon: _icons[entry.key] ?? 'event',
          categoryId: 'timeline',
          // An age and a historical period are eras, so they inherit the era
          // rather than the bare temporal base: one set of fields, three
          // names. Everything else is an event and inherits the base.
          baseTypeId:
              eraChildTypeIds.contains(entry.key) ? eraTypeId : baseTypeId,
          fields: const [],
          sections: const [],
          suggestedLinkTypeIds: const [
            'partOf',
            'before',
            'after',
            'occursAt',
            'involves',
            'relatedTo',
          ],
          builtIn: true,
          sourcePackId: 'authoros-core',
          permissions: const {'editableDefinition': false},
          extensionData: const {'timelineStudio': true},
        ),
      )
      .toList(growable: false);
}

// `final`, not `const`: three of these fields take their description from the
// craft library, and a library lookup is not a const expression. Everything
// that needs no lookup keeps its own `const`, so the change costs one
// allocation at startup rather than eleven.
final _base = RecordTypeDefinition(
  id: TimelineRecordTypes.baseTypeId,
  name: 'Timeline Record',
  description: 'A temporal record shared across AuthorOS studios.',
  icon: 'timeline',
  categoryId: 'timeline',
  baseTypeId: 'general-lore',
  fields: [
    const RecordFieldDefinition(
      id: 'eventType',
      label: 'Event type',
      type: RecordFieldType.shortText,
      order: 100,
    ),
    const RecordFieldDefinition(
      id: 'start',
      label: 'Start',
      type: RecordFieldType.table,
      order: 101,
      extensionData: {'temporalValue': true},
    ),
    const RecordFieldDefinition(
      id: 'end',
      label: 'End',
      type: RecordFieldType.table,
      order: 102,
      extensionData: {'temporalValue': true},
    ),
    RecordFieldDefinition(
      id: 'duration',
      label: 'Duration',
      description: CraftLibrary.describe('timeline.duration'),
      type: RecordFieldType.table,
      order: 103,
    ),
    const RecordFieldDefinition(
      id: 'precision',
      label: 'Precision',
      type: RecordFieldType.singleChoice,
      order: 104,
      defaultValue: 'unknown',
      // Glosses, not craft — so they are written here rather than in the craft
      // library, which holds terms that have something to say about writing.
      // `exact` and `unknown` say themselves and carry nothing.
      optionDescriptions: {
        'approximate': 'Near enough to place on the timeline, not exact.',
        'range': 'Somewhere between two points, and not narrowed further.',
        'relative': 'Fixed against another event rather than a calendar — '
            'often the only dating an invented world has.',
      },
      options: ['exact', 'approximate', 'range', 'relative', 'unknown'],
    ),
    const RecordFieldDefinition(
      id: 'temporalStatus',
      label: 'Status',
      type: RecordFieldType.shortText,
      order: 105,
    ),
    RecordFieldDefinition(
      id: 'importance',
      label: 'Importance',
      description: CraftLibrary.describe('timeline.importance'),
      type: RecordFieldType.singleChoice,
      order: 106,
      defaultValue: 'normal',
      options: ['minor', 'normal', 'important', 'major', 'critical'],
    ),
    const RecordFieldDefinition(
      id: 'temporalScope',
      label: 'Scope',
      type: RecordFieldType.shortText,
      order: 107,
    ),
    const RecordFieldDefinition(
      id: 'dateRepresentations',
      label: 'Calendar representations',
      type: RecordFieldType.table,
      order: 108,
      extensionData: {'stableIds': true},
    ),
    const RecordFieldDefinition(
      id: 'relativeDate',
      label: 'Relative date',
      type: RecordFieldType.table,
      order: 109,
      extensionData: {'stableIds': true},
    ),
    RecordFieldDefinition(
      id: 'narrativeTime',
      label: 'Narrative time',
      description: CraftLibrary.describe('timeline.narrativeTime'),
      type: RecordFieldType.table,
      order: 110,
      extensionData: {'distinctFromWorldTime': true},
    ),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'temporal',
      title: 'Temporal',
      order: 10,
      fieldIds: [
        'eventType',
        'start',
        'end',
        'duration',
        'precision',
        'temporalStatus',
        'importance',
        'temporalScope',
        'dateRepresentations',
        'relativeDate',
        'narrativeTime',
      ],
    ),
  ],
  suggestedLinkTypeIds: const [
    'partOf',
    'before',
    'after',
    'during',
    'contains',
    'overlaps',
    'concurrentWith',
    'causedBy',
    'leadsTo',
    'follows',
    'precedes',
    'repeats',
    'occursAt',
    'associatedWith',
    'involves',
    'relatedTo',
  ],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: const {'editableDefinition': false},
  extensionData: const {'timelineStudio': true, 'abstract': true},
);

const _calendar = RecordTypeDefinition(
  id: TimelineRecordTypes.calendarTypeId,
  name: 'Calendar Definition',
  description: 'A deterministic project calendar without Earth assumptions.',
  icon: 'calendar_month',
  categoryId: 'timeline',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
      id: 'months',
      label: 'Months',
      type: RecordFieldType.table,
      order: 100,
    ),
    RecordFieldDefinition(
      id: 'weekStructure',
      label: 'Week structure',
      type: RecordFieldType.table,
      order: 101,
    ),
    RecordFieldDefinition(
      id: 'yearLength',
      label: 'Year length',
      type: RecordFieldType.number,
      order: 102,
    ),
    RecordFieldDefinition(
      id: 'eraNames',
      label: 'Era names',
      type: RecordFieldType.list,
      order: 103,
    ),
    RecordFieldDefinition(
      id: 'epoch',
      label: 'Epoch',
      type: RecordFieldType.table,
      order: 104,
    ),
    RecordFieldDefinition(
      id: 'dateFormat',
      label: 'Date format',
      type: RecordFieldType.shortText,
      order: 105,
    ),
    RecordFieldDefinition(
      id: 'hasYearZero',
      label: 'Has year zero',
      type: RecordFieldType.boolean,
      order: 106,
    ),
    RecordFieldDefinition(
      id: 'yearDirection',
      label: 'Year direction',
      type: RecordFieldType.singleChoice,
      order: 107,
      options: ['forward', 'backward'],
    ),
    RecordFieldDefinition(
      id: 'conversionMetadata',
      label: 'Conversion metadata',
      type: RecordFieldType.table,
      order: 108,
    ),
    // The Calendar Bible, since 0.6.0: what the calendar means, beside how it
    // counts. Every field is optional, and a calendar written before them
    // reads as it did. The structured ones are read by
    // `timelineCalendarFromRecord`; the prose ones are the author's.
    RecordFieldDefinition(
      id: 'culturalOrigin',
      label: 'Cultural origin',
      type: RecordFieldType.longText,
      order: 20,
    ),
    RecordFieldDefinition(
      id: 'usedBy',
      label: 'Who keeps it',
      type: RecordFieldType.longText,
      order: 21,
    ),
    RecordFieldDefinition(
      id: 'controlledBy',
      label: 'Who controls it',
      type: RecordFieldType.longText,
      order: 22,
    ),
    RecordFieldDefinition(
      id: 'publicMeaning',
      label: 'What it means in public',
      type: RecordFieldType.longText,
      order: 23,
    ),
    RecordFieldDefinition(
      id: 'hiddenLore',
      label: 'What it hides',
      type: RecordFieldType.longText,
      order: 24,
    ),
    RecordFieldDefinition(
      id: 'newYearEvent',
      label: 'How the year begins',
      type: RecordFieldType.longText,
      order: 30,
    ),
    RecordFieldDefinition(
      id: 'yearNaming',
      label: 'How years are named',
      type: RecordFieldType.longText,
      order: 31,
    ),
    RecordFieldDefinition(
      id: 'resetRules',
      label: 'Resets and reckonings',
      type: RecordFieldType.longText,
      order: 32,
    ),
    RecordFieldDefinition(
      id: 'dateFormats',
      label: 'Ways of writing a date',
      type: RecordFieldType.table,
      order: 110,
    ),
    RecordFieldDefinition(
      id: 'specialDates',
      label: 'Festivals and special dates',
      type: RecordFieldType.table,
      order: 120,
    ),
    RecordFieldDefinition(
      id: 'astrologySystem',
      label: 'How a reading works',
      type: RecordFieldType.longText,
      order: 130,
    ),
    RecordFieldDefinition(
      id: 'readingParts',
      label: 'Parts of a birth reading',
      type: RecordFieldType.list,
      order: 131,
    ),
    RecordFieldDefinition(
      id: 'signs',
      label: 'Stars, signs and omens',
      type: RecordFieldType.table,
      order: 132,
    ),
    RecordFieldDefinition(
      id: 'proseGuidance',
      label: 'Using it in prose',
      type: RecordFieldType.longText,
      order: 140,
    ),
    RecordFieldDefinition(
      id: 'customSections',
      label: 'More about this calendar',
      type: RecordFieldType.table,
      order: 150,
    ),
  ],
  sections: [
    RecordTemplateSection(
      id: 'calendar-overview',
      title: 'Overview',
      order: 11,
      fieldIds: [
        'culturalOrigin',
        'usedBy',
        'controlledBy',
        'publicMeaning',
        'hiddenLore',
      ],
    ),
    RecordTemplateSection(
      id: 'calendar-year',
      title: 'The year',
      order: 12,
      fieldIds: ['newYearEvent', 'yearNaming', 'resetRules'],
    ),
    RecordTemplateSection(
      id: 'calendar',
      title: 'Calendar',
      order: 10,
      fieldIds: [
        'months',
        'weekStructure',
        'yearLength',
        'eraNames',
        'epoch',
        'dateFormat',
        'hasYearZero',
        'yearDirection',
        'conversionMetadata',
        'dateFormats',
      ],
    ),
    RecordTemplateSection(
      id: 'calendar-special-dates',
      title: 'Festivals and special dates',
      order: 13,
      fieldIds: ['specialDates'],
    ),
    RecordTemplateSection(
      id: 'calendar-astrology',
      title: 'Astrology and omens',
      order: 14,
      fieldIds: ['astrologySystem', 'readingParts', 'signs'],
    ),
    RecordTemplateSection(
      id: 'calendar-prose',
      title: 'Using it in prose',
      order: 16,
      fieldIds: ['proseGuidance', 'customSections'],
    ),
  ],
  suggestedLinkTypeIds: ['relatedTo'],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
  extensionData: {'timelineStudio': true, 'calendarDefinition': true},
);

/// An era: a stretch of world-time with a character of its own.
///
/// **It declares nothing about *when* it is.** Every field below is about what
/// an era *is*, because [_base] already carries when it began, when it ended,
/// how long it ran, how precisely it is dated and where it sits in narrative
/// time. An era that re-declared its dates would be two answers to one
/// question, which is the thing Lock 1 objects to.
///
/// It also declares no ordering. `before`, `after` and `partOf` are suggested
/// link types on the base, and an era that carried a "followed by" field would
/// be a second edge model beside the Connection Engine.
///
/// **This is the type; `timeline-age` and `timeline-historical-period` inherit
/// it.** Both existed as bare children with no fields at all, which made three
/// names for one idea and no way to record any of them. See
/// [TimelineRecordTypes.eraChildTypeIds].
///
/// ## Why [dateLabel] is the load-bearing field
///
/// `TimelineDate.era` is a string stamped on every dated record in the
/// project, and until now it resolved to nothing: an author could date a
/// scene "Year 412, Third Age" and the Third Age was a word. An era whose
/// label matches is what turns that string into a record — see
/// `TimelineQueryService.inEra`, which gathers everything dated inside an era
/// rather than only what someone remembered to link.
///
/// The calendar's own `eraNames` list is deliberately untouched. It is the
/// dating *vocabulary* — the labels a formatter may stamp — and this is the
/// record of what happened under one of them. Two different questions, and
/// the record is the canonical answer to the second.
const _era = RecordTypeDefinition(
  id: TimelineRecordTypes.eraTypeId,
  name: 'Era',
  description: 'A stretch of world-time with a character of its own: what '
      'made it, what was true in it, and what it left behind.',
  icon: 'history',
  categoryId: 'timeline',
  baseTypeId: TimelineRecordTypes.baseTypeId,
  optionSets: [_eraKind],
  fields: [
    RecordFieldDefinition(
      id: 'eraKind',
      label: 'Kind',
      type: RecordFieldType.singleChoice,
      order: 200,
      optionSetId: 'era-kind',
      allowCustomValues: true,
      quickCreateVisible: true,
    ),
    RecordFieldDefinition(
      id: 'calendar',
      label: 'In which calendar',
      type: RecordFieldType.recordReference,
      order: 201,
      referenceTypeIds: [TimelineRecordTypes.calendarTypeId],
      description: 'The calendar this era is dated against. It points at the '
          'calendar the timeline actually uses, not at a note about one.',
      quickCreateVisible: true,
    ),
    RecordFieldDefinition(
      id: 'dateLabel',
      label: 'How dates here are stamped',
      type: RecordFieldType.shortText,
      order: 202,
      description: 'The label that appears in a date — "3A", "AR", "Before '
          'the Sundering". Match it to what your dates already say and this '
          'era gathers every record written inside it.',
    ),
    RecordFieldDefinition(
      id: 'namedBy',
      label: 'Who calls it that',
      type: RecordFieldType.shortText,
      order: 203,
      description: 'Eras are named afterwards, and usually by whoever won. '
          'Nobody living through one calls it the Dark Age.',
    ),
    RecordFieldDefinition(
      id: 'began',
      label: 'What began it',
      type: RecordFieldType.recordReference,
      order: 210,
      referenceTypeIds: [TimelineRecordTypes.baseTypeId],
      description: 'The event that opened it. The date is above; this is the '
          'cause.',
    ),
    RecordFieldDefinition(
      id: 'ended',
      label: 'What ended it',
      type: RecordFieldType.recordReference,
      order: 211,
      referenceTypeIds: [TimelineRecordTypes.baseTypeId],
    ),
    RecordFieldDefinition(
      id: 'defining',
      label: 'What was true here and not on either side',
      type: RecordFieldType.richText,
      order: 212,
      description: 'The one field an era cannot do without. If nothing goes '
          'here, what you have is a date range.',
    ),
    RecordFieldDefinition(
      id: 'power',
      label: 'Who held power',
      type: RecordFieldType.recordReference,
      order: 213,
      referenceTypeIds: ['faction', 'character', 'organisation'],
    ),
    RecordFieldDefinition(
      id: 'everyday',
      label: 'An ordinary day in it',
      type: RecordFieldType.richText,
      order: 220,
      description: 'What someone with no part in the great events woke up to.',
    ),
    RecordFieldDefinition(
      id: 'limits',
      label: 'What exists, and what does not',
      type: RecordFieldType.richText,
      order: 221,
      description: 'Travel, medicine, weapons, letters, magic. The half of an '
          'era writers get wrong is the half that had not been invented yet.',
    ),
    RecordFieldDefinition(
      id: 'conflict',
      label: 'What it is fighting about',
      type: RecordFieldType.longText,
      order: 222,
    ),
    RecordFieldDefinition(
      id: 'legacy',
      label: 'What it left behind',
      type: RecordFieldType.longText,
      order: 223,
      description: 'Ruins, laws, grudges, songs. This is what makes an era '
          'useful to a book set long after it.',
    ),
  ],
  sections: [
    RecordTemplateSection(
      id: 'era-identity',
      title: 'The era',
      order: 20,
      fieldIds: ['eraKind', 'calendar', 'dateLabel', 'namedBy'],
    ),
    RecordTemplateSection(
      id: 'era-edges',
      title: 'What made it',
      order: 21,
      fieldIds: ['began', 'ended', 'defining', 'power'],
    ),
    RecordTemplateSection(
      id: 'era-life',
      title: 'Living in it',
      order: 22,
      fieldIds: ['everyday', 'limits', 'conflict', 'legacy'],
    ),
  ],
  suggestedLinkTypeIds: [
    'partOf',
    'before',
    'after',
    'involves',
    'relatedTo',
  ],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
  extensionData: {'timelineStudio': true, 'era': true},
);

/// The kinds an era comes in, and custom values are allowed beside them.
///
/// A list of what an era *was like*, never of what it was worth: "dark age"
/// is what a later century called it, which is why [_era]'s `namedBy` sits
/// beside this field.
const _eraKind = RecordOptionSet(
  id: 'era-kind',
  name: 'Kind of era',
  description: 'What the stretch was like to live in. Custom values are '
      'allowed beside these, because no list of eleven covers a world.',
  values: [
    'Founding',
    'Golden age',
    'Dark age',
    'Dynasty',
    'Republic',
    'Occupation',
    'Interregnum',
    'Exile',
    'War years',
    'Reconstruction',
    'Decline',
  ],
  optionDescriptions: {
    'Dark age': 'What a later century called it. Nobody living through one '
        'uses the phrase.',
    'Interregnum': 'Between two settled orders, and named for the gap rather '
        'than for anything in it.',
  },
);

const _timelineTypes = <String, String>{
  'timeline': 'Timeline',
  'timeline-era': 'Era',
  'timeline-age': 'Age',
  'timeline-historical-period': 'Historical Period',
  'timeline-event': 'Event',
  'timeline-event-group': 'Event Group',
  'timeline-date': 'Date',
  'timeline-date-range': 'Date Range',
  'timeline-milestone': 'Milestone',
  'timeline-turning-point': 'Turning Point',
  'timeline-historical-record': 'Historical Record',
  'timeline-war': 'War',
  'timeline-battle': 'Battle',
  'timeline-disaster': 'Disaster',
  'timeline-political-event': 'Political Event',
  'timeline-birth': 'Birth',
  'timeline-death': 'Death',
  'timeline-discovery': 'Discovery',
  'timeline-invention': 'Invention',
  'timeline-founding': 'Founding',
  'timeline-destruction': 'Destruction',
  'timeline-migration': 'Migration',
  'timeline-journey': 'Journey',
  'timeline-relationship-event': 'Relationship Event',
  'timeline-character-event': 'Character Event',
  'timeline-world-event': 'World Event',
  'timeline-custom-event': 'Custom Event',
};

const _icons = <String, String>{
  'timeline': 'timeline',
  'timeline-era': 'history',
  'timeline-event-group': 'account_tree',
  'timeline-war': 'shield',
  'timeline-battle': 'swords',
  'timeline-birth': 'child_care',
  'timeline-death': 'memorial',
  'timeline-journey': 'route',
};
