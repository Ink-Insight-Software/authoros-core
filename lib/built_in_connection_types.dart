import 'built_in_record_types.dart';
import 'civilisation_record_types.dart';
import 'connection_types.dart';
import 'plot_record_types.dart';
import 'record_types.dart';
import 'research_record_types.dart';
import 'timeline_record_types.dart';
import 'world_record_types.dart';

class BuiltInConnectionTypes {
  const BuiltInConnectionTypes._();

  static final definitions = <ConnectionTypeDefinition>[
    _characterRelationship('friendOf', 'Friend', undirected: true),
    _characterRelationship('enemyOf', 'Enemy', undirected: true),
    _characterRelationship('alliedWith', 'Ally', undirected: true),
    _characterRelationship('rivalOf', 'Rival', undirected: true),
    _characterRelationship('partnerOf', 'Partner', undirected: true,
        extra: _unionMetadata),
    _characterRelationship('parentOf', 'Parent of',
        inverseLabel: 'Child of', extra: _parentageMetadata),
    _characterRelationship(
      'guardianOf',
      'Guardian of',
      inverseLabel: 'Ward of',
    ),
    _characterRelationship('mentors', 'Mentor of', inverseLabel: 'Student of'),
    _characterRelationship(
      'protects',
      'Protects',
      inverseLabel: 'Protected by',
    ),
    _characterRelationship(
      'employs',
      'Employs',
      inverseLabel: 'Employed by',
    ),
    _characterRelationship('trusts', 'Trusts', inverseLabel: 'Trusted by'),
    _characterRelationship(
      'distrusts',
      'Distrusts',
      inverseLabel: 'Distrusted by',
    ),
    const ConnectionTypeDefinition(
      id: 'memberOf',
      displayName: 'Member of',
      sourceTypeIds: ['character'],
      targetTypeIds: ['faction', 'organisation'],
      inverseLabel: 'Has member',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
      metadataFields: [
        // Seniority is structural; the title is authorial. `role` is a closed
        // ladder the app can sort, band and colour, so a roster can put a
        // leader above an initiate and compare a guild's shape to a war band's.
        // `rank` stays open beside it so the Order can have a Grand Magister
        // without the vocabulary needing to know the word.
        //
        // Seven values rather than thirty: the shortest ladder every group kind
        // in NEXT.md §6 maps onto — court, guild, war band, council, cult,
        // crew and criminal network alike. See
        // `docs/relationship-canvas-implementation-map.md`.
        const RecordFieldDefinition(
          id: 'role',
          label: 'Role',
          type: RecordFieldType.singleChoice,
          order: 0,
          options: [
            'Founder',
            'Leader',
            'Second',
            'Officer',
            'Member',
            'Initiate',
            'Former',
          ],
        ),
        RecordFieldDefinition(
          id: 'rank',
          label: 'Rank',
          type: RecordFieldType.shortText,
          order: 1,
        ),
        RecordFieldDefinition(
          id: 'joinedDate',
          label: 'Joined date',
          type: RecordFieldType.date,
          order: 2,
        ),
        RecordFieldDefinition(
          id: 'leftDate',
          label: 'Left date',
          type: RecordFieldType.date,
          order: 3,
        ),
        RecordFieldDefinition(
          id: 'status',
          label: 'Status',
          type: RecordFieldType.shortText,
          order: 4,
        ),
      ],
    ),
    const ConnectionTypeDefinition(
      id: 'livesIn',
      displayName: 'Lives in',
      sourceTypeIds: ['character'],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Has resident',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'controls',
      displayName: 'Controls',
      sourceTypeIds: ['character', 'faction', 'organisation', 'government'],
      targetTypeIds: [
        ...WorldRecordTypes.spatialTypeIds,
        'faction',
        'organisation',
        'resource',
      ],
      inverseLabel: 'Controlled by',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    // The land a people holds (`civilisation_record_types.dart`). Not
    // `locatedIn`, which places a thing, nor `controls`, which is political
    // rule and belongs to a government. Time-bounded, because peoples move,
    // conquer and are driven out.
    ConnectionTypeDefinition(
      id: 'occupies',
      displayName: 'Occupies',
      sourceTypeIds: const [CivilisationRecordTypes.civilisationTypeId],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Occupied by',
      temporalSupport: true,
      metadataFields: _timeBoundedMetadata,
      builtIn: true,
      sourcePackId: CivilisationRecordTypes.packId,
    ),
    const ConnectionTypeDefinition(
      id: 'locatedIn',
      displayName: 'Located in',
      sourceTypeIds: [
        ...WorldRecordTypes.spatialTypeIds,
        'item',
        'artefact',
        'faction',
      ],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Contains',
      // A placement can be time-bounded: the Resolute is located in Port
      // Varen from chapter three to chapter nine, then in the Shattered
      // Strait. Declared here, once, so a moving vessel and a moved heirloom
      // are the same edge — no position store and no motion engine anywhere.
      temporalSupport: true,
      metadataFields: _timeBoundedMetadata,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'owns',
      displayName: 'Owns',
      sourceTypeIds: ['character', 'faction', 'organisation'],
      targetTypeIds: ['item', 'artefact', 'weapon'],
      inverseLabel: 'Owned by',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'uses',
      displayName: 'Uses',
      sourceTypeIds: ['character', 'faction', 'organisation'],
      targetTypeIds: ['item', 'artefact', 'weapon', 'technology'],
      inverseLabel: 'Used by',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'appearsIn',
      displayName: 'Appears in',
      // Widened beyond the original twelve so any Codex entity can record a
      // book, chapter or scene appearance. Every id is named, so the edge
      // stays typed instead of becoming another wildcard.
      sourceTypeIds: [
        'character',
        'person',
        'historical-figure',
        'public-figure',
        'deity',
        'entity-state',
        'faction',
        'organisation',
        'house',
        'clan',
        'guild',
        'company',
        'military-unit',
        'government',
        'institution',
        'item',
        'artefact',
        'weapon',
        'armour',
        'vehicle',
        'document',
        'species',
        'race',
        'creature',
        'monster',
        'language',
        'culture',
        'religion',
        'magic-system',
        'technology',
        'concept',
        'secret',
        'general-lore',
        'historical-event',
        ...WorldRecordTypes.spatialTypeIds,
        ...PlotRecordTypes.recordTypeIds,
      ],
      targetTypeIds: ['scene', 'chapter', 'book'],
      // The source list names `general-lore` to mean "any Codex entry", and
      // since permission resolves through inheritance (#84) that is now
      // literally every record type — the manuscript's own containers
      // included. They are the one thing this edge cannot mean: a chapter does
      // not appear in a book, it *is* part of one, and `partOf` says that.
      excludedSourceTypeIds: BuiltInRecordTypes.manuscriptStructureTypeIds,
      inverseLabel: 'Features',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
      // Book-usage detail lives here. ConnectionTypeRegistry._validateMetadata
      // rejects any key a definition does not declare, so an appearance cannot
      // carry a role or a status until the field exists.
      metadataFields: [
        RecordFieldDefinition(
          id: 'role',
          label: 'Role',
          type: RecordFieldType.shortText,
          order: 0,
        ),
        RecordFieldDefinition(
          id: 'firstAppearance',
          label: 'First appearance',
          type: RecordFieldType.shortText,
          order: 1,
        ),
        RecordFieldDefinition(
          id: 'lastAppearance',
          label: 'Last appearance',
          type: RecordFieldType.shortText,
          order: 2,
        ),
        RecordFieldDefinition(
          id: 'status',
          label: 'Status in this book',
          type: RecordFieldType.shortText,
          order: 3,
        ),
        RecordFieldDefinition(
          id: 'notes',
          label: 'Notes',
          type: RecordFieldType.longText,
          order: 4,
        ),
      ],
    ),
    const ConnectionTypeDefinition(
      id: 'mentionedIn',
      displayName: 'Mentioned in',
      sourceTypeIds: ['character'],
      targetTypeIds: ['scene', 'chapter', 'book'],
      inverseLabel: 'Mentions',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'bornIn',
      displayName: 'Born in',
      sourceTypeIds: ['character'],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Birthplace of',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'worksIn',
      displayName: 'Works in',
      sourceTypeIds: ['character'],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Workplace of',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'visits',
      displayName: 'Visits',
      sourceTypeIds: ['character'],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Visited by',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'carries',
      displayName: 'Carries',
      sourceTypeIds: ['character'],
      targetTypeIds: ['item', 'artefact', 'weapon'],
      inverseLabel: 'Carried by',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'pursues',
      displayName: 'Pursues',
      sourceTypeIds: [
        'character',
        'faction',
        'plotline',
        'story',
        'world',
      ],
      targetTypeIds: ['goal', 'plot-thread'],
      inverseLabel: 'Pursued by',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'hasArc',
      displayName: 'Has arc',
      sourceTypeIds: ['character', 'story', 'plotline', 'relationship'],
      targetTypeIds: [
        'plot-thread',
        'arc',
        'character-arc',
        'relationship-arc',
        'world-arc',
        'political-arc',
        'romance-arc',
        'mystery-arc',
      ],
      inverseLabel: 'Character arc for',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'knows',
      displayName: 'Knows',
      sourceTypeIds: ['character'],
      targetTypeIds: ['*'],
      inverseLabel: 'Known by',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
      metadataFields: [
        RecordFieldDefinition(
          id: 'knowledgeState',
          label: 'Knowledge state',
          type: RecordFieldType.singleChoice,
          order: 0,
          options: [
            'Knows',
            "Doesn't Know",
            'Suspects',
            'Believes',
            'Misunderstands',
            'Has Forgotten',
            // October 3, 2026 (AOS-Write PLAN.md §3.59): a character who
            // knows and says otherwise, and one who knows and keeps it.
            'Lies About',
            'Conceals',
          ],
        ),
        RecordFieldDefinition(
          id: 'private',
          label: 'Private knowledge',
          type: RecordFieldType.boolean,
          order: 1,
        ),
        // Where they learned it: the scene, or the event, that tells them.
        // `knowledge_ledger.dart` reads it to say who knows what *as of* a
        // point in the book.
        RecordFieldDefinition(
          id: 'learnedIn',
          label: 'Learned in',
          type: RecordFieldType.recordReference,
          order: 2,
          referenceTypeIds: ['scene', ...TimelineRecordTypes.recordTypeIds],
          description: 'The scene or event in which they learn it.',
        ),
      ],
    ),
    const ConnectionTypeDefinition(
      id: 'occursAt',
      displayName: 'Occurs at',
      sourceTypeIds: [
        ...TimelineRecordTypes.recordTypeIds,
        'historical-event',
        'scene',
        ...PlotRecordTypes.recordTypeIds,
      ],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      inverseLabel: 'Hosts event',
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'involves',
      displayName: 'Involves',
      sourceTypeIds: [
        ...TimelineRecordTypes.recordTypeIds,
        'historical-event',
        'scene',
      ],
      targetTypeIds: ['character', 'faction', 'organisation'],
      inverseLabel: 'Involved in',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'represents',
      displayName: 'Represents',
      sourceTypeIds: ['map-marker'],
      targetTypeIds: ['*'],
      inverseLabel: 'Represented by',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'documents',
      displayName: 'Documents',
      sourceTypeIds: [
        'codex-entry',
        'reference',
        'entity-state',
        ...ResearchRecordTypes.recordTypeIds,
      ],
      targetTypeIds: ['*'],
      inverseLabel: 'Documented by',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    const ConnectionTypeDefinition(
      id: 'partOf',
      displayName: 'Part of',
      sourceTypeIds: ['*'],
      targetTypeIds: ['*'],
      inverseLabel: 'Contains',
      builtIn: true,
      sourcePackId: 'authoros-core',
      // Where an entry sits in a bible it is part of (`bible.dart`,
      // AOS-Write PLAN.md §3.58). Optional, and meaningless on any other
      // `partOf`, which carries none.
      metadataFields: [
        RecordFieldDefinition(
          id: 'bibleSection',
          label: 'Bible section',
          type: RecordFieldType.shortText,
          order: 0,
        ),
      ],
    ),
    // The series spine. Typed on both endpoints rather than reusing the
    // wildcard `partOf`, so a book's place in its series is a fact the
    // registry can check.
    const ConnectionTypeDefinition(
      id: 'bookInSeries',
      displayName: 'Book in series',
      sourceTypeIds: ['book'],
      targetTypeIds: ['series'],
      inverseLabel: 'Has book',
      builtIn: true,
      sourcePackId: 'authoros-series-core',
      metadataFields: [
        RecordFieldDefinition(
          id: 'order',
          label: 'Order in series',
          type: RecordFieldType.number,
          order: 0,
        ),
      ],
    ),
    // A book's state record belongs to exactly one book. Typed both ways so a
    // state can never be attached to something that is not a book.
    const ConnectionTypeDefinition(
      id: 'stateInBook',
      displayName: 'State in book',
      sourceTypeIds: ['entity-state'],
      targetTypeIds: ['book'],
      inverseLabel: 'Has entity state',
      builtIn: true,
      sourcePackId: 'authoros-series-core',
    ),
    const ConnectionTypeDefinition(
      id: 'relatedTo',
      displayName: 'Related to',
      sourceTypeIds: ['*'],
      targetTypeIds: ['*'],
      direction: ConnectionDirection.undirected,
      inverseLabel: 'Related to',
      builtIn: true,
      sourcePackId: 'authoros-core',
    ),
    ..._foundationRelationships,
    ..._worldRelationships,
    ..._timelineRelationships(const {
      'before': ('Before', 'After'),
      'after': ('After', 'Before'),
      'during': ('During', 'Contains'),
      'overlaps': ('Overlaps', 'Overlaps'),
      'concurrentWith': ('Concurrent with', 'Concurrent with'),
      'causedBy': ('Caused by', 'Caused'),
      'repeats': ('Repeats', 'Repeated by'),
      'changed': ('Changed', 'Changed by'),
      'founded': ('Founded', 'Founded by'),
      'destroyed': ('Destroyed', 'Destroyed by'),
      'changedBordersOf': ('Changed borders of', 'Borders changed by'),
      'tookPlaceIn': ('Took place in', 'Hosted'),
      'depictedIn': ('Depicted in', 'Depicts'),
      'occursDuring': ('Occurs during', 'Includes'),
      'witnessed': ('Witnessed', 'Witnessed by'),
      'changedDuring': ('Changed during', 'Changed'),
      'presentAt': ('Present at', 'Had present'),
      'established': ('Established', 'Established by'),
      'created': ('Created', 'Created by'),
      'introduced': ('Introduced', 'Introduced by'),
      'signed': ('Signed', 'Signed by'),
      'lost': ('Lost', 'Lost by'),
      'covers': ('Covers', 'Covered by'),
    }),
    ..._codexRelationships(const {
      'ruledBy': ('Ruled by', 'Rules'),
      'foundedBy': ('Founded by', 'Founded'),
      'influences': ('Influences', 'Influenced by'),
      'worships': ('Worships', 'Worshipped by'),
      'belongsTo': ('Belongs to', 'Has member'),
      'createdBy': ('Created by', 'Created'),
      'ownedBy': ('Owned by', 'Owns'),
      'usedBy': ('Used by', 'Uses'),
      'originatedFrom': ('Originated from', 'Origin of'),
      'caused': ('Caused', 'Caused by'),
      'resultedIn': ('Resulted in', 'Result of'),
      'precedes': ('Precedes', 'Follows'),
      'follows': ('Follows', 'Precedes'),
      'requires': ('Requires', 'Required by'),
      'contradicts': ('Contradicts', 'Contradicted by'),
      'supports': ('Supports', 'Supported by'),
      'inspired': ('Inspired', 'Inspired by'),
      'associatedWith': ('Associated with', 'Associated with'),
      'connectedTo': ('Connected to', 'Connected to'),
      'speaks': ('Speaks', 'Spoken by'),
      'participatedIn': ('Participated in', 'Had participant'),
      'practices': ('Practices', 'Practised by'),
      'revealedIn': ('Revealed in', 'Reveals'),
      'introducedIn': ('Introduced in', 'Introduces'),
      'explainedIn': ('Explained in', 'Explains'),
      'foreshadowedIn': ('Foreshadowed in', 'Foreshadows'),
      'confirmedIn': ('Confirmed in', 'Confirms'),
    }),
    ..._plotRelationships,
  ];

  /// The architectural relationship primitives every Studio may rely on.
  ///
  /// Studio-specific relationship types stay in [definitions] alongside these;
  /// this list only names the foundation vocabulary so a future Studio can
  /// assert its presence without hard-coding the whole registry.
  static const List<String> foundationTypeIds = [
    'appearsIn',
    'belongsTo',
    'childOf',
    'contains',
    'follows',
    'involves',
    'locatedAt',
    'memberOf',
    'occursAt',
    'parentOf',
    'partOf',
    'precedes',
    'references',
    'relatedTo',
  ];

  /// The built-in edges, with relationship permission resolved through the
  /// record tree.
  ///
  /// [recordTypes] defaults to the built-in record registry, so the ordinary
  /// caller gets inheritance-aware permission without asking for it — which is
  /// the point of #84. Pass a project registry instead when custom record
  /// types are in play, so a custom child of `item` is reachable by the same
  /// edges its parent is.
  static ConnectionTypeRegistry registry({
    Iterable<ConnectionTypeDefinition> additionalDefinitions = const [],
    RecordTypeRegistry? recordTypes,
  }) =>
      ConnectionTypeRegistry(
        [...definitions, ...additionalDefinitions],
        recordTypes: recordTypes ?? BuiltInRecordTypes.registry(),
      );
}

/// Relationship primitives that belong to no single Studio.
///
/// They carry no metadata fields on purpose: a foundation edge should stay
/// cheap to create and strict about what it accepts, while richer Studio
/// relationship types keep their own metadata schemas.
final _foundationRelationships = <ConnectionTypeDefinition>[
  _foundationRelationship('childOf', 'Child of', 'Parent of'),
  _foundationRelationship('locatedAt', 'Located at', 'Location of'),
  _foundationRelationship('references', 'References', 'Referenced by'),
];

ConnectionTypeDefinition _foundationRelationship(
  String id,
  String displayName,
  String inverseLabel,
) =>
    ConnectionTypeDefinition(
      id: id,
      displayName: displayName,
      sourceTypeIds: const ['*'],
      targetTypeIds: const ['*'],
      inverseLabel: inverseLabel,
      builtIn: true,
      sourcePackId: 'authoros-core',
    );

final _plotRelationships = <ConnectionTypeDefinition>[
  ..._plotLinkDefinitions(const {
    'causes': ('Causes', 'Caused by'),
    'changes': ('Changes', 'Changed by'),
    'paidOffBy': ('Paid off by', 'Pays off'),
    'plannedFor': ('Planned for', 'Has planned beat'),
    'fulfilledBy': ('Fulfilled by', 'Fulfils'),
    'depicts': ('Depicts', 'Depicted by'),
    'resolvesIn': ('Resolves in', 'Resolves'),
    'dependsOn': ('Depends on', 'Required by'),
    'opposes': ('Opposes', 'Opposed by'),
    'motivatedBy': ('Motivated by', 'Motivates'),
    'hasStake': ('Has stake', 'Stake in'),
  }),
];

List<ConnectionTypeDefinition> _plotLinkDefinitions(
  Map<String, (String, String)> definitions,
) =>
    definitions.entries
        .map(
          (entry) => ConnectionTypeDefinition(
            id: entry.key,
            displayName: entry.value.$1,
            sourceTypeIds: const ['*'],
            targetTypeIds: const ['*'],
            inverseLabel: entry.value.$2,
            builtIn: true,
            sourcePackId: 'authoros-core',
            extensionData: const {'plotStudio': true},
          ),
        )
        .toList(growable: false);

final _worldRelationships = <ConnectionTypeDefinition>[
  _openRelationship('contains', 'Contains', 'Contained by'),
  _spatial('inside', 'Inside', 'Contains'),
  _spatial('outside', 'Outside', 'Inside'),
  _spatial('surrounds', 'Surrounds', 'Surrounded by'),
  _spatial('crosses', 'Crosses', 'Crossed by'),
  _spatial('passesThrough', 'Passes through', 'Passed through by'),
  _openRelationship('leadsTo', 'Leads to', 'Led from'),
  _spatial('accessibleFrom', 'Accessible from', 'Provides access to'),
  _spatial('inaccessibleFrom', 'Inaccessible from', 'Cannot access'),
  _spatial('above', 'Above', 'Below'),
  _spatial('below', 'Below', 'Above'),
  _spatial('northOf', 'North of', 'South of'),
  _spatial('southOf', 'South of', 'North of'),
  _spatial('adjacentTo', 'Adjacent to', 'Adjacent to', undirected: true),
  _spatial('borders', 'Borders', 'Borders', undirected: true),
  _spatial('near', 'Near', 'Near', undirected: true),
  _spatial('farFrom', 'Far from', 'Far from', undirected: true),
  ConnectionTypeDefinition(
    id: 'maps',
    displayName: 'Maps',
    sourceTypeIds: [...WorldRecordTypes.mapTypeIds],
    // A map holds things as well as places. A floorplan with a bar drawn on it
    // says the bar is in that room, and the edge has to be able to say so or
    // the drawing and the graph disagree about a thing they can both see.
    targetTypeIds: [
      ...WorldRecordTypes.spatialTypeIds,
      ...BuiltInRecordTypes.itemTypeIds,
    ],
    inverseLabel: 'Mapped by',
    // `role` says how the map relates to the place: absent for "this map
    // shows this place among others" (every Map Studio placement), and
    // `interior` for "this map draws this place's inside" — the join that
    // makes free-form nesting walkable without a stored map tree.
    metadataFields: const [
      RecordFieldDefinition(
        id: 'role',
        label: 'Role',
        type: RecordFieldType.shortText,
        order: 0,
      ),
    ],
    builtIn: true,
    sourcePackId: 'authoros-world-core',
  ),
  const ConnectionTypeDefinition(
    id: 'onMap',
    displayName: 'On map',
    sourceTypeIds: ['map-marker'],
    targetTypeIds: [...WorldRecordTypes.mapTypeIds],
    inverseLabel: 'Has marker',
    builtIn: true,
    sourcePackId: 'authoros-world-core',
  ),
  const ConnectionTypeDefinition(
    id: 'routeFrom',
    displayName: 'Route from',
    sourceTypeIds: [...WorldRecordTypes.routeTypeIds],
    targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
    inverseLabel: 'Starts route',
    builtIn: true,
    sourcePackId: 'authoros-world-core',
  ),
  const ConnectionTypeDefinition(
    id: 'routeTo',
    displayName: 'Route to',
    sourceTypeIds: [...WorldRecordTypes.routeTypeIds],
    targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
    inverseLabel: 'Ends route',
    builtIn: true,
    sourcePackId: 'authoros-world-core',
  ),
  ..._characterLocationRelationships(const {
    'currentlyAt': ('Currently at', 'Current location of'),
    'previouslyAt': ('Previously at', 'Previous location of'),
    'homeAt': ('Home', 'Home of'),
    'safehouseAt': ('Safehouse', 'Safehouse of'),
    'favouriteLocation': ('Favourite location', 'Favoured by'),
    'forbiddenFrom': ('Forbidden from', 'Forbidden to'),
    'fromLocation': ('From', 'Origin of'),
  }),
  _openRelationship('headquartersAt', 'Headquarters at', 'Headquarters of'),
  _openRelationship('rules', 'Rules', 'Ruled by'),
  _openRelationship('governedBy', 'Governed by', 'Governs'),
  _openRelationship('hasCulture', 'Has culture', 'Culture of'),
  _openRelationship('knownFor', 'Known for', 'Associated location'),
];

ConnectionTypeDefinition _spatial(
  String id,
  String displayName,
  String inverseLabel, {
  bool undirected = false,
}) =>
    ConnectionTypeDefinition(
      id: id,
      displayName: displayName,
      sourceTypeIds: [...WorldRecordTypes.spatialTypeIds],
      targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
      direction: undirected
          ? ConnectionDirection.undirected
          : ConnectionDirection.directed,
      inverseLabel: inverseLabel,
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-world-core',
      metadataFields: _worldRelationshipMetadata,
    );

Iterable<ConnectionTypeDefinition> _characterLocationRelationships(
  Map<String, (String, String)> definitions,
) =>
    definitions.entries.map(
      (entry) => ConnectionTypeDefinition(
        id: entry.key,
        displayName: entry.value.$1,
        sourceTypeIds: const ['character'],
        targetTypeIds: [...WorldRecordTypes.spatialTypeIds],
        inverseLabel: entry.value.$2,
        temporalSupport: true,
        builtIn: true,
        sourcePackId: 'authoros-world-core',
        metadataFields: _worldRelationshipMetadata,
      ),
    );

ConnectionTypeDefinition _openRelationship(
  String id,
  String displayName,
  String inverseLabel,
) =>
    ConnectionTypeDefinition(
      id: id,
      displayName: displayName,
      sourceTypeIds: const ['*'],
      targetTypeIds: const ['*'],
      inverseLabel: inverseLabel,
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-world-core',
      metadataFields: _worldRelationshipMetadata,
    );

/// The minimal time-bounding surface: when a fact starts and when it stops
/// being true. Shared by every foundation relationship that gains temporal
/// support, so "time-bounded" means one thing everywhere.
const _timeBoundedMetadata = <RecordFieldDefinition>[
  RecordFieldDefinition(
      id: 'startDate',
      label: 'Start date',
      type: RecordFieldType.date,
      order: 0),
  RecordFieldDefinition(
      id: 'endDate', label: 'End date', type: RecordFieldType.date, order: 1),
];

const _worldRelationshipMetadata = <RecordFieldDefinition>[
  RecordFieldDefinition(
      id: 'startDate',
      label: 'Start date',
      type: RecordFieldType.date,
      order: 0),
  RecordFieldDefinition(
      id: 'endDate', label: 'End date', type: RecordFieldType.date, order: 1),
  RecordFieldDefinition(
      id: 'distance',
      label: 'Distance',
      type: RecordFieldType.shortText,
      order: 2),
  RecordFieldDefinition(
      id: 'travelTime',
      label: 'Travel time',
      type: RecordFieldType.shortText,
      order: 3),
  RecordFieldDefinition(
      id: 'difficulty',
      label: 'Difficulty',
      type: RecordFieldType.shortText,
      order: 4),
  RecordFieldDefinition(
      id: 'cost', label: 'Cost', type: RecordFieldType.shortText, order: 5),
  RecordFieldDefinition(
      id: 'danger', label: 'Danger', type: RecordFieldType.shortText, order: 6),
  RecordFieldDefinition(
      id: 'restrictions',
      label: 'Restrictions',
      type: RecordFieldType.longText,
      order: 7),
  RecordFieldDefinition(
      id: 'conditions',
      label: 'Conditions',
      type: RecordFieldType.longText,
      order: 8),
  RecordFieldDefinition(
      id: 'notes', label: 'Notes', type: RecordFieldType.longText, order: 9),
];

Iterable<ConnectionTypeDefinition> _timelineRelationships(
  Map<String, (String, String)> definitions,
) =>
    definitions.entries.map(
      (entry) => ConnectionTypeDefinition(
        id: entry.key,
        displayName: entry.value.$1,
        sourceTypeIds: const ['*'],
        targetTypeIds: const ['*'],
        inverseLabel: entry.value.$2,
        temporalSupport: true,
        builtIn: true,
        sourcePackId: 'authoros-timeline-core',
        metadataFields: _timelineRelationshipMetadata,
      ),
    );

const _timelineRelationshipMetadata = <RecordFieldDefinition>[
  RecordFieldDefinition(
    id: 'offset',
    label: 'Offset',
    type: RecordFieldType.number,
    order: 0,
  ),
  RecordFieldDefinition(
    id: 'unit',
    label: 'Unit',
    type: RecordFieldType.shortText,
    order: 1,
  ),
  RecordFieldDefinition(
    id: 'description',
    label: 'Description',
    type: RecordFieldType.longText,
    order: 2,
  ),
];

Iterable<ConnectionTypeDefinition> _codexRelationships(
  Map<String, (String, String)> definitions,
) =>
    definitions.entries.map(
      (entry) => ConnectionTypeDefinition(
        id: entry.key,
        displayName: entry.value.$1,
        sourceTypeIds: const ['*'],
        targetTypeIds: const ['*'],
        inverseLabel: entry.value.$2,
        temporalSupport: true,
        builtIn: true,
        sourcePackId: 'authoros-codex-core',
        metadataFields: _codexMetadataFields,
      ),
    );

const _codexMetadataFields = <RecordFieldDefinition>[
  RecordFieldDefinition(
    id: 'strength',
    label: 'Relationship strength',
    type: RecordFieldType.rating,
    order: 0,
  ),
  RecordFieldDefinition(
    id: 'startDate',
    label: 'Start date',
    type: RecordFieldType.date,
    order: 1,
  ),
  RecordFieldDefinition(
    id: 'endDate',
    label: 'End date',
    type: RecordFieldType.date,
    order: 2,
  ),
  RecordFieldDefinition(
    id: 'status',
    label: 'Status',
    type: RecordFieldType.shortText,
    order: 3,
  ),
  RecordFieldDefinition(
    id: 'private',
    label: 'Private',
    type: RecordFieldType.boolean,
    order: 4,
  ),
  RecordFieldDefinition(
    id: 'secret',
    label: 'Secret',
    type: RecordFieldType.boolean,
    order: 5,
  ),
  RecordFieldDefinition(
    id: 'notes',
    label: 'Notes',
    type: RecordFieldType.longText,
    order: 6,
  ),
  RecordFieldDefinition(
    id: 'context',
    label: 'Context',
    type: RecordFieldType.longText,
    order: 7,
  ),
  RecordFieldDefinition(
    id: 'source',
    label: 'Source',
    type: RecordFieldType.shortText,
    order: 8,
  ),
  RecordFieldDefinition(
    id: 'confidence',
    label: 'Confidence',
    type: RecordFieldType.rating,
    order: 9,
  ),
];

/// What kind of union a `partnerOf` is (October 10, 2026, for AOS
/// Worldsmith's Ancestry Room): betrothal, marriage and its ends. Beside the
/// shared `beginning` and `ending` dates, so a widowing has a date and a
/// betrothal that never became a marriage is still on record. Partners with
/// no union recorded are partners, as before.
const _unionMetadata = [
  RecordFieldDefinition(
    id: 'union',
    label: 'Union',
    type: RecordFieldType.singleChoice,
    order: 20,
    allowCustomValues: true,
    options: [
      'Betrothed',
      'Married',
      'Separated',
      'Divorced',
      'Annulled',
      'Widowed',
    ],
  ),
];

/// Legitimacy and certainty of a `parentOf` (October 10, 2026, with
/// [_unionMetadata]). Adoption and guardianship stay `guardianOf`: this is
/// about a child of the body, and whether the world accepts it.
const _parentageMetadata = [
  RecordFieldDefinition(
    id: 'legitimacy',
    label: 'Legitimacy',
    type: RecordFieldType.singleChoice,
    order: 20,
    allowCustomValues: true,
    options: ['Legitimate', 'Born outside marriage', 'Legitimised'],
  ),
  RecordFieldDefinition(
    id: 'parentage',
    label: 'Parentage',
    type: RecordFieldType.singleChoice,
    order: 21,
    allowCustomValues: true,
    options: ['Certain', 'Disputed', 'Claimed'],
  ),
];

ConnectionTypeDefinition _characterRelationship(
  String id,
  String displayName, {
  String? inverseLabel,
  bool undirected = false,
  List<RecordFieldDefinition> extra = const [],
}) =>
    ConnectionTypeDefinition(
      id: id,
      displayName: displayName,
      sourceTypeIds: const ['character'],
      targetTypeIds: const ['character'],
      direction: undirected
          ? ConnectionDirection.undirected
          : ConnectionDirection.directed,
      inverseLabel: inverseLabel ?? displayName,
      temporalSupport: true,
      builtIn: true,
      sourcePackId: 'authoros-character-core',
      metadataFields: [
        const RecordFieldDefinition(
          id: 'strength',
          label: 'Strength',
          type: RecordFieldType.rating,
          order: 0,
        ),
        const RecordFieldDefinition(
          id: 'status',
          label: 'Status',
          type: RecordFieldType.shortText,
          order: 1,
        ),
        const RecordFieldDefinition(
          id: 'beginning',
          label: 'Beginning',
          type: RecordFieldType.date,
          order: 2,
        ),
        const RecordFieldDefinition(
          id: 'ending',
          label: 'Ending',
          type: RecordFieldType.date,
          order: 3,
        ),
        const RecordFieldDefinition(
          id: 'mutuality',
          label: 'Mutuality',
          type: RecordFieldType.shortText,
          order: 4,
        ),
        const RecordFieldDefinition(
          id: 'publicKnowledge',
          label: 'Public knowledge',
          type: RecordFieldType.boolean,
          order: 5,
        ),
        const RecordFieldDefinition(
          id: 'secret',
          label: 'Secret',
          type: RecordFieldType.boolean,
          order: 6,
        ),
        const RecordFieldDefinition(
          id: 'trust',
          label: 'Trust',
          type: RecordFieldType.rating,
          order: 7,
        ),
        const RecordFieldDefinition(
          id: 'conflict',
          label: 'Conflict',
          type: RecordFieldType.longText,
          order: 8,
        ),
        const RecordFieldDefinition(
          id: 'history',
          label: 'History',
          type: RecordFieldType.longText,
          order: 9,
        ),
        const RecordFieldDefinition(
          id: 'notes',
          label: 'Notes',
          type: RecordFieldType.longText,
          order: 10,
        ),
        ...extra,
      ],
    );
