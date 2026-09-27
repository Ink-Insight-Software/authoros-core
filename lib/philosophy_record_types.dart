/// The Philosophy specialist system's record types.
///
/// One type. `concept` was a bare `general-lore` child with **no fields of its
/// own**, so an idea a whole plot argues about was recorded with a title, a
/// summary and a blank page.
///
/// ## Why one type, again
///
/// The third system to land at one or two types after applying Language's
/// test — is the concept *shared between* records, is it *unbounded* — and the
/// third to record what it declined rather than inventing to look larger:
///
/// * A **school of thought** would pass the shared test, but a school is a
///   body of people with a founder, a seat and a history. `institution` and
///   `faction` already model that, and a school is those with edges to the
///   concepts it holds.
/// * A **tenet** is bounded — a philosophy has a handful, not an unbounded
///   list the way a language has words — so it is a field.
/// * An **argument** is what `concept.objections` and `concept.implications`
///   are for. Splitting it out would ask an author to make two records to
///   write down one disagreement.
///
/// ## `concept` is claimed, and that is a real decision
///
/// It is the most general type any system has claimed so far, and the question
/// the last four base types raised applies here too: does an author lose
/// something they should always have, when Philosophy is off?
///
/// The answer is no, and the reason is precise. `item`, `location`,
/// `travel-route` and `world` are **base types** — other types inherit them,
/// and the registry resolves membership through them. `concept` is a leaf:
/// nothing descends from it, no service resolves through it, and
/// `general-lore` — which is what "somewhere to write an idea down" actually
/// means — stays unclaimed and always offered. A test asserts both halves.
///
/// ## Compatibility
///
/// Nothing is re-parented and nothing removed. `concept` had no fields, so no
/// value anywhere can be orphaned.
library;

import 'record_types.dart';

class PhilosophyRecordTypes {
  const PhilosophyRecordTypes._();

  static const conceptTypeId = 'concept';

  /// Every type the Philosophy system presents.
  static const List<String> recordTypeIds = [conceptTypeId];

  /// The generic that must stay unclaimed for `concept` to be claimable.
  ///
  /// `general-lore` is where an author writes down anything at all. If
  /// Philosophy were ever to claim it, "somewhere to put a note" would become
  /// conditional on a toggle.
  static const String loreFoundationTypeId = 'general-lore';

  /// Concepts considered and declined, with the reason, so a later wave
  /// inherits the argument rather than reopening it.
  static const Map<String, String> declinedTypes = {
    'school-of-thought': 'a body of people; institution and faction model that',
    'tenet': 'bounded — a philosophy has a handful, so it is a field',
    'argument': 'objections and implications are fields on the concept',
    'ideology': 'a concept with adherents; the edges carry the adherents',
  };

  /// The seven `general-lore` ids `concept` inherits and keeps unchanged.
  static const List<String> inheritedLoreFieldIds = [
    'name',
    'aliases',
    'summary',
    'description',
    'notes',
    'knowledgeStatus',
    'sourceReferences',
  ];

  static final List<RecordTypeDefinition> definitions = [_concept];
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

/// An idea people argue about: what it claims, what follows from it, and who
/// is against it.
///
/// The fields are built around disagreement rather than definition, because an
/// idea nobody contests does not generate a plot. `objections` is the one an
/// author is most likely to skip and most likely to need.
final _concept = RecordTypeDefinition(
  id: PhilosophyRecordTypes.conceptTypeId,
  name: 'Concept',
  description: 'An idea people argue about: what it claims, what follows from '
      'it, and who is against it.',
  icon: 'psychology',
  categoryId: 'lore',
  baseTypeId: PhilosophyRecordTypes.loreFoundationTypeId,
  fields: [
    _field('holds', 'What it holds', RecordFieldType.richText, 100,
        description: 'The claim itself, stated as its believers would state '
            'it.'),
    _field('implications', 'What follows', RecordFieldType.richText, 101,
        description: 'What you have to accept if you accept this. Usually '
            'where the trouble is.'),
    _field('practice', 'What it asks of you', RecordFieldType.richText, 102,
        description: 'What believing it makes a person actually do.'),
    _field('objections', 'Objections', RecordFieldType.richText, 110,
        description: 'The strongest case against — the one a reader would '
            'make. An idea with no answer to this reads as a strawman.'),
    _field('opposes', 'Opposed to', RecordFieldType.list, 111,
        description: 'The ideas it is defined against. Link them.'),
    _field('proponents', 'Held by', RecordFieldType.list, 112,
        description: 'Who argues for it. Link the people and factions.'),
    // shortText rather than singleChoice: the field system has no
    // custom-value support, and a fixed list would refuse an author whose idea
    // is in a state nobody anticipated. Same reasoning as `deity.status`.
    _field('standing', 'Standing', RecordFieldType.shortText, 113,
        description: 'Orthodox, heretical, fashionable, forgotten, illegal.'),
    _field('origin', 'Origin', RecordFieldType.richText, 120,
        description: 'Where it came from and who first argued it — which is '
            'rarely who is remembered for it.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'concept-claim',
      title: 'The claim',
      order: 10,
      fieldIds: ['holds', 'implications', 'practice'],
    ),
    RecordTemplateSection(
      id: 'concept-contested',
      title: 'Contested',
      order: 11,
      fieldIds: ['objections', 'opposes', 'proponents', 'standing'],
    ),
    RecordTemplateSection(
      id: 'concept-origin',
      title: 'Origin',
      order: 12,
      fieldIds: ['origin'],
    ),
  ],
  suggestedLinkTypeIds: const [
    'contradicts',
    'supports',
    'influences',
    'originatedFrom',
  ],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-philosophy-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
