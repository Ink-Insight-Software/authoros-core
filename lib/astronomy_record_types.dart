/// The Astronomy specialist system's record types.
///
/// Nine types — `universe`, `galaxy`, `solar-system`, `star`, `planet`,
/// `moon`, `dimension`, `realm`, `plane` — every one of them a bare child of
/// `world` with **zero fields of its own**.
///
/// The third World-domain system, and the third to be possible only because
/// the activation gate now reaches both Studios.
///
/// ## What was missing
///
/// `world` is a deep template: forty fields across identity, environment and
/// society. So these nine were never field-less in the way Bestiary's six
/// were — they inherit all forty. What none of them has is anything
/// *astronomical*. An author could record a star's terrain and its politics,
/// and had nowhere to put its mass, its age, its colour, what it is made of,
/// what it orbits, or what the people below it think it means.
///
/// ## A defect this file records and does **not** fix
///
/// The forty inherited fields are not merely insufficient for a star; several
/// are absurd on one. A star record is asked for its climate, its terrain, its
/// flora and fauna, its economy, its religion and its politics. That is the
/// same family of defect as `spell` inheriting `magic-system` and `deity`
/// inheriting `religion`: **inheritance asserted rather than observed.**
///
/// It is not corrected here, for a reason worth stating rather than glossing:
///
/// * A planet, a moon, a realm and a plane genuinely *are* worlds. They have
///   terrain, weather, peoples and politics, and re-parenting them would
///   strand forty fields each to fix nothing.
/// * A star, a solar system and a galaxy are not. Correcting those three means
///   re-parenting them away from `world` and re-declaring, by hand, every one
///   of the roughly fifteen inherited ids that still means something — the
///   retained-id technique Magic and Religion used, at four times the scale
///   either of them faced.
///
/// That is a correction with its own migration surface and its own decision,
/// and bundling it into a deepening PR would be the kind of quiet
/// architectural change this programme has been careful not to make. It is
/// recorded here, asserted in the tests as a known state rather than a
/// desirable one, and left for its own PR.
///
/// ## `world` is not claimed
///
/// It is the base every cosmic type descends from, it is the root record of a
/// project's setting, and `WorldService` resolves world membership through
/// `isTemplateCompatible(id, 'world')`. Fourth base type this programme has
/// declined to claim, after `item`, `location` and `travel-route`. The rule is
/// now settled: **a generic that everything descends from belongs to no
/// system, because a type no system claims is always offered.**
///
/// ## The id sets are untouched
///
/// These nine move to a dedicated pack, but their ids stay in
/// [WorldRecordTypes.cosmicTypeIds] and therefore in `spatialTypeIds`, which
/// drives `isBuiltInWorldType` and is read across nine files and seventeen
/// connection definitions. Only the definitions move.
library;

import 'record_types.dart';

class AstronomyRecordTypes {
  const AstronomyRecordTypes._();

  static const universeTypeId = 'universe';
  static const galaxyTypeId = 'galaxy';
  static const solarSystemTypeId = 'solar-system';
  static const starTypeId = 'star';
  static const planetTypeId = 'planet';
  static const moonTypeId = 'moon';
  static const dimensionTypeId = 'dimension';
  static const realmTypeId = 'realm';
  static const planeTypeId = 'plane';

  /// Every type the Astronomy system presents. The manifest names exactly
  /// these.
  static const List<String> recordTypeIds = [
    universeTypeId,
    galaxyTypeId,
    solarSystemTypeId,
    starTypeId,
    planetTypeId,
    moonTypeId,
    dimensionTypeId,
    realmTypeId,
    planeTypeId,
  ];

  /// The base every cosmic type descends from, deliberately left unclaimed.
  static const String worldFoundationTypeId = 'world';

  /// The three types for which `baseTypeId: 'world'` is false, recorded so the
  /// correction has somewhere to start.
  ///
  /// A star has no terrain, a galaxy no economy, a solar system no religion.
  /// They keep the parent for now — see the library comment for why this is
  /// its own PR — and the tests assert the state so it stays visible rather
  /// than becoming folklore.
  static const List<String> misinheritedTypeIds = [
    starTypeId,
    solarSystemTypeId,
    galaxyTypeId,
  ];

  /// Field ids that mean the same thing on every type in the family and carry
  /// the same id and type on each.
  static const List<String> sharedFieldIds = [
    'scale',
    'composition',
    'age',
    'motion',
    'observation',
    'significance',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _universe,
    _galaxy,
    _solarSystem,
    _star,
    _planet,
    _moon,
    _dimension,
    _realm,
    _plane,
  ];
}

/// Matches what the World templates already carried, so the World Studio sees
/// no change in how it classifies these.
const _worldTemplate = <String, Object?>{
  'worldDomain': true,
  'worldTemplate': true,
};

RecordFieldDefinition _field(
  String id,
  String label,
  RecordFieldType type,
  int order, {
  String description = '',
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

/// The fields every cosmic body carries, with one id and one type each.
///
/// None shadows one of `world`'s forty — asserted in the tests, because
/// shadowing one with a different type is the only way this file could
/// re-interpret a value an author already wrote. `size` is `world`'s and is
/// left alone; `scale` is this system's and means something else.
List<RecordFieldDefinition> _shared({int from = 300}) => [
      _field('scale', 'Scale', RecordFieldType.shortText, from,
          description: 'How large, in whatever terms this world would use to '
              'say it.'),
      _field('composition', 'Composition', RecordFieldType.richText, from + 1,
          description: 'What it is made of, as far as anyone knows.'),
      _field('age', 'Age', RecordFieldType.shortText, from + 2,
          description: 'How old, and how that is claimed to be known.'),
      _field('motion', 'Motion', RecordFieldType.richText, from + 3,
          description: 'What it turns around, how long it takes, and whether '
              'that has always been so.'),
      _field(
          'observation', 'Seen from below', RecordFieldType.richText, from + 4,
          description: 'What it looks like to someone standing on the ground, '
              'and with what instrument if any.'),
      _field('significance', 'Significance', RecordFieldType.richText, from + 5,
          description: 'What the people who look at it believe it means. '
              'Usually the reason it is in the book at all.'),
    ];

const _sharedSections = [
  RecordTemplateSection(
    id: 'astronomy-body',
    title: 'Body',
    order: 30,
    fieldIds: ['scale', 'composition', 'age', 'motion'],
  ),
  RecordTemplateSection(
    id: 'astronomy-seen',
    title: 'Seen from below',
    order: 31,
    fieldIds: ['observation', 'significance'],
  ),
];

RecordTypeDefinition _cosmic(
  String id,
  String name,
  String description,
  String icon,
  List<RecordFieldDefinition> own,
  List<RecordTemplateSection> ownSections,
) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      description: description,
      icon: icon,
      categoryId: 'world',
      // Kept, deliberately. See the library comment: correcting the three that
      // are not worlds is its own PR, not a side effect of this one.
      baseTypeId: AstronomyRecordTypes.worldFoundationTypeId,
      fields: [..._shared(), ...own],
      sections: [..._sharedSections, ...ownSections],
      suggestedLinkTypeIds: const ['partOf', 'locatedIn', 'associatedWith'],
      templateVersion: 2,
      builtIn: true,
      sourcePackId: 'authoros-astronomy-system',
      extensionData: _worldTemplate,
    );

// ---------------------------------------------------------------------------

final _universe = _cosmic(
  AstronomyRecordTypes.universeTypeId,
  'Universe',
  'Everything there is, and what this world believes about how it began.',
  'blur_on',
  [
    _field('cosmology', 'Cosmology', RecordFieldType.richText, 320,
        description: 'How this world explains its own existence. Rarely the '
            'same as how it happened.'),
    _field('origin', 'Origin', RecordFieldType.richText, 321,
        description: 'What began it, if anything is said to have.'),
  ],
  const [
    RecordTemplateSection(
      id: 'universe-cosmology',
      title: 'Cosmology',
      order: 32,
      fieldIds: ['cosmology', 'origin'],
    ),
  ],
);

final _galaxy = _cosmic(
  AstronomyRecordTypes.galaxyTypeId,
  'Galaxy',
  'A great gathering of stars.',
  'blur_circular',
  [
    _field('form', 'Form', RecordFieldType.shortText, 320,
        description: 'Spiral, elliptical, a smear nobody has named.'),
  ],
  const [
    RecordTemplateSection(
      id: 'galaxy-form',
      title: 'Form',
      order: 32,
      fieldIds: ['form'],
    ),
  ],
);

final _solarSystem = _cosmic(
  AstronomyRecordTypes.solarSystemTypeId,
  'Solar System',
  'A star and what goes around it.',
  'track_changes',
  [
    _field('bodies', 'Bodies', RecordFieldType.list, 320,
        description: 'What it holds. Link them for detail.'),
  ],
  const [
    RecordTemplateSection(
      id: 'solar-system-bodies',
      title: 'Bodies',
      order: 32,
      fieldIds: ['bodies'],
    ),
  ],
);

final _star = _cosmic(
  AstronomyRecordTypes.starTypeId,
  'Star',
  'A sun: its colour, its size, and what living under it is like.',
  'brightness_7',
  [
    _field('luminosity', 'Brightness', RecordFieldType.shortText, 320,
        description: 'How bright, and whether that is steady.'),
    _field('colour', 'Colour', RecordFieldType.shortText, 321,
        description: 'What colour its light is, which decides what everything '
            'under it looks like.'),
  ],
  const [
    RecordTemplateSection(
      id: 'star-light',
      title: 'Light',
      order: 32,
      fieldIds: ['luminosity', 'colour'],
    ),
  ],
);

final _planet = _cosmic(
  AstronomyRecordTypes.planetTypeId,
  'Planet',
  'A world in the sky, or the one underfoot.',
  'public',
  [
    _field('orbit', 'Orbit', RecordFieldType.shortText, 320,
        description: 'What it goes around, and how far out.'),
    _field('habitability', 'Habitability', RecordFieldType.richText, 321,
        description: 'Whether anything lives there, and what it costs to.'),
  ],
  const [
    RecordTemplateSection(
      id: 'planet-orbit',
      title: 'Orbit',
      order: 32,
      fieldIds: ['orbit', 'habitability'],
    ),
  ],
);

final _moon = _cosmic(
  AstronomyRecordTypes.moonTypeId,
  'Moon',
  'A body that goes around another, and what it does to those below.',
  'nightlight',
  [
    _field('phases', 'Phases', RecordFieldType.richText, 320,
        description: 'Its cycle, and what is reckoned by it — months, tides, '
            'festivals, transformations.'),
  ],
  const [
    RecordTemplateSection(
      id: 'moon-phases',
      title: 'Phases',
      order: 32,
      fieldIds: ['phases'],
    ),
  ],
);

/// Dimension, realm and plane share a shape: somewhere else, reachable by some
/// means, running on rules of its own.
///
/// They stay three siblings rather than one type with a kind field, because
/// they already exist as three and collapsing them would delete an author's
/// distinction. They stay siblings rather than a hierarchy for the reason
/// Bestiary declined a taxonomy: which of them contains which is the author's
/// cosmology, not AuthorOS's.
List<RecordFieldDefinition> _otherworldFields() => [
      _field('access', 'Access', RecordFieldType.richText, 320,
          description: 'How anything gets there, and what it costs to come '
              'back.'),
      _field('physicalLaws', 'Laws of the place', RecordFieldType.richText, 321,
          description: 'What works differently here. `Laws` inherited from '
              'World is legislation; this is physics.'),
    ];

const _otherworldSection = RecordTemplateSection(
  id: 'otherworld',
  title: 'Getting there',
  order: 32,
  fieldIds: ['access', 'physicalLaws'],
);

final _dimension = _cosmic(
  AstronomyRecordTypes.dimensionTypeId,
  'Dimension',
  'Somewhere else, running on rules of its own.',
  'layers',
  _otherworldFields(),
  const [_otherworldSection],
);

final _realm = _cosmic(
  AstronomyRecordTypes.realmTypeId,
  'Realm',
  'A domain apart, usually with something that holds it.',
  'castle',
  _otherworldFields(),
  const [_otherworldSection],
);

final _plane = _cosmic(
  AstronomyRecordTypes.planeTypeId,
  'Plane',
  'One of the layers this cosmology is built from.',
  'view_in_ar',
  _otherworldFields(),
  const [_otherworldSection],
);
