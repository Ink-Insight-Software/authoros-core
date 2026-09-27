/// The Bloodlines specialist system's record types.
///
/// Two types — `house` and `clan` — both bare `faction` children with **no
/// fields of their own**. They inherit faction's nineteen, which describe an
/// organisation: purpose, leadership, members, hierarchy, territory, allies,
/// enemies, resources. Every one of those is true of a house, and none of them
/// is about **descent**, which is the only thing that makes a house different
/// from a guild.
///
/// An author could record who leads House Vance and had nowhere to say who it
/// descends from, how the name passes, which junior lines exist, who it has
/// married into, or what it will not forgive.
///
/// ## `lineage` belongs to Species Evolution, and this does not touch it
///
/// Species Evolution claims `lineage` for biological descent — how a species
/// came from another. Bloodlines is social descent: how a name and a claim
/// pass between people. They are different questions that happen to share a
/// word, and the registry's one-owner rule means only one system can hold the
/// type. Evolution got there first and its meaning is the more specific, so
/// this system uses fields on `house` and `clan` rather than claiming a type
/// whose owner means something else by it. A test asserts the boundary.
///
/// ## `faction` is not claimed
///
/// It is the base both types descend from, and `organisation`,
/// `military-unit`, `guild` and `company` descend from it too. Fifth base type
/// declined, after `item`, `location`, `travel-route` and `world` — and the
/// first where the base has siblings owned by nobody, which makes claiming it
/// worse than usual: turning Bloodlines off would take guilds and armies with
/// it.
///
/// ## What the two share, and what they do not
///
/// Six ids mean the same thing on both — a clan has a founder and a feud as
/// surely as a house does. What differs is the trappings: a house has a seat,
/// words and arms; a clan has septs and the marks that identify a member. They
/// stay siblings rather than one type with a kind field, because they already
/// exist as two and collapsing them would delete a distinction an author has
/// already made.
///
/// ## Compatibility
///
/// Nothing is re-parented and nothing removed. Both types had no fields, so no
/// value anywhere can be orphaned, and all nineteen inherited ids are
/// untouched.
library;

import 'record_types.dart';

class BloodlineRecordTypes {
  const BloodlineRecordTypes._();

  static const houseTypeId = 'house';
  static const clanTypeId = 'clan';

  /// Every type the Bloodlines system presents.
  static const List<String> recordTypeIds = [houseTypeId, clanTypeId];

  /// The base both descend from, deliberately left unclaimed.
  static const String factionFoundationTypeId = 'faction';

  /// Types that inherit `faction` and belong to nobody, named to show what
  /// claiming the base would have taken with it.
  static const List<String> factionSiblings = [
    'organisation',
    'guild',
    'company',
    'military-unit',
  ];

  /// Owned by Species Evolution, for biological descent. Bloodlines models
  /// social descent in fields and does not claim it.
  static const String evolutionLineageTypeId = 'lineage';

  /// The nineteen ids both types inherit from `faction` and `general-lore` and
  /// keep unchanged.
  static const List<String> inheritedFieldIds = [
    'name',
    'aliases',
    'summary',
    'description',
    'notes',
    'knowledgeStatus',
    'sourceReferences',
    'factionType',
    'purpose',
    'leadership',
    'members',
    'hierarchy',
    'territory',
    'allies',
    'enemies',
    'resources',
    'beliefs',
    'history',
    'secrets',
  ];

  /// Field ids that mean the same thing on both types.
  static const List<String> sharedFieldIds = [
    'founder',
    'descent',
    'marriages',
    'feuds',
    'heirlooms',
    'standing',
  ];

  static final List<RecordTypeDefinition> definitions = [_house, _clan];
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

/// The fields both types carry — descent, which is the whole of what a
/// bloodline is and none of what `faction` describes.
List<RecordFieldDefinition> _shared({int from = 200}) => [
      _field('founder', 'Founder', RecordFieldType.shortText, from,
          description: 'Who it descends from — and whether that is true, '
              'which is a different question. Link them for detail.'),
      _field('descent', 'Descent', RecordFieldType.richText, from + 1,
          description: 'How the name and the claim pass: eldest, agnatic, '
              'elective, disputed.'),
      _field('marriages', 'Marriages', RecordFieldType.richText, from + 2,
          description: 'Who it has married into, and what that bought.'),
      _field('feuds', 'Feuds', RecordFieldType.richText, from + 3,
          description: 'Who it will not marry into. `Enemies` is who it '
              'fights; this is who it will not forgive.'),
      _field('heirlooms', 'Heirlooms', RecordFieldType.list, from + 4,
          description: 'What passes with the name. Link the artefacts.'),
      _field('standing', 'Standing', RecordFieldType.shortText, from + 5,
          description: 'Ascendant, diminished, attainted, extinct in the '
              'senior line.'),
    ];

const _sharedSections = [
  RecordTemplateSection(
    id: 'bloodline-descent',
    title: 'Descent',
    order: 20,
    fieldIds: ['founder', 'descent', 'standing'],
  ),
  RecordTemplateSection(
    id: 'bloodline-ties',
    title: 'Ties',
    order: 21,
    fieldIds: ['marriages', 'feuds', 'heirlooms'],
  ),
];

// ---------------------------------------------------------------------------

/// A family that holds something: who it descends from, how the name passes,
/// and what it will not forgive.
final _house = RecordTypeDefinition(
  id: BloodlineRecordTypes.houseTypeId,
  name: 'House',
  description: 'A family that holds something: who it descends from, how the '
      'name passes, and what it will not forgive.',
  icon: 'shield_moon',
  categoryId: 'factions',
  baseTypeId: BloodlineRecordTypes.factionFoundationTypeId,
  fields: [
    ..._shared(),
    _field('seat', 'Seat', RecordFieldType.shortText, 220,
        description: 'The place it is named for and would die holding. '
            '`Territory` is everything it holds; this is the one that '
            'matters.'),
    _field('words', 'Words', RecordFieldType.shortText, 221,
        description: 'Its motto. Worth writing before you need it.'),
    _field('arms', 'Arms', RecordFieldType.richText, 222,
        description: 'Its heraldry, and what the devices are supposed to '
            'mean.'),
    _field('cadetBranches', 'Cadet branches', RecordFieldType.list, 223,
        description: 'Junior lines, and how junior they admit to being.'),
  ],
  sections: const [
    ..._sharedSections,
    RecordTemplateSection(
      id: 'house-seat',
      title: 'Name and seat',
      order: 22,
      fieldIds: ['seat', 'words', 'arms', 'cadetBranches'],
    ),
  ],
  suggestedLinkTypeIds: const [
    'foundedBy',
    'belongsTo',
    'ruledBy',
    'associatedWith',
  ],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bloodlines-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A kinship group: who counts as one of it, and what marks them.
///
/// A sibling of `house` rather than a child of it. A clan is not a large
/// house, and a house is not a formal clan — one is a line that holds
/// property, the other a set of families that claim common blood. Making
/// either inherit the other would decide for the author which of those their
/// world runs on.
final _clan = RecordTypeDefinition(
  id: BloodlineRecordTypes.clanTypeId,
  name: 'Clan',
  description: 'A kinship group: who counts as one of it, and what marks '
      'them.',
  icon: 'groups_2',
  categoryId: 'factions',
  baseTypeId: BloodlineRecordTypes.factionFoundationTypeId,
  fields: [
    ..._shared(),
    _field('septs', 'Septs', RecordFieldType.list, 220,
        description: 'The families that count themselves part of it, and the '
            'ones it counts.'),
    _field('marks', 'Marks', RecordFieldType.richText, 221,
        description: 'What identifies a member on sight — dress, scarring, '
            'a name-form, an oath said a particular way.'),
    _field('territoryClaim', 'Claim', RecordFieldType.richText, 222,
        description: 'What it says is its by right of blood, which is not '
            'always what it holds.'),
  ],
  sections: const [
    ..._sharedSections,
    RecordTemplateSection(
      id: 'clan-kin',
      title: 'Kin',
      order: 22,
      fieldIds: ['septs', 'marks', 'territoryClaim'],
    ),
  ],
  suggestedLinkTypeIds: const [
    'foundedBy',
    'belongsTo',
    'associatedWith',
    'originatedFrom',
  ],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-bloodlines-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
