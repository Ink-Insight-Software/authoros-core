/// The Culture specialist system's record types.
///
/// The third system, and the first with **no inheritance defect to correct**.
/// Every type here was already a flat child of `general-lore`; none inherited
/// anything it should not have. So this file is pure deepening — five types
/// that had a title and a description between them, given the structure an
/// author was previously improvising inside prose.
///
/// ## What Culture deliberately does not claim
///
/// `language` and `currency` sit in the `culture` category and would look like
/// obvious members. They are not claimed here:
///
/// * **`language`** belongs to the Language system (Wave 2).
/// * **`currency`** belongs to Economy (Wave 4).
///
/// The framework enforces one owner per record type at registry construction,
/// so claiming either would turn a future wave into a startup `FormatException`
/// rather than a conversation. This is the same rule that reserves `species`
/// for Bestiary rather than Species Evolution.
///
/// A culture still *references* both — see `language` and `religion` below.
///
/// ## The two soft references
///
/// `culture.language` and `culture.religion` are `recordReference` **fields**,
/// and they predate this phase. `speaks`, `practices` and `hasCulture` already
/// express the same facts as **edges**, and only an edge can be traversed by
/// search, the graph, the map overlay or the intelligence layer.
///
/// They are kept, because an author may have values in them and this phase does
/// not delete author data to tidy a model. They are not extended, and no third
/// one is added. What they gain is `referenceTypeIds`, so at least the editor
/// knows what they point at. Treat them as superseded by the edges rather than
/// as the pattern to follow.
///
/// ## `clothing`, added later — the reservation redeemed
///
/// Weapons held `clothing` back rather than claiming it, on the stated ground
/// that "a cloak is material culture". It is claimed here, which closes the
/// last of the four reservations the programme recorded — `language` went to
/// Language, `vehicle` to Travel, `currency` to Economy, and this to Culture.
///
/// It is the only type here that is **not** a child of `general-lore`. A cloak
/// is a thing you can own, steal, lose and be recognised by, so it stays a
/// child of `item` and keeps all ten inherited fields. That asymmetry against
/// its sibling `food` is deliberate and is the honest reading of both: a dish
/// is closer to an idea a people holds than to an object in a chest.
///
/// **There is a `culture.clothing` field, and it stays.** This system already
/// runs that pattern for food: `culture.food` is prose about what a people
/// eats, and `food` is a record for one dish. Dress works the same way —
/// `culture.clothing` is how the Dothraki dress, and a `clothing` record is
/// the Kingsguard's white cloak. Neither replaces the other, and a test
/// asserts both survive, because collapsing them would either delete an
/// author's paragraph or ask them to make a record before they can write a
/// sentence.
///
/// The fabric is the inherited `materials`, so no textile field is added and
/// no `textile` type invented — `material` already models a substance, which
/// is the third system to reach that conclusion after Weapons and Alchemy.
///
/// ## Compatibility
///
/// Nothing is re-parented and nothing is removed, so this is the safest shape a
/// deepening can have: every change is additive. `clothing` had no fields of
/// its own, so nothing can be orphaned by deepening it either. `culture` keeps all thirteen
/// of its fields with the same ids and types, and the four children gain fields
/// where they had none. `culture_compatibility_test.dart` proves it against
/// records built in the old shape rather than assuming it.
library;

import 'record_types.dart';

class CultureRecordTypes {
  const CultureRecordTypes._();

  static const cultureTypeId = 'culture';
  static const customTypeId = 'custom-tradition';
  static const festivalTypeId = 'festival';
  static const holidayTypeId = 'holiday';
  static const foodTypeId = 'food';
  static const clothingTypeId = 'clothing';

  /// Every type the Culture system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [
    cultureTypeId,
    customTypeId,
    festivalTypeId,
    holidayTypeId,
    foodTypeId,
    clothingTypeId,
  ];

  /// Types in the `culture` category that Culture deliberately leaves alone.
  ///
  /// Named so the reservation is checkable rather than remembered — a test
  /// asserts Culture claims none of them.
  static const List<String> reservedForOtherSystems = ['language', 'currency'];

  /// The ten `item` field ids `clothing` inherits and keeps unchanged.
  ///
  /// `materials` is the fabric and `itemType` is the kind — cloak, robe, veil,
  /// coat. Named because the compatibility guarantee depends on them: nothing
  /// declared here may shadow one with a different type.
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

  /// The field on `culture` that describes how a people dresses.
  ///
  /// Kept, and deliberately not replaced by the type. See the library comment.
  static const String cultureDressFieldId = 'clothing';

  /// The inherited field that carries what a garment is made of.
  static const String fabricFieldId = 'materials';

  /// Dress concepts considered and declined, with the reason.
  static const Map<String, String> declinedTypes = {
    'garment': 'the same record as clothing, under another word',
    'textile': 'material already models a substance, down to its worth and '
        'where it is found',
    'fabric': 'material, again',
    'uniform': 'a kind of clothing — itemType names it, and who must wear it '
        'is wornBy',
    'costume': 'a kind of clothing',
    'regalia': 'a kind of clothing, or an artefact when the crown outlives '
        'the king',
    'jewellery': 'an item, and an artefact when it matters — adornment is not '
        'dress',
    'dress-code': 'a custom-tradition; a rule about clothing is not a garment',
    'fashion': 'a custom-tradition that changed, which is what customs do',
    'insignia': 'symbol already exists, and a badge is a symbol on a garment',
  };

  /// The `culture` fields that were already there before this phase.
  ///
  /// Every one survives with the same id and the same type. Named so the
  /// guarantee can be asserted rather than eyeballed.
  static const List<String> preExistingCultureFieldIds = [
    'origin',
    'values',
    'customs',
    'traditions',
    'language',
    'religion',
    'clothing',
    'food',
    'art',
    'socialStructure',
    'familyStructure',
    'laws',
    'taboos',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _culture,
    _custom,
    _festival,
    _holiday,
    _food,
    _clothing,
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

// ---------------------------------------------------------------------------
// The culture
// ---------------------------------------------------------------------------

/// A people: what they value, how they live, and what they will not do.
///
/// All thirteen previous fields are unchanged in id and type. What is new is
/// shape — five sections instead of one flat list — and five fields that were
/// previously improvised inside `customs`.
final _culture = RecordTypeDefinition(
  id: CultureRecordTypes.cultureTypeId,
  name: 'Culture',
  description: 'A people: what they value, how they live, what they will not '
      'do.',
  icon: 'diversity_3',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  fields: [
    _field('origin', 'Origin', RecordFieldType.longText, 100),
    _field('values', 'Values', RecordFieldType.list, 101),
    _field('worldview', 'Worldview', RecordFieldType.richText, 102,
        description: 'How this people explains the world to itself.'),
    _field('customs', 'Customs', RecordFieldType.richText, 110),
    _field('traditions', 'Traditions', RecordFieldType.richText, 111),
    _field('etiquette', 'Etiquette', RecordFieldType.richText, 112,
        description: 'What courtesy looks like, and what gives offence.'),
    _field('taboos', 'Taboos', RecordFieldType.list, 113),
    _field('clothing', 'Clothing', RecordFieldType.richText, 120),
    _field('food', 'Food', RecordFieldType.richText, 121),
    _field('art', 'Art', RecordFieldType.richText, 122),
    _field('music', 'Music', RecordFieldType.richText, 123),
    _field(
        'socialStructure', 'Social Structure', RecordFieldType.richText, 130),
    _field(
        'familyStructure', 'Family Structure', RecordFieldType.richText, 131),
    _field('laws', 'Laws', RecordFieldType.list, 132),
    _field('deathRites', 'Death rites', RecordFieldType.richText, 133,
        description: 'What is done with the dead, and what that says.'),
    // Superseded by edges, kept for the data already in them. See the library
    // comment. `referenceTypeIds` is added so the editor at least knows what
    // they point at; nothing else about them changes.
    _field('language', 'Language', RecordFieldType.recordReference, 140,
        referenceTypeIds: ['language'],
        description: 'Superseded by the `speaks` relationship.'),
    _field('religion', 'Religion', RecordFieldType.recordReference, 141,
        referenceTypeIds: ['religion'],
        description: 'Superseded by the `practices` relationship.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'culture',
      title: 'People',
      order: 10,
      fieldIds: ['origin', 'values', 'worldview'],
    ),
    RecordTemplateSection(
      id: 'culture-conduct',
      title: 'Conduct',
      order: 11,
      fieldIds: ['customs', 'traditions', 'etiquette', 'taboos'],
    ),
    RecordTemplateSection(
      id: 'culture-expression',
      title: 'Expression',
      order: 12,
      fieldIds: ['clothing', 'food', 'art', 'music'],
    ),
    RecordTemplateSection(
      id: 'culture-order',
      title: 'Order',
      order: 13,
      fieldIds: [
        'socialStructure',
        'familyStructure',
        'laws',
        'deathRites',
      ],
    ),
    RecordTemplateSection(
      id: 'culture-links',
      title: 'Connected records',
      order: 14,
      collapsedByDefault: true,
      fieldIds: ['language', 'religion'],
    ),
  ],
  suggestedLinkTypeIds: const ['associatedWith', 'influences', 'hasCulture'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-culture-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// Customs, festivals, holidays, food
// ---------------------------------------------------------------------------

/// One practice a people keeps.
///
/// Previously a bare `general-lore` child with no fields of its own, so an
/// author writing down a custom had a title and a paragraph and no way to say
/// who keeps it, when, or what happens if it is broken.
final _custom = RecordTypeDefinition(
  id: CultureRecordTypes.customTypeId,
  name: 'Custom / Tradition',
  description: 'One practice a people keeps.',
  icon: 'handshake_outlined',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  fields: [
    _field('culture', 'Culture', RecordFieldType.recordReference, 100,
        referenceTypeIds: [CultureRecordTypes.cultureTypeId]),
    _field('practice', 'What is done', RecordFieldType.richText, 101),
    _field('occasion', 'When', RecordFieldType.shortText, 102),
    _field('participants', 'Who takes part', RecordFieldType.longText, 110),
    _field('origin', 'Origin', RecordFieldType.richText, 111),
    _field('meaning', 'What it means', RecordFieldType.richText, 112),
    _field('ifBroken', 'If it is broken', RecordFieldType.richText, 120),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'custom',
      title: 'Custom',
      order: 10,
      fieldIds: ['culture', 'practice', 'occasion'],
    ),
    RecordTemplateSection(
      id: 'custom-meaning',
      title: 'Meaning',
      order: 11,
      fieldIds: ['participants', 'origin', 'meaning', 'ifBroken'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-culture-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A gathering a people holds.
///
/// Kept a sibling of [_holiday] rather than its parent. The two overlap, but a
/// festival is an occasion and a holiday is a day, and inventing an
/// inheritance edge between them would be exactly the move this programme has
/// twice had to undo.
final _festival = RecordTypeDefinition(
  id: CultureRecordTypes.festivalTypeId,
  name: 'Festival',
  description: 'A gathering a people holds.',
  icon: 'celebration_outlined',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  fields: [
    _field('culture', 'Culture', RecordFieldType.recordReference, 100,
        referenceTypeIds: [CultureRecordTypes.cultureTypeId]),
    _field('occasion', 'What it marks', RecordFieldType.richText, 101),
    _field('timing', 'When', RecordFieldType.shortText, 102),
    _field('duration', 'How long', RecordFieldType.shortText, 103),
    _field('activities', 'What happens', RecordFieldType.richText, 110),
    _field('foods', 'Foods', RecordFieldType.list, 111),
    _field('dress', 'Dress', RecordFieldType.longText, 112),
    _field('participants', 'Who takes part', RecordFieldType.longText, 113),
    _field('origin', 'Origin', RecordFieldType.richText, 120),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'festival',
      title: 'Festival',
      order: 10,
      fieldIds: ['culture', 'occasion', 'timing', 'duration'],
    ),
    RecordTemplateSection(
      id: 'festival-observance',
      title: 'Observance',
      order: 11,
      fieldIds: ['activities', 'foods', 'dress', 'participants', 'origin'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'occursAt'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-culture-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A day a people sets apart.
final _holiday = RecordTypeDefinition(
  id: CultureRecordTypes.holidayTypeId,
  name: 'Holiday',
  description: 'A day a people sets apart.',
  icon: 'event_outlined',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  fields: [
    _field('culture', 'Culture', RecordFieldType.recordReference, 100,
        referenceTypeIds: [CultureRecordTypes.cultureTypeId]),
    _field(
        'commemorates', 'What it commemorates', RecordFieldType.richText, 101),
    _field('date', 'Date', RecordFieldType.shortText, 102,
        description: 'In the calendar this people keeps.'),
    _field('observance', 'How it is kept', RecordFieldType.richText, 110),
    _field('workPermitted', 'Work permitted', RecordFieldType.shortText, 111),
    _field('origin', 'Origin', RecordFieldType.richText, 120),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'holiday',
      title: 'Holiday',
      order: 10,
      fieldIds: ['culture', 'commemorates', 'date'],
    ),
    RecordTemplateSection(
      id: 'holiday-observance',
      title: 'Observance',
      order: 11,
      fieldIds: ['observance', 'workPermitted', 'origin'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith', 'occursAt'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-culture-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// Something a people eats.
///
/// Note the id collision with `culture.food`, a `richText` field describing a
/// culture's cuisine generally. The two live in different namespaces — one is
/// a record type, the other a field id — so nothing breaks, and renaming
/// either would orphan whatever an author has already written. Recorded here
/// so the next reader does not mistake it for a bug.
final _food = RecordTypeDefinition(
  id: CultureRecordTypes.foodTypeId,
  name: 'Food',
  description: 'Something a people eats.',
  icon: 'restaurant_outlined',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  fields: [
    _field('culture', 'Culture', RecordFieldType.recordReference, 100,
        referenceTypeIds: [CultureRecordTypes.cultureTypeId]),
    _field('ingredients', 'Ingredients', RecordFieldType.list, 101),
    _field('preparation', 'Preparation', RecordFieldType.richText, 102),
    _field('occasion', 'Eaten when', RecordFieldType.shortText, 110),
    _field('whoEatsIt', 'Who eats it', RecordFieldType.longText, 111,
        description: 'Everyone, or only some — which is often the point.'),
    _field('significance', 'Significance', RecordFieldType.richText, 112),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'food',
      title: 'Food',
      order: 10,
      fieldIds: ['culture', 'ingredients', 'preparation'],
    ),
    RecordTemplateSection(
      id: 'food-place',
      title: 'Place at the table',
      order: 11,
      fieldIds: ['occasion', 'whoEatsIt', 'significance'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'associatedWith'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-culture-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The clothing
// ---------------------------------------------------------------------------

/// Something a people wears: who may wear it, when, and what wearing it says.
///
/// The one type here that stays a child of `item`, because a cloak is a thing
/// you can own, steal, lose and be recognised by. The ten inherited fields
/// still answer for a garment — `itemType` is the kind, `materials` is the
/// fabric, `creator` is whoever made it — so this adds only what an item
/// cannot know: the social facts. Dress in fiction is almost never about
/// warmth.
final _clothing = RecordTypeDefinition(
  id: CultureRecordTypes.clothingTypeId,
  name: 'Clothing',
  description: 'Something a people wears: who may wear it, when, and what '
      'wearing it says.',
  icon: 'checkroom',
  categoryId: 'items',
  baseTypeId: 'item',
  fields: [
    // Mirrors `food.culture`: the sibling types both point back at the people
    // whose thing this is, with the same id and the same reference target.
    _field('culture', 'Culture', RecordFieldType.recordReference, 100,
        referenceTypeIds: [CultureRecordTypes.cultureTypeId]),
    _field('wornBy', 'Worn by', RecordFieldType.richText, 101,
        description: 'Which people — a rank, a trade, an age, a sex, the '
            'married. Not the individuals who own one; that is Known Users.'),
    // Same id and type as `food.occasion`, because it means the same thing.
    _field('occasion', 'Worn when', RecordFieldType.shortText, 102,
        description: 'Daily, at court, in mourning, once.'),
    _field('signals', 'What it says', RecordFieldType.richText, 110,
        description: 'Rank, mourning, marriage, guild, disgrace. A garment '
            'that says nothing is a prop rather than a costume.'),
    _field('forbiddenTo', 'Forbidden to', RecordFieldType.richText, 111,
        description: 'Who may not wear it, and what happens when they do. '
            'Sumptuary law is a plot waiting to be used.'),
    _field('construction', 'How it is made and worn', RecordFieldType.richText,
        120,
        description: 'Layers, fastenings, how long it takes — and whether a '
            'person can put it on without help, which decides who else is in '
            'the room.'),
    // Same id and type as `weapon.maintenance` and `armour.maintenance`:
    // shared vocabulary across systems, because upkeep means one thing.
    _field('maintenance', 'Upkeep', RecordFieldType.longText, 121,
        description: 'What keeps it wearable — washing, oiling, moths, a dye '
            'that runs — and who does that work.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'clothing-who',
      title: 'Worn by whom',
      order: 10,
      fieldIds: ['culture', 'wornBy', 'occasion'],
    ),
    RecordTemplateSection(
      id: 'clothing-meaning',
      title: 'What it says',
      order: 11,
      fieldIds: ['signals', 'forbiddenTo'],
    ),
    RecordTemplateSection(
      id: 'clothing-thing',
      title: 'The thing itself',
      order: 12,
      fieldIds: ['construction', 'maintenance'],
    ),
  ],
  // The `*`-typed Codex edges. `requires` carries a garment to the `material`
  // it is made from, the same edge Alchemy's preparation uses for the same
  // reason. The forward `owns` and `carries` edges are available too now that
  // #84 has landed, and are left to the author rather than suggested here.
  suggestedLinkTypeIds: const [
    'associatedWith',
    'requires',
    'createdBy',
    'ownedBy',
  ],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-culture-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
