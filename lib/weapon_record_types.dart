/// The Weapons specialist system's record types.
///
/// Two types that between them had **no fields at all**. `weapon` and `armour`
/// were bare `_derivedChildren` of `item`, so an author cataloguing an
/// armoury got the ten generic item fields — Type, Creator, Owner, Materials,
/// Powers, Limitations, History, Current Location, Known Users, Secrets — and
/// nowhere to say what the thing is, how it is held, what it stops, or what it
/// costs to carry.
///
/// ## Nothing is re-parented, and that is the finding
///
/// Magic and Religion were corrections: `spell` was declared under
/// `magic-system` and `deity` under `religion`, and in both cases inheritance
/// was asserting something false. Here it is not. **A weapon genuinely is an
/// item and armour genuinely is an item**, so `baseTypeId: 'item'` is correct
/// and stays, and both types keep all ten inherited fields with their ids,
/// labels and typed editors untouched.
///
///     general-lore
///     └── item          the ten generic fields, unchanged
///         ├── weapon    what it is, how it is held, what it does
///         └── armour    what it covers, what it stops, what it costs
///
/// This is worth saying plainly because the programme has now twice had to
/// undo inheritance that was asserted rather than observed. The lesson is not
/// "flatten everything" — it is "inherit where the claim is true". Here it is
/// true, so nothing moves, and this becomes the most conservative change in
/// the programme: every field is added, none is re-parented, and none leaves.
///
/// ## What the two share
///
/// Four field ids mean the same thing on both and carry the same id and type
/// on each — see [WeaponRecordTypes.sharedFieldIds]. That is the same device
/// Bestiary uses: shared vocabulary without a shared parent that would have to
/// claim a weapon and a breastplate are the same kind of thing.
///
/// ## What this system deliberately does not claim
///
/// `clothing` and `vehicle` are the other two zero-field children of `item`,
/// and both are left alone — see [WeaponRecordTypes.reservedForOtherSystems].
/// A cloak is material culture and a cart is travel; neither becomes a weapon
/// because it happens to sit in the same corner of the registry. One owner per
/// record type is enforced at registry construction, so claiming either now
/// would turn a later wave into a startup failure rather than a conversation.
/// Culture reserved `language` on exactly this reasoning and Language then
/// claimed it cleanly, which is the reservation working.
///
/// ## A limitation worth knowing about, and its odd shape
///
/// Relationship permission is exact-match rather than inheritance-aware
/// (issue #84), so an `item` child is only reachable by an edge that names it
/// by hand. `weapon` was hand-added to three of those lists years apart and
/// `armour` was not, which produces this:
///
///     character -owns->     weapon PERMITTED    armour REJECTED
///     character -uses->     weapon PERMITTED    armour REJECTED
///     character -carries->  weapon PERMITTED    armour REJECTED
///     weapon    -locatedIn-> place  REJECTED    (but `item` and `artefact` may)
///
/// A character may own a sword and may not own a breastplate; a sword may not
/// be *anywhere*, though the generic item it inherits from may. None of that
/// is a decision anyone made — it is the accumulated residue of hand-listing,
/// which is precisely what #84 describes. It is **not** worked around here by
/// adding `armour` to those lists: hand-adding is the cause, not the cure.
///
/// The system ships instead on the `*`-typed Codex edges, which are permitted
/// for every type in the family and say the same things:
///
///     ownedBy   PERMITTED for weapon, armour, clothing, vehicle
///     usedBy    PERMITTED for all four
///     createdBy PERMITTED for all four
///
/// So `character -owns-> armour` is rejected while `armour -ownedBy-> character`
/// is permitted — the same fact, in the direction that happens to be wildcard.
/// Weapons uses the direction that works, and gains the other the day #84
/// lands, with no change to this file.
///
/// ## Compatibility
///
/// Both types had zero fields of their own, so no value anywhere can be
/// orphaned by this, and the ten inherited ids are untouched. `templateVersion`
/// goes to 2, which `TemplateEngine` reports as an upgrade rather than a break,
/// and no added field is required. `weapon_compatibility_test.dart` proves each
/// claim against records built in the shape the old definitions produced.
library;

import 'record_types.dart';

class WeaponRecordTypes {
  const WeaponRecordTypes._();

  static const weaponTypeId = 'weapon';
  static const armourTypeId = 'armour';

  /// Every type the Weapons system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [weaponTypeId, armourTypeId];

  /// The other zero-field children of `item`, deliberately left unclaimed.
  ///
  /// `clothing` belongs with material culture and `vehicle` with Travel,
  /// which has since claimed it. Named rather than merely omitted, so the
  /// reservation is a recorded decision a later wave can rely on — and so the
  /// test that asserts Weapons does not claim them has something to assert
  /// against.
  static const List<String> reservedForOtherSystems = ['clothing', 'vehicle'];

  /// The ten field ids `weapon` and `armour` inherit from `item` and keep
  /// unchanged.
  ///
  /// Named because the compatibility guarantee depends on them: nothing in
  /// this file may shadow one of these ids with a different type, or an
  /// existing record's value would lose its editor.
  static const List<String> inheritedItemFieldIds = [
    'itemType',
    'creator',
    'owner',
    'materials',
    'powers',
    'limitations',
    'history',
    'currentLocation',
    'knownUsers',
    'secrets',
  ];

  /// Field ids that mean the same thing on both types and carry the same id
  /// and type on each.
  ///
  /// Shared vocabulary without a shared parent. Asserted in the tests, so it
  /// stays true as the two grow.
  static const List<String> sharedFieldIds = [
    'requirements',
    'maintenance',
    'marks',
    'notableUses',
  ];

  static final List<RecordTypeDefinition> definitions = [_weapon, _armour];
}

/// Matches what the generated Codex templates carried before this file, so
/// nothing downstream sees a change.
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

/// The fields both types carry, with one id and one type each.
///
/// None of these shadows an inherited `item` id — asserted in the tests,
/// because shadowing one with a different type is the single way this file
/// could break an existing record.
List<RecordFieldDefinition> _shared({int from = 120}) => [
      _field('requirements', 'Requirements', RecordFieldType.richText, from,
          description: 'What it takes to use this — strength, training, '
              'a bloodline, a name it will answer to.'),
      _field('maintenance', 'Upkeep', RecordFieldType.longText, from + 1,
          description: 'What keeps it working, and what happens when that '
              'is neglected.'),
      _field('marks', 'Marks', RecordFieldType.list, from + 2,
          description: 'Notches, inscriptions, a maker\'s stamp — what '
              'identifies this one rather than its kind.'),
      _field('notableUses', 'Notable uses', RecordFieldType.richText, from + 3,
          description: 'What it has been used for that the story remembers.'),
    ];

const _sharedSections = [
  RecordTemplateSection(
    id: 'weapons-condition',
    title: 'Handling and upkeep',
    order: 11,
    fieldIds: ['requirements', 'maintenance', 'marks'],
  ),
  RecordTemplateSection(
    id: 'weapons-story',
    title: 'Story',
    order: 12,
    fieldIds: ['notableUses'],
  ),
];

// ---------------------------------------------------------------------------
// The weapon
// ---------------------------------------------------------------------------

/// A thing made to do harm: what it is, how it is held, and what it does.
///
/// Stays a child of `item`, because it is one. The ten inherited fields —
/// Materials, Creator, Owner, Powers, Limitations and the rest — are still
/// there and still answer for a weapon, so this adds only what `item` cannot
/// know: the shape of the thing and the manner of its use.
final _weapon = RecordTypeDefinition(
  id: WeaponRecordTypes.weaponTypeId,
  name: 'Weapon',
  description: 'A thing made to do harm: what it is, how it is held, '
      'and what it does.',
  icon: 'swords',
  categoryId: 'items',
  baseTypeId: 'item',
  fields: [
    _field('weaponClass', 'Class', RecordFieldType.shortText, 100,
        description: 'Sword, bow, sidearm, siege engine — the kind of thing '
            'it is.'),
    _field('reach', 'Reach', RecordFieldType.shortText, 101,
        description: 'How far it acts: a hand, a room, a valley.'),
    _field('handedness', 'Handedness', RecordFieldType.shortText, 102,
        description: 'One-handed, two-handed, crewed, mounted.'),
    _field('effect', 'Effect', RecordFieldType.richText, 103,
        description: 'What happens when it lands.'),
    _field('ammunition', 'Ammunition', RecordFieldType.shortText, 104,
        description: 'What it consumes, if anything.'),
    ..._shared(),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'weapon',
      title: 'Weapon',
      order: 10,
      fieldIds: [
        'weaponClass',
        'reach',
        'handedness',
        'effect',
        'ammunition',
      ],
    ),
    ..._sharedSections,
  ],
  // The `*`-typed Codex edges, verified permitted for this type. The natural
  // forward edges — owns, uses, carries, locatedIn — are unavailable or
  // inconsistent under #84 and are deliberately not hand-added.
  suggestedLinkTypeIds: const ['ownedBy', 'usedBy', 'createdBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-weapons-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The armour
// ---------------------------------------------------------------------------

/// A thing made to prevent harm: what it covers, what it stops, and what
/// wearing it costs.
///
/// A sibling of `weapon` rather than a child of it, and not the other way
/// round either. They share four field ids because those four mean the same
/// thing on both; they do not share a parent below `item`, because there is no
/// truthful claim that a breastplate is a kind of sword or a sword a kind of
/// armour.
final _armour = RecordTypeDefinition(
  id: WeaponRecordTypes.armourTypeId,
  name: 'Armour',
  description: 'A thing made to prevent harm: what it covers, what it stops, '
      'and what wearing it costs.',
  icon: 'shield',
  categoryId: 'items',
  baseTypeId: 'item',
  fields: [
    _field('armourClass', 'Class', RecordFieldType.shortText, 100,
        description: 'Plate, mail, hide, ward — the kind of thing it is.'),
    _field('coverage', 'Coverage', RecordFieldType.shortText, 101,
        description: 'What it actually protects, and what it leaves open.'),
    _field('protection', 'Protection', RecordFieldType.richText, 102,
        description: 'What it stops. Being specific here is what makes the '
            'thing it does not stop matter.'),
    _field('mobility', 'Burden', RecordFieldType.richText, 103,
        description: 'What wearing it costs — speed, sight, breath, heat.'),
    ..._shared(),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'armour',
      title: 'Armour',
      order: 10,
      fieldIds: ['armourClass', 'coverage', 'protection', 'mobility'],
    ),
    ..._sharedSections,
  ],
  suggestedLinkTypeIds: const ['ownedBy', 'usedBy', 'createdBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-weapons-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
