/// The Climate & Weather specialist system's record types.
///
/// The same mechanism the other systems use: ordinary [RecordTypeDefinition]s
/// in the canonical registry, carrying a pack of their own, named by a manifest
/// that defines nothing.
///
/// ## The ground was held open for this
///
/// S8 Ecosystem is the system most tempted to absorb climate, and it declined
/// to — `biome.conditions` is prose that models nothing, and no temperature or
/// rainfall field exists anywhere in that pack. It left a list,
/// `EcosystemRecordTypes.reservedForClimate`, and a test asserting that
/// `climate`, `weather` and `season` resolved to no record type at all.
///
/// That test now fails, which is exactly what it was written to do: it forced
/// this decision to be made deliberately rather than discovered. It is updated
/// in this change from "nobody owns these" to "Climate owns these, and
/// Ecosystem still does not", which is the assertion worth keeping.
///
/// ## What was here before
///
/// Fields on `location`, and only fields. `authoros-world-core` gives every
/// spatial type a `climate` long text, a `weather` long text, a `seasons` list,
/// `hazards` and `naturalPhenomena`. They describe *this* place: two valleys
/// under one monsoon get two descriptions that were meant to say the same
/// thing, and drift. It is the same defect S8 found in `location.flora`, and it
/// takes the same shape of fix.
///
/// Note that the field id `climate` on `location` and the record type id
/// `climate` declared here are different namespaces and do not collide. The
/// field stays where it is, untouched — an author who never enables this system
/// keeps exactly what they had.
///
/// ## The shape
///
///     general-lore
///     ├── climate          the regime: what the conditions reliably are
///     ├── season           one division of the world's year
///     ├── weather-pattern  what recurs most years, and why
///     └── weather-event    one occurrence worth naming
///
/// Four altitudes of the same subject, which is why they are four types and not
/// one with a "kind" field: a climate is a decades-long regime, a season is a
/// cycle within a year, a pattern is what that cycle reliably does, and an
/// event is the once that broke the pattern. An author reaching for any one of
/// them is not reaching for the others.
///
/// Three of the four descend from `general-lore`. `weather-event` descends from
/// `historical-event`, and that is the one inheritance edge worth arguing for.
///
/// It was not the first draft. The first draft made all four siblings on the
/// reasoning that `historical-event` is a bare child with no fields, so the
/// edge would transfer nothing — which turned out to be false. It carries ten:
/// `date`, `period`, `location`, `participants`, `cause`, `event`,
/// `consequences`, `publicKnowledge`, `hiddenTruth` and `relatedEvents`. The
/// draft was re-declaring four of them under different names (`when`, `where`,
/// `course`, `consequences`), which is precisely the duplication S8 objected to
/// in `location.flora`.
///
/// So the #83 test — does the child deserve the parent's field list? — is
/// answered yes here. A named storm has a date, a place, a cause, participants
/// and consequences, and it has a public account and a hidden truth as readily
/// as any battle. What this system adds on top is what makes it weather:
/// [kind], [severity], the [pattern] it belongs to, and what it cost.
///
/// The recurring half stays a sibling. `weather-pattern` is what happens most
/// years and is not an event in history; the storm that broke the pattern is.
/// That line is the reason these are two types rather than one.
///
/// ## What this system deliberately does not claim
///
/// **The locations.** `location` and its thirty-odd children belong to
/// `authoros-world-core`, which is infrastructure and always on. A climate
/// *covers* places; it is not one. Same boundary S8 drew, same reason.
///
/// **`biome`.** The neighbour that comes closest, and the distinction is worth
/// stating: a climate is the conditions, a biome is the living result. Rain and
/// warmth are climate; the rainforest that grows because of them is not. Both
/// can point at the same places without either owning the other.
///
/// **The cosmic bodies.** `planet`, `star` and `moon` belong to Astronomy
/// (S10). A season is caused by an orbit and an axial tilt, so `season` points
/// at those types and defines none of them — the third system in this codebase
/// to reference across a boundary rather than claim across one.
///
/// **`calendar-system` and `calendar-event`.** Both exist on `authoros-core`,
/// both bare. A season sits in a calendar and a calendar holds more than
/// seasons — feast days, regnal years, market weeks — so claiming it here would
/// take a general type for a specific purpose. `season.calendar` points at it
/// instead.
///
/// **`historical-event`, `hazards` and `naturalPhenomena`.** The first stays on
/// core; the second and third stay as fields on `location`, untouched.
library;

import 'record_types.dart';

class ClimateRecordTypes {
  const ClimateRecordTypes._();

  static const climateTypeId = 'climate';
  static const seasonTypeId = 'season';
  static const patternTypeId = 'weather-pattern';
  static const eventTypeId = 'weather-event';

  static const packId = 'authoros-climate-system';

  /// Every type this system presents. All four are new; it takes nothing over.
  static const List<String> recordTypeIds = [
    climateTypeId,
    seasonTypeId,
    patternTypeId,
    eventTypeId,
  ];

  /// The two S8 reserved and this system now claims.
  ///
  /// `weather` is deliberately not among them. S8 reserved the word, and the
  /// right type turned out to be two — `weather-pattern` and `weather-event` —
  /// because what recurs and what happened once are different things. The bare
  /// name stays unclaimed rather than being taken for one of them.
  static const List<String> claimedFromReservation = [
    climateTypeId,
    seasonTypeId,
  ];

  /// Types this system points at and deliberately does not own.
  static const List<String> ownedByAstronomy = ['planet', 'star', 'moon'];

  /// The neighbour that comes closest. A climate is the conditions; a biome is
  /// the living result of them.
  static const List<String> ownedByEcosystem = ['biome', 'ecosystem'];

  /// Bare types on `authoros-core`. A calendar holds more than seasons.
  static const List<String> ownedByCore = [
    'calendar-system',
    'calendar-event',
    'historical-event',
  ];

  /// All existing, all `*`-typed. No relationship is added and none is widened.
  static const List<String> connectionTypeIds = [
    'partOf',
    'occursDuring',
    'relatedTo',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _climate,
    _season,
    _pattern,
    _event,
  ];
}

const _codexTemplate = <String, Object?>{
  'codexTemplate': true,
  'supportsSimpleMode': true,
};

RecordFieldDefinition _field(
  String id,
  String label,
  RecordFieldType type,
  int order, {
  String description = '',
  List<String> referenceTypeIds = const [],
  String? optionSetId,
  bool allowCustomValues = false,
  bool quickCreateVisible = false,
  bool searchable = true,
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      referenceTypeIds: referenceTypeIds,
      optionSetId: optionSetId,
      allowCustomValues: allowCustomValues,
      quickCreateVisible: quickCreateVisible,
      searchable: searchable,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

// ---------------------------------------------------------------------------
// Option sets
// ---------------------------------------------------------------------------

const _climateKind = RecordOptionSet(
  id: 'climate-kind',
  name: 'Kind of climate',
  description: 'The broad regime, however the world would name it.',
  values: [
    'Tropical',
    'Arid',
    'Temperate',
    'Continental',
    'Polar',
    'Alpine',
    'Oceanic',
    'Mediterranean',
    'Monsoon',
    'Subterranean',
    'Magical',
    'Blighted',
    'Artificial',
  ],
);

const _seasonKind = RecordOptionSet(
  id: 'season-kind',
  name: 'Kind of season',
  description: 'Not every world divides its year into four, or into weather.',
  values: [
    'Spring',
    'Summer',
    'Autumn',
    'Winter',
    'Wet',
    'Dry',
    'Growing',
    'Harvest',
    'Dormant',
    'Storm',
    'Long dark',
    'Long light',
    'Flood',
    'Migration',
  ],
);

const _weatherKind = RecordOptionSet(
  id: 'weather-kind',
  name: 'Kind of weather',
  values: [
    'Rain',
    'Snow',
    'Storm',
    'Hurricane',
    'Tornado',
    'Drought',
    'Flood',
    'Heatwave',
    'Cold snap',
    'Fog',
    'Hail',
    'Dust storm',
    'Ashfall',
    'Aurora',
    'Magical',
  ],
);

const _severity = RecordOptionSet(
  id: 'weather-severity',
  name: 'Severity',
  description: 'Measured by what it does to people, not by any instrument.',
  values: [
    'Unremarkable',
    'Inconvenient',
    'Damaging',
    'Dangerous',
    'Devastating',
    'Unsurvivable',
  ],
);

// ---------------------------------------------------------------------------
// The climate
// ---------------------------------------------------------------------------

/// A regime of conditions, defined once and shared by every place under it.
///
/// The gap this fills is the one `location.climate` leaves: that field
/// describes a single place, so two valleys under one monsoon are described
/// twice and drift apart. This is that description given an id.
///
/// Deliberately about conditions and not about life. What grows under these
/// conditions is a biome, which S8 owns; the two point at the same places
/// without either containing the other.
final _climate = RecordTypeDefinition(
  id: ClimateRecordTypes.climateTypeId,
  name: 'Climate',
  description: 'A regime of conditions, defined once and shared by every '
      'place under it.',
  icon: 'thermostat',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_climateKind],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 90,
        optionSetId: 'climate-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field(
        'character', 'What it is like to live in', RecordFieldType.richText, 91,
        description: 'The lived version, written once.',
        quickCreateVisible: true),
    _field('temperature', 'Temperature', RecordFieldType.longText, 100,
        description: 'However the world measures or describes it.'),
    _field('precipitation', 'Precipitation', RecordFieldType.longText, 101),
    _field('wind', 'Wind', RecordFieldType.longText, 102),
    _field('variability', 'How reliable it is', RecordFieldType.longText, 103,
        description: 'A climate that can be counted on and one that cannot '
            'produce different peoples.'),
    _field('covers', 'Places under it', RecordFieldType.list, 110,
        description: 'Locations belong to the world, not to this system, so '
            'this is a list rather than a claim on them.',
        searchable: false),
    _field('drivenBy', 'What drives it', RecordFieldType.longText, 111,
        description: 'Ocean currents, a mountain wall, an orbit, a spell that '
            'was never lifted.'),
    _field('changing', 'Whether it is changing', RecordFieldType.richText, 112,
        description: 'And who has noticed. A climate that is shifting is a '
            'plot; one that is stable is a setting.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'climate-identity',
      title: 'The regime',
      order: 9,
      fieldIds: ['kind', 'character'],
    ),
    RecordTemplateSection(
      id: 'climate-conditions',
      title: 'Conditions',
      order: 10,
      fieldIds: ['temperature', 'precipitation', 'wind', 'variability'],
    ),
    RecordTemplateSection(
      id: 'climate-extent',
      title: 'Extent and cause',
      order: 11,
      fieldIds: ['covers', 'drivenBy', 'changing'],
    ),
  ],
  suggestedLinkTypeIds: ClimateRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: ClimateRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The season
// ---------------------------------------------------------------------------

/// One division of the world's year.
///
/// `location.seasons` is a list of names, which is enough to say a world has
/// four and nothing about what any of them does. A season that can be recorded
/// with its length, its work and its danger is one an author can set a chapter
/// inside.
///
/// [causedBy] points at Astronomy's bodies rather than describing an orbit
/// here. A season is the consequence of one, and the consequence is this
/// system's business; the orbit is not.
final _season = RecordTypeDefinition(
  id: ClimateRecordTypes.seasonTypeId,
  name: 'Season',
  description: 'One division of the world\'s year, and what it does to the '
      'people living through it.',
  icon: 'calendar_month',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_seasonKind],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 90,
        optionSetId: 'season-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('climate', 'In which climate', RecordFieldType.recordReference, 91,
        referenceTypeIds: [ClimateRecordTypes.climateTypeId],
        description: 'A season belongs to a regime; the same month is not the '
            'same season everywhere.',
        quickCreateVisible: true),
    _field('length', 'How long', RecordFieldType.shortText, 100,
        description: 'However the world counts time.'),
    _field(
        'calendar', 'In which calendar', RecordFieldType.recordReference, 101,
        referenceTypeIds: const ['calendar-system'],
        description: 'Declared on the core pack; a calendar holds more than '
            'seasons, so this points at one rather than owning it.'),
    _field('conditions', 'What it is like', RecordFieldType.richText, 102),
    _field('causedBy', 'What causes it', RecordFieldType.recordReference, 103,
        referenceTypeIds: const ['planet', 'star', 'moon'],
        description: 'The orbit or the body behind it. Declared by Astronomy; '
            'this system points at it and does not own it.'),
    _field('work', 'What people do in it', RecordFieldType.richText, 110,
        description: 'Planting, harvest, migration, war. A season with no work '
            'in it is scenery.'),
    _field('danger', 'What it makes dangerous', RecordFieldType.longText, 111),
    _field('observances', 'What it is marked by', RecordFieldType.list, 112,
        description: 'Festivals, fasts, closures — the calendar of it.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'season-identity',
      title: 'The season',
      order: 9,
      fieldIds: ['kind', 'climate'],
    ),
    RecordTemplateSection(
      id: 'season-shape',
      title: 'Shape of it',
      order: 10,
      fieldIds: ['length', 'calendar', 'conditions', 'causedBy'],
    ),
    RecordTemplateSection(
      id: 'season-life',
      title: 'Living through it',
      order: 11,
      fieldIds: ['work', 'danger', 'observances'],
    ),
  ],
  suggestedLinkTypeIds: ClimateRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: ClimateRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The weather pattern
// ---------------------------------------------------------------------------

/// What the weather reliably does, and what it costs when it does it.
///
/// Separate from [_event] because "the monsoon" and "the monsoon of the year
/// the bridge went" are different records, and collapsing them loses the more
/// useful one: a pattern is what characters plan around, an event is what
/// happens to them.
final _pattern = RecordTypeDefinition(
  id: ClimateRecordTypes.patternTypeId,
  name: 'Weather pattern',
  description: 'What the weather reliably does, and what people do about it.',
  icon: 'cyclone',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_weatherKind],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 90,
        optionSetId: 'weather-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('climate', 'In which climate', RecordFieldType.recordReference, 91,
        referenceTypeIds: [ClimateRecordTypes.climateTypeId],
        quickCreateVisible: true),
    _field('season', 'In which season', RecordFieldType.recordReference, 92,
        referenceTypeIds: [ClimateRecordTypes.seasonTypeId]),
    _field('frequency', 'How often', RecordFieldType.shortText, 100,
        description: 'Every year, most years, once a generation.'),
    _field('warning', 'How it announces itself', RecordFieldType.longText, 101,
        description: 'What the people who live here read before it arrives.'),
    _field('course', 'How it runs', RecordFieldType.richText, 102),
    _field(
        'preparation', 'What people do about it', RecordFieldType.richText, 110,
        description: 'A pattern that is prepared for shapes architecture, '
            'trade and law.'),
    _field('toll', 'What it costs anyway', RecordFieldType.longText, 111),
    _field('folklore', 'What is said about it', RecordFieldType.longText, 112,
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'pattern-identity',
      title: 'The pattern',
      order: 9,
      fieldIds: ['kind', 'climate', 'season'],
    ),
    RecordTemplateSection(
      id: 'pattern-course',
      title: 'How it runs',
      order: 10,
      fieldIds: ['frequency', 'warning', 'course'],
    ),
    RecordTemplateSection(
      id: 'pattern-cost',
      title: 'What it costs',
      order: 11,
      fieldIds: ['preparation', 'toll', 'folklore'],
    ),
  ],
  suggestedLinkTypeIds: ClimateRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: ClimateRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The weather event
// ---------------------------------------------------------------------------

/// One occurrence worth naming.
///
/// The only type here that inherits, and from `historical-event` — because that
/// is what it is. It brings `date`, `location`, `cause`, `event`,
/// `consequences`, `participants`, `publicKnowledge`, `hiddenTruth` and
/// `relatedEvents` with it, so none of those is re-declared under a
/// weather-flavoured name. What is added below is only what makes it weather.
final _event = RecordTypeDefinition(
  id: ClimateRecordTypes.eventTypeId,
  name: 'Weather event',
  description: 'One occurrence worth naming, and what it changed.',
  icon: 'flash_on',
  categoryId: 'world',
  baseTypeId: 'historical-event',
  optionSets: const [_weatherKind, _severity],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 90,
        optionSetId: 'weather-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('severity', 'Severity', RecordFieldType.singleChoice, 91,
        optionSetId: 'weather-severity',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('pattern', 'An instance of', RecordFieldType.recordReference, 92,
        referenceTypeIds: [ClimateRecordTypes.patternTypeId],
        description: 'The pattern it belongs to, if it belongs to one. The '
            'ones that do not are the interesting ones.'),
    // `date`, `location`, `cause`, `event`, `consequences`, `participants`,
    // `publicKnowledge` and `hiddenTruth` all arrive from `historical-event`
    // and are deliberately not repeated here.
    _field('deaths', 'What it cost', RecordFieldType.longText, 110,
        description: 'In lives, in livestock, in a harvest — whatever the '
            'world counts.',
        searchable: false),
    _field('remembered', 'How it is remembered', RecordFieldType.longText, 111,
        description: 'And by whom — the name a disaster is given is rarely '
            'the one the survivors use.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'event-identity',
      title: 'The event',
      order: 9,
      fieldIds: ['kind', 'severity', 'pattern'],
    ),
    RecordTemplateSection(
      id: 'event-aftermath',
      title: 'What it cost',
      order: 10,
      fieldIds: ['deaths', 'remembered'],
    ),
  ],
  suggestedLinkTypeIds: ClimateRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: ClimateRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
