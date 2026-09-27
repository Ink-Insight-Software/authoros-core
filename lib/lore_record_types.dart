/// The Lore & Legend specialist system's record types.
///
/// Four types — `myth`, `legend`, `rumour`, `folklore` — all bare
/// `general-lore` children with **no fields of their own**. An author could
/// name the story every character in the book has heard, and then had a title,
/// a summary and a blank page.
///
/// ## The system exists because of one field it does not add
///
/// `general-lore` already carries `knowledgeStatus`: Confirmed, Suspected,
/// Rumoured, False, Unknown, Secret, Revealed. That is the *reader-facing*
/// question — how sure is anyone — and these four types inherit it unchanged.
/// Nothing here duplicates it, and a test asserts no added field means the
/// same thing.
///
/// What none of them had is the question underneath: **who tells it, how the
/// versions differ, and what actually happened.** A myth with one version is a
/// fact; a rumour nobody repeats is a note. The variance is the content, and
/// there was nowhere to put it.
///
/// `truth` is marked author-visibility, like `knowledgeStatus`, because it is
/// what the author knows and the world does not.
///
/// ## Why this is not "World-State"
///
/// The system originally scoped for this slot was World-State, whose natural
/// type is `entity-state`. That type is **infrastructure**: it is
/// `BookScope.entityStateTypeId`, written by `SeriesService.setEntityState`,
/// read by the entity-profile and canon-conflict services, keyed by record and
/// book, and carrying a `required` field. Claiming it would gate a
/// machine-managed record behind an author toggle — the same mistake as
/// claiming the specialist-activation record, which the foundation explicitly
/// excluded.
///
/// The world's *state* is already modelled, by book and series scope. What was
/// genuinely unowned is the world's *stories*, which is this.
///
/// ## Four types, not one with a kind field
///
/// They already exist as four, and collapsing them would delete a distinction
/// an author has already made. They stay siblings rather than a hierarchy for
/// the reason Bestiary refused a taxonomy: whether a legend is a kind of myth
/// is the author's cosmology, not AuthorOS's. What they share is field ids.
///
/// ## Compatibility
///
/// Nothing is re-parented and nothing removed; all four had no fields, so no
/// value anywhere can be orphaned.
library;

import 'record_types.dart';

class LoreRecordTypes {
  const LoreRecordTypes._();

  static const mythTypeId = 'myth';
  static const legendTypeId = 'legend';
  static const rumourTypeId = 'rumour';
  static const folkloreTypeId = 'folklore';

  /// Every type the Lore system presents.
  static const List<String> recordTypeIds = [
    mythTypeId,
    legendTypeId,
    rumourTypeId,
    folkloreTypeId,
  ];

  /// The generic all four descend from, deliberately left unclaimed.
  static const String loreFoundationTypeId = 'general-lore';

  /// Infrastructure this system deliberately does not claim, with the reason.
  ///
  /// `entity-state` is what a "World-State" system would have reached for. It
  /// is written and read by the series machinery and carries a required field;
  /// gating it behind a toggle would break canon resolution, not just hide a
  /// template.
  static const Map<String, String> declinedInfrastructure = {
    'entity-state':
        'machine-managed by SeriesService; keyed by record and book, and '
            'carries a required field',
  };

  /// The seven `general-lore` ids all four inherit and keep unchanged.
  ///
  /// `knowledgeStatus` is the one that matters: it already answers "how sure
  /// is anyone", so nothing added here may mean the same thing.
  static const List<String> inheritedLoreFieldIds = [
    'name',
    'aliases',
    'summary',
    'description',
    'notes',
    'knowledgeStatus',
    'sourceReferences',
  ];

  /// Field ids that mean the same thing on every type in the family.
  static const List<String> sharedFieldIds = [
    'tellers',
    'variants',
    'age',
    'purpose',
    'origin',
    'truth',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _myth,
    _legend,
    _rumour,
    _folklore,
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
  String visibility = 'default',
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      extensionData: {'visibility': visibility, 'templateOwned': true},
    );

/// The fields every story carries.
///
/// None of these restates `knowledgeStatus`. That field asks how sure anyone
/// is; these ask who is doing the telling and what is underneath it.
List<RecordFieldDefinition> _shared({int from = 100}) => [
      _field('tellers', 'Told by', RecordFieldType.list, from,
          description: 'Who repeats it. A story with no tellers is a note.'),
      _field('variants', 'Variants', RecordFieldType.richText, from + 1,
          description: 'How the versions differ, and who tells which. This is '
              'usually the content — a story with one version is a fact.'),
      _field('age', 'Age', RecordFieldType.shortText, from + 2,
          description: 'How old it is said to be, which is rarely how old it '
              'is.'),
      _field('purpose', 'What it does', RecordFieldType.richText, from + 3,
          description: 'What it does for the people who tell it — warns, '
              'excuses, flatters, binds. Why it survived.'),
      _field('origin', 'Origin', RecordFieldType.richText, from + 4,
          description: 'Where it started, as far as anyone in the world can '
              'say.'),
      // Author-visibility, like `knowledgeStatus`: this is what the writer
      // knows and the world does not.
      _field(
          'truth', 'What actually happened', RecordFieldType.richText, from + 5,
          description: 'For your eyes. The gap between this and the telling '
              'is the story.',
          visibility: 'author'),
    ];

const _sharedSections = [
  RecordTemplateSection(
    id: 'lore-telling',
    title: 'The telling',
    order: 10,
    fieldIds: ['tellers', 'variants', 'age'],
  ),
  RecordTemplateSection(
    id: 'lore-underneath',
    title: 'Underneath',
    order: 12,
    fieldIds: ['purpose', 'origin', 'truth'],
  ),
];

RecordTypeDefinition _lore(
  String id,
  String name,
  String description,
  String icon,
  List<RecordFieldDefinition> own,
  List<RecordTemplateSection> ownSections,
) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      description: description,
      icon: icon,
      categoryId: 'lore',
      baseTypeId: LoreRecordTypes.loreFoundationTypeId,
      fields: [..._shared(), ...own],
      sections: [..._sharedSections, ...ownSections],
      suggestedLinkTypeIds: const [
        'originatedFrom',
        'associatedWith',
        'contradicts',
        'revealedIn',
      ],
      templateVersion: 2,
      builtIn: true,
      sourcePackId: 'authoros-lore-system',
      permissions: const {'editableDefinition': false},
      exportBehavior: const {'includeStructuredFields': true},
      extensionData: _codexTemplate,
    );

// ---------------------------------------------------------------------------

final _myth = _lore(
  LoreRecordTypes.mythTypeId,
  'Myth',
  'A story a people tells to account for something.',
  'auto_stories',
  [
    _field('explains', 'What it accounts for', RecordFieldType.richText, 120,
        description: 'The seasons, death, a mountain, why that family rules. '
            'A myth that explains nothing is a legend.'),
  ],
  const [
    RecordTemplateSection(
      id: 'myth-explains',
      title: 'What it accounts for',
      order: 11,
      fieldIds: ['explains'],
    ),
  ],
);

final _legend = _lore(
  LoreRecordTypes.legendTypeId,
  'Legend',
  'A story about someone, and what they are said to have done.',
  'military_tech',
  [
    _field('subject', 'About', RecordFieldType.shortText, 120,
        description: 'Who or what it is about. Link them — the record and the '
            'legend are not the same thing, and the difference is the point.'),
    _field('deeds', 'Deeds', RecordFieldType.richText, 121,
        description: 'What they are said to have done, in the order the story '
            'tells it.'),
  ],
  const [
    RecordTemplateSection(
      id: 'legend-subject',
      title: 'Subject',
      order: 11,
      fieldIds: ['subject', 'deeds'],
    ),
  ],
);

final _rumour = _lore(
  LoreRecordTypes.rumourTypeId,
  'Rumour',
  'Something being said right now, and who gains by it.',
  'campaign',
  [
    _field('circulating', 'Circulating', RecordFieldType.richText, 120,
        description: 'Where it is being told, how fast, and whether it is '
            'still spreading or already spent.'),
    _field('benefits', 'Who gains', RecordFieldType.richText, 121,
        description: 'Who is better off if it is believed. Often the answer '
            'to who started it.'),
  ],
  const [
    RecordTemplateSection(
      id: 'rumour-spread',
      title: 'Spread',
      order: 11,
      fieldIds: ['circulating', 'benefits'],
    ),
  ],
);

final _folklore = _lore(
  LoreRecordTypes.folkloreTypeId,
  'Folklore',
  'What people do because of a story, whether or not they believe it.',
  'diversity_2',
  [
    _field('observance', 'Observance', RecordFieldType.richText, 120,
        description: 'The charm, the avoidance, the thing said at a door. '
            'What survives when belief does not.'),
  ],
  const [
    RecordTemplateSection(
      id: 'folklore-observance',
      title: 'Observance',
      order: 11,
      fieldIds: ['observance'],
    ),
  ],
);
