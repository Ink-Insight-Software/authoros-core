/// The Bloodlines specialist system's record types.
///
/// Four types since October 10, 2026: `house` and `clan`, below, and `title`
/// and `estate`, added for AOS Worldsmith's Ancestry Room and described at
/// the foot of this file.
///
/// `house` and `clan` began as bare `faction` children with **no
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
import 'world_record_types.dart';

class BloodlineRecordTypes {
  const BloodlineRecordTypes._();

  static const houseTypeId = 'house';
  static const clanTypeId = 'clan';

  /// What a family holds by right: a rank, and the succession it passes by.
  /// New October 10, 2026, for AOS Worldsmith's Ancestry Room.
  static const titleTypeId = 'title';

  /// What a title or a House holds on the ground: a seat, lands, revenue.
  /// New October 10, 2026, with [titleTypeId].
  static const estateTypeId = 'estate';

  /// Every type the Bloodlines system presents.
  static const List<String> recordTypeIds = [
    houseTypeId,
    clanTypeId,
    titleTypeId,
    estateTypeId,
  ];

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

  static final List<RecordTypeDefinition> definitions = [
    _house,
    _clan,
    _title,
    _estate,
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

// ---------------------------------------------------------------------------
// Titles and estates (October 10, 2026)
// ---------------------------------------------------------------------------
//
// AOS Worldsmith's Ancestry Room needed somewhere to say *Duke of Harrowmere*
// and *the Harrowmere lands* apart from the person and the House. Neither
// existed: `political-office` is a post a government fills ("Lord
// Chancellor"), and a title is a dignity a family holds and passes, whether or
// not it carries any office. Keeping them apart is what lets a dynasty lose
// the chancellorship and keep the dukedom.
//
// Both are free types with free fields, like `house` and `clan`: ADR-0017
// gates depth by field, never a type, and nothing here is sold. Succession is
// recorded here as the rule a title passes by; the line of succession itself
// is read by the Council Chamber's succession model, which is the only
// succession engine (Worldsmith build plan, Phase 5).

RecordFieldDefinition _detail(
  String id,
  String label,
  RecordFieldType type,
  int order, {
  String description = '',
  List<String> referenceTypeIds = const [],
  String? optionSetId,
  bool allowCustomValues = false,
  bool quickCreateVisible = false,
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
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

const _titleSuccession = RecordOptionSet(
  id: 'title-succession',
  name: 'Succession',
  description: 'The rule a title passes by, from one holder to the next.',
  values: [
    'Male-line primogeniture',
    'Absolute primogeniture',
    'Seniority',
    'Elective',
    'Tanistry',
    'Appointed by the crown',
    'Partible',
    'Ultimogeniture',
    'Life only',
  ],
);

/// A dignity a family holds and passes: its rank, who holds it now, and the
/// rule it passes by.
final _title = RecordTypeDefinition(
  id: BloodlineRecordTypes.titleTypeId,
  name: 'Title',
  description: 'A dignity held and passed down: its rank, who holds it, and '
      'the rule it passes by.',
  icon: 'workspace_premium',
  categoryId: 'factions',
  baseTypeId: 'general-lore',
  optionSets: const [_titleSuccession],
  fields: [
    _detail('rank', 'Rank', RecordFieldType.shortText, 200,
        description: 'Duke, khan, margravine, high priestess of the third '
            'flame. Say it the way the world says it.',
        quickCreateVisible: true),
    _detail('holder', 'Current holder', RecordFieldType.recordReference, 201,
        referenceTypeIds: const ['character'],
        description: 'The title outlives them; keep them apart.',
        quickCreateVisible: true),
    _detail('house', 'House', RecordFieldType.recordReference, 202,
        referenceTypeIds: const [
          BloodlineRecordTypes.houseTypeId,
          BloodlineRecordTypes.clanTypeId,
        ],
        description: 'The family it belongs to, which may not be the '
            'holder\'s.'),
    _detail('estate', 'Estate', RecordFieldType.recordReference, 203,
        referenceTypeIds: const [BloodlineRecordTypes.estateTypeId],
        description: 'What it holds on the ground, if anything. Some titles '
            'are only a name.'),
    _detail('succession', 'Passes by', RecordFieldType.singleChoice, 210,
        optionSetId: 'title-succession', allowCustomValues: true),
    _detail('successor', 'Heir', RecordFieldType.recordReference, 211,
        referenceTypeIds: const ['character'],
        description: 'Who is next by the rule, if the rule is followed.'),
    _detail('predecessors', 'Former holders', RecordFieldType.list, 212),
    _detail('contested', 'Contested by', RecordFieldType.longText, 213,
        description: 'Rival claims, and what each one rests on.'),
    _detail('grantedBy', 'Granted by', RecordFieldType.recordReference, 220,
        referenceTypeIds: const ['government', 'character', 'faction'],
        description: 'Who made it, and so who could unmake it.'),
    _detail('created', 'Created', RecordFieldType.shortText, 221,
        description: 'When it was first granted, in the world\'s reckoning.'),
    _detail('style', 'Style of address', RecordFieldType.shortText, 222,
        description: 'Your Grace, Most Serene, Mother of the Hearth.'),
    _detail('precedence', 'Precedence', RecordFieldType.shortText, 223,
        description: 'Where it stands among the others, and who disputes '
            'that.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'title-dignity',
      title: 'The dignity',
      order: 20,
      fieldIds: ['rank', 'holder', 'house', 'estate'],
    ),
    RecordTemplateSection(
      id: 'title-succession',
      title: 'Succession',
      order: 21,
      fieldIds: ['succession', 'successor', 'predecessors', 'contested'],
    ),
    RecordTemplateSection(
      id: 'title-origin',
      title: 'Origin and standing',
      order: 22,
      fieldIds: ['grantedBy', 'created', 'style', 'precedence'],
    ),
  ],
  suggestedLinkTypeIds: const ['belongsTo', 'associatedWith'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: 'authoros-bloodlines-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// Land held by right: its seat, what it yields, and who holds it.
final _estate = RecordTypeDefinition(
  id: BloodlineRecordTypes.estateTypeId,
  name: 'Estate',
  description: 'Land held by right: its seat, what it yields, and who holds '
      'it.',
  icon: 'castle',
  categoryId: 'factions',
  baseTypeId: 'general-lore',
  fields: [
    _detail('holder', 'Held by', RecordFieldType.recordReference, 200,
        referenceTypeIds: const [
          'character',
          BloodlineRecordTypes.houseTypeId,
          BloodlineRecordTypes.clanTypeId,
          'faction',
        ],
        quickCreateVisible: true),
    _detail('seat', 'Seat', RecordFieldType.recordReference, 201,
        referenceTypeIds: [...WorldRecordTypes.spatialTypeIds],
        description: 'The place the estate is run from.',
        quickCreateVisible: true),
    _detail('lands', 'Lands', RecordFieldType.longText, 202,
        description: 'What it covers. Link the regions for the map.'),
    _detail('title', 'Title', RecordFieldType.recordReference, 203,
        referenceTypeIds: const [BloodlineRecordTypes.titleTypeId],
        description: 'The dignity it goes with, if it goes with one.'),
    _detail('yield', 'Yield', RecordFieldType.longText, 210,
        description: 'What it produces and what it is worth.'),
    _detail('obligations', 'Obligations', RecordFieldType.richText, 211,
        description: 'What is owed for it: levies, tithes, homage.'),
    _detail('entail', 'Entail', RecordFieldType.shortText, 212,
        description: 'Whether it can be sold, split or left to anyone but '
            'the heir.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'estate-holding',
      title: 'The holding',
      order: 20,
      fieldIds: ['holder', 'seat', 'lands', 'title'],
    ),
    RecordTemplateSection(
      id: 'estate-worth',
      title: 'Worth and obligation',
      order: 21,
      fieldIds: ['yield', 'obligations', 'entail'],
    ),
  ],
  suggestedLinkTypeIds: const ['belongsTo', 'locatedIn', 'associatedWith'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: 'authoros-bloodlines-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
