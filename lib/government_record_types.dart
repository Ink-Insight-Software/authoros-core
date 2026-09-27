/// The Government & Political specialist system's record types.
///
/// The same mechanism the other systems use: ordinary [RecordTypeDefinition]s
/// in the canonical registry, carrying a pack of their own, named by a manifest
/// that defines nothing.
///
/// ## What was here before
///
/// `government`, `political-system` and `law` existed the way `language` did
/// before S1 — entries in the `_children` map, which produce a name, a category,
/// `baseTypeId: 'general-lore'` and **no fields at all**. An author could make a
/// record called The Ashen Senate and then had a title and a blank page. The S0
/// audit recorded this system's gap as "fields", and the field pack below is the
/// larger half of the work.
///
/// ## The shape
///
///     general-lore
///     ├── government         the governing body: its form, powers and claim
///     ├── political-system   the form of rule as an idea, not a body
///     ├── law                one law, and what happens when it is broken
///     ├── political-office   a post that carries power, and who holds it
///     └── treaty             an agreement between polities
///
/// Nothing here inherits from anything else, and that is deliberate rather than
/// an oversight. A law is not a kind of government, an office is not a small
/// government, and a treaty is not a government either — they are things a
/// government has, makes and signs. #83 removed `magic-ability`'s inheritance
/// from `magic-system` for borrowing a field list it did not deserve; the same
/// test applied here says these five are siblings.
///
/// `government` and `political-system` are separate for the same reason. A
/// political system is the abstract form — monarchy, republic, theocracy — and
/// a government is the particular body claiming to embody it. A world can hold
/// three governments of one system, or one government whose system changed
/// while the body persisted.
///
/// ## What this system deliberately does not claim
///
/// `faction` and its six children — `organisation`, `house`, `clan`, `guild`,
/// `company`, `military-unit` — stay unclaimed. A guild and a trading company
/// are not governmental, and one owner per record type is enforced at registry
/// construction, so claiming `faction` here would turn Economy (Wave 4) and
/// Bloodline (Wave 4) into startup failures rather than conversations.
///
/// `institution` is left alone for a subtler reason: it is genuinely ambiguous.
/// A parliament and a court are governmental, a bank and a university are not,
/// and a type claimed early on an ambiguous reading is a collision later. A
/// government can name an institution through a relationship without owning the
/// type, which costs nothing and keeps the decision open.
///
/// `rule` is too generic to belong to anyone — `magic-rule` and `grammar-rule`
/// already exist as the specific forms that matter.
///
/// ## Politics & Power's Phase 3 added three fields here, and all three are free
///
/// `branches` on `government`, and `successor` and `jurisdiction` on
/// `political-office`. The expansion needed the succession seam and found
/// `predecessors` with no mirror; completing a free pair is a free Write
/// enhancement, and selling the second half of one would be the manufactured
/// upgrade ADR-0017 forbids. **No field on any of these five types carries an
/// ownership marker**, and `politics_and_power_phase3_test.dart` asserts it:
/// what the expansion sells is four fields on `faction` and the reading across
/// all of them, not the political records themselves.
library;

import 'record_types.dart';

class GovernmentRecordTypes {
  const GovernmentRecordTypes._();

  static const governmentTypeId = 'government';
  static const politicalSystemTypeId = 'political-system';
  static const lawTypeId = 'law';
  static const officeTypeId = 'political-office';
  static const treatyTypeId = 'treaty';

  static const packId = 'authoros-government-system';

  /// Every type the Government system presents. The manifest names exactly
  /// these, and because the pack is dedicated, `conformanceIssues` fails if a
  /// definition carrying [packId] is missing from this list.
  static const List<String> recordTypeIds = [
    governmentTypeId,
    politicalSystemTypeId,
    lawTypeId,
    officeTypeId,
    treatyTypeId,
  ];

  /// Types this system could plausibly have claimed and deliberately does not.
  ///
  /// Named rather than merely omitted, so the reservation can be asserted the
  /// way Culture's is instead of relying on someone remembering the reasoning
  /// in the library comment.
  static const List<String> reservedForOtherSystems = [
    'faction',
    'organisation',
    'institution',
    'rule',
  ];

  /// The relationships the system presents.
  ///
  /// Read off `government`'s own `suggestedLinkTypeIds` rather than chosen
  /// here, the rule every system before this follows. All three already exist
  /// and all three are `*`-typed, so no relationship type is added and none is
  /// widened. `controls`, `alliedWith`, `enemyOf` and `memberOf` would each fit
  /// a political domain and are all narrowly typed today — widening them is a
  /// change to the shared relationship vocabulary, not part of declaring a
  /// system, so they are left alone.
  static const List<String> connectionTypeIds = [
    'governedBy',
    'ruledBy',
    'signed',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _government,
    _politicalSystem,
    _law,
    _office,
    _treaty,
  ];
}

/// Shared extension data, matching what every other Codex-facing type carries.
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

/// Declared once and referenced by id. The same form applies to a government
/// and to the political system it embodies, and two inline copies would drift
/// the first time one was edited.
const _form = RecordOptionSet(
  id: 'government-form',
  name: 'Form of rule',
  description: 'Where authority is held, and by how many.',
  values: [
    'Absolute monarchy',
    'Constitutional monarchy',
    'Republic',
    'Democracy',
    'Oligarchy',
    'Theocracy',
    'Autocracy',
    'Military junta',
    'Confederation',
    'Tribal council',
    'Merchant council',
    'Magocracy',
    'Occupied',
    'Stateless',
  ],
);

const _succession = RecordOptionSet(
  id: 'government-succession',
  name: 'Succession',
  description: 'How power passes from one holder to the next.',
  values: [
    'Hereditary',
    'Elective',
    'Appointed',
    'Seized',
    'Rotational',
    'Divine selection',
    'Drawn by lot',
    'Contested',
  ],
);

const _lawStatus = RecordOptionSet(
  id: 'law-status',
  name: 'Status',
  values: [
    'Proposed',
    'Enacted',
    'In force',
    'Suspended',
    'Repealed',
    'Unenforced',
    'Customary',
  ],
);

const _treatyStatus = RecordOptionSet(
  id: 'treaty-status',
  name: 'Status',
  values: [
    'Proposed',
    'Signed',
    'Ratified',
    'In force',
    'Violated',
    'Lapsed',
    'Renounced',
    'Secret',
  ],
);

// ---------------------------------------------------------------------------
// The government
// ---------------------------------------------------------------------------

/// A governing body: its form, the reach of its power, and the story it tells
/// about why it is entitled to hold it.
///
/// Every field is new; the previous definition had none, so nothing an existing
/// record carries is displaced.
final _government = RecordTypeDefinition(
  id: GovernmentRecordTypes.governmentTypeId,
  name: 'Government',
  description: 'A governing body: its form, its powers and its claim to them.',
  icon: 'account_balance',
  categoryId: 'factions',
  baseTypeId: 'general-lore',
  optionSets: const [_form, _succession],
  fields: [
    _field('form', 'Form of rule', RecordFieldType.singleChoice, 100,
        optionSetId: 'government-form',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('politicalSystem', 'Political system',
        RecordFieldType.recordReference, 101,
        referenceTypeIds: [GovernmentRecordTypes.politicalSystemTypeId],
        description: 'The form as an idea. A body and its system can diverge.',
        quickCreateVisible: true),
    _field('seat', 'Seat of power', RecordFieldType.recordReference, 102,
        referenceTypeIds: const ['location'],
        description: 'Where it sits, which is not always where it rules.'),
    _field('territory', 'Territory', RecordFieldType.longText, 103,
        description: 'What it claims, which is not always what it holds.'),
    _field('branches', 'Branches', RecordFieldType.list, 104,
        description: 'The bodies it governs through — a senate, a court, a '
            'ministry. Each can be a record of its own; this is the list that '
            'says the body has parts.'),
    _field('succession', 'Succession', RecordFieldType.singleChoice, 110,
        optionSetId: 'government-succession', allowCustomValues: true),
    _field('legitimacy', 'Claim to rule', RecordFieldType.richText, 111,
        description: 'Why the governed accept it — or are made to.'),
    _field('powers', 'Powers', RecordFieldType.richText, 112,
        description: 'What it may do that no one else may.'),
    _field('limits', 'Limits', RecordFieldType.richText, 113,
        description: 'What it may not do, and who enforces that.'),
    _field('revenue', 'Revenue', RecordFieldType.longText, 120,
        description: 'What pays for it. Follow the money and the plot follows.',
        searchable: false),
    _field('enforcement', 'Enforcement', RecordFieldType.richText, 121,
        description: 'Who carries out its will, and how willingly.'),
    _field('opposition', 'Opposition', RecordFieldType.richText, 122,
        description:
            'Who wants it gone, and what they would put in its place.'),
    _field('history', 'History', RecordFieldType.richText, 130),
    _field('stability', 'Stability', RecordFieldType.richText, 131,
        description: 'What would bring it down, and how close that is.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'government-shape',
      title: 'Shape',
      order: 10,
      fieldIds: ['form', 'politicalSystem', 'seat', 'territory', 'branches'],
    ),
    RecordTemplateSection(
      id: 'government-authority',
      title: 'Authority',
      order: 11,
      fieldIds: ['succession', 'legitimacy', 'powers', 'limits'],
    ),
    RecordTemplateSection(
      id: 'government-machinery',
      title: 'Machinery',
      order: 12,
      fieldIds: ['revenue', 'enforcement', 'opposition'],
    ),
    RecordTemplateSection(
      id: 'government-standing',
      title: 'Standing',
      order: 13,
      fieldIds: ['history', 'stability'],
    ),
  ],
  suggestedLinkTypeIds: GovernmentRecordTypes.connectionTypeIds,
  templateVersion: 3,
  builtIn: true,
  sourcePackId: GovernmentRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The political system
// ---------------------------------------------------------------------------

/// The form of rule as an idea rather than a body.
///
/// Separate from `government` because a world can hold three governments of one
/// system, and one government whose system changed while the body persisted.
final _politicalSystem = RecordTypeDefinition(
  id: GovernmentRecordTypes.politicalSystemTypeId,
  name: 'Political System',
  description: 'A form of rule: how power is meant to be held and passed on.',
  icon: 'gavel',
  categoryId: 'factions',
  baseTypeId: 'general-lore',
  optionSets: const [_form],
  fields: [
    _field('form', 'Form', RecordFieldType.singleChoice, 100,
        optionSetId: 'government-form',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('principle', 'Founding principle', RecordFieldType.richText, 101,
        description: 'What it says power is for.'),
    _field('whoDecides', 'Who decides', RecordFieldType.longText, 102,
        description: 'Who holds a say, and who is excluded from one.'),
    _field('checks', 'Checks', RecordFieldType.richText, 110,
        description: 'What is meant to stop power concentrating.'),
    _field('failureMode', 'How it fails', RecordFieldType.richText, 111,
        description: 'Every system fails in its own characteristic way.'),
    _field('adoptedBy', 'Adopted by', RecordFieldType.list, 120,
        description: 'Governments that claim this form.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'political-system-idea',
      title: 'The idea',
      order: 10,
      fieldIds: ['form', 'principle', 'whoDecides'],
    ),
    RecordTemplateSection(
      id: 'political-system-practice',
      title: 'In practice',
      order: 11,
      fieldIds: ['checks', 'failureMode', 'adoptedBy'],
    ),
  ],
  suggestedLinkTypeIds: const ['governedBy', 'ruledBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: GovernmentRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The law
// ---------------------------------------------------------------------------

/// One law, what it forbids or requires, and what happens when it is broken.
///
/// The same shape as `magic-rule` and `grammar-rule`: a system described in
/// prose on the parent, plus the individual rules an author looks up,
/// contradicts and breaks.
final _law = RecordTypeDefinition(
  id: GovernmentRecordTypes.lawTypeId,
  name: 'Law',
  description: 'One law: what it demands, and what breaking it costs.',
  icon: 'balance',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_lawStatus],
  fields: [
    _field('government', 'Enacted by', RecordFieldType.recordReference, 90,
        referenceTypeIds: [GovernmentRecordTypes.governmentTypeId],
        quickCreateVisible: true),
    _field('status', 'Status', RecordFieldType.singleChoice, 91,
        optionSetId: 'law-status',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('statement', 'The law', RecordFieldType.richText, 100,
        description: 'Stated as an author would have a herald read it.'),
    _field('appliesTo', 'Applies to', RecordFieldType.longText, 101,
        description: 'Who is bound. Who is exempt is usually the story.'),
    _field('penalty', 'Penalty', RecordFieldType.richText, 110),
    _field('enforcement', 'Enforced by', RecordFieldType.longText, 111,
        description: 'A law nobody enforces is a different law.'),
    _field('exceptions', 'Exceptions', RecordFieldType.richText, 112,
        searchable: false),
    _field('origin', 'Why it exists', RecordFieldType.richText, 120,
        description: 'Laws are written because something happened.',
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'law-scope',
      title: 'Scope',
      order: 9,
      fieldIds: ['government', 'status'],
    ),
    RecordTemplateSection(
      id: 'law-text',
      title: 'The law',
      order: 10,
      fieldIds: ['statement', 'appliesTo'],
    ),
    RecordTemplateSection(
      id: 'law-teeth',
      title: 'Teeth',
      order: 11,
      fieldIds: ['penalty', 'enforcement', 'exceptions', 'origin'],
    ),
  ],
  suggestedLinkTypeIds: const ['governedBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: GovernmentRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The political office
// ---------------------------------------------------------------------------

/// A post that carries power, distinct from whoever currently holds it.
///
/// New in this phase, and the missing middle: without it an author has a
/// government and a cast, and nowhere to say that the office outlives the
/// person, or that two people claim the same chair.
///
/// Named `political-office` rather than `title` on purpose. A hereditary title
/// is a Bloodline concern (Wave 4), and a name broad enough to cover both would
/// have to be claimed by one of them and denied to the other.
final _office = RecordTypeDefinition(
  id: GovernmentRecordTypes.officeTypeId,
  name: 'Political Office',
  description: 'A post that carries power, and who holds it.',
  icon: 'chair',
  categoryId: 'factions',
  baseTypeId: 'general-lore',
  optionSets: const [_succession],
  fields: [
    _field('government', 'Within', RecordFieldType.recordReference, 90,
        referenceTypeIds: [GovernmentRecordTypes.governmentTypeId],
        quickCreateVisible: true),
    _field('holder', 'Current holder', RecordFieldType.recordReference, 91,
        referenceTypeIds: const ['character'],
        description: 'The office outlives the holder; keep them apart.',
        quickCreateVisible: true),
    _field('selection', 'How it is filled', RecordFieldType.singleChoice, 100,
        optionSetId: 'government-succession', allowCustomValues: true),
    _field('term', 'Term', RecordFieldType.shortText, 101,
        description: 'For life, for a season, until someone objects.'),
    _field('authority', 'Authority', RecordFieldType.richText, 110,
        description: 'What the chair lets its occupant do.'),
    _field('obligations', 'Obligations', RecordFieldType.richText, 111),
    _field('jurisdiction', 'Jurisdiction', RecordFieldType.longText, 112,
        description: 'Where the authority reaches. A government claims '
            'territory; an office claims a remit inside it.'),
    _field('predecessors', 'Predecessors', RecordFieldType.list, 120,
        searchable: false),
    // The mirror of `predecessors`, and **free**, like it. An office that can
    // say who held it and not who is next has half a succession, and Politics
    // & Power's Phase 4 line of succession has to read the chain from
    // somewhere. Selling the second half of a field pair the free type already
    // ships would be the kind of manufactured upgrade ADR-0017 forbids.
    _field('successor', 'Designated successor', RecordFieldType.recordReference,
        121,
        referenceTypeIds: const ['character'],
        description: 'Who is next, if that is settled. Often it is not, and '
            '"Contested by" is the more honest field.'),
    _field('contested', 'Contested by', RecordFieldType.longText, 122,
        description: 'Rival claims are where offices become plots.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'office-place',
      title: 'The post',
      order: 9,
      fieldIds: ['government', 'holder'],
    ),
    RecordTemplateSection(
      id: 'office-tenure',
      title: 'Tenure',
      order: 10,
      fieldIds: ['selection', 'term'],
    ),
    RecordTemplateSection(
      id: 'office-power',
      title: 'Power',
      order: 11,
      fieldIds: ['authority', 'obligations', 'jurisdiction'],
    ),
    RecordTemplateSection(
      id: 'office-succession',
      title: 'Succession',
      order: 12,
      fieldIds: ['predecessors', 'successor', 'contested'],
    ),
  ],
  suggestedLinkTypeIds: const ['ruledBy', 'governedBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: GovernmentRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The treaty
// ---------------------------------------------------------------------------

/// An agreement between polities, and the terms someone will break.
///
/// New in this phase. `signed` already exists as a `*`-typed relationship, so a
/// treaty connects to its signatories through the canonical vocabulary rather
/// than through a list of names.
final _treaty = RecordTypeDefinition(
  id: GovernmentRecordTypes.treatyTypeId,
  name: 'Treaty',
  description: 'An agreement between powers, and the terms that will break.',
  icon: 'handshake',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_treatyStatus],
  fields: [
    _field('status', 'Status', RecordFieldType.singleChoice, 90,
        optionSetId: 'treaty-status',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('parties', 'Parties', RecordFieldType.list, 91,
        description: 'Who is bound by it.', quickCreateVisible: true),
    _field('signedAt', 'Signed', RecordFieldType.shortText, 92,
        description: 'When, and where — both tend to matter later.'),
    _field('terms', 'Terms', RecordFieldType.richText, 100),
    _field('secretTerms', 'Secret terms', RecordFieldType.richText, 101,
        description: 'What the parties agreed and did not publish.',
        searchable: false),
    _field('duration', 'Duration', RecordFieldType.shortText, 110),
    _field('breachTerms', 'On breach', RecordFieldType.richText, 111,
        description: 'What the treaty says happens. Rarely what happens.'),
    _field('history', 'History', RecordFieldType.richText, 120,
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'treaty-standing',
      title: 'Standing',
      order: 9,
      fieldIds: ['status', 'parties', 'signedAt'],
    ),
    RecordTemplateSection(
      id: 'treaty-terms',
      title: 'Terms',
      order: 10,
      fieldIds: ['terms', 'secretTerms'],
    ),
    RecordTemplateSection(
      id: 'treaty-life',
      title: 'Life of it',
      order: 11,
      fieldIds: ['duration', 'breachTerms', 'history'],
    ),
  ],
  suggestedLinkTypeIds: const ['signed', 'governedBy'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: GovernmentRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
