/// The Ecosystem & Ecology specialist system's record types.
///
/// The same mechanism the other systems use: ordinary [RecordTypeDefinition]s
/// in the canonical registry, carrying a pack of their own, named by a manifest
/// that defines nothing.
///
/// ## What was here before, and why this is narrower than its name
///
/// S8 arrives into territory three neighbours already occupy, and the useful
/// work was deciding what is genuinely missing rather than restating them.
///
/// `location` and its thirty-odd children — `region`, `forest`, `desert`,
/// `ocean`, `island`, `natural-feature` — belong to `authoros-world-core`,
/// which is infrastructure and always on. Their **Environment** section already
/// carries `geography`, `climate`, `terrain`, `elevation`, `naturalResources`,
/// `water`, `wildlife`, `flora`, `fauna`, `weather`, `seasons`, `hazards` and
/// `naturalPhenomena`. Bestiary declares `species`, `race`, `creature`,
/// `monster`, `animal` and `plant`, each carrying `habitat` and `diet`.
///
/// So a place already says what grows there, and an organism already says where
/// it lives. What neither can express is the **system between them**:
///
///   * `location.flora` and `location.fauna` are lists of names. They say what
///     is present and nothing about what depends on what, so an author cannot
///     ask what happens to the valley if the wolves go.
///   * `species.diet` is a single short text field. "Carnivore" does not
///     traverse; it cannot be followed to the thing eaten.
///   * `location.climate` describes *this* forest. There is nowhere to define
///     "temperate rainforest" once and have six locations point at it, so the
///     description is retyped per place and drifts.
///
/// ## The shape
///
///     general-lore
///     ├── biome              a recurring kind of living environment
///     ├── ecosystem          one living community, in one place
///     ├── food-web           who eats whom, and what a collapse cascades into
///     └── ecological-niche   what one species does for a living
///
/// Nothing here inherits from anything else. An ecosystem is not a kind of
/// biome — it is an instance of one, which is a reference and not an
/// inheritance edge — and a niche is not a small food web. The test #83 applied
/// to `magic-ability` (does the child deserve the parent's field list?) says
/// these four are siblings.
///
/// `biome` and `ecosystem` are separate for the reason `political-system` and
/// `government` are separate in S5: the biome is the recurring kind, the
/// ecosystem is the particular community claiming to be one. A world can hold
/// nine tundra ecosystems, each with a different food web.
///
/// ## What this system deliberately does not claim
///
/// **The locations.** `region` and the other spatial types stay with
/// world-core. An ecosystem *occupies* a place; it is not one, and claiming
/// `region` would take an always-on infrastructure type into a pack an author
/// can switch off — which Lock 6 permits but which would leave every location
/// record in the project looking disabled.
///
/// **The organisms.** `species`, `race`, `creature`, `monster`, `animal` and
/// `plant` stay with Bestiary. One owner per record type is enforced at
/// registry construction, so these are pointed at, never claimed — the same
/// boundary S6 drew, and for the same reason.
///
/// **Climate and weather.** This is the boundary worth stating plainly, because
/// it is the one an ecology system is most tempted to cross. Climate is S9. A
/// biome names the conditions it needs in prose and points at nothing that
/// models them, so when S9 arrives it finds the type unclaimed rather than
/// half-built. `weather` and `seasons` likewise remain fields on `location`.
///
/// **`resource`.** It exists on `authoros-core` and Economy (Wave 4) has the
/// better claim: a resource is a thing extracted and traded, and its ecological
/// aspect is one reading of it rather than the whole.
///
/// ## On the trophic vocabulary
///
/// Descent had this problem in S6 and it recurs here. The honest relationship
/// names would be `eats` and `preyedOnBy`, and neither exists; `livesIn` does
/// exist but is declared with `sourceTypeIds: ['character']`, so a species
/// cannot be its subject without widening it. Adding or widening a relationship
/// is a change to the shared vocabulary rather than part of declaring a system,
/// so this uses `partOf`, `requires` and `relatedTo` — all three already
/// present and all three `*`-typed — and carries the trophic detail as fields
/// on `food-web` and `ecological-niche`, where it is at least traversable.
library;

import 'record_types.dart';

class EcosystemRecordTypes {
  const EcosystemRecordTypes._();

  static const biomeTypeId = 'biome';
  static const ecosystemTypeId = 'ecosystem';
  static const foodWebTypeId = 'food-web';
  static const nicheTypeId = 'ecological-niche';

  static const packId = 'authoros-ecosystem-system';

  /// Every type this system presents. All four are new; it takes nothing over.
  static const List<String> recordTypeIds = [
    biomeTypeId,
    ecosystemTypeId,
    foodWebTypeId,
    nicheTypeId,
  ];

  /// Types this system points at and deliberately does not own.
  ///
  /// Named so each boundary is assertable rather than remembered. An over-claim
  /// on any of these would not fail today — it would fail the next time both
  /// systems are constructed together, which is the failure mode
  /// `_validateDisjointRecordTypes` exists to make loud.
  static const List<String> ownedByBestiary = [
    'species',
    'race',
    'creature',
    'monster',
    'animal',
    'plant',
  ];

  /// Spatial types belonging to `authoros-world-core`, which is infrastructure
  /// and always on. An ecosystem occupies one; it is not one.
  static const List<String> ownedByWorldCore = [
    'location',
    'region',
    'continent',
    'forest',
    'desert',
    'island',
    'ocean',
    'sea',
    'lake',
    'river',
    'mountain',
    'cave',
    'natural-feature',
  ];

  /// Left for Climate, and since claimed by it.
  ///
  /// This was written when S9 did not exist, as three ids this system must not
  /// take. Climate now declares `climate` and `season`; `weather` turned out to
  /// need two types — `weather-pattern` and `weather-event` — so the bare name
  /// is still unclaimed by anyone.
  ///
  /// The list is kept rather than deleted because what it asserts is still
  /// true and is still worth failing on: none of these belongs to this system.
  /// The test that reads it changed from "nobody owns these" to "Climate owns
  /// these, and Ecosystem still does not", which is the durable half.
  static const List<String> reservedForClimate = [
    'climate',
    'weather',
    'season',
  ];

  /// All existing, all `*`-typed. No relationship is added and none is widened.
  static const List<String> connectionTypeIds = [
    'partOf',
    'requires',
    'relatedTo',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _biome,
    _ecosystem,
    _foodWeb,
    _niche,
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

const _biomeKind = RecordOptionSet(
  id: 'biome-kind',
  name: 'Kind of biome',
  description: 'The broad character of the environment.',
  values: [
    'Forest',
    'Grassland',
    'Scrubland',
    'Desert',
    'Tundra',
    'Wetland',
    'Freshwater',
    'Marine',
    'Coastal',
    'Montane',
    'Subterranean',
    'Aerial',
    'Volcanic',
    'Blighted',
    'Magical',
    'Artificial',
  ],
);

const _ecosystemState = RecordOptionSet(
  id: 'ecosystem-state',
  name: 'State',
  description: 'How the community is faring, as of the story\'s present.',
  values: [
    'Thriving',
    'Stable',
    'Strained',
    'Declining',
    'Collapsing',
    'Collapsed',
    'Recovering',
    'Artificially sustained',
  ],
);

const _trophicRole = RecordOptionSet(
  id: 'trophic-role',
  name: 'Trophic role',
  description: 'What the organism does for a living.',
  values: [
    'Producer',
    'Primary consumer',
    'Secondary consumer',
    'Apex predator',
    'Omnivore',
    'Scavenger',
    'Decomposer',
    'Parasite',
    'Pollinator',
    'Symbiont',
  ],
);

const _interaction = RecordOptionSet(
  id: 'ecological-interaction',
  name: 'Interaction',
  description: 'How this species meets the others around it.',
  values: [
    'Predation',
    'Competition',
    'Mutualism',
    'Commensalism',
    'Parasitism',
    'Symbiosis',
    'Herbivory',
    'Displacement',
  ],
);

// ---------------------------------------------------------------------------
// The biome
// ---------------------------------------------------------------------------

/// A recurring kind of living environment, defined once.
///
/// The gap this fills is narrow and specific. `location.climate` and
/// `location.terrain` describe one place; two forests a continent apart get two
/// descriptions that were meant to say the same thing and gradually stop. A
/// biome is that description given an id, so the places can point at it.
///
/// Note what it does **not** carry: no temperature, no rainfall, no seasonal
/// cycle. Those are Climate's (S9), and `conditions` below is prose precisely
/// so this type does not quietly become a weather model.
final _biome = RecordTypeDefinition(
  id: EcosystemRecordTypes.biomeTypeId,
  name: 'Biome',
  description: 'A recurring kind of living environment, defined once and '
      'shared by every place that is one.',
  icon: 'forest',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_biomeKind],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 90,
        optionSetId: 'biome-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('character', 'What it is like', RecordFieldType.richText, 91,
        description: 'The walk-through-it description, written once.',
        quickCreateVisible: true),
    _field('conditions', 'Conditions it needs', RecordFieldType.longText, 100,
        description: 'In prose. Climate is its own system; this names what the '
            'biome requires without modelling it.'),
    _field('dominantFlora', 'Dominant plant life', RecordFieldType.list, 101),
    _field('dominantFauna', 'Dominant animal life', RecordFieldType.list, 102),
    _field('productivity', 'How much life it supports',
        RecordFieldType.shortText, 103,
        description: 'Sparse, moderate, teeming — however the world would put '
            'it.'),
    _field('occursIn', 'Where it occurs', RecordFieldType.list, 110,
        description: 'Places of this kind. Locations belong to the world, not '
            'to this system, so this is a list rather than a claim on them.',
        searchable: false),
    _field('boundaries', 'Where it gives way', RecordFieldType.longText, 111,
        description: 'What it borders, and how sharp the edge is.',
        searchable: false),
    _field(
        'hazards', 'What makes it hard to live in', RecordFieldType.list, 112,
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'biome-identity',
      title: 'The kind',
      order: 9,
      fieldIds: ['kind', 'character'],
    ),
    RecordTemplateSection(
      id: 'biome-life',
      title: 'What lives there',
      order: 10,
      fieldIds: [
        'conditions',
        'dominantFlora',
        'dominantFauna',
        'productivity'
      ],
    ),
    RecordTemplateSection(
      id: 'biome-extent',
      title: 'Extent',
      order: 11,
      fieldIds: ['occursIn', 'boundaries', 'hazards'],
    ),
  ],
  suggestedLinkTypeIds: EcosystemRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EcosystemRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The ecosystem
// ---------------------------------------------------------------------------

/// One living community, in one place, at one time.
///
/// Separate from `biome` the way `government` is separate from
/// `political-system`: the biome is the recurring kind, this is the particular
/// community claiming to be one. Two tundra ecosystems can share every
/// condition and differ entirely in who lives there and whether it is holding.
///
/// [state] and [disturbance] are what make this worth recording rather than
/// describing in a location's notes: an ecosystem that can be *strained* is one
/// a plot can break.
final _ecosystem = RecordTypeDefinition(
  id: EcosystemRecordTypes.ecosystemTypeId,
  name: 'Ecosystem',
  description: 'One living community in one place: who is in it, what holds '
      'it together, and what would break it.',
  icon: 'hub',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_ecosystemState],
  fields: [
    _field('biome', 'Biome', RecordFieldType.recordReference, 90,
        referenceTypeIds: [EcosystemRecordTypes.biomeTypeId],
        description: 'The kind of environment this is an instance of.',
        quickCreateVisible: true),
    _field('place', 'Where', RecordFieldType.recordReference, 91,
        referenceTypeIds: const ['location'],
        description: 'Declared by the world, not by this system; an ecosystem '
            'occupies a place rather than being one.',
        quickCreateVisible: true),
    _field('state', 'State', RecordFieldType.singleChoice, 92,
        optionSetId: 'ecosystem-state',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('members', 'What lives here', RecordFieldType.list, 100,
        description: 'The roll call. Who depends on whom is the food web.'),
    _field('keystone', 'Keystone species', RecordFieldType.recordReference, 101,
        referenceTypeIds: const ['species'],
        description: 'The one whose removal takes the rest with it. Declared '
            'by Bestiary.'),
    _field('balance', 'What holds it together', RecordFieldType.richText, 102),
    _field('disturbance', 'What would break it', RecordFieldType.richText, 110,
        description: 'The pressure the story can apply.'),
    _field('ifItCollapsed', 'If it collapsed', RecordFieldType.richText, 111,
        description: 'What the place becomes, and who notices first.',
        searchable: false),
    _field(
        'humanUse', 'What people take from it', RecordFieldType.longText, 112,
        description: 'However the world\'s peoples use it — hunting, grazing, '
            'harvest, extraction.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'ecosystem-setting',
      title: 'Setting',
      order: 9,
      fieldIds: ['biome', 'place', 'state'],
    ),
    RecordTemplateSection(
      id: 'ecosystem-community',
      title: 'The community',
      order: 10,
      fieldIds: ['members', 'keystone', 'balance'],
    ),
    RecordTemplateSection(
      id: 'ecosystem-pressure',
      title: 'Pressure',
      order: 11,
      fieldIds: ['disturbance', 'ifItCollapsed', 'humanUse'],
    ),
  ],
  suggestedLinkTypeIds: EcosystemRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EcosystemRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The food web
// ---------------------------------------------------------------------------

/// Who eats whom, and what a removal cascades into.
///
/// `species.diet` is one short text field, so "carnivore" is where the thought
/// stops. This is the same information given structure: tiers that can be read
/// downward, and a cascade an author can actually follow when a plot removes
/// something from the middle of it.
///
/// A record rather than fields on `ecosystem` because a web is a claim about
/// many species and belongs to none of them — the argument S6 made for
/// `lineage`, which holds here for the same reason.
final _foodWeb = RecordTypeDefinition(
  id: EcosystemRecordTypes.foodWebTypeId,
  name: 'Food web',
  description: 'The trophic structure of one ecosystem, and what a collapse '
      'cascades into.',
  icon: 'lan',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  fields: [
    _field('ecosystem', 'Ecosystem', RecordFieldType.recordReference, 90,
        referenceTypeIds: [EcosystemRecordTypes.ecosystemTypeId],
        quickCreateVisible: true),
    _field('producers', 'Producers', RecordFieldType.list, 100,
        description: 'What makes food rather than taking it.'),
    _field('primaryConsumers', 'Primary consumers', RecordFieldType.list, 101,
        description: 'What eats the producers.'),
    _field('predators', 'Predators', RecordFieldType.list, 102),
    _field('apex', 'Apex', RecordFieldType.recordReference, 103,
        referenceTypeIds: const ['species'],
        description: 'What nothing else eats. Declared by Bestiary.'),
    _field('decomposers', 'Decomposers', RecordFieldType.list, 104,
        description: 'What returns the dead to the system.'),
    _field('cascade', 'If a tier were removed', RecordFieldType.richText, 110,
        description: 'The point of writing the web down: what follows, and how '
            'far up or down it travels.'),
    _field(
        'competition', 'Where it is contested', RecordFieldType.longText, 111,
        searchable: false),
    _field(
        'imports', 'What comes in from outside', RecordFieldType.longText, 112,
        description: 'Migrations, seasonal arrivals, anything the web does not '
            'produce for itself.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'food-web-subject',
      title: 'Subject',
      order: 9,
      fieldIds: ['ecosystem'],
    ),
    RecordTemplateSection(
      id: 'food-web-tiers',
      title: 'Tiers',
      order: 10,
      fieldIds: [
        'producers',
        'primaryConsumers',
        'predators',
        'apex',
        'decomposers'
      ],
    ),
    RecordTemplateSection(
      id: 'food-web-dynamics',
      title: 'Dynamics',
      order: 11,
      fieldIds: ['cascade', 'competition', 'imports'],
    ),
  ],
  suggestedLinkTypeIds: EcosystemRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EcosystemRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The niche
// ---------------------------------------------------------------------------

/// What one species does for a living, in one system.
///
/// The per-species counterpart to the food web's system-level view, and
/// deliberately not a field on `species`: the same creature is an apex predator
/// in one valley and prey in the next, so the role belongs to the pairing
/// rather than to the organism.
final _niche = RecordTypeDefinition(
  id: EcosystemRecordTypes.nicheTypeId,
  name: 'Ecological niche',
  description: 'What one species does for a living, and what it would leave '
      'behind.',
  icon: 'pest_control',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_trophicRole, _interaction],
  fields: [
    _field('species', 'Species', RecordFieldType.recordReference, 90,
        referenceTypeIds: const ['species'],
        description: 'Declared by Bestiary; this system points at it and does '
            'not own it.',
        quickCreateVisible: true),
    _field('ecosystem', 'In', RecordFieldType.recordReference, 91,
        referenceTypeIds: [EcosystemRecordTypes.ecosystemTypeId],
        description: 'A role is held in a system. The same creature can be '
            'apex here and prey elsewhere.',
        quickCreateVisible: true),
    _field('role', 'Trophic role', RecordFieldType.singleChoice, 92,
        optionSetId: 'trophic-role',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('eats', 'What it eats', RecordFieldType.list, 100),
    _field('eatenBy', 'What eats it', RecordFieldType.list, 101),
    _field('interaction', 'How it meets its neighbours',
        RecordFieldType.multipleChoice, 102,
        optionSetId: 'ecological-interaction', allowCustomValues: true),
    _field('competesWith', 'Competes with', RecordFieldType.list, 103,
        searchable: false),
    _field(
        'dependsOn', 'What it cannot do without', RecordFieldType.richText, 110,
        description: 'The dependency that makes it fragile.'),
    _field('ifItVanished', 'If it vanished', RecordFieldType.richText, 111,
        description: 'What takes the role, or what goes untaken.',
        searchable: false),
    _field('range', 'Where in the system', RecordFieldType.longText, 112,
        description: 'The part of the ecosystem it actually occupies.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'niche-subject',
      title: 'Subject',
      order: 9,
      fieldIds: ['species', 'ecosystem', 'role'],
    ),
    RecordTemplateSection(
      id: 'niche-feeding',
      title: 'Feeding',
      order: 10,
      fieldIds: ['eats', 'eatenBy', 'interaction', 'competesWith'],
    ),
    RecordTemplateSection(
      id: 'niche-fragility',
      title: 'Fragility',
      order: 11,
      fieldIds: ['dependsOn', 'ifItVanished', 'range'],
    ),
  ],
  suggestedLinkTypeIds: EcosystemRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EcosystemRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
