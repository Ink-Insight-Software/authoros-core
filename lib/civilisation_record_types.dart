/// The Civilisation specialist system's record type.
///
/// One type, `civilisation`: *a people and its systems*. It is distinct from
/// `country` and `nation`, which are **territory**: a civilisation can spread
/// over several countries, a country can hold several civilisations, and a
/// civilisation can outlast every border it ever had. Modelling one as a
/// country with a profile cannot say any of those, which is why the owner chose
/// a type of its own (AOS Worldsmith build plan, Phase 2, §7 Q1, October 5,
/// 2026).
///
/// ## What a civilisation does not hold
///
/// Its culture, faith, language and government are records of their own, owned
/// by the systems that already own them. A civilisation **links** to them; it
/// does not describe them a second time:
///
/// * `hasCulture` → its `culture`
/// * `worships` → its `religion` and deities
/// * `speaks` → its `language`
/// * `governedBy` → its `government`
///
/// All four already exist and are `*`-typed, so none is added or widened.
/// Copying their fields here would be a second canonical description of each
/// (Lock 1), and the first edit to either copy would make them disagree.
///
/// ## The one edge it adds
///
/// `occupies`: the land a people holds, from a civilisation to a place, and
/// time-bounded, because peoples move, conquer and are driven out. `locatedIn`
/// is not the same claim — it places a thing, and a people is not a thing in a
/// place — and `controls` is political rule, which a government holds, not a
/// people. It is declared in `built_in_connection_types.dart` beside
/// `locatedIn`.
library;

import 'record_types.dart';

class CivilisationRecordTypes {
  const CivilisationRecordTypes._();

  static const civilisationTypeId = 'civilisation';

  static const packId = 'authoros-civilisation-system';

  /// Every type the Civilisation system presents. One, on purpose.
  static const List<String> recordTypeIds = [civilisationTypeId];

  /// Types a civilisation system could plausibly have claimed and does not.
  ///
  /// `country` and `nation` are territory and stay with the world types;
  /// `culture`, `religion`, `language` and `government` are linked to, never
  /// redescribed.
  static const List<String> reservedForOtherSystems = [
    'country',
    'nation',
    'culture',
    'religion',
    'language',
    'government',
  ];

  /// The relationships the system presents: the four existing `*`-typed edges
  /// to the systems a people has, and the one it adds.
  static const List<String> connectionTypeIds = [
    'occupies',
    'hasCulture',
    'worships',
    'speaks',
    'governedBy',
  ];

  static final List<RecordTypeDefinition> definitions = [_civilisation];
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
      optionSetId: optionSetId,
      allowCustomValues: allowCustomValues,
      quickCreateVisible: quickCreateVisible,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

/// Where a civilisation stands now. Custom values are allowed: an author's
/// own word for an age is often better than ours.
const _standing = RecordOptionSet(
  id: 'civilisation-standing',
  name: 'Standing',
  description: 'Where the civilisation stands in its own history.',
  values: [
    'Emerging',
    'Rising',
    'Flourishing',
    'Stagnant',
    'Declining',
    'Collapsed',
    'Remembered only',
  ],
);

/// A people and its systems.
final _civilisation = RecordTypeDefinition(
  id: CivilisationRecordTypes.civilisationTypeId,
  name: 'Civilisation',
  description: 'A people and its systems: who they are, where they live, '
      'and how they rose and fell.',
  icon: 'groups',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  optionSets: const [_standing],
  fields: [
    _field('demonym', 'Name for its people', RecordFieldType.shortText, 100,
        description: 'What its people are called — by themselves first.',
        quickCreateVisible: true),
    _field('alsoKnownAs', 'Also known as', RecordFieldType.list, 101,
        description: 'Names others use, kind or otherwise.'),
    _field('standing', 'Standing', RecordFieldType.singleChoice, 102,
        optionSetId: 'civilisation-standing',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('population', 'Population', RecordFieldType.shortText, 103,
        description: 'As exact or as vague as the world knows it.'),
    _field('rose', 'Rose', RecordFieldType.shortText, 110,
        description: "When it began, in the world's own reckoning."),
    _field('fell', 'Fell', RecordFieldType.shortText, 111,
        description: 'When it ended, if it has. Empty while it endures.'),
    _field('technology', 'Level of technology', RecordFieldType.shortText,
        112,
        description: 'What it can make and do, in a phrase.'),
    _field('defining', 'What defines it', RecordFieldType.richText, 120,
        description: 'What a stranger would notice first, and what its '
            'people would say instead.'),
    _field('history', 'History', RecordFieldType.richText, 121,
        description: 'Its rise, its height and its turns. Wars, reigns and '
            'eras are records of their own; this is the story that joins '
            'them.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'civilisation',
      title: 'People',
      order: 10,
      fieldIds: ['demonym', 'alsoKnownAs', 'standing', 'population'],
    ),
    RecordTemplateSection(
      id: 'civilisation-age',
      title: 'Age',
      order: 20,
      fieldIds: ['rose', 'fell', 'technology'],
    ),
    RecordTemplateSection(
      id: 'civilisation-story',
      title: 'Character and history',
      order: 30,
      fieldIds: ['defining', 'history'],
    ),
  ],
  suggestedLinkTypeIds: CivilisationRecordTypes.connectionTypeIds,
  builtIn: true,
  sourcePackId: CivilisationRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
