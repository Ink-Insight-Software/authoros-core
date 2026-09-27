/// The Bestiary specialist system's record types.
///
/// Six types that between them had **no fields at all** — `species`, `race`,
/// `creature`, `monster`, `animal` and `plant` were bare `general-lore`
/// children, so an author cataloguing a world's living things had a title, a
/// description, and nowhere to put anatomy, habitat, behaviour or what kills
/// it. This is the shallowest family in Wave 1 and the largest gain.
///
/// ## Why they stay flat
///
/// It is tempting to make `monster` inherit `creature`, or `race` inherit
/// `species`. This file deliberately does not, and the reason is not caution
/// for its own sake: **taxonomy is the author's business, not AuthorOS's.**
/// One writer's "race" is another's "species"; one writer's "monster" is
/// another's "animal" seen from the wrong end of a field. Hard-coding an
/// inheritance edge would assert a biology on every project that opens the
/// system, and inheritance asserted rather than observed is exactly what this
/// programme has twice had to undo — in `spell -> magic-system` and in
/// `deity -> religion`.
///
/// So the six stay siblings, and an author who wants a hierarchy expresses it
/// with a `partOf` edge, which is theirs to shape and can be changed without a
/// migration. For the same reason there is no `parentSpecies` field: a single
/// hard-coded parent pointer is a one-level taxonomy imposed by the tool.
///
/// What the types *do* share is **field ids**. `appearance`, `habitat`,
/// `behaviour`, `diet`, `abilities` and `weaknesses` mean the same thing on
/// each of them and carry the same id and type, so a record compared against
/// its neighbour — or retyped by an author who decides the thing is a monster
/// after all — reads consistently. That is the benefit inheritance would have
/// given, without the assertion.
///
/// ## No cross-system soft references
///
/// A race plainly relates to a culture, and a creature to a location. Neither
/// is a `recordReference` field here. Culture's `language` and `religion`
/// fields are kept only because authors may already have values in them, and
/// this phase does not add new ones: cross-system connection is what the edge
/// model is for, and only an edge can be traversed by search, the graph or the
/// map. The within-system parent pointers that Magic and Religion use
/// (`ability.system`, `deity.religion`) are a different thing — structural
/// containment inside one domain — and Bestiary has none of those either,
/// because of the taxonomy decision above.
///
/// ## A limitation worth knowing about
///
/// The natural edges for a bestiary — `livesIn` a place, `locatedIn` a region,
/// `appearsIn` a scene — are **not available to these types**, because
/// relationship permission is exact-match rather than inheritance-aware. That
/// is issue #84, it is live on `main` independently of this work, and it must
/// not be worked around by hand-adding `creature` to those definitions' type
/// lists — the hand-adding is what produced the inconsistency #84 describes.
///
/// Measured, so the gap is known rather than guessed:
///
///     creature -partOf->         PERMITTED    creature -livesIn->    REJECTED
///     creature -associatedWith-> PERMITTED    creature -locatedIn->  REJECTED
///     creature -originatedFrom-> PERMITTED    creature -appearsIn->  REJECTED
///
/// Bestiary therefore ships on the `*`-typed edges, which are sufficient — a
/// creature's habitat is expressible as `associatedWith` or `originatedFrom` —
/// and gains the natural vocabulary the day #84 lands, with no change here.
///
/// ## Compatibility
///
/// Nothing is re-parented and nothing is removed. Every one of these types had
/// zero fields, so there is not a single value anywhere that can be orphaned:
/// this is the most purely additive change in the programme.
/// `bestiary_compatibility_test.dart` proves it against records built in the
/// old shape rather than assuming it.
library;

import 'record_types.dart';

class BestiaryRecordTypes {
  const BestiaryRecordTypes._();

  static const speciesTypeId = 'species';
  static const raceTypeId = 'race';
  static const creatureTypeId = 'creature';
  static const monsterTypeId = 'monster';
  static const animalTypeId = 'animal';
  static const plantTypeId = 'plant';

  /// Every type the Bestiary presents. The manifest names exactly these.
  ///
  /// `species` is here by the recorded reservation: Bestiary owns it, and
  /// Species Evolution (Wave 3) consumes and extends the canonical type rather
  /// than claiming it. One owner per record type is enforced at registry
  /// construction, so a later claim is a startup failure, not a debate.
  static const List<String> recordTypeIds = [
    speciesTypeId,
    raceTypeId,
    creatureTypeId,
    monsterTypeId,
    animalTypeId,
    plantTypeId,
  ];

  /// Field ids that mean the same thing on every type in the family and carry
  /// the same id and type on each.
  ///
  /// This is what the family shares instead of an inheritance edge. Asserted
  /// in the tests, so it stays true as the types grow.
  static const List<String> sharedFieldIds = [
    'appearance',
    'habitat',
    'behaviour',
    'diet',
    'abilities',
    'weaknesses',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _species,
    _race,
    _creature,
    _monster,
    _animal,
    _plant,
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
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

/// The fields every member of the family carries, with one id and one type
/// each. Written once and spread into each definition — shared vocabulary
/// without shared inheritance.
List<RecordFieldDefinition> _shared({int from = 100}) => [
      _field('appearance', 'Appearance', RecordFieldType.richText, from),
      _field('habitat', 'Habitat', RecordFieldType.longText, from + 1),
      _field('behaviour', 'Behaviour', RecordFieldType.richText, from + 2),
      _field('diet', 'Diet', RecordFieldType.shortText, from + 3),
      _field('abilities', 'Abilities', RecordFieldType.list, from + 4),
      _field('weaknesses', 'Weaknesses', RecordFieldType.list, from + 5),
    ];

const _sharedSection = RecordTemplateSection(
  id: 'bestiary-shared',
  title: 'Form and life',
  order: 10,
  fieldIds: [
    'appearance',
    'habitat',
    'behaviour',
    'diet',
    'abilities',
    'weaknesses',
  ],
);

// ---------------------------------------------------------------------------

/// A kind of living thing, as the author's world classifies it.
final _species = RecordTypeDefinition(
  id: BestiaryRecordTypes.speciesTypeId,
  name: 'Species',
  description: 'A kind of living thing, as this world classifies it.',
  icon: 'genetics',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  fields: [
    ..._shared(),
    _field('biology', 'Biology', RecordFieldType.richText, 120),
    _field('lifespan', 'Lifespan', RecordFieldType.shortText, 121),
    _field('reproduction', 'Reproduction', RecordFieldType.richText, 122),
    _field('intelligence', 'Intelligence', RecordFieldType.shortText, 123),
    _field('society', 'Society', RecordFieldType.richText, 130,
        description: 'How they live together, if they do.'),
    _field('distribution', 'Where found', RecordFieldType.longText, 131),
    _field('variants', 'Variants', RecordFieldType.list, 132,
        description: 'Subspecies and regional forms. Link them for detail.'),
  ],
  sections: const [
    _sharedSection,
    RecordTemplateSection(
      id: 'species-biology',
      title: 'Biology',
      order: 11,
      fieldIds: ['biology', 'lifespan', 'reproduction', 'intelligence'],
    ),
    RecordTemplateSection(
      id: 'species-range',
      title: 'Range',
      order: 12,
      fieldIds: ['society', 'distribution', 'variants'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'originatedFrom'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bestiary-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A people, as this world reckons peoples.
final _race = RecordTypeDefinition(
  id: BestiaryRecordTypes.raceTypeId,
  name: 'Race',
  description: 'A people, as this world reckons peoples.',
  icon: 'groups_2_outlined',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  fields: [
    ..._shared(),
    _field('traits', 'Traits', RecordFieldType.list, 120),
    _field('lifespan', 'Lifespan', RecordFieldType.shortText, 121),
    _field('homeland', 'Homeland', RecordFieldType.longText, 122),
    _field('standing', 'Standing', RecordFieldType.richText, 130,
        description: 'How others treat them, and how they take it.'),
    _field('history', 'History', RecordFieldType.richText, 131),
  ],
  sections: const [
    _sharedSection,
    RecordTemplateSection(
      id: 'race-people',
      title: 'People',
      order: 11,
      fieldIds: ['traits', 'lifespan', 'homeland'],
    ),
    RecordTemplateSection(
      id: 'race-place',
      title: 'Place in the world',
      order: 12,
      fieldIds: ['standing', 'history'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'originatedFrom'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bestiary-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A living thing in this world.
final _creature = RecordTypeDefinition(
  id: BestiaryRecordTypes.creatureTypeId,
  name: 'Creature',
  description: 'A living thing in this world.',
  icon: 'pets',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  fields: [
    ..._shared(),
    _field('classification', 'Classification', RecordFieldType.shortText, 120,
        description: 'Where it sits in this world\'s reckoning.'),
    _field('lifespan', 'Lifespan', RecordFieldType.shortText, 121),
    _field('distribution', 'Where found', RecordFieldType.longText, 122),
    _field('encounters', 'Encounters', RecordFieldType.richText, 130,
        description: 'What meeting one is actually like.'),
  ],
  sections: const [
    _sharedSection,
    RecordTemplateSection(
      id: 'creature-kind',
      title: 'Kind',
      order: 11,
      fieldIds: ['classification', 'lifespan', 'distribution', 'encounters'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'originatedFrom'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bestiary-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A creature framed as a danger.
final _monster = RecordTypeDefinition(
  id: BestiaryRecordTypes.monsterTypeId,
  name: 'Monster',
  description: 'A creature framed as a danger.',
  icon: 'raven',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  fields: [
    ..._shared(),
    _field('threat', 'Threat', RecordFieldType.shortText, 120),
    _field('hunts', 'How it hunts', RecordFieldType.richText, 121),
    _field('killedBy', 'How it is killed', RecordFieldType.richText, 122,
        description: 'What actually works, as opposed to what is believed.'),
    _field('origin', 'Origin', RecordFieldType.richText, 130),
    _field('legends', 'Legends', RecordFieldType.richText, 131,
        description: 'What people say about it, true or not.'),
  ],
  sections: const [
    _sharedSection,
    RecordTemplateSection(
      id: 'monster-danger',
      title: 'Danger',
      order: 11,
      fieldIds: ['threat', 'hunts', 'killedBy'],
    ),
    RecordTemplateSection(
      id: 'monster-story',
      title: 'Story',
      order: 12,
      fieldIds: ['origin', 'legends'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'originatedFrom'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bestiary-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A beast this world takes for granted.
final _animal = RecordTypeDefinition(
  id: BestiaryRecordTypes.animalTypeId,
  name: 'Animal',
  description: 'A beast this world takes for granted.',
  icon: 'cruelty_free',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  fields: [
    ..._shared(),
    _field('domesticated', 'Domesticated', RecordFieldType.shortText, 120),
    _field('uses', 'Uses', RecordFieldType.list, 121,
        description: 'What people keep it for.'),
    _field('lifespan', 'Lifespan', RecordFieldType.shortText, 122),
    _field('distribution', 'Where found', RecordFieldType.longText, 123),
  ],
  sections: const [
    _sharedSection,
    RecordTemplateSection(
      id: 'animal-husbandry',
      title: 'In use',
      order: 11,
      fieldIds: ['domesticated', 'uses', 'lifespan', 'distribution'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'originatedFrom'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bestiary-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// Something that grows here.
///
/// Carries the shared field set like the rest of the family, including `diet`
/// and `behaviour` — which read oddly for a fern and exactly right for the
/// things fantasy authors actually write down. A plant that eats and a plant
/// that moves are both common enough that removing the fields would cost more
/// than leaving them empty does.
final _plant = RecordTypeDefinition(
  id: BestiaryRecordTypes.plantTypeId,
  name: 'Plant',
  description: 'Something that grows here.',
  icon: 'local_florist_outlined',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  fields: [
    ..._shared(),
    _field('growth', 'Growth', RecordFieldType.richText, 120),
    _field('harvest', 'Harvest', RecordFieldType.longText, 121),
    _field('uses', 'Uses', RecordFieldType.list, 122),
    _field('toxicity', 'Toxicity', RecordFieldType.richText, 130),
    _field('distribution', 'Where found', RecordFieldType.longText, 131),
  ],
  sections: const [
    _sharedSection,
    RecordTemplateSection(
      id: 'plant-growth',
      title: 'Growth and use',
      order: 11,
      fieldIds: ['growth', 'harvest', 'uses'],
    ),
    RecordTemplateSection(
      id: 'plant-range',
      title: 'Range',
      order: 12,
      fieldIds: ['toxicity', 'distribution'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'originatedFrom'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bestiary-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
