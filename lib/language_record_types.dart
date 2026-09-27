/// The Language specialist system's record types.
///
/// The same mechanism Magic and Religion use: ordinary [RecordTypeDefinition]s
/// in the canonical registry, carrying a pack of their own, named by a manifest
/// that defines nothing. Nothing here is a parallel model.
///
/// ## What was here before
///
/// `language` existed, and existed as almost nothing: one entry in the
/// `_children` map in `built_in_record_types.dart`, which produces a definition
/// with a name, a category, `baseTypeId: 'general-lore'` and **no fields at
/// all**. An author could make a record called Sindarin and then had a title, a
/// summary and a blank page. The S0 audit recorded the gap for this system as
/// "fields only", and that is the larger half of what follows.
///
/// The move out of `_children` is additive in the only direction that matters:
/// an existing `language` record gains editors it did not have and loses
/// nothing, because the old definition had nothing to lose. That is a weaker
/// change than Magic's re-parenting, which had to argue that removed fields
/// stayed readable; here no field is removed from anything.
///
/// ## The shape
///
///     general-lore
///     ├── language          a language: its people, sound, grammar and script
///     │   └── dialect       a variety of one language
///     ├── writing-system    a script — shared between languages, so its own thing
///     ├── lexicon-entry     one word or phrase
///     └── grammar-rule      one rule of one language
///
/// `dialect` inherits from `language`, and the edge is real rather than
/// convenient. A dialect has a phonology, a grammar, a region, a speaker
/// population and a status in exactly the way a language does — the two are the
/// same kind of thing at different scales, which is precisely the test #83
/// applied when it *removed* `magic-ability`'s inheritance from `magic-system`.
/// A spell is not a small magic system; a dialect is a variety of a language.
///
/// `writing-system` is deliberately not a field on `language`. The Latin script
/// carries hundreds of languages and a constructed world's script will carry
/// several; a value that one record owns cannot be shared, and the World Studio
/// template's flat `language.script` string is exactly the limitation this
/// replaces. Those old values are not touched and stay visible as author keys.
///
/// ## On lexicon size
///
/// A lexicon is the one place in this system that can grow without bound — a
/// developed conlang is thousands of entries, and every one of them is a record
/// in the same project and the same search index. The S0 audit named that risk
/// ("search index dilution") and named `searchable` as the control, so the
/// control is used here rather than described: on `lexicon-entry` only the term
/// and its gloss reach the index. Pronunciation, etymology and usage notes are
/// stored, versioned, exported and editable exactly like any other field, and
/// simply do not dilute a search for a character's name.
library;

import 'record_types.dart';

class LanguageRecordTypes {
  const LanguageRecordTypes._();

  static const languageTypeId = 'language';
  static const dialectTypeId = 'dialect';
  static const writingSystemTypeId = 'writing-system';
  static const lexiconEntryTypeId = 'lexicon-entry';
  static const grammarRuleTypeId = 'grammar-rule';

  /// Every type the Language system presents. The manifest names exactly these,
  /// and because the pack is dedicated, `conformanceIssues` fails if a
  /// definition carrying [packId] is missing from this list.
  static const List<String> recordTypeIds = [
    languageTypeId,
    dialectTypeId,
    writingSystemTypeId,
    lexiconEntryTypeId,
    grammarRuleTypeId,
  ];

  static const packId = 'authoros-language-system';

  /// The relationship types the system presents.
  ///
  /// Read off `language`'s own `suggestedLinkTypeIds` rather than chosen here,
  /// the rule Magic and Religion already follow. All three already exist in the
  /// canonical connection registry and all three are `*`-typed, so no
  /// relationship type is added and none needs widening.
  static const List<String> connectionTypeIds = [
    'speaks',
    'originatedFrom',
    'influences',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _language,
    _dialect,
    _writingSystem,
    _lexiconEntry,
    _grammarRule,
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

/// Declared once and referenced by id, which is what an option set is for: the
/// same vitality scale means the same thing on a language and on a dialect, and
/// two inline copies would drift the first time one of them was edited.
const _vitality = RecordOptionSet(
  id: 'language-vitality',
  name: 'Vitality',
  description: 'How alive a language is among the people who have it.',
  values: [
    'Thriving',
    'Living',
    'Shifting',
    'Endangered',
    'Moribund',
    'Extinct',
    'Revived',
    'Liturgical',
    'Constructed',
  ],
);

const _scriptType = RecordOptionSet(
  id: 'writing-system-type',
  name: 'Script type',
  description: 'What one written symbol stands for.',
  values: [
    'Alphabet',
    'Abjad',
    'Abugida',
    'Syllabary',
    'Logographic',
    'Mixed',
    'Pictographic',
    'Unwritten',
  ],
);

const _writingDirection = RecordOptionSet(
  id: 'writing-system-direction',
  name: 'Direction',
  values: [
    'Left to right',
    'Right to left',
    'Top to bottom',
    'Boustrophedon',
    'Varies',
  ],
);

const _wordClass = RecordOptionSet(
  id: 'lexicon-word-class',
  name: 'Word class',
  values: [
    'Noun',
    'Verb',
    'Adjective',
    'Adverb',
    'Pronoun',
    'Adposition',
    'Conjunction',
    'Determiner',
    'Numeral',
    'Particle',
    'Interjection',
    'Affix',
    'Phrase',
  ],
);

const _grammarDomain = RecordOptionSet(
  id: 'grammar-rule-domain',
  name: 'Domain',
  description: 'Which layer of the language the rule governs.',
  values: [
    'Phonology',
    'Morphology',
    'Syntax',
    'Orthography',
    'Semantics',
    'Pragmatics',
    'Register',
  ],
);

// ---------------------------------------------------------------------------
// The language
// ---------------------------------------------------------------------------

/// A language: who speaks it, how it sounds, how it works, how it is written.
///
/// Every field is new, because the previous definition had none. Nothing an
/// existing record carries is displaced.
final _language = RecordTypeDefinition(
  id: LanguageRecordTypes.languageTypeId,
  name: 'Language',
  description: 'A language: its speakers, its sound, its grammar and its '
      'script.',
  icon: 'translate',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  optionSets: const [_vitality],
  fields: [
    _field('family', 'Family', RecordFieldType.shortText, 100,
        description: 'The wider group it descends from, if any.',
        quickCreateVisible: true),
    _field('vitality', 'Vitality', RecordFieldType.singleChoice, 101,
        optionSetId: 'language-vitality',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('speakers', 'Speakers', RecordFieldType.longText, 102,
        description: 'Who speaks it, and how many.'),
    _field('region', 'Where it is spoken', RecordFieldType.longText, 103),
    _field('register', 'Registers', RecordFieldType.richText, 104,
        description: 'Formal, familiar, sacred, forbidden — and who may use '
            'which.'),
    _field('phonology', 'Sound', RecordFieldType.richText, 110,
        description: 'The inventory of sounds, and what may follow what.'),
    _field('prosody', 'Stress and tone', RecordFieldType.longText, 111),
    _field('grammarSummary', 'Grammar', RecordFieldType.richText, 112,
        description: 'The shape of the language in prose. Individual rules '
            'belong in Grammar Rule records.'),
    _field(
        'writingSystem', 'Writing system', RecordFieldType.recordReference, 120,
        referenceTypeIds: [LanguageRecordTypes.writingSystemTypeId],
        description: 'A script is shared between languages, so it is a record '
            'rather than a value here.'),
    _field('sampleText', 'Sample', RecordFieldType.richText, 121,
        description: 'A passage in the language, with a translation.'),
    _field('namingConventions', 'Naming', RecordFieldType.richText, 122,
        description: 'How people, places and things are named in it.'),
    _field('history', 'History', RecordFieldType.richText, 130),
    _field('influences', 'Influences', RecordFieldType.list, 131,
        description: 'Languages it borrowed from or was shaped by.'),
    _field('culturalRole', 'Cultural role', RecordFieldType.richText, 132,
        description: 'What speaking it, or not speaking it, means.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'language-people',
      title: 'People',
      order: 10,
      fieldIds: ['family', 'vitality', 'speakers', 'region', 'register'],
    ),
    RecordTemplateSection(
      id: 'language-form',
      title: 'Form',
      order: 11,
      fieldIds: ['phonology', 'prosody', 'grammarSummary'],
    ),
    RecordTemplateSection(
      id: 'language-written',
      title: 'Written and spoken',
      order: 12,
      fieldIds: ['writingSystem', 'sampleText', 'namingConventions'],
    ),
    RecordTemplateSection(
      id: 'language-world',
      title: 'In the world',
      order: 13,
      fieldIds: ['history', 'influences', 'culturalRole'],
    ),
  ],
  suggestedLinkTypeIds: LanguageRecordTypes.connectionTypeIds,
  templateVersion: 2,
  builtIn: true,
  sourcePackId: LanguageRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The dialect
// ---------------------------------------------------------------------------

/// A variety of one language.
///
/// Inherits from `language`, and the edge is the domain's rather than a field
/// list's: a dialect has a phonology, a grammar, a region, speakers and a
/// vitality in exactly the sense a language does. It adds only what makes it a
/// dialect rather than a language — the language it is a variety *of*, and how
/// far it has moved from it.
final _dialect = RecordTypeDefinition(
  id: LanguageRecordTypes.dialectTypeId,
  name: 'Dialect',
  description: 'A regional or social variety of a language.',
  icon: 'record_voice_over',
  categoryId: 'culture',
  baseTypeId: LanguageRecordTypes.languageTypeId,
  fields: [
    _field('parentLanguage', 'Language', RecordFieldType.recordReference, 90,
        referenceTypeIds: [LanguageRecordTypes.languageTypeId],
        description: 'The language this is a variety of.',
        quickCreateVisible: true),
    _field('divergence', 'How it differs', RecordFieldType.richText, 140,
        description: 'What a speaker of the standard would notice.'),
    _field('intelligibility', 'Mutual intelligibility',
        RecordFieldType.longText, 141,
        description: 'Whether speakers of each can understand the other, and '
            'in which direction.'),
    _field('prestige', 'Prestige', RecordFieldType.longText, 142,
        description: 'How it is regarded, and what that costs its speakers.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'dialect-variety',
      title: 'Variety',
      order: 9,
      fieldIds: ['parentLanguage'],
    ),
    RecordTemplateSection(
      id: 'dialect-difference',
      title: 'Difference',
      order: 14,
      fieldIds: ['divergence', 'intelligibility', 'prestige'],
    ),
  ],
  suggestedLinkTypeIds: LanguageRecordTypes.connectionTypeIds,
  templateVersion: 1,
  builtIn: true,
  sourcePackId: LanguageRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The writing system
// ---------------------------------------------------------------------------

/// A script: the symbols a language is written in.
///
/// Its own record rather than a field on `language`, because one script serves
/// many languages and a field cannot be shared. This is also what lets an
/// author say a language was rewritten in a new script without losing the old
/// one.
final _writingSystem = RecordTypeDefinition(
  id: LanguageRecordTypes.writingSystemTypeId,
  name: 'Writing System',
  description: 'A script: its symbols, its direction and who reads it.',
  icon: 'edit_note',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  optionSets: const [_scriptType, _writingDirection],
  fields: [
    _field('scriptType', 'Script type', RecordFieldType.singleChoice, 100,
        optionSetId: 'writing-system-type',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('direction', 'Direction', RecordFieldType.singleChoice, 101,
        optionSetId: 'writing-system-direction', allowCustomValues: true),
    _field('symbolCount', 'Number of symbols', RecordFieldType.number, 102),
    _field('symbols', 'Symbols', RecordFieldType.richText, 110,
        description: 'The characters themselves, and what each stands for.'),
    _field('orthography', 'Spelling rules', RecordFieldType.richText, 111,
        searchable: false),
    _field('materials', 'Written on', RecordFieldType.longText, 112,
        description: 'Stone, wax, paper, bark — what the script was shaped by.',
        searchable: false),
    _field('literacy', 'Who can read it', RecordFieldType.richText, 120,
        description: 'Literacy is rarely universal, and who is excluded is '
            'usually the interesting part.'),
    _field('origin', 'Origin', RecordFieldType.richText, 121),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'script-form',
      title: 'Form',
      order: 10,
      fieldIds: ['scriptType', 'direction', 'symbolCount', 'symbols'],
    ),
    RecordTemplateSection(
      id: 'script-use',
      title: 'Use',
      order: 11,
      fieldIds: ['orthography', 'materials', 'literacy', 'origin'],
    ),
  ],
  suggestedLinkTypeIds: const ['originatedFrom', 'influences'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: LanguageRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The lexicon entry
// ---------------------------------------------------------------------------

/// One word or phrase.
///
/// The type that can exist in the thousands, and the reason `searchable` is set
/// deliberately here rather than left at its default: `term` and `gloss` are
/// what an author searches a lexicon for, and indexing an etymology essay for
/// every word would bury every other record in the project.
final _lexiconEntry = RecordTypeDefinition(
  id: LanguageRecordTypes.lexiconEntryTypeId,
  name: 'Lexicon Entry',
  description: 'A word or phrase in a language.',
  icon: 'menu_book',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  optionSets: const [_wordClass],
  fields: [
    _field('term', 'Term', RecordFieldType.shortText, 90,
        description: 'The word as it is written in the language.',
        quickCreateVisible: true),
    _field('gloss', 'Meaning', RecordFieldType.shortText, 91,
        description: 'The shortest true translation.',
        quickCreateVisible: true),
    _field('language', 'Language', RecordFieldType.recordReference, 92,
        referenceTypeIds: [
          LanguageRecordTypes.languageTypeId,
          LanguageRecordTypes.dialectTypeId,
        ],
        quickCreateVisible: true),
    _field('wordClass', 'Word class', RecordFieldType.singleChoice, 100,
        optionSetId: 'lexicon-word-class', allowCustomValues: true),
    _field('pronunciation', 'Pronunciation', RecordFieldType.shortText, 101,
        description: 'However the author prefers to write it.',
        searchable: false),
    _field('inflections', 'Inflections', RecordFieldType.table, 102,
        searchable: false),
    _field('etymology', 'Etymology', RecordFieldType.richText, 110,
        searchable: false),
    _field('usage', 'Usage', RecordFieldType.richText, 111,
        description: 'Register, connotation, and who would never say it.',
        searchable: false),
    _field('examples', 'Examples', RecordFieldType.list, 112,
        searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'lexicon-entry',
      title: 'Entry',
      order: 9,
      fieldIds: ['term', 'gloss', 'language'],
    ),
    RecordTemplateSection(
      id: 'lexicon-form',
      title: 'Form',
      order: 10,
      fieldIds: ['wordClass', 'pronunciation', 'inflections'],
    ),
    RecordTemplateSection(
      id: 'lexicon-sense',
      title: 'Sense',
      order: 11,
      fieldIds: ['etymology', 'usage', 'examples'],
    ),
  ],
  suggestedLinkTypeIds: const ['originatedFrom', 'influences'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: LanguageRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The grammar rule
// ---------------------------------------------------------------------------

/// One rule of one language.
///
/// The same shape as `magic-rule`: a system described in prose on the parent
/// record, plus the individual rules an author actually wants to look up,
/// contradict and break.
final _grammarRule = RecordTypeDefinition(
  id: LanguageRecordTypes.grammarRuleTypeId,
  name: 'Grammar Rule',
  description: 'One rule of a language, and what breaks it.',
  icon: 'rule',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  optionSets: const [_grammarDomain],
  fields: [
    _field('language', 'Language', RecordFieldType.recordReference, 90,
        referenceTypeIds: [
          LanguageRecordTypes.languageTypeId,
          LanguageRecordTypes.dialectTypeId,
        ],
        quickCreateVisible: true),
    _field('domain', 'Domain', RecordFieldType.singleChoice, 91,
        optionSetId: 'grammar-rule-domain',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('statement', 'Rule', RecordFieldType.richText, 100,
        description: 'The rule, stated plainly.'),
    _field('examples', 'Examples', RecordFieldType.list, 101),
    _field('exceptions', 'Exceptions', RecordFieldType.richText, 110,
        description: 'A language without exceptions has not been spoken '
            'by anyone.'),
    _field('notes', 'Notes', RecordFieldType.richText, 111, searchable: false),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'grammar-scope',
      title: 'Scope',
      order: 9,
      fieldIds: ['language', 'domain'],
    ),
    RecordTemplateSection(
      id: 'grammar-rule',
      title: 'Rule',
      order: 10,
      fieldIds: ['statement', 'examples'],
    ),
    RecordTemplateSection(
      id: 'grammar-exceptions',
      title: 'Exceptions',
      order: 11,
      fieldIds: ['exceptions', 'notes'],
    ),
  ],
  suggestedLinkTypeIds: const ['influences'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: LanguageRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
