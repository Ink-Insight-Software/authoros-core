/// The Religion specialist system's record types.
///
/// The second application of the correction Magic established, and the second
/// file to follow the per-domain convention Character, Plot, Timeline, World,
/// Research and Magic already use. Nothing new about the mechanism: ordinary
/// [RecordTypeDefinition]s in the canonical registry, named by a manifest that
/// defines nothing.
///
/// ## The defect this file corrects
///
/// `deity` was declared with `baseTypeId: 'religion'`. Inheritance merges the
/// parent's fields into the child, so every Deity record presented the
/// *religion's* ten — most absurdly a **`deities` list, on a deity**. An author
/// writing down a god was also asked for that god's sacred texts, its beliefs
/// and its practices, which belong to the faith that worships it.
///
///     general-lore
///     ├── religion   a faith: what it holds, how it is practised, who leads it
///     └── deity      a god: its domain, its symbols, what is owed to it
///
/// Unlike `spell`, `deity` gets **no** inheritance edge back to its parent. A
/// spell genuinely is an ability; a god is not a religion. The relationship
/// between them is `worships`, and an edge is the honest way to say it —
/// pantheons overlap, gods are shared between faiths and abandoned by them,
/// and none of that survives being modelled as inheritance.
///
/// ## How existing records survive it
///
/// The same three mechanisms that carried Magic, verified again here rather
/// than assumed:
///
/// * Nothing prunes. `StoryCodexService.updateCodexEntry` merges, so a value
///   outside the template survives every later save.
/// * Nothing rejects. [RecordValidator] iterates the *definition's* fields.
/// * Nothing hides. The Codex entry pane builds an editor for every record key
///   the template lacks, and writes it back.
///
/// And the same cheap migration wherever it applies: **a field that still means
/// something on the child keeps its id.** Six of the ten do — a god has
/// symbols, rites, feast days, taboos, a priesthood and a history — so an
/// existing `deity` record keeps them with their labels and typed editors
/// intact. Only the four that are the faith's and never the god's leave.
///
/// `religion_compatibility_test.dart` proves each claim against records built
/// in the shape the old definitions produced.
library;

import 'record_types.dart';

class ReligionRecordTypes {
  const ReligionRecordTypes._();

  static const religionTypeId = 'religion';
  static const deityTypeId = 'deity';

  /// Every type the Religion system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [religionTypeId, deityTypeId];

  /// Field ids `deity` inherited from `religion` and **keeps**, because they
  /// describe a god as truthfully as a faith.
  ///
  /// Named rather than merely used: the migration guarantee depends on them.
  /// An existing record's value for one of these keeps its label and its typed
  /// editor instead of becoming a loose key.
  static const List<String> retainedDeityFieldIds = [
    'symbols',
    'rituals',
    'holidays',
    'taboos',
    'clergy',
    'history',
  ];

  /// Field ids that leave `deity`, because they belong to the religion and
  /// never to one god.
  ///
  /// `deities` is the clearest of them — a god has no list of gods. A record
  /// carrying any of these keeps the value; it simply stops being offered a
  /// dedicated editor for it.
  static const List<String> releasedDeityFieldIds = [
    'deities',
    'beliefs',
    'practices',
    'sacredTexts',
  ];

  static final List<RecordTypeDefinition> definitions = [_religion, _deity];
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
// The religion
// ---------------------------------------------------------------------------

/// A faith: what it holds, how it is practised, and who leads it.
///
/// Every field the previous definition carried is still here, with the same id
/// and the same type, so no existing `religion` record changes at all. What is
/// new is shape — four sections instead of one flat list of ten — and four
/// fields an author previously had to improvise inside `beliefs`.
final _religion = RecordTypeDefinition(
  id: ReligionRecordTypes.religionTypeId,
  name: 'Religion',
  description: 'A faith: what it holds, how it is practised, who leads it.',
  icon: 'temple_buddhist',
  categoryId: 'religion',
  baseTypeId: 'general-lore',
  fields: [
    _field('beliefs', 'Beliefs', RecordFieldType.richText, 100),
    _field('deities', 'Deities', RecordFieldType.list, 101,
        description: 'The gods this faith holds. Link them for detail.'),
    _field('afterlife', 'Afterlife', RecordFieldType.richText, 102,
        description: 'What this faith says happens next.'),
    _field('morality', 'Morality', RecordFieldType.richText, 103,
        description: 'What it calls right, and what it calls sin.'),
    _field('practices', 'Practices', RecordFieldType.richText, 110),
    _field('rituals', 'Rituals', RecordFieldType.richText, 111),
    _field('holidays', 'Holidays', RecordFieldType.list, 112),
    _field('taboos', 'Taboos', RecordFieldType.list, 113),
    _field('sacredTexts', 'Sacred Texts', RecordFieldType.list, 120),
    _field('symbols', 'Symbols', RecordFieldType.list, 121),
    _field('holySites', 'Holy Sites', RecordFieldType.list, 122),
    _field('clergy', 'Clergy', RecordFieldType.richText, 130),
    _field('hierarchy', 'Hierarchy', RecordFieldType.richText, 131,
        description: 'How authority is held and passed on.'),
    _field('adherents', 'Adherents', RecordFieldType.longText, 132,
        description: 'Who follows it, and how many.'),
    _field('history', 'History', RecordFieldType.richText, 140),
    _field('schisms', 'Schisms', RecordFieldType.richText, 141,
        description: 'Where it split, and over what.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'religion',
      title: 'Faith',
      order: 10,
      fieldIds: ['beliefs', 'deities', 'afterlife', 'morality'],
    ),
    RecordTemplateSection(
      id: 'religion-practice',
      title: 'Practice',
      order: 11,
      fieldIds: ['practices', 'rituals', 'holidays', 'taboos'],
    ),
    RecordTemplateSection(
      id: 'religion-canon',
      title: 'Canon and places',
      order: 12,
      fieldIds: ['sacredTexts', 'symbols', 'holySites'],
    ),
    RecordTemplateSection(
      id: 'religion-institution',
      title: 'Institution',
      order: 13,
      fieldIds: ['clergy', 'hierarchy', 'adherents', 'history', 'schisms'],
    ),
  ],
  suggestedLinkTypeIds: const ['worships', 'associatedWith'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-religion-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The deity
// ---------------------------------------------------------------------------

/// A god: its domain, its symbols, and what is owed to it.
///
/// Re-parented from `religion` to `general-lore`, and deliberately **not**
/// given an inheritance edge back. A god is not a kind of faith. Which faiths
/// worship it is a `worships` edge, which is also the only shape that survives
/// a god being shared between two pantheons or abandoned by one.
///
/// The six ids in [ReligionRecordTypes.retainedDeityFieldIds] are unchanged in
/// id and type, so an existing record's values for them keep their labels and
/// their editors across the change.
final _deity = RecordTypeDefinition(
  id: ReligionRecordTypes.deityTypeId,
  name: 'Deity',
  description: 'A god: its domain, its symbols, and what is owed to it.',
  icon: 'auto_awesome',
  categoryId: 'religion',
  baseTypeId: 'general-lore',
  fields: [
    _field('religion', 'Religion', RecordFieldType.recordReference, 100,
        referenceTypeIds: [ReligionRecordTypes.religionTypeId],
        description: 'The faith that holds this god, if one does.'),
    _field('domain', 'Domain', RecordFieldType.list, 101,
        description: 'What this god governs — storms, oaths, the harvest.'),
    _field('epithets', 'Epithets', RecordFieldType.list, 102,
        description: 'What worshippers call it. Also searched in prose.'),
    // Deliberately shortText rather than singleChoice: the field system has no
    // custom-value support, so a fixed option list would refuse an author whose
    // god is in a state nobody anticipated. See the architecture stream's
    // Universal Field System work.
    _field('status', 'Standing', RecordFieldType.shortText, 103,
        description: 'Worshipped, forgotten, sleeping, dead, imprisoned…'),
    _field('appearance', 'Appearance', RecordFieldType.richText, 110),
    // Retained ids — an existing record keeps these with their editors.
    _field('symbols', 'Symbols', RecordFieldType.list, 111),
    _field('domainOfWorship', 'Where it is worshipped',
        RecordFieldType.longText, 112),
    _field('rituals', 'Rites', RecordFieldType.richText, 120),
    _field('holidays', 'Feast days', RecordFieldType.list, 121),
    _field('taboos', 'Taboos', RecordFieldType.list, 122),
    _field('clergy', 'Priesthood', RecordFieldType.richText, 123),
    _field('origin', 'Origin', RecordFieldType.richText, 130,
        description: 'Where this god came from, as the faith tells it.'),
    _field('history', 'History', RecordFieldType.richText, 131),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'deity',
      title: 'God',
      order: 10,
      fieldIds: ['religion', 'domain', 'epithets', 'status'],
    ),
    RecordTemplateSection(
      id: 'deity-form',
      title: 'Form',
      order: 11,
      fieldIds: ['appearance', 'symbols', 'domainOfWorship'],
    ),
    RecordTemplateSection(
      id: 'deity-worship',
      title: 'Worship',
      order: 12,
      fieldIds: ['rituals', 'holidays', 'taboos', 'clergy'],
    ),
    RecordTemplateSection(
      id: 'deity-story',
      title: 'Story',
      order: 13,
      fieldIds: ['origin', 'history'],
    ),
  ],
  suggestedLinkTypeIds: const ['worships', 'associatedWith', 'partOf'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-religion-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
