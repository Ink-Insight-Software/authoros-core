/// The Species Evolution specialist system's record types.
///
/// ## Why this system owns no species
///
/// S6 was scoped as "Species Evolution & Biology", and by the time it was built
/// the biology half was already shipped. Bestiary (S7) declares `species` and
/// `race`, and its `species` carries biology, lifespan, reproduction,
/// intelligence, society, distribution and variants. One owner per record type
/// is enforced at registry construction, so this system could not have taken
/// them even if the overlap were desirable — and it is not. Two systems
/// deepening one type is how a field ends up defined twice and answered
/// differently.
///
/// What Bestiary does not model is **descent**: how one kind became another,
/// under what pressure, and what changed. `variants` is a list of names on a
/// species record, which is a note rather than a structure — it cannot say
/// which variant came first, what drove the split, or which pressure a trait
/// answers. That gap is this system.
///
/// ## The shape
///
///     general-lore
///     ├── lineage                 a line of descent, and where it branched
///     ├── adaptation              one trait, and the pressure that produced it
///     └── evolutionary-pressure   what the world did to make a kind change
///
/// Nothing here inherits from anything else, and nothing inherits from
/// `species`. A lineage is not a kind of species; it is a claim about several.
///
/// ## Referencing a type another system owns
///
/// `lineage.species` and `adaptation.species` point at Bestiary's `species`.
/// This is the first time a system references a record type another system
/// declares, so it is worth saying plainly that this is allowed and why: a
/// reference is not a claim. Ownership decides who may define a type's fields;
/// a reference only says a record points at another. Culture already references
/// `language` this way through the soft `culture.language` field it kept, and
/// nothing in the registry treats that as ownership.
///
/// The practical consequence is that enabling Evolution without Bestiary leaves
/// those references pointing at a type whose records an author has no specialist
/// surface for. That is a presentation matter, not a data one — the type
/// resolves either way, because both live in the same canonical registry — and
/// [SpecialistSystemDefinition.dependsOn] is advisory precisely so it can say
/// so without forcing anything on.
///
/// ## On the descent edge
///
/// Descent is a relationship, and the honest name for it would be
/// `descendedFrom`, which does not exist. `originatedFrom` does, and is
/// `*`-typed. This system uses it rather than adding a relationship type: every
/// system before this has added none and widened none, and a vocabulary change
/// is a decision about the shared model rather than part of declaring a system.
/// If descent later earns its own edge, this is the comment that should be
/// revisited.
library;

import 'record_types.dart';

class EvolutionRecordTypes {
  const EvolutionRecordTypes._();

  static const lineageTypeId = 'lineage';
  static const adaptationTypeId = 'adaptation';
  static const pressureTypeId = 'evolutionary-pressure';

  static const packId = 'authoros-evolution-system';

  /// Every type this system presents. All three are new; it takes nothing over.
  static const List<String> recordTypeIds = [
    lineageTypeId,
    adaptationTypeId,
    pressureTypeId,
  ];

  /// The type this system points at and deliberately does not own.
  ///
  /// Named so the boundary is assertable rather than remembered. Bestiary
  /// declares `species` and `race`; an over-claim here would not fail today, it
  /// would fail the next time both systems are constructed together.
  static const List<String> ownedByBestiary = ['species', 'race'];

  /// Read off `lineage`'s own `suggestedLinkTypeIds`. Both already exist and
  /// both are `*`-typed, so no relationship is added and none is widened.
  static const List<String> connectionTypeIds = [
    'originatedFrom',
    'relatedTo',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _lineage,
    _adaptation,
    _pressure,
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

const _pressureKind = RecordOptionSet(
  id: 'evolutionary-pressure-kind',
  name: 'Kind of pressure',
  description: 'What is doing the selecting.',
  values: [
    'Climate',
    'Predation',
    'Competition',
    'Scarcity',
    'Disease',
    'Isolation',
    'Sexual selection',
    'Domestication',
    'Magical',
    'Deliberate breeding',
    'Divine intervention',
  ],
);

const _adaptationKind = RecordOptionSet(
  id: 'adaptation-kind',
  name: 'Kind of change',
  values: [
    'Anatomical',
    'Physiological',
    'Behavioural',
    'Sensory',
    'Reproductive',
    'Social',
    'Metabolic',
    'Camouflage',
    'Defensive',
  ],
);

const _divergence = RecordOptionSet(
  id: 'lineage-divergence',
  name: 'Divergence',
  description: 'How far the branch has travelled from its parent.',
  values: [
    'Variant',
    'Subspecies',
    'Distinct species',
    'Separate genus',
    'Unrecognisable',
    'Convergent',
  ],
);

// ---------------------------------------------------------------------------
// The lineage
// ---------------------------------------------------------------------------

/// A line of descent: what came from what, and where it branched.
///
/// Deliberately a record rather than a field on `species`, because a lineage is
/// a claim about *several* species and belongs to none of them. Putting it on
/// one would make the parent the owner of a fact the child equally holds.
final _lineage = RecordTypeDefinition(
  id: EvolutionRecordTypes.lineageTypeId,
  name: 'Lineage',
  description: 'A line of descent: what came from what, and what changed.',
  icon: 'account_tree',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  optionSets: const [_divergence],
  fields: [
    _field('species', 'Species', RecordFieldType.recordReference, 90,
        referenceTypeIds: const ['species'],
        description: 'The kind this line arrives at. Declared by Bestiary; '
            'this system points at it and does not own it.',
        quickCreateVisible: true),
    _field(
        'descendedFrom', 'Descended from', RecordFieldType.recordReference, 91,
        referenceTypeIds: const ['species'],
        description: 'The kind it came from, if the world remembers.',
        quickCreateVisible: true),
    _field('divergence', 'Divergence', RecordFieldType.singleChoice, 92,
        optionSetId: 'lineage-divergence', allowCustomValues: true),
    _field('branchedWhen', 'When it branched', RecordFieldType.shortText, 100,
        description: 'However the world counts time.'),
    _field('branchedWhere', 'Where it branched',
        RecordFieldType.recordReference, 101,
        referenceTypeIds: const ['location']),
    _field('cause', 'What drove it', RecordFieldType.richText, 102,
        description: 'The short version. Pressures get their own records.'),
    _field('changes', 'What changed', RecordFieldType.richText, 110),
    _field('intermediates', 'Intermediate forms', RecordFieldType.list, 111,
        searchable: false),
    _field('evidence', 'Evidence', RecordFieldType.richText, 120,
        description: 'What survives that shows this happened — and who '
            'disputes it.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'lineage-line',
      title: 'The line',
      order: 9,
      fieldIds: ['species', 'descendedFrom', 'divergence'],
    ),
    RecordTemplateSection(
      id: 'lineage-branch',
      title: 'The branch',
      order: 10,
      fieldIds: ['branchedWhen', 'branchedWhere', 'cause'],
    ),
    RecordTemplateSection(
      id: 'lineage-record',
      title: 'What is known',
      order: 11,
      fieldIds: ['changes', 'intermediates', 'evidence'],
    ),
  ],
  suggestedLinkTypeIds: EvolutionRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EvolutionRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The adaptation
// ---------------------------------------------------------------------------

/// One trait, and the pressure it answers.
///
/// The pairing is the point. A trait recorded without its pressure is a
/// description; recorded with one it is a cause, and an author can ask what
/// happens to the trait when the pressure lifts.
final _adaptation = RecordTypeDefinition(
  id: EvolutionRecordTypes.adaptationTypeId,
  name: 'Adaptation',
  description: 'One trait, the pressure that produced it, and its cost.',
  icon: 'biotech',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  optionSets: const [_adaptationKind],
  fields: [
    _field('species', 'Species', RecordFieldType.recordReference, 90,
        referenceTypeIds: const ['species'], quickCreateVisible: true),
    _field('kind', 'Kind of change', RecordFieldType.singleChoice, 91,
        optionSetId: 'adaptation-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('pressure', 'Answers', RecordFieldType.recordReference, 92,
        referenceTypeIds: [EvolutionRecordTypes.pressureTypeId],
        description: 'The pressure this trait is a response to.'),
    _field('trait', 'The trait', RecordFieldType.richText, 100),
    _field('advantage', 'What it buys', RecordFieldType.richText, 101),
    _field('cost', 'What it costs', RecordFieldType.richText, 102,
        description: 'Every adaptation is paid for somewhere.'),
    _field('vestigial', 'If the pressure lifted', RecordFieldType.richText, 110,
        description: 'What becomes of it when the reason is gone.',
        searchable: false),
    _field('observedIn', 'Observed in', RecordFieldType.list, 111,
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'adaptation-subject',
      title: 'Subject',
      order: 9,
      fieldIds: ['species', 'kind', 'pressure'],
    ),
    RecordTemplateSection(
      id: 'adaptation-trade',
      title: 'The trade',
      order: 10,
      fieldIds: ['trait', 'advantage', 'cost'],
    ),
    RecordTemplateSection(
      id: 'adaptation-after',
      title: 'Afterwards',
      order: 11,
      fieldIds: ['vestigial', 'observedIn'],
    ),
  ],
  suggestedLinkTypeIds: const ['originatedFrom', 'relatedTo'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EvolutionRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The pressure
// ---------------------------------------------------------------------------

/// What the world did that made a kind change.
///
/// Its own record because one pressure shapes many species, and an author who
/// writes a long winter wants every adaptation that answers it to point at the
/// same winter.
final _pressure = RecordTypeDefinition(
  id: EvolutionRecordTypes.pressureTypeId,
  name: 'Evolutionary Pressure',
  description: 'A force that made kinds change, and what it selected for.',
  icon: 'filter_alt',
  categoryId: 'creatures',
  baseTypeId: 'general-lore',
  optionSets: const [_pressureKind],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 90,
        optionSetId: 'evolutionary-pressure-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('where', 'Where', RecordFieldType.recordReference, 91,
        referenceTypeIds: const ['location']),
    _field('when', 'When', RecordFieldType.shortText, 92,
        description: 'However the world counts time.'),
    _field('cause', 'What caused it', RecordFieldType.richText, 100),
    _field('selectsFor', 'Selects for', RecordFieldType.richText, 101,
        description: 'What survives it, and what does not.'),
    _field('severity', 'Severity', RecordFieldType.longText, 102),
    _field('duration', 'Duration', RecordFieldType.shortText, 110,
        description: 'A pressure that lifts and one that never does produce '
            'different worlds.'),
    _field('aftermath', 'Aftermath', RecordFieldType.richText, 111,
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'pressure-what',
      title: 'The pressure',
      order: 9,
      fieldIds: ['kind', 'where', 'when'],
    ),
    RecordTemplateSection(
      id: 'pressure-effect',
      title: 'Effect',
      order: 10,
      fieldIds: ['cause', 'selectsFor', 'severity'],
    ),
    RecordTemplateSection(
      id: 'pressure-after',
      title: 'Afterwards',
      order: 11,
      fieldIds: ['duration', 'aftermath'],
    ),
  ],
  suggestedLinkTypeIds: const ['relatedTo'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: EvolutionRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
