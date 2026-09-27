/// The Architecture specialist system's record types.
///
/// The first system to claim World-domain types, and the reason PR 10 had to
/// land first: `building`, `structure`, `room` and `ruin` are all offered by
/// the World Studio as well as the Codex, so until the activation gate reached
/// both surfaces this system could only have been half off.
///
/// ## What was missing
///
/// `location` is a deep template — forty fields across identity, environment
/// and society — and every one of these four inherits all of it. So they were
/// never field-less the way Bestiary's six were. What none of them had is the
/// thing that makes a built structure different from a place: **how it was
/// made.** An author could record a keep's climate, terrain, wildlife and
/// politics, and had nowhere to say what it was built from, who raised it,
/// when, or whether it is still standing.
///
/// `location.architecture` exists, but it is a prose field describing what a
/// *settlement's* buildings look like in general. It is not a record of one
/// building, and this system does not touch it.
///
/// ## Inheritance is kept
///
/// A building is a location, so `baseTypeId: 'location'` stays on all four and
/// every inherited field keeps its id, type and editor. Third system in a row
/// where the claim is true and nothing is re-parented — Magic and Religion
/// remain the only two corrections.
///
/// ## The retained ids
///
/// `building` already had five fields of its own: owner, purpose, rooms,
/// security and importantPeople. Three of those describe any built thing, not
/// just a building, so **they keep their ids and types and become the shared
/// vocabulary** rather than being replaced by new ones. An existing `building`
/// record's Owner, Purpose and Security values keep their labels and typed
/// editors across this change; the same technique Magic and Religion used when
/// re-parenting, applied here to widening.
///
/// ## What is deliberately not claimed
///
/// * **`location` and `basic-location`** — foundation. A type no system claims
///   is always offered, and "a place exists" must never depend on a toggle.
///   The same reasoning that kept `item` out of Artifacts.
/// * **Settlements** — `city`, `town`, `village`, `settlement`, `district`,
///   `neighbourhood`. A city is geography, not a work of architecture, and
///   `city` already carries its own five fields. Hiding cities behind an
///   Architecture toggle would be absurd.
/// * **`landmark`** — a landmark is as often a mountain or a tree as a
///   monument. Gating it here would hide a natural feature behind a building
///   toggle.
/// * **`interior-location`** — near-identical to `room`, and generic enough to
///   read as foundation. Claiming both would have been padding.
/// * **`road`** — infrastructure, and closer to Travel than to architecture.
///
/// All of these stay exactly where they are, in `authoros-world-core`.
///
/// ## The id sets are untouched
///
/// These four definitions move to a dedicated pack, but their ids stay in
/// [WorldRecordTypes.locationTypeIds]. That set drives `isBuiltInWorldType`
/// and is read 44 times across nine files and seventeen connection-type
/// definitions; nothing here changes what it contains. Verified: nothing in
/// `lib/` reads `authoros-world-core` or the `worldDomain` / `worldTemplate`
/// flags, so the pack move is inert beyond specialist discovery — where it
/// makes the registry's "a dedicated pack is wholly owned by its system" rule
/// binding rather than inert.
library;

import 'record_types.dart';

class ArchitectureRecordTypes {
  const ArchitectureRecordTypes._();

  static const buildingTypeId = 'building';
  static const structureTypeId = 'structure';
  static const roomTypeId = 'room';
  static const ruinTypeId = 'ruin';

  /// Every type the Architecture system presents. The manifest names exactly
  /// these.
  static const List<String> recordTypeIds = [
    buildingTypeId,
    structureTypeId,
    roomTypeId,
    ruinTypeId,
  ];

  /// Spatial types deliberately left in `authoros-world-core`.
  ///
  /// Named rather than merely omitted, so the reservation is a recorded
  /// decision and the test asserting it has something to assert against.
  static const List<String> reservedAsWorldFoundation = [
    'location',
    'basic-location',
    'city',
    'town',
    'village',
    'settlement',
    'district',
    'neighbourhood',
    'landmark',
    'interior-location',
    'road',
  ];

  /// Ids that were already on `building` and are kept, with the same id and
  /// the same type, because they describe any built thing.
  ///
  /// The compatibility guarantee turns on these: an existing `building`
  /// record's values for them keep their labels and typed editors.
  static const List<String> retainedBuildingFieldIds = [
    'owner',
    'purpose',
    'security',
  ];

  /// Field ids that mean the same thing on all four types and carry the same
  /// id and type on each.
  ///
  /// Shared vocabulary without a shared parent below `location`. The first
  /// three are [retainedBuildingFieldIds]; the rest are new.
  static const List<String> sharedFieldIds = [
    'owner',
    'purpose',
    'security',
    'style',
    'materials',
    'built',
    'builder',
    'condition',
    'access',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _building,
    _structure,
    _room,
    _ruin,
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
  List<String> referenceTypeIds = const [],
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      referenceTypeIds: referenceTypeIds,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

/// The fields every built thing carries, with one id and one type each.
///
/// `owner`, `purpose` and `security` are `building`'s original three, kept at
/// their original types so no existing value is re-interpreted.
List<RecordFieldDefinition> _shared({int from = 300}) => [
      _field('owner', 'Owner', RecordFieldType.recordReference, from,
          description: 'Who holds it now.'),
      _field('purpose', 'Purpose', RecordFieldType.longText, from + 1,
          description: 'What it was built to do — which is not always what '
              'it is used for.'),
      _field('style', 'Style', RecordFieldType.shortText, from + 2,
          description: 'Vernacular, imperial, dwarven, grown rather than '
              'built.'),
      _field('materials', 'Materials', RecordFieldType.list, from + 3,
          description: 'What it is made of. Often the first thing a reader '
              'is told.'),
      _field('built', 'Built', RecordFieldType.shortText, from + 4,
          description: 'When it was raised, in the world\'s own reckoning.'),
      _field('builder', 'Builder', RecordFieldType.recordReference, from + 5,
          description: 'Who raised it. `Owner` is who has it now.'),
      _field('condition', 'Condition', RecordFieldType.shortText, from + 6,
          description: 'Sound, settling, half-fallen, held up by something '
              'that should not hold it up.'),
      _field('security', 'Defences', RecordFieldType.richText, from + 7,
          description: 'What keeps people out, and what it does not keep '
              'out.'),
      _field('access', 'Access', RecordFieldType.richText, from + 8,
          description: 'How you get in, who may, and the way nobody is '
              'supposed to know about.'),
    ];

const _sharedSections = [
  RecordTemplateSection(
    id: 'architecture-make',
    title: 'Make',
    order: 30,
    fieldIds: ['style', 'materials', 'built', 'builder', 'condition'],
  ),
  RecordTemplateSection(
    id: 'architecture-use',
    title: 'Use and access',
    order: 31,
    fieldIds: ['owner', 'purpose', 'security', 'access'],
  ),
];

// ---------------------------------------------------------------------------

/// A raised, enclosed, occupied thing: who holds it, what it is for, and how
/// it was made.
///
/// Keeps all five of its original fields. Three become shared vocabulary;
/// `rooms` and `importantPeople` stay its own.
final _building = RecordTypeDefinition(
  id: ArchitectureRecordTypes.buildingTypeId,
  name: 'Building',
  description: 'A raised, enclosed, occupied thing: who holds it, what it is '
      'for, and how it was made.',
  icon: 'domain',
  categoryId: 'locations',
  baseTypeId: 'location',
  fields: [
    ..._shared(),
    _field('rooms', 'Rooms', RecordFieldType.list, 320,
        description: 'Link them for detail.'),
    _field('floors', 'Storeys', RecordFieldType.shortText, 321,
        description: 'Above ground and below it.'),
    _field('importantPeople', 'Important People', RecordFieldType.list, 322),
    // What the plan is *of*, which decides the whole programme: a tavern is a
    // big room and a stair, a warehouse is one volume. Written by the
    // procedural engine and undeclared until the Lock 9 review.
    _field('buildingKind', 'Plan kind', RecordFieldType.shortText, 323,
        description: 'Tavern, manor, keep, dungeon, vessel — what it is for.'),
  ],
  sections: const [
    ..._sharedSections,
    RecordTemplateSection(
      id: 'building-inside',
      title: 'Inside',
      order: 32,
      fieldIds: ['rooms', 'floors', 'buildingKind', 'importantPeople'],
    ),
  ],
  suggestedLinkTypeIds: const ['locatedIn', 'partOf', 'ownedBy', 'createdBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-architecture-system',
  extensionData: _worldTemplate,
);

/// Something built that is not a building: a wall, a bridge, an aqueduct, a
/// standing stone.
final _structure = RecordTypeDefinition(
  id: ArchitectureRecordTypes.structureTypeId,
  name: 'Structure',
  description: 'Something built that is not a building — a wall, a bridge, '
      'an aqueduct, a standing stone.',
  icon: 'account_balance',
  categoryId: 'locations',
  baseTypeId: 'location',
  fields: [
    ..._shared(),
    _field('scale', 'Scale', RecordFieldType.shortText, 320,
        description: 'How big it is, in terms the world would use.'),
    _field('buildingKind', 'Plan kind', RecordFieldType.shortText, 321,
        description: 'What the plan is for, when one was generated.'),
  ],
  sections: const [
    ..._sharedSections,
    RecordTemplateSection(
      id: 'structure-scale',
      title: 'Scale',
      order: 32,
      fieldIds: ['scale'],
    ),
  ],
  suggestedLinkTypeIds: const ['locatedIn', 'partOf', 'ownedBy', 'createdBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-architecture-system',
  extensionData: _worldTemplate,
);

/// One space inside something built.
///
/// A sibling of `building` rather than a child of it. A room is inside a
/// building the way a character is inside a faction — a `partOf` edge, which
/// the author shapes and can change without a migration. A hard-coded parent
/// pointer would be a one-level containment imposed by the tool, which is the
/// mistake Bestiary declined to make with `parentSpecies`.
final _room = RecordTypeDefinition(
  id: ArchitectureRecordTypes.roomTypeId,
  name: 'Room',
  description: 'One space inside something built.',
  icon: 'meeting_room',
  categoryId: 'locations',
  baseTypeId: 'location',
  fields: [
    ..._shared(),
    _field('exits', 'Exits', RecordFieldType.list, 320,
        description: 'Where it leads, including the ways that are not '
            'doors.'),
    // Written by the procedural engine's floorplans and undeclared until the
    // Lock 9 review. Which storey the room is on, kept on the room so a room
    // read on its own still says where it sits.
    //
    // The plan also draws doorways. Those are *not* here: a doorway is part of
    // the room's drawn shape, so it lives in the `_map.` namespace beside the
    // outline. Declaring it as a room field was the first fix for this
    // finding, and it made every generated room fail validation.
    _field('floorLevel', 'Storey', RecordFieldType.number, 321,
        description: 'Ground is 0, a cellar is negative.'),
  ],
  sections: const [
    ..._sharedSections,
    RecordTemplateSection(
      id: 'room-exits',
      title: 'Exits',
      order: 32,
      fieldIds: ['exits'],
    ),
  ],
  suggestedLinkTypeIds: const ['locatedIn', 'partOf', 'ownedBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-architecture-system',
  extensionData: _worldTemplate,
);

/// What is left of something built.
///
/// Not a child of `building`: a ruin may have been a wall, a road or a city,
/// and inheriting from any one of those would decide for the author what it
/// used to be.
final _ruin = RecordTypeDefinition(
  id: ArchitectureRecordTypes.ruinTypeId,
  name: 'Ruin',
  description: 'What is left of something built.',
  icon: 'foundation',
  categoryId: 'locations',
  baseTypeId: 'location',
  fields: [
    ..._shared(),
    _field('ruinedBy', 'Ruined by', RecordFieldType.richText, 320,
        description: 'What brought it down — and whether anyone admits it.'),
    _field('remains', 'What remains', RecordFieldType.richText, 321,
        description: 'What is still standing, and what can still be reached.'),
  ],
  sections: const [
    ..._sharedSections,
    RecordTemplateSection(
      id: 'ruin-fall',
      title: 'The fall',
      order: 32,
      fieldIds: ['ruinedBy', 'remains'],
    ),
  ],
  suggestedLinkTypeIds: const [
    'locatedIn',
    'partOf',
    'originatedFrom',
    'createdBy',
  ],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-architecture-system',
  extensionData: _worldTemplate,
);
