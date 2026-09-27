import 'craft/craft_entry.dart';
import 'craft/craft_library.dart';
import 'craft_fields.dart';
import 'record_scope.dart';
import 'record_types.dart';

class PlotRecordTypes {
  const PlotRecordTypes._();

  static const baseTypeId = 'plot-record';
  static const beatTypeId = 'beat';

  static const List<String> recordTypeIds = [
    'story',
    'act',
    'sequence',
    'plot',
    'plotline',
    'subplot',
    'arc',
    'character-arc',
    'relationship-arc',
    'world-arc',
    'political-arc',
    'romance-arc',
    'mystery-arc',
    'conflict',
    'goal',
    'motivation',
    'obstacle',
    'stake',
    'turning-point',
    beatTypeId,
    'arc-beat',
    'story-event',
    'reveal',
    'foreshadowing',
    'payoff',
    'set-piece',
    'climax',
    'resolution',
    'scene-plan',
    'chapter-plan',
  ];

  /// The thirty types, grouped for the picker that offers them.
  ///
  /// Descriptions made each option understandable and made the list *long*:
  /// a row carries two or three lines now, so about five fill a menu where
  /// fifteen bare labels used to. Thirty of those in one flat run is a wall,
  /// and an author looking for *Beat* had no way to guess whether it sat
  /// above or below *Stake*.
  ///
  /// **The groups are the distinctions this file already draws, not a fresh
  /// taxonomy.** That is deliberate: a grouping invented for the dropdown
  /// would be a second opinion about what these types are, free to drift from
  /// the model that decides how they behave. So —
  ///
  /// - *What a thread is made of* is exactly [_componentTypes], the four the
  ///   `conventions` field is withheld from, for the reason recorded there:
  ///   they are components inside a unit of story rather than units of it.
  ///   Conflict is **not** among them, and is grouped with the threads it
  ///   shapes, because that is the call [_componentTypes] already made — *a
  ///   conflict is the shape of a whole thread, not a component of one*.
  /// - *Arcs* is `arc` and the six types [_baseTypes] hangs off it.
  /// - *Moments* keeps `climax` and `resolution` beside the `turning-point`
  ///   they extend, and `arc-beat` beside `beat`, again per [_baseTypes].
  ///
  /// `test/plot_type_options_test.dart` holds each of those to the model, so
  /// a type that changes what it *is* cannot keep sitting under a heading
  /// that says otherwise.
  ///
  /// A project's own custom types are not here and cannot be: they are
  /// registered at runtime. The picker gathers whatever it is handed that no
  /// family claims and offers it under a heading of its own, which is also
  /// what makes this list safe to reorder without touching the view.
  static const List<PlotTypeFamily> families = [
    PlotTypeFamily(
      title: 'Structure',
      typeIds: ['story', 'act', 'sequence'],
    ),
    PlotTypeFamily(
      title: 'Threads',
      typeIds: ['plot', 'plotline', 'subplot', 'conflict'],
    ),
    PlotTypeFamily(
      title: 'Arcs',
      typeIds: [
        'arc',
        'character-arc',
        'relationship-arc',
        'world-arc',
        'political-arc',
        'romance-arc',
        'mystery-arc',
      ],
    ),
    PlotTypeFamily(
      title: 'What a thread is made of',
      typeIds: ['goal', 'motivation', 'obstacle', 'stake'],
    ),
    PlotTypeFamily(
      title: 'Moments',
      typeIds: [
        'turning-point',
        'climax',
        'resolution',
        beatTypeId,
        'arc-beat',
        'story-event',
        'set-piece',
      ],
    ),
    PlotTypeFamily(
      title: 'Setup and payoff',
      typeIds: ['foreshadowing', 'reveal', 'payoff'],
    ),
    PlotTypeFamily(
      title: 'Planned, not yet drafted',
      typeIds: ['scene-plan', 'chapter-plan'],
    ),
  ];

  static final List<RecordTypeDefinition> definitions = [
    _base,
    ...recordTypeIds.map(_definition),
  ];

  static RecordTypeDefinition customType({
    required String id,
    required String name,
    required String projectId,
    List<RecordFieldDefinition> fields = const [],
    List<RecordTemplateSection> sections = const [],
  }) =>
      RecordTypeDefinition(
        id: id,
        name: name,
        categoryId: 'plot',
        baseTypeId: baseTypeId,
        fields: fields,
        sections: sections,
        suggestedLinkTypeIds: _plotLinks,
        scopeType: RecordScopeType.project,
        scopeId: projectId,
        sourcePackId: 'project:$projectId',
        extensionData: const {'plotStudio': true, 'custom': true},
      );

  static RecordTypeDefinition _definition(String id) {
    final fields = <RecordFieldDefinition>[
      ...?_fieldsByType[id],
      if (!_componentTypes.contains(id)) _conventions,
    ];
    return RecordTypeDefinition(
      id: id,
      name: _names[id]!,
      description: _descriptions[id]!,
      icon: _icons[id] ?? 'account_tree',
      categoryId: 'plot',
      baseTypeId: _baseTypes[id] ?? baseTypeId,
      fields: fields,
      sections: fields.isEmpty
          ? const []
          : [
              RecordTemplateSection(
                id: 'plotDetails',
                title: 'Plot details',
                order: 20,
                fieldIds: fields.map((field) => field.id).toList(),
              ),
            ],
      suggestedLinkTypeIds: _plotLinks,
      builtIn: true,
      sourcePackId: 'authoros-core',
      permissions: const {'editableDefinition': false},
      extensionData: const {'plotStudio': true},
    );
  }
}

/// One labelled group of Plot types, for a picker that has to offer thirty.
class PlotTypeFamily {
  const PlotTypeFamily({required this.title, required this.typeIds});

  /// The heading shown above the group.
  final String title;

  /// The types in it, in the order they are offered.
  final List<String> typeIds;
}

const _base = RecordTypeDefinition(
  id: PlotRecordTypes.baseTypeId,
  name: 'Plot Record',
  description: 'A story architecture record shared across AuthorOS studios.',
  icon: 'account_tree',
  categoryId: 'plot',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
      id: 'purpose',
      label: 'Purpose',
      type: RecordFieldType.longText,
      order: 100,
    ),
    RecordFieldDefinition(
      id: 'plotStatus',
      label: 'Status',
      type: RecordFieldType.singleChoice,
      order: 101,
      options: ['planned', 'active', 'resolved', 'abandoned'],
    ),
    RecordFieldDefinition(
      id: 'planningOrder',
      label: 'Planning order',
      type: RecordFieldType.number,
      order: 102,
    ),
    RecordFieldDefinition(
      id: 'narrativeOrder',
      label: 'Narrative order',
      type: RecordFieldType.number,
      order: 103,
    ),
    RecordFieldDefinition(
      id: 'chronologicalOrder',
      label: 'Chronological order',
      type: RecordFieldType.number,
      order: 104,
    ),
    RecordFieldDefinition(
      id: 'dependencies',
      label: 'Dependencies',
      type: RecordFieldType.list,
      order: 105,
      extensionData: {'stableIds': true},
    ),
  ],
  sections: [
    RecordTemplateSection(
      id: 'architecture',
      title: 'Architecture',
      order: 10,
      fieldIds: [
        'purpose',
        'plotStatus',
        'planningOrder',
        'narrativeOrder',
        'chronologicalOrder',
        'dependencies',
      ],
    ),
  ],
  suggestedLinkTypeIds: _plotLinks,
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
  extensionData: {'plotStudio': true, 'abstract': true},
);

const _plotLinks = [
  'partOf',
  'contains',
  'appearsIn',
  'hasArc',
  'pursues',
  'involves',
  'relatedTo',
  'causes',
  'changes',
  'leadsTo',
  'paidOffBy',
  'plannedFor',
  'fulfilledBy',
  'occursDuring',
  'depicts',
  'resolvesIn',
  'dependsOn',
  'opposes',
  'motivatedBy',
  'hasStake',
];

const _names = <String, String>{
  'story': 'Story',
  'act': 'Act',
  'sequence': 'Sequence',
  'plot': 'Plot',
  'plotline': 'Plotline',
  'subplot': 'Subplot',
  'arc': 'Arc',
  'character-arc': 'Character Arc',
  'relationship-arc': 'Relationship Arc',
  'world-arc': 'World Arc',
  'political-arc': 'Political Arc',
  'romance-arc': 'Romance Arc',
  'mystery-arc': 'Mystery Arc',
  'conflict': 'Conflict',
  'goal': 'Goal',
  'motivation': 'Motivation',
  'obstacle': 'Obstacle',
  'stake': 'Stake',
  'turning-point': 'Turning Point',
  'beat': 'Beat',
  'arc-beat': 'Arc Beat',
  'story-event': 'Story Event',
  'reveal': 'Reveal',
  'foreshadowing': 'Foreshadowing',
  'payoff': 'Payoff',
  'set-piece': 'Set Piece',
  'climax': 'Climax',
  'resolution': 'Resolution',
  'scene-plan': 'Scene Plan',
  'chapter-plan': 'Chapter Plan',
};

/// What choosing each Plot type actually does.
///
/// The Type field offers thirty of these and used to describe them with
/// `'$name represented in Plot Studio.'` — a formula that printed "Plot
/// represented in Plot Studio" and told an author nothing about the difference
/// between an Act, a Sequence and a Plotline. A description that says the label
/// back is worse than none: it occupies the place someone looks for an answer.
/// This is the same call `character_record_types.dart` made about its twelve
/// templates, for the same reason.
///
/// **What these promise is what the type opens.** Every plot record carries the
/// shared architecture block — purpose, status, the three orders, dependencies
/// — and all but the four component types carry `conventions`. A type earns a
/// description by saying what it adds on top of that, and where it adds
/// nothing, the description says *that* rather than implying a difference the
/// fields do not have: `subplot` is `plotline`'s fields under another name, and
/// four of the seven arcs are `arc`'s.
///
/// ## Why these are not craft library entries
///
/// Several of these names are craft terms the library already explains — it
/// holds entries for the turning point, the climax, the resolution, the payoff
/// and the plant, keyed to the option lists that offer them. These strings
/// answer a different question: not *what is a climax* but *what does picking
/// Climax here give me*, which is a fact about this application. Writing a
/// second account of the word would be the drift `lib/core/craft/` exists to
/// prevent, so where a term is explained on the shelf these point at the field
/// that carries the explanation instead of restating it.
const _descriptions = <String, String>{
  'story': 'The whole book as one record — the root the rest hangs off. The '
      'shared architecture block only; its parts live in the records beneath '
      'it.',
  'act': 'A major division of the book. Adds an opening and a closing state, '
      'so an act is described by what changes across it.',
  'sequence': 'A run of scenes pulling towards one goal. Adds the goal, the '
      'conflict and the outcome, each pointing at the record that holds it.',
  'plot': 'A thread of story, unqualified. The shared architecture block only '
      '— Plotline is the same thing with somewhere to say which kind of '
      'thread it is.',
  'plotline': 'A named thread through the book. Adds its kind (main, subplot, '
      'romance, mystery and eight more), a priority, where it starts, and both '
      'the resolution you intend and the one you wrote.',
  'subplot': 'A thread you are calling secondary. Plotline\'s fields exactly — '
      'the difference is the name on the board and the priority you give it.',
  'arc': 'A change tracked across the book. Adds the beginning, desired end '
      'and current state, a progression table, and the resolution.',
  'character-arc': 'One person\'s change. Arc\'s fields plus a starting and '
      'ending state, the goal and motivation driving it, the false belief and '
      'the truth that replaces it, and the internal and external conflict '
      'between them.',
  'relationship-arc': 'What happens between two people across the book. Arc\'s '
      'fields plus the initial relationship, a progression table and the final '
      'state.',
  'world-arc': 'A change in the world rather than in a person. Arc\'s fields; '
      'nothing world-specific comes with it.',
  'political-arc': 'A change in who holds power. Arc\'s fields; nothing '
      'politics-specific comes with it.',
  'romance-arc': 'A change between people the book is reading as a romance. '
      'Arc\'s fields — Relationship Arc is the one that adds fields for two '
      'people.',
  'mystery-arc': 'A question the book opens and closes. Arc\'s fields; the '
      'clues and the answer are Foreshadowing, Reveal and Payoff records '
      'linked to it.',
  'conflict': 'The opposition a thread is built on. Adds its kind — against '
      'another character, against self, against society and six more, each '
      'explained where you choose it — with a source and target, how it '
      'escalates, its outcome, and what the outcome costs.',
  'goal': 'What someone is trying to get. Adds the owner, what success and '
      'failure each look like, and a deadline. A component of a thread rather '
      'than a thread, so no conventions field.',
  'motivation': 'Why they want it. Adds a kind — survival, love, revenge and '
      'ten more. A component of a thread, so no conventions field.',
  'obstacle': 'What stands in the way. Adds a kind, a source and a target, how '
      'it escalates, how it resolves and what that costs. A component of a '
      'thread, so no conventions field.',
  'stake': 'What failing would cost. Adds the kind — personal, moral, world '
      'and seven more, each explained where you choose it. A component of a '
      'thread, so no conventions field.',
  'turning-point': 'A moment the story changes direction. Adds the kind — '
      'inciting incident, midpoint, reversal, crisis and four more, each '
      'explained where you choose it.',
  'beat': 'The smallest unit Plot Studio records: one thing that happens. Adds '
      'a type, how much it matters, and the consequence it leaves behind.',
  'arc-beat': 'A beat that belongs to an arc. Beat\'s fields; link it to the '
      'arc it moves.',
  'story-event': 'Something that happens in the world of the story, whether or '
      'not the book shows it. The shared architecture block only.',
  'reveal': 'A moment information changes hands. Adds the secret, who reveals '
      'it and to whom, where you meant it to land against where it does, and '
      'three separate accounts of who knows what — yours, the characters\' and '
      'the reader\'s.',
  'foreshadowing': 'Something planted early to be collected later. Adds the '
      'plant itself, what the characters make of it at the time, and what the '
      'reader is given to notice.',
  'payoff': 'The moment a plant is collected. Adds the setup it answers, the '
      'payoff itself, and where you expected it against where it lands.',
  'set-piece': 'A large scene the book is built around. The shared '
      'architecture block only.',
  'climax': 'The turning point the book has been pointed at. Turning Point\'s '
      'fields under a name that says so on the board.',
  'resolution': 'Where a thread comes to rest. Turning Point\'s fields under a '
      'name that says so on the board.',
  'scene-plan': 'A scene planned before it is drafted. The shared architecture '
      'block only — the scene itself lives in the manuscript.',
  'chapter-plan': 'A chapter planned before it is drafted. The shared '
      'architecture block only — the chapter itself lives in the manuscript.',
};

const _icons = <String, String>{
  'story': 'auto_stories',
  'act': 'view_agenda',
  'sequence': 'reorder',
  'plotline': 'route',
  'beat': 'music_note',
  'turning-point': 'turn_sharp_right',
  'reveal': 'visibility',
  'foreshadowing': 'lightbulb',
  'payoff': 'task_alt',
  'climax': 'landscape',
  'resolution': 'flag',
};

/// The applied lens on Plot Studio.
///
/// A convention is something a *unit of story* does, so it is offered on
/// every plot type except the four in [_componentTypes]. The author claims
/// it; nothing here reads their manuscript to find one. See
/// `lib/core/craft_fields.dart`.
final _conventions = CraftFields.assertion(
  id: 'conventions',
  label: 'Conventions at work',
  family: CraftFamily.tropes,
  subject: CraftSubject.plot,
  order: 300,
  description: 'Conventions this part of the story is using, as you read it. '
      'Tick what applies, add anything the list has not heard of, or leave it '
      'empty — nothing else in AuthorOS reads this except you.',
);

/// The plot types a convention is not offered on.
///
/// These four are components inside a unit of story rather than units of it:
/// what someone wants, why they want it, what stands in the way, and what it
/// costs. *This obstacle is a ticking clock* is a category error rather than a
/// claim an author would make. Everything else in Plot Studio is something a
/// reader moves through in order, a conflict included — a conflict is the
/// shape of a whole thread, not a component of one.
const _componentTypes = <String>{'goal', 'motivation', 'obstacle', 'stake'};

const _baseTypes = <String, String>{
  'subplot': 'plotline',
  'character-arc': 'arc',
  'relationship-arc': 'arc',
  'world-arc': 'arc',
  'political-arc': 'arc',
  'romance-arc': 'arc',
  'mystery-arc': 'arc',
  'arc-beat': 'beat',
  'climax': 'turning-point',
  'resolution': 'turning-point',
};

// No longer const as a whole: four of these types take their craft guidance
// from `core/craft/craft_library.dart` rather than writing it out here, so a
// sentence lives in one place and serves both the helper text under the input
// and the browsable shelf. A library lookup is not a const expression.
//
// Every list that needs no lookup is still const, so only the four that do
// are built at load time. Nothing read this map as a const — `_definition`
// reaches it at runtime — so the change costs nothing but those four.
final _fieldsByType = <String, List<RecordFieldDefinition>>{
  'act': const [
    RecordFieldDefinition(
        id: 'openingState',
        label: 'Opening state',
        type: RecordFieldType.longText,
        order: 200),
    RecordFieldDefinition(
        id: 'closingState',
        label: 'Closing state',
        type: RecordFieldType.longText,
        order: 201),
  ],
  'sequence': const [
    RecordFieldDefinition(
        id: 'goal',
        label: 'Goal',
        type: RecordFieldType.recordReference,
        order: 200),
    RecordFieldDefinition(
        id: 'conflict',
        label: 'Conflict',
        type: RecordFieldType.recordReference,
        order: 201),
    RecordFieldDefinition(
        id: 'outcome',
        label: 'Outcome',
        type: RecordFieldType.longText,
        order: 202),
  ],
  'plotline': const [
    RecordFieldDefinition(
        id: 'plotlineType',
        label: 'Type',
        type: RecordFieldType.singleChoice,
        order: 200,
        options: [
          'main',
          'subplot',
          'character',
          'romance',
          'mystery',
          'political',
          'world',
          'conflict',
          'investigation',
          'survival',
          'quest',
          'custom'
        ]),
    RecordFieldDefinition(
        id: 'priority',
        label: 'Priority',
        type: RecordFieldType.number,
        order: 201),
    RecordFieldDefinition(
        id: 'start',
        label: 'Start',
        type: RecordFieldType.shortText,
        order: 202),
    RecordFieldDefinition(
        id: 'targetResolution',
        label: 'Target resolution',
        type: RecordFieldType.longText,
        order: 203),
    RecordFieldDefinition(
        id: 'actualResolution',
        label: 'Actual resolution',
        type: RecordFieldType.longText,
        order: 204),
  ],
  'arc': const [
    RecordFieldDefinition(
        id: 'beginningState',
        label: 'Beginning state',
        type: RecordFieldType.longText,
        order: 200),
    RecordFieldDefinition(
        id: 'desiredEndState',
        label: 'Desired end state',
        type: RecordFieldType.longText,
        order: 201),
    RecordFieldDefinition(
        id: 'currentState',
        label: 'Current state',
        type: RecordFieldType.longText,
        order: 202),
    RecordFieldDefinition(
        id: 'progression',
        label: 'Progression',
        type: RecordFieldType.table,
        order: 203),
    RecordFieldDefinition(
        id: 'resolution',
        label: 'Resolution',
        type: RecordFieldType.longText,
        order: 204),
  ],
  'character-arc': const [
    RecordFieldDefinition(
        id: 'startingState',
        label: 'Starting state',
        type: RecordFieldType.longText,
        order: 200),
    RecordFieldDefinition(
        id: 'goal',
        label: 'Goal',
        type: RecordFieldType.recordReference,
        order: 201),
    RecordFieldDefinition(
        id: 'motivation',
        label: 'Motivation',
        type: RecordFieldType.recordReference,
        order: 202),
    RecordFieldDefinition(
        id: 'falseBelief',
        label: 'False belief',
        type: RecordFieldType.longText,
        order: 203),
    RecordFieldDefinition(
        id: 'internalConflict',
        label: 'Internal conflict',
        type: RecordFieldType.longText,
        order: 204),
    RecordFieldDefinition(
        id: 'externalConflict',
        label: 'External conflict',
        type: RecordFieldType.longText,
        order: 205),
    RecordFieldDefinition(
        id: 'truth',
        label: 'Truth',
        type: RecordFieldType.longText,
        order: 206),
    RecordFieldDefinition(
        id: 'transformation',
        label: 'Transformation',
        type: RecordFieldType.longText,
        order: 207),
    RecordFieldDefinition(
        id: 'endingState',
        label: 'Ending state',
        type: RecordFieldType.longText,
        order: 208),
  ],
  'relationship-arc': const [
    RecordFieldDefinition(
        id: 'initialRelationship',
        label: 'Initial relationship',
        type: RecordFieldType.longText,
        order: 200),
    RecordFieldDefinition(
        id: 'progression',
        label: 'Progression',
        type: RecordFieldType.table,
        order: 201),
    RecordFieldDefinition(
        id: 'finalState',
        label: 'Final state',
        type: RecordFieldType.longText,
        order: 202),
  ],
  'goal': const [
    RecordFieldDefinition(
        id: 'owner',
        label: 'Owner',
        type: RecordFieldType.recordReference,
        order: 200),
    RecordFieldDefinition(
        id: 'successCondition',
        label: 'Success condition',
        type: RecordFieldType.longText,
        order: 201),
    RecordFieldDefinition(
        id: 'failureCondition',
        label: 'Failure condition',
        type: RecordFieldType.longText,
        order: 202),
    RecordFieldDefinition(
        id: 'deadline',
        label: 'Deadline',
        type: RecordFieldType.shortText,
        order: 203),
  ],
  'motivation': const [
    RecordFieldDefinition(
        id: 'motivationType',
        label: 'Type',
        type: RecordFieldType.singleChoice,
        order: 200,
        options: [
          'survival',
          'love',
          'revenge',
          'freedom',
          'power',
          'belonging',
          'duty',
          'protection',
          'truth',
          'redemption',
          'fear',
          'ambition',
          'custom'
        ]),
  ],
  'obstacle': const [
    RecordFieldDefinition(
        id: 'obstacleType',
        label: 'Type',
        type: RecordFieldType.shortText,
        order: 200),
    RecordFieldDefinition(
        id: 'source',
        label: 'Source',
        type: RecordFieldType.recordReference,
        order: 201),
    RecordFieldDefinition(
        id: 'target',
        label: 'Target',
        type: RecordFieldType.recordReference,
        order: 202),
    RecordFieldDefinition(
        id: 'escalation',
        label: 'Escalation',
        type: RecordFieldType.longText,
        order: 203),
    RecordFieldDefinition(
        id: 'resolution',
        label: 'Resolution',
        type: RecordFieldType.longText,
        order: 204),
    RecordFieldDefinition(
        id: 'consequence',
        label: 'Consequence',
        type: RecordFieldType.longText,
        order: 205),
  ],
  'conflict': [
    RecordFieldDefinition(
        id: 'conflictType',
        label: 'Type',
        type: RecordFieldType.singleChoice,
        order: 200,
        optionDescriptions:
            CraftLibrary.describeOptions('plot.conflict.conflictType'),
        options: [
          'character-vs-character',
          'character-vs-self',
          'character-vs-society',
          'character-vs-nature',
          'character-vs-system',
          'character-vs-supernatural',
          'character-vs-faction',
          'character-vs-world',
          'custom'
        ]),
    const RecordFieldDefinition(
        id: 'source',
        label: 'Source',
        type: RecordFieldType.recordReference,
        order: 201),
    const RecordFieldDefinition(
        id: 'target',
        label: 'Target',
        type: RecordFieldType.recordReference,
        order: 202),
    const RecordFieldDefinition(
        id: 'escalation',
        label: 'Escalation',
        type: RecordFieldType.longText,
        order: 203),
    const RecordFieldDefinition(
        id: 'outcome',
        label: 'Outcome',
        type: RecordFieldType.longText,
        order: 204),
    const RecordFieldDefinition(
        id: 'consequences',
        label: 'Consequences',
        type: RecordFieldType.list,
        order: 205),
  ],
  'stake': [
    RecordFieldDefinition(
        id: 'stakeType',
        label: 'Type',
        type: RecordFieldType.singleChoice,
        order: 200,
        optionDescriptions:
            CraftLibrary.describeOptions('plot.stake.stakeType'),
        options: [
          'personal',
          'emotional',
          'relationship',
          'physical',
          'moral',
          'political',
          'social',
          'world',
          'existential',
          'custom'
        ]),
  ],
  'beat': const [
    RecordFieldDefinition(
        id: 'beatType',
        label: 'Type',
        type: RecordFieldType.shortText,
        order: 200),
    RecordFieldDefinition(
        id: 'importance',
        label: 'Importance',
        type: RecordFieldType.singleChoice,
        order: 201,
        options: ['minor', 'normal', 'major', 'critical']),
    RecordFieldDefinition(
        id: 'consequence',
        label: 'Consequence',
        type: RecordFieldType.longText,
        order: 202),
  ],
  'turning-point': [
    RecordFieldDefinition(
        id: 'turningPointType',
        label: 'Type',
        type: RecordFieldType.singleChoice,
        order: 200,
        description:
            CraftLibrary.describe('plot.turning-point.turningPointType'),
        optionDescriptions:
            CraftLibrary.describeOptions('plot.turning-point.turningPointType'),
        options: [
          'inciting-incident',
          'first-major-decision',
          'midpoint',
          'reversal',
          'crisis',
          'climax',
          'resolution',
          'custom'
        ]),
  ],
  // A reveal record carries three separate accounts of who knows what — the
  // author's, the characters', and the reader's — and the distance between the
  // last two is the whole difference between suspense and surprise. That was
  // built into the fields and never said anywhere the author could read it.
  'reveal': [
    RecordFieldDefinition(
        id: 'secret',
        label: 'Secret',
        type: RecordFieldType.recordReference,
        order: 200,
        description: CraftLibrary.describe('plot.reveal.secret')),
    RecordFieldDefinition(
        id: 'revealedInformation',
        label: 'Revealed information',
        type: RecordFieldType.longText,
        order: 201,
        description: CraftLibrary.describe('plot.reveal.revealedInformation')),
    RecordFieldDefinition(
        id: 'revealedTo',
        label: 'Revealed to',
        type: RecordFieldType.list,
        order: 202,
        description: CraftLibrary.describe('plot.reveal.revealedTo')),
    RecordFieldDefinition(
        id: 'revealedBy',
        label: 'Revealed by',
        type: RecordFieldType.recordReference,
        order: 203,
        description: CraftLibrary.describe('plot.reveal.revealedBy')),
    const RecordFieldDefinition(
        id: 'intendedRevealPoint',
        label: 'Intended reveal point',
        type: RecordFieldType.recordReference,
        order: 204,
        description: 'Where you meant it to land.'),
    RecordFieldDefinition(
        id: 'actualRevealPoint',
        label: 'Actual reveal point',
        type: RecordFieldType.recordReference,
        order: 205,
        description: CraftLibrary.describe('plot.reveal.actualRevealPoint')),
    RecordFieldDefinition(
        id: 'authorKnowledge',
        label: 'Author knowledge',
        type: RecordFieldType.longText,
        order: 206,
        description: CraftLibrary.describe('plot.reveal.authorKnowledge')),
    RecordFieldDefinition(
        id: 'characterKnowledge',
        label: 'Character knowledge',
        type: RecordFieldType.table,
        order: 207,
        description: CraftLibrary.describe('plot.reveal.characterKnowledge')),
    RecordFieldDefinition(
        id: 'readerKnowledge',
        label: 'Reader knowledge',
        type: RecordFieldType.longText,
        order: 208,
        description: CraftLibrary.describe('plot.reveal.readerKnowledge')),
  ],
  'foreshadowing': [
    RecordFieldDefinition(
        id: 'plant',
        label: 'Plant',
        type: RecordFieldType.longText,
        order: 200,
        description: CraftLibrary.describe('plot.foreshadowing.plant')),
    const RecordFieldDefinition(
        id: 'characterAwareness',
        label: 'Character awareness',
        type: RecordFieldType.table,
        order: 201,
        description: 'Who in the scene knows what this means at the time.'),
    RecordFieldDefinition(
        id: 'readerAwareness',
        label: 'Reader awareness',
        type: RecordFieldType.longText,
        order: 202,
        description:
            CraftLibrary.describe('plot.foreshadowing.readerAwareness')),
  ],
  'payoff': [
    RecordFieldDefinition(
        id: 'setup',
        label: 'Setup',
        type: RecordFieldType.recordReference,
        order: 200,
        description: CraftLibrary.describe('plot.payoff.setup')),
    RecordFieldDefinition(
        id: 'payoff',
        label: 'Payoff',
        type: RecordFieldType.longText,
        order: 201,
        description: CraftLibrary.describe('plot.payoff.payoff')),
    const RecordFieldDefinition(
        id: 'expectedTiming',
        label: 'Expected timing',
        type: RecordFieldType.shortText,
        order: 202,
        description: 'Where you intend it to land.'),
    const RecordFieldDefinition(
        id: 'actualTiming',
        label: 'Actual timing',
        type: RecordFieldType.shortText,
        order: 203,
        description: 'Where it lands as drafted.'),
  ],
};

class PlotStructureTemplate {
  const PlotStructureTemplate({
    required this.id,
    required this.name,
    required this.stages,
    this.hierarchical = false,
  });

  final String id;
  final String name;
  final List<String> stages;
  final bool hierarchical;
}

class PlotStructureTemplates {
  const PlotStructureTemplates._();

  static const templates = [
    PlotStructureTemplate(id: 'three-act', name: 'Three Act', stages: [
      'Setup',
      'Inciting Incident',
      'Rising Action',
      'Midpoint',
      'Crisis',
      'Climax',
      'Resolution'
    ]),
    PlotStructureTemplate(id: 'five-act', name: 'Five Act', stages: [
      'Exposition',
      'Rising Action',
      'Climax',
      'Falling Action',
      'Resolution'
    ]),
    PlotStructureTemplate(id: 'heros-journey', name: "Hero's Journey", stages: [
      'Ordinary World',
      'Call to Adventure',
      'Refusal of the Call',
      'Meeting the Mentor',
      'Crossing the Threshold',
      'Tests, Allies, and Enemies',
      'Approach to the Inmost Cave',
      'Ordeal',
      'Reward',
      'The Road Back',
      'Resurrection',
      'Return with the Elixir'
    ]),
    PlotStructureTemplate(id: 'save-the-cat', name: 'Save the Cat', stages: [
      'Opening Image',
      'Theme Stated',
      'Setup',
      'Catalyst',
      'Debate',
      'Break into Two',
      'B Story',
      'Fun and Games',
      'Midpoint',
      'Bad Guys Close In',
      'All Is Lost',
      'Dark Night of the Soul',
      'Break into Three',
      'Finale',
      'Final Image'
    ]),
    PlotStructureTemplate(id: 'seven-point', name: 'Seven Point', stages: [
      'Hook',
      'Plot Turn 1',
      'Pinch Point 1',
      'Midpoint',
      'Pinch Point 2',
      'Plot Turn 2',
      'Resolution'
    ]),
    PlotStructureTemplate(
        id: 'snowflake',
        name: 'Snowflake',
        stages: [
          'One-sentence summary',
          'One-paragraph summary',
          'Character summaries',
          'Expanded synopsis',
          'Character charts',
          'Scene list'
        ],
        hierarchical: true),
    PlotStructureTemplate(id: 'custom', name: 'Custom', stages: []),
  ];
}
