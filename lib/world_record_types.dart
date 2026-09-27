import 'craft/craft_library.dart';
import 'record_types.dart';

class WorldRecordTypes {
  const WorldRecordTypes._();

  static const locationTypeIds = <String>{
    'location',
    'basic-location',
    'continent',
    'region',
    'country',
    'nation',
    'province',
    'state',
    'territory',
    'city',
    'town',
    'village',
    'settlement',
    'district',
    'neighbourhood',
    // Map Studio Phase 7 completes the scale hierarchy between a district and a
    // room. Both are added here, to the one canonical location vocabulary,
    // rather than in a Phase 7 type list beside it — so every existing consumer
    // picks them up unchanged: they become placeable through
    // `MapTypes.locationTypeIds` and linkable through `locatedIn` and `partOf`
    // without a single call site changing.
    'street',
    'building',
    'structure',
    'floor',
    'room',
    'interior-location',
    'landmark',
    'natural-feature',
    'mountain',
    'river',
    'lake',
    'ocean',
    'sea',
    'forest',
    'desert',
    'island',
    'cave',
    'ruin',
    'battlefield',
    'road',
    'route-location',
    'border',
    'other-custom-location',
  };

  static const cosmicTypeIds = <String>{
    'universe',
    'world',
    'planet',
    'moon',
    'star',
    'solar-system',
    'galaxy',
    'dimension',
    'realm',
    'plane',
  };

  /// Places that move.
  ///
  /// A vessel is a spatial record like any other — it takes markers, regions,
  /// interior maps, story overlays and reveal points exactly as a castle does.
  /// The one thing that distinguishes it, motion, is not modelled here at all:
  /// a vessel's position is a time-bounded `locatedIn` link, projected by the
  /// Phase 5 world clock like any other time-bounded fact. No vessel store, no
  /// motion engine, no coordinates-over-time table.
  static const vesselTypeIds = <String>{
    'vessel',
    'ship',
    'sailing-ship',
    'submarine',
    'spaceship',
    'starship',
    'space-station',
    'airship',
    'train',
    'caravan',
    'generation-ship',
    'other-custom-vessel',
  };

  static const spatialTypeIds = <String>{
    ...locationTypeIds,
    ...cosmicTypeIds,
    ...vesselTypeIds,
    'place',
  };

  static const mapTypeIds = <String>{
    'map',
    'world-map',
    'regional-map',
    'country-map',
    'city-map',
    'building-map',
    'dungeon-map',
    'battle-map',
    'custom-map',
    // The interiors a vessel or building draws: a starship's engineering
    // deck and a manor's ground floor are the same kind of map.
    'deck-plan',
    'interior-map',
  };

  static const routeTypeIds = <String>{
    'travel-route',
    'road-route',
    'path-route',
    'portal-route',
    'gate-route',
    'ferry-route',
    'bridge-route',
    'tunnel-route',
    'flight-path',
    'space-route',
    'magical-route',
  };

  static const worldDomainTypeIds = <String>{
    ...locationTypeIds,
    ...cosmicTypeIds,
    ...vesselTypeIds,
    ...mapTypeIds,
    ...routeTypeIds,
    'map-marker',
  };

  static final definitions = <RecordTypeDefinition>[
    _world,
    _location,
    ..._locationTemplates,
    ..._cosmicTemplates,
    ..._vesselTemplates,
    _map,
    ..._derived(mapTypeIds.difference(const {'map'}), 'map', 'maps'),
    _mapMarker,
    _travelRoute,
    // The ten named kinds are owned by the Travel system. Their ids stay in
    // routeTypeIds — only the definitions move. See travel_record_types.dart.
  ];

  static bool isBuiltInWorldType(String typeId) =>
      worldDomainTypeIds.contains(typeId);
}

const _identityFields = <RecordFieldDefinition>[
  RecordFieldDefinition(
      id: 'primaryName',
      label: 'Primary Name',
      type: RecordFieldType.shortText,
      order: 10),
  RecordFieldDefinition(
      id: 'alternateNames',
      label: 'Alternate Names',
      type: RecordFieldType.list,
      order: 11,
      searchable: true,
      extensionData: {'aliasKind': 'alternate'}),
  RecordFieldDefinition(
      id: 'historicalNames',
      label: 'Historical Names',
      type: RecordFieldType.list,
      order: 12,
      searchable: true,
      extensionData: {'aliasKind': 'historical'}),
  RecordFieldDefinition(
      id: 'localNames',
      label: 'Local Names',
      type: RecordFieldType.list,
      order: 13,
      searchable: true,
      extensionData: {'aliasKind': 'local'}),
  RecordFieldDefinition(
      id: 'translations',
      label: 'Translations',
      type: RecordFieldType.table,
      order: 14,
      searchable: true),
  RecordFieldDefinition(
      id: 'nicknames',
      label: 'Nicknames',
      type: RecordFieldType.list,
      order: 15,
      searchable: true,
      extensionData: {'aliasKind': 'nickname'}),
  RecordFieldDefinition(
      id: 'locationType',
      label: 'Type',
      type: RecordFieldType.shortText,
      order: 16),
  RecordFieldDefinition(
      id: 'summary',
      label: 'Summary',
      type: RecordFieldType.longText,
      order: 17),
  RecordFieldDefinition(
      id: 'description',
      label: 'Description',
      type: RecordFieldType.richText,
      order: 18),
  RecordFieldDefinition(
      id: 'notes', label: 'Notes', type: RecordFieldType.longText, order: 19),
];

const _environmentFields = <RecordFieldDefinition>[
  RecordFieldDefinition(
      id: 'geography',
      label: 'Geography',
      type: RecordFieldType.richText,
      order: 100),
  RecordFieldDefinition(
      id: 'climate',
      label: 'Climate',
      type: RecordFieldType.longText,
      order: 101),
  // Written by the procedural engine and, until the Lock 9 review, declared by
  // nothing. They sit here rather than on the settlement types because they are
  // facts about a *site*: a forest has a biome and a harbour is coastal exactly
  // as a city is.
  RecordFieldDefinition(
      id: 'biome',
      label: 'Biome',
      type: RecordFieldType.shortText,
      order: 102,
      description: 'The dominant biome of this place.'),
  RecordFieldDefinition(
      id: 'coastal',
      label: 'Coastal',
      type: RecordFieldType.boolean,
      order: 103,
      description: 'Whether it stands on water.'),
  RecordFieldDefinition(
      id: 'terrain',
      label: 'Terrain',
      type: RecordFieldType.longText,
      order: 102),
  RecordFieldDefinition(
      id: 'elevation',
      label: 'Elevation',
      type: RecordFieldType.shortText,
      order: 103),
  RecordFieldDefinition(
      id: 'size', label: 'Size', type: RecordFieldType.shortText, order: 104),
  RecordFieldDefinition(
      id: 'population',
      label: 'Population',
      type: RecordFieldType.number,
      order: 105),
  RecordFieldDefinition(
      id: 'density',
      label: 'Density',
      type: RecordFieldType.shortText,
      order: 106),
  RecordFieldDefinition(
      id: 'naturalResources',
      label: 'Natural Resources',
      type: RecordFieldType.list,
      order: 107),
  RecordFieldDefinition(
      id: 'water', label: 'Water', type: RecordFieldType.longText, order: 108),
  RecordFieldDefinition(
      id: 'wildlife',
      label: 'Wildlife',
      type: RecordFieldType.list,
      order: 109),
  RecordFieldDefinition(
      id: 'flora', label: 'Flora', type: RecordFieldType.list, order: 110),
  RecordFieldDefinition(
      id: 'fauna', label: 'Fauna', type: RecordFieldType.list, order: 111),
  RecordFieldDefinition(
      id: 'weather',
      label: 'Weather',
      type: RecordFieldType.longText,
      order: 112),
  RecordFieldDefinition(
      id: 'seasons', label: 'Seasons', type: RecordFieldType.list, order: 113),
  RecordFieldDefinition(
      id: 'hazards', label: 'Hazards', type: RecordFieldType.list, order: 114),
  RecordFieldDefinition(
      id: 'naturalPhenomena',
      label: 'Natural Phenomena',
      type: RecordFieldType.list,
      order: 115),
];

const _societyFields = <RecordFieldDefinition>[
  RecordFieldDefinition(
      id: 'architecture',
      label: 'Architecture',
      type: RecordFieldType.richText,
      order: 200),
  RecordFieldDefinition(
      id: 'infrastructure',
      label: 'Infrastructure',
      type: RecordFieldType.richText,
      order: 201),
  RecordFieldDefinition(
      id: 'economy',
      label: 'Economy',
      type: RecordFieldType.richText,
      order: 202),
  RecordFieldDefinition(
      id: 'transportation',
      label: 'Transportation',
      type: RecordFieldType.richText,
      order: 203),
  RecordFieldDefinition(
      id: 'technology',
      label: 'Technology',
      type: RecordFieldType.recordReference,
      order: 204),
  RecordFieldDefinition(
      id: 'magic',
      label: 'Magic',
      type: RecordFieldType.recordReference,
      order: 205),
  RecordFieldDefinition(
      id: 'culture',
      label: 'Culture',
      type: RecordFieldType.recordReference,
      order: 206),
  RecordFieldDefinition(
      id: 'religion',
      label: 'Religion',
      type: RecordFieldType.recordReference,
      order: 207),
  RecordFieldDefinition(
      id: 'politics',
      label: 'Politics',
      type: RecordFieldType.richText,
      order: 208),
  RecordFieldDefinition(
      id: 'military',
      label: 'Military',
      type: RecordFieldType.richText,
      order: 209),
  RecordFieldDefinition(
      id: 'laws', label: 'Laws', type: RecordFieldType.list, order: 210),
  RecordFieldDefinition(
      id: 'customs', label: 'Customs', type: RecordFieldType.list, order: 211),
  RecordFieldDefinition(
      id: 'history',
      label: 'History',
      type: RecordFieldType.richText,
      order: 212),
  RecordFieldDefinition(
      id: 'secrets',
      label: 'Secrets',
      type: RecordFieldType.table,
      order: 213,
      extensionData: {'visibility': 'author'}),
];

/// The shape of the height field a generated world was built from.
///
/// A world an author typed in by hand has none of these and shows none of
/// them; a generated one carries the grid it was derived from, which is what
/// lets the same seed be recognised later. Declared here rather than left as
/// loose keys in `fields`, which is where the Lock 9 review found them.
const _worldGridFields = <RecordFieldDefinition>[
  RecordFieldDefinition(
      id: 'gridWidth',
      label: 'Grid width',
      type: RecordFieldType.number,
      order: 400,
      description: 'Cells across, when this world was generated.'),
  RecordFieldDefinition(
      id: 'gridHeight',
      label: 'Grid height',
      type: RecordFieldType.number,
      order: 401,
      description: 'Cells down, when this world was generated.'),
  RecordFieldDefinition(
      id: 'seaLevel',
      label: 'Sea level',
      type: RecordFieldType.number,
      order: 402,
      description: 'The height at which land becomes water.'),
];

const _world = RecordTypeDefinition(
  id: 'world',
  name: 'World',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  fields: [
    ..._identityFields,
    ..._environmentFields,
    ..._societyFields,
    ..._worldGridFields,
  ],
  sections: [
    RecordTemplateSection(
        id: 'worldIdentity',
        title: 'Identity',
        order: 10,
        fieldIds: [
          'primaryName',
          'alternateNames',
          'historicalNames',
          'localNames',
          'translations',
          'nicknames',
          'summary',
          'description',
          'notes'
        ]),
    RecordTemplateSection(
        id: 'worldEnvironment',
        title: 'Environment',
        order: 20,
        fieldIds: [
          'geography',
          'climate',
          'terrain',
          'elevation',
          'size',
          'population',
          'density',
          'naturalResources',
          'water',
          'wildlife',
          'flora',
          'fauna',
          'weather',
          'seasons',
          'hazards',
          'naturalPhenomena'
        ]),
    RecordTemplateSection(
        id: 'worldSociety',
        title: 'Society',
        order: 30,
        fieldIds: [
          'architecture',
          'infrastructure',
          'economy',
          'transportation',
          'technology',
          'magic',
          'culture',
          'religion',
          'politics',
          'military',
          'laws',
          'customs',
          'history',
          'secrets'
        ]),
  ],
  suggestedLinkTypeIds: ['contains', 'locatedIn', 'associatedWith'],
  builtIn: true,
  sourcePackId: 'authoros-world-core',
  extensionData: {'worldDomain': true, 'worldTemplate': true},
);

const _location = RecordTypeDefinition(
  id: 'location',
  name: 'Basic Location',
  categoryId: 'locations',
  baseTypeId: 'general-lore',
  fields: [..._identityFields, ..._environmentFields, ..._societyFields],
  sections: [
    RecordTemplateSection(
        id: 'locationIdentity',
        title: 'Identity',
        order: 10,
        fieldIds: [
          'primaryName',
          'alternateNames',
          'historicalNames',
          'localNames',
          'translations',
          'nicknames',
          'locationType',
          'summary',
          'description',
          'notes'
        ]),
    RecordTemplateSection(
        id: 'environment',
        title: 'Environment',
        order: 20,
        fieldIds: [
          'geography',
          'climate',
          'terrain',
          'elevation',
          'size',
          'population',
          'density',
          'naturalResources',
          'water',
          'wildlife',
          'flora',
          'fauna',
          'weather',
          'seasons',
          'hazards',
          'naturalPhenomena'
        ]),
    RecordTemplateSection(
        id: 'society',
        title: 'Society',
        order: 30,
        fieldIds: [
          'architecture',
          'infrastructure',
          'economy',
          'transportation',
          'technology',
          'magic',
          'culture',
          'religion',
          'politics',
          'military',
          'laws',
          'customs',
          'history',
          'secrets'
        ]),
  ],
  suggestedLinkTypeIds: ['locatedIn', 'contains', 'adjacentTo', 'borders'],
  builtIn: true,
  sourcePackId: 'authoros-world-core',
  extensionData: {'worldDomain': true, 'worldTemplate': true},
);

/// What the procedural engine says about a settlement, a quarter and a way.
///
/// Shared rather than repeated on each type, because a settlement role means
/// the same thing on a city and on a village.
const _settlementFields = <(String, String, RecordFieldType)>[
  ('settlementRole', 'Settlement role', RecordFieldType.shortText),
  ('walled', 'Walled', RecordFieldType.boolean),
];

const _quarterFields = <(String, String, RecordFieldType)>[
  ('quarter', 'Quarter', RecordFieldType.shortText),
  ('wealth', 'Wealth', RecordFieldType.number),
];

const _wayFields = <(String, String, RecordFieldType)>[
  ('streetKind', 'Kind of way', RecordFieldType.shortText),
];

final _locationTemplates = <RecordTypeDefinition>[
  ..._derived(
    WorldRecordTypes.locationTypeIds.difference(const {
      'location',
      'city',
      'country',
      'nation',
      'region',
      'building',
      'natural-feature',
      // Declared below, with the fields the procedural engine writes on them.
      'town',
      'village',
      'settlement',
      'district',
      'neighbourhood',
      'street',
      'road',
      'floor',
      // Owned by the Architecture system. The ids stay in locationTypeIds —
      // only the definitions move. See architecture_record_types.dart.
      'structure',
      'room',
      'ruin',
    }),
    'location',
    'locations',
  ),
  _specialized('city', 'City', const [
    ('government', 'Government', RecordFieldType.recordReference),
    ('districts', 'Districts', RecordFieldType.list),
    ('landmarks', 'Landmarks', RecordFieldType.list),
    ('factions', 'Factions', RecordFieldType.list),
    ('importantCharacters', 'Important Characters', RecordFieldType.list),
    ..._settlementFields,
  ]),
  // The settlements below a city. They derived from `location` with no fields
  // of their own until the Lock 9 review found the generator writing
  // `settlementRole` onto them anyway.
  _specialized('town', 'Town', _settlementFields),
  _specialized('village', 'Village', _settlementFields),
  _specialized('settlement', 'Settlement', _settlementFields),
  _specialized('district', 'District', _quarterFields),
  _specialized('neighbourhood', 'Neighbourhood', _quarterFields),
  _specialized('street', 'Street', _wayFields),
  _specialized('road', 'Road', _wayFields),
  _specialized('floor', 'Floor', const [
    ('level', 'Level', RecordFieldType.number),
  ]),
  _specialized('country', 'Country / Nation', const [
    ('government', 'Government', RecordFieldType.recordReference),
    ('capital', 'Capital', RecordFieldType.locationReference),
    ('borders', 'Borders', RecordFieldType.list),
    ('language', 'Language', RecordFieldType.recordReference),
    ('factions', 'Factions', RecordFieldType.list),
  ]),
  _specialized('nation', 'Nation', const [], baseTypeId: 'country'),
  _specialized('region', 'Region', const [
    ('settlements', 'Settlements', RecordFieldType.list),
    ('factions', 'Factions', RecordFieldType.list),
  ]),
  _specialized('natural-feature', 'Natural Feature', const [
    ('culturalSignificance', 'Cultural Significance', RecordFieldType.richText),
  ]),
];

final _vesselTemplates = <RecordTypeDefinition>[
  // `buildingKind`, `purpose` and `floors` are the three the procedural
  // engine writes when it draws a vessel, and none of them was declared until
  // the Lock 9 review. `floors` is the deck *count* the plan drew — the
  // generator writes the same key on a manor and on a starship, and a count is
  // not the `decks` list below, which names them.
  _specialized('vessel', 'Vessel', const [
    ('buildingKind', 'Plan kind', RecordFieldType.shortText),
    ('purpose', 'Purpose', RecordFieldType.longText),
    ('floors', 'Deck count', RecordFieldType.shortText),
    ('vesselClass', 'Class', RecordFieldType.shortText),
    ('registry', 'Registry / Designation', RecordFieldType.shortText),
    ('captain', 'Captain / Commander', RecordFieldType.recordReference),
    ('crewCapacity', 'Crew Capacity', RecordFieldType.number),
    ('propulsion', 'Propulsion', RecordFieldType.shortText),
    ('homePort', 'Home Port', RecordFieldType.locationReference),
    ('decks', 'Decks', RecordFieldType.list),
    ('cargo', 'Cargo', RecordFieldType.list),
    ('armament', 'Armament', RecordFieldType.list),
  ]),
  ..._derived(
    WorldRecordTypes.vesselTypeIds.difference(const {'vessel'}),
    'vessel',
    'locations',
  ),
];

// The nine cosmic types below `world` are owned by the Astronomy system. Their
// ids stay in cosmicTypeIds — only the definitions move. See
// astronomy_record_types.dart.
final _cosmicTemplates = <RecordTypeDefinition>[];

// `final`, not `const`: these two take their field descriptions from the craft
// library, and a library lookup is not a const expression. The rest of this
// file stays const — only the map types consult it.
//
// Keys are `world.<type id>.<field id>`, qualified because this file declares
// many types and their field ids repeat (`description`, `history`, `type`).
// Fifteen of the eighteen map fields are drawing mechanics that the library
// says nothing about; they resolve to the empty string and are unchanged.
final _map = RecordTypeDefinition(
  id: 'map',
  name: 'Map',
  categoryId: 'maps',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
        id: 'mapType',
        description: CraftLibrary.describe('world.map.mapType'),
        label: 'Map Type',
        type: RecordFieldType.shortText,
        order: 100),
    RecordFieldDefinition(
        id: 'coordinateSystem',
        description: CraftLibrary.describe('world.map.coordinateSystem'),
        label: 'Coordinate System',
        type: RecordFieldType.shortText,
        order: 101),
    RecordFieldDefinition(
        id: 'width',
        description: CraftLibrary.describe('world.map.width'),
        label: 'Width',
        type: RecordFieldType.number,
        order: 102),
    RecordFieldDefinition(
        id: 'height',
        description: CraftLibrary.describe('world.map.height'),
        label: 'Height',
        type: RecordFieldType.number,
        order: 103),
    RecordFieldDefinition(
        id: 'scale',
        description: CraftLibrary.describe('world.map.scale'),
        label: 'Scale',
        type: RecordFieldType.shortText,
        order: 104),
    RecordFieldDefinition(
        id: 'centerPoint',
        description: CraftLibrary.describe('world.map.centerPoint'),
        label: 'Center Point',
        type: RecordFieldType.table,
        order: 105),
    RecordFieldDefinition(
        id: 'backgroundReference',
        description: CraftLibrary.describe('world.map.backgroundReference'),
        label: 'Background Reference',
        type: RecordFieldType.fileReference,
        order: 106),
    RecordFieldDefinition(
        id: 'projection',
        description: CraftLibrary.describe('world.map.projection'),
        label: 'Map Projection',
        type: RecordFieldType.shortText,
        order: 107),
    RecordFieldDefinition(
        id: 'mapMetadata',
        description: CraftLibrary.describe('world.map.mapMetadata'),
        label: 'Map Metadata',
        type: RecordFieldType.table,
        order: 108),
  ],
  sections: const [
    RecordTemplateSection(
        id: 'mapData',
        title: 'Map Data',
        order: 10,
        fieldIds: [
          'mapType',
          'coordinateSystem',
          'width',
          'height',
          'scale',
          'centerPoint',
          'backgroundReference',
          'projection',
          'mapMetadata'
        ])
  ],
  suggestedLinkTypeIds: const ['maps'],
  builtIn: true,
  sourcePackId: 'authoros-world-core',
  extensionData: const {'worldDomain': true, 'mapFoundation': true},
);

final _mapMarker = RecordTypeDefinition(
  id: 'map-marker',
  name: 'Map Marker',
  categoryId: 'maps',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
        id: 'mapId',
        description: CraftLibrary.describe('world.map-marker.mapId'),
        label: 'Map',
        type: RecordFieldType.recordReference,
        order: 100,
        required: true),
    // Optional on purpose: a Map Studio marker may stand alone before it is
    // pointed at a character, location, plot thread or timeline event.
    RecordFieldDefinition(
        id: 'recordId',
        description: CraftLibrary.describe('world.map-marker.recordId'),
        label: 'Record',
        type: RecordFieldType.recordReference,
        order: 101),
    RecordFieldDefinition(
        id: 'x',
        description: CraftLibrary.describe('world.map-marker.x'),
        label: 'X',
        type: RecordFieldType.number,
        order: 102,
        required: true),
    RecordFieldDefinition(
        id: 'y',
        description: CraftLibrary.describe('world.map-marker.y'),
        label: 'Y',
        type: RecordFieldType.number,
        order: 103,
        required: true),
    RecordFieldDefinition(
        id: 'label',
        description: CraftLibrary.describe('world.map-marker.label'),
        label: 'Label',
        type: RecordFieldType.shortText,
        order: 104),
    RecordFieldDefinition(
        id: 'icon',
        description: CraftLibrary.describe('world.map-marker.icon'),
        label: 'Icon',
        type: RecordFieldType.shortText,
        order: 105),
    RecordFieldDefinition(
        id: 'category',
        description: CraftLibrary.describe('world.map-marker.category'),
        label: 'Category',
        type: RecordFieldType.shortText,
        order: 106),
    RecordFieldDefinition(
        id: 'visibility',
        description: CraftLibrary.describe('world.map-marker.visibility'),
        label: 'Visibility',
        type: RecordFieldType.shortText,
        order: 107),
    RecordFieldDefinition(
        id: 'markerNotes',
        description: CraftLibrary.describe('world.map-marker.markerNotes'),
        label: 'Notes',
        type: RecordFieldType.longText,
        order: 108),
  ],
  sections: const [
    RecordTemplateSection(
        id: 'markerData',
        title: 'Marker Data',
        order: 10,
        fieldIds: [
          'mapId',
          'recordId',
          'x',
          'y',
          'label',
          'icon',
          'category',
          'visibility',
          'markerNotes'
        ])
  ],
  suggestedLinkTypeIds: const ['onMap', 'represents'],
  builtIn: true,
  sourcePackId: 'authoros-world-core',
  extensionData: const {'worldDomain': true, 'mapMarkerFoundation': true},
);

const _travelRoute = RecordTypeDefinition(
  id: 'travel-route',
  name: 'Travel Route',
  categoryId: 'routes',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
        id: 'routeType',
        label: 'Route Type',
        type: RecordFieldType.shortText,
        order: 100),
    RecordFieldDefinition(
        id: 'startId',
        label: 'Start',
        type: RecordFieldType.locationReference,
        order: 101,
        required: true),
    RecordFieldDefinition(
        id: 'endId',
        label: 'End',
        type: RecordFieldType.locationReference,
        order: 102,
        required: true),
    RecordFieldDefinition(
        id: 'distance',
        label: 'Distance',
        type: RecordFieldType.shortText,
        order: 103),
    RecordFieldDefinition(
        id: 'travelTime',
        label: 'Travel Time',
        type: RecordFieldType.shortText,
        order: 104),
    RecordFieldDefinition(
        id: 'difficulty',
        label: 'Difficulty',
        type: RecordFieldType.shortText,
        order: 105),
    RecordFieldDefinition(
        id: 'cost', label: 'Cost', type: RecordFieldType.shortText, order: 106),
    RecordFieldDefinition(
        id: 'danger',
        label: 'Danger',
        type: RecordFieldType.shortText,
        order: 107),
    RecordFieldDefinition(
        id: 'restrictions',
        label: 'Restrictions',
        type: RecordFieldType.list,
        order: 108),
    RecordFieldDefinition(
        id: 'conditions',
        label: 'Conditions',
        type: RecordFieldType.list,
        order: 109),
  ],
  sections: [
    RecordTemplateSection(
        id: 'routeData',
        title: 'Route Data',
        order: 10,
        fieldIds: [
          'routeType',
          'startId',
          'endId',
          'distance',
          'travelTime',
          'difficulty',
          'cost',
          'danger',
          'restrictions',
          'conditions'
        ])
  ],
  suggestedLinkTypeIds: ['routeFrom', 'routeTo', 'passesThrough'],
  builtIn: true,
  sourcePackId: 'authoros-world-core',
  extensionData: {'worldDomain': true, 'routeFoundation': true},
);

RecordTypeDefinition _specialized(
  String id,
  String name,
  List<(String, String, RecordFieldType)> fields, {
  String baseTypeId = 'location',
  String categoryId = 'locations',
}) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      categoryId: categoryId,
      baseTypeId: baseTypeId,
      fields: [
        for (var index = 0; index < fields.length; index++)
          RecordFieldDefinition(
              id: fields[index].$1,
              label: fields[index].$2,
              type: fields[index].$3,
              order: 300 + index),
      ],
      sections: const [],
      builtIn: true,
      sourcePackId: 'authoros-world-core',
      extensionData: const {'worldDomain': true, 'worldTemplate': true},
    );

Iterable<RecordTypeDefinition> _derived(
  Iterable<String> ids,
  String baseTypeId,
  String categoryId,
) =>
    ids.map(
      (id) => RecordTypeDefinition(
        id: id,
        name: _title(id),
        categoryId: categoryId,
        baseTypeId: baseTypeId,
        fields: const [],
        sections: const [],
        builtIn: true,
        sourcePackId: 'authoros-world-core',
        extensionData: const {'worldDomain': true, 'worldTemplate': true},
      ),
    );

String _title(String id) => id
    .split('-')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
