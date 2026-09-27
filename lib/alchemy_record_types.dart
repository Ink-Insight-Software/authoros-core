/// The Alchemy specialist system's record types.
///
/// The first system in the programme that had to **invent** its types. Every
/// system before it deepened something already in the tree — `spell`, `deity`,
/// `weapon`, `concept`, `house` all existed as bare entries before their wave
/// touched them. Alchemy has no such entry: a survey of the registry finds no
/// `potion`, no `recipe`, no `reagent`, no `substance`, no `process`. An author
/// writing an apothecary had `item` and a blank page.
///
/// That makes the discipline harder rather than easier, because nothing
/// constrains invention. So the same test Language set is applied to every
/// candidate, and applied more strictly here than anywhere:
///
///   * is the thing **shared between** records, or does it belong to one?
///   * is it **unbounded**, or does an author write down three of them?
///
/// Two survive. Everything else is in [AlchemyRecordTypes.declinedTypes] with
/// the reason, so a later wave inherits the argument rather than reopening it.
///
/// ## Why `reagent` is not here — and this is the whole shape of the system
///
/// A reagent passes both halves of the test cleanly. Mercury appears in fifty
/// formulas, and an alchemy's ingredient list is unbounded the way a lexicon
/// is. On the test alone it should be a type.
///
/// It is not one, because **`material` already is**. `material` landed as a
/// foundation type owned by no system, and it carries exactly what a reagent
/// needs — appearance, properties, where it is found, who works it, rarity,
/// worth, history, and `substitutes`, which is the alchemist's substitution
/// list under another name. Declaring `reagent` would have produced a second
/// record type for the same idea, split an author's substances into two lists
/// depending on whether they happened to end up in a flask, and made the
/// Weapons author's iron and the Alchemy author's iron different records.
///
/// So Alchemy **uses** `material` and does **not** claim it. That distinction
/// is now the seventh application of the declined-base-type rule, and the
/// argument is the same one as `item` and `general-lore`: other systems'
/// authors need somewhere to write down a substance whether or not Alchemy is
/// switched on, and `material` is that somewhere. A test asserts it stays
/// unclaimed and stays offered with every system off.
///
/// ## `preparation` inherits `item`, and the claim is true
///
/// A made substance is a thing you can carry, steal, hide and be found with.
/// So `preparation` is a child of `item` and keeps all ten inherited fields —
/// which is not a formality, because two of them do real work here:
///
///     itemType    the kind: potion, poison, tincture, salve, philter
///     materials   the ingredient list
///
/// Alchemy therefore adds **no second kind field and no second ingredient
/// list**, on the same discipline that kept Lore from adding a second
/// `knowledgeStatus`. The ingredients an author writes into `materials` are
/// the same field the same author fills in for a sword's steel, and the day
/// those free-text lists become references to `material` records, a
/// preparation comes along for free. Both facts are asserted in the tests,
/// because a later hand adding `ingredients` would quietly fork the data.
///
///     general-lore
///     ├── item                  the ten generic fields, unchanged
///     │   └── preparation       how it is made, what it does, how it fails
///     ├── material              used, never claimed — the reagents live here
///     └── alchemical-process    the operation itself
///
/// ## Why the process is a type and not a field on the preparation
///
/// This is the one invention that had to justify itself hardest, because
/// "distillation" looks like a step in a recipe, and steps are fields.
///
/// It survives on a fact about the domain: **a process is not always in
/// service of a preparation**. Transmuting lead yields a `material`. Refining
/// a corpse yields a `character` problem. The Great Work, in most fiction that
/// uses it, yields nothing you can bottle at all. A field on `preparation`
/// cannot hold an operation that produces no preparation. And the same
/// operation is shared across dozens of workings, which is the other half of
/// the test.
///
/// ## What it costs to be wrong, and where the fields put the pressure
///
/// Alchemy's dramatic engine is failure, not success — a potion that works is
/// a plot device, a potion that half-works is a plot. So `preparation` asks
/// for `failure` and `detection` and `keeping`, and `alchemical-process` asks
/// for `hazards` and `limits`. These are the fields an author is most likely
/// to skip and most likely to need, and they are the reason this system is
/// not a list of magic items.
///
/// ## Relationships
///
/// Both types ship on the `*`-typed Codex edges, which are permitted for every
/// type including ones invented today. No relationship type is added and none
/// is widened. In particular `requires` carries preparation → material, which
/// is the edge the system actually turns on, and `practices` carries a
/// character to a process.
///
/// The exact-match permission gap (#84) bites here exactly as it bites
/// Weapons: `character -carries-> preparation` is rejected because `carries`
/// names `item`, `artefact` and `weapon` by hand rather than resolving through
/// inheritance. It is **not** worked around by adding `preparation` to that
/// list — hand-adding is the cause of #84, not the cure. The wildcard
/// `ownedBy` says the same thing in the direction that works, and the forward
/// edge arrives the day #84 lands with no change to this file.
///
/// ## Compatibility
///
/// Both types are new, so no record anywhere is written under an older
/// definition of them and nothing can be orphaned. Nothing existing is
/// re-parented, no field is removed, and no field this system declares is
/// required. `item`, `material` and `general-lore` are untouched.
library;

import 'record_types.dart';

class AlchemyRecordTypes {
  const AlchemyRecordTypes._();

  static const packId = 'authoros-alchemy-system';

  static const preparationTypeId = 'preparation';
  static const processTypeId = 'alchemical-process';

  /// Every type the Alchemy system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [preparationTypeId, processTypeId];

  /// The base types Alchemy uses and deliberately does not claim.
  ///
  /// `item` because a preparation inherits it, `material` because the reagents
  /// live there and every other system's author needs it, `general-lore`
  /// because it is where anything at all gets written down. Claiming any of
  /// the three would make a foundation of the tree conditional on a toggle.
  static const List<String> usedButUnclaimed = [
    'item',
    'material',
    'general-lore',
  ];

  /// The ten `item` field ids `preparation` inherits and keeps unchanged.
  ///
  /// Named because the compatibility guarantee depends on them: nothing in
  /// this file may shadow one of these with a different type.
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

  /// The inherited field that carries the ingredient list.
  ///
  /// Alchemy adds no second one. Asserted, because adding `ingredients` later
  /// would fork an author's substances into two places.
  static const String ingredientsFieldId = 'materials';

  /// The inherited field that carries the kind — potion, poison, salve.
  ///
  /// Alchemy adds no second one, for the same reason.
  static const String kindFieldId = 'itemType';

  /// The seven `general-lore` ids `alchemical-process` inherits unchanged.
  static const List<String> inheritedLoreFieldIds = [
    'name',
    'aliases',
    'summary',
    'description',
    'notes',
    'knowledgeStatus',
    'sourceReferences',
  ];

  /// Types considered and declined, with the reason.
  ///
  /// The longest such list in the programme, which is the point: a system with
  /// nothing to inherit is the one most tempted to invent, so the record of
  /// what it refused to invent is the part worth keeping.
  static const Map<String, String> declinedTypes = {
    'reagent': 'material already models it, down to the substitutes list',
    'substance': 'material, again — a second name for the same record',
    'element': 'a material whose kind is named in materialType',
    'recipe': 'preparation.method is the recipe; a recipe with no product is '
        'a preparation nobody has brewed yet',
    'formula': 'the same record as recipe, under an older name',
    'potion': 'a kind of preparation, not a type — itemType names it',
    'poison': 'a kind of preparation; splitting it would ask which list a '
        'sleeping draught belongs in',
    'elixir': 'a kind of preparation',
    'remedy': 'a kind of preparation',
    'laboratory': 'a place — location, building and room already model it',
    'apparatus': 'an item; what a working needs is preparation.apparatus',
    'alchemist': 'a person — character, person and profession model it, and '
        'who made a thing is item.creator plus the edges',
    'alchemical-tradition': 'a body of people; institution, faction and '
        'culture model that, and a tradition is those with edges to the '
        'processes it teaches',
    'transmutation': 'an instance of alchemical-process, not a peer of it',
  };

  /// The edges each type suggests, read off the definitions below rather than
  /// chosen twice.
  static const List<String> connectionTypeIds = [
    'requires',
    'createdBy',
    'usedBy',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _preparation,
    _process,
  ];
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

// ---------------------------------------------------------------------------
// The preparation
// ---------------------------------------------------------------------------

/// A made substance: how it is made, what it does, and what it does when it
/// goes wrong.
///
/// A child of `item`, because a phial is a thing you can carry and lose. The
/// kind goes in the inherited `itemType` and the ingredients in the inherited
/// `materials`, so everything declared here is what an item cannot know: the
/// working, the dose, and the several ways this can turn on the person holding
/// it.
final _preparation = RecordTypeDefinition(
  id: AlchemyRecordTypes.preparationTypeId,
  name: 'Preparation',
  description: 'A made substance — potion, poison, tincture, salve, philter: '
      'how it is made, what it does, and how it fails.',
  icon: 'science',
  categoryId: 'items',
  baseTypeId: 'item',
  fields: [
    _field('form', 'Form', RecordFieldType.shortText, 100,
        description: 'Liquid, powder, paste, vapour, crystal, salve — the '
            'state it is in. What it is for goes in Type.'),
    _field('method', 'Method', RecordFieldType.richText, 101,
        description: 'The working itself, in order. This is the recipe; there '
            'is no separate record for one.'),
    _field('apparatus', 'Apparatus', RecordFieldType.list, 102,
        description: 'What the working needs — an alembic, a copper vessel, '
            'running water, a night without a moon.'),
    _field('workingTime', 'Time to make', RecordFieldType.shortText, 103,
        description: 'How long it takes, which is how long someone is '
            'somewhere they can be found.'),
    _field('yield', 'Yield', RecordFieldType.shortText, 104,
        description: 'What one working makes. A single dose and a barrel are '
            'different stories.'),
    _field('dose', 'Dose', RecordFieldType.shortText, 110,
        description: 'How much, how taken, how often — and what too much '
            'does.'),
    _field('onset', 'Onset and duration', RecordFieldType.shortText, 111,
        description: 'How long before it acts, and how long it lasts. Both '
            'are timing, and timing is plot.'),
    _field('aftereffects', 'Aftereffects', RecordFieldType.richText, 112,
        description: 'What it costs when it works as intended. A cure with no '
            'price is a device.'),
    _field('antidote', 'Counter', RecordFieldType.shortText, 113,
        description: 'What stops it, reverses it, or blunts it — and who '
            'knows that.'),
    _field('failure', 'When it fails', RecordFieldType.richText, 120,
        description: 'What a botched batch does, and what a stale one does. '
            'The field most likely to be skipped and most likely to be '
            'needed.'),
    _field('detection', 'Detection', RecordFieldType.richText, 121,
        description: 'Whether it can be tasted, smelled, seen or tested for. '
            'Half of every poison plot is here.'),
    _field('keeping', 'Keeping', RecordFieldType.shortText, 122,
        description: 'How long it stays good and how it has to be stored.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'preparation-making',
      title: 'Making',
      order: 10,
      fieldIds: ['form', 'method', 'apparatus', 'workingTime', 'yield'],
    ),
    RecordTemplateSection(
      id: 'preparation-taking',
      title: 'Taking it',
      order: 11,
      fieldIds: ['dose', 'onset', 'aftereffects', 'antidote'],
    ),
    RecordTemplateSection(
      id: 'preparation-trouble',
      title: 'Trouble',
      order: 12,
      fieldIds: ['failure', 'detection', 'keeping'],
    ),
  ],
  // The `*`-typed Codex edges, verified permitted for this type. `requires`
  // carries preparation -> material, which is the edge the system turns on.
  // The forward `carries` and `owns` edges name `item`, `artefact` and
  // `weapon` by hand and are unavailable under #84; they are deliberately not
  // hand-added to.
  suggestedLinkTypeIds: const [
    'requires',
    'createdBy',
    'usedBy',
    'ownedBy',
  ],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: AlchemyRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The process
// ---------------------------------------------------------------------------

/// An operation performed on matter: what it changes, what it takes, and what
/// it does to whoever gets it wrong.
///
/// A child of `general-lore` rather than of `technology`, which is bare and
/// would assert that every alchemical operation is a technology. Some are; the
/// Great Work is not, and the registry should not decide that for an author.
final _process = RecordTypeDefinition(
  id: AlchemyRecordTypes.processTypeId,
  name: 'Alchemical Process',
  description: 'An operation performed on matter: what it changes, what it '
      'takes, and what it does to whoever gets it wrong.',
  icon: 'transform',
  categoryId: 'technology',
  baseTypeId: 'general-lore',
  fields: [
    _field('operation', 'What it does', RecordFieldType.richText, 100,
        description: 'The change it works on matter, stated plainly — before '
            'anyone argues about what it means.'),
    _field('stages', 'Stages', RecordFieldType.list, 101,
        description: 'The steps in order, under whatever names the practice '
            'gives them.'),
    _field('conditions', 'Conditions', RecordFieldType.richText, 102,
        description: 'Heat, vessel, timing, hour, who has to be present.'),
    _field('inputs', 'What it takes', RecordFieldType.list, 110,
        description: 'The materials it consumes. Link them.'),
    _field('outputs', 'What it yields', RecordFieldType.list, 111,
        description: 'What comes out — which is not always something you can '
            'bottle, and is the reason this is a record rather than a step in '
            'a recipe.'),
    _field('signs', 'Signs', RecordFieldType.richText, 112,
        description: 'How you know it is working: the colours in order, the '
            'smell, the sound it makes at the turn.'),
    _field('hazards', 'Hazards', RecordFieldType.richText, 120,
        description: 'What it does to a careless practitioner, and how far '
            'that reaches beyond them.'),
    _field('mastery', 'What it takes to do', RecordFieldType.richText, 121,
        description: 'Training, tools, a temperament, a gift — and how long '
            'it takes to acquire.'),
    _field('limits', 'Limits', RecordFieldType.richText, 122,
        description: 'What it cannot do, whatever its practitioners claim. '
            'The claim and the limit are rarely the same.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'process-operation',
      title: 'The operation',
      order: 10,
      fieldIds: ['operation', 'stages', 'conditions'],
    ),
    RecordTemplateSection(
      id: 'process-matter',
      title: 'Matter',
      order: 11,
      fieldIds: ['inputs', 'outputs', 'signs'],
    ),
    RecordTemplateSection(
      id: 'process-cost',
      title: 'Cost and limit',
      order: 12,
      fieldIds: ['hazards', 'mastery', 'limits'],
    ),
  ],
  suggestedLinkTypeIds: const [
    'requires',
    'usedBy',
    'practices',
    'originatedFrom',
  ],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: AlchemyRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
