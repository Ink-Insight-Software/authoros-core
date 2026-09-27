import 'alchemy_record_types.dart';
import 'architecture_record_types.dart';
import 'astronomy_record_types.dart';
import 'artifact_record_types.dart';
import 'bestiary_record_types.dart';
import 'bloodline_record_types.dart';
import 'character_chat.dart';
import 'curio_activation.dart';
import 'character_record_types.dart';
import 'interrogation_session.dart';
import 'climate_record_types.dart';
import 'culture_record_types.dart';
import 'ecosystem_record_types.dart';
import 'economy_record_types.dart';
import 'evolution_record_types.dart';
import 'government_record_types.dart';
import 'knowledge_graph_record_types.dart';
import 'language_record_types.dart';
import 'lore_record_types.dart';
import 'magic_record_types.dart';
import 'philosophy_record_types.dart';
import 'plot_record_types.dart';
import 'craft/craft_library.dart';
import 'record_scope.dart';
import 'record_types.dart';
import 'religion_record_types.dart';
import 'research_record_types.dart';
import 'specialist_system.dart';
import 'timeline_record_types.dart';
import 'travel_record_types.dart';
import 'weapon_record_types.dart';
import 'world_record_types.dart';
import 'build_flags.dart';

class BuiltInRecordTypes {
  const BuiltInRecordTypes._();

  /// The item family: a **thing**, as opposed to a place.
  ///
  /// Derived from [definitions] rather than listed, because it is already
  /// listed there — `artefact`, `weapon`, `armour`, `clothing` and `vehicle`
  /// are all declared as children of `item`, and a second copy of that list
  /// would be wrong within a month of anyone adding a sixth.
  ///
  /// Map Studio needs the family by name: a bed on a floorplan is an `item`
  /// with a position, and *placeable* turned out to be a different question
  /// from *is a place*.
  static final Set<String> itemTypeIds = {
    'item',
    for (final definition in definitions)
      if (definition.baseTypeId == 'item') definition.id,
  };

  static final List<RecordTypeDefinition> definitions = [
    _generalLore,
    CharacterRecordTypes.character,
    ...CharacterRecordTypes.templates,
    ...PlotRecordTypes.definitions,
    ...TimelineRecordTypes.definitions,
    ...ResearchRecordTypes.definitions,
    ...KnowledgeGraphRecordTypes.definitions,
    ...WorldRecordTypes.definitions,
    _faction,
    ...CultureRecordTypes.definitions,
    ...ClimateRecordTypes.definitions,
    ...EcosystemRecordTypes.definitions,
    ...EconomyRecordTypes.definitions,
    ...EvolutionRecordTypes.definitions,
    ...GovernmentRecordTypes.definitions,
    ...AlchemyRecordTypes.definitions,
    ...ArchitectureRecordTypes.definitions,
    ...AstronomyRecordTypes.definitions,
    ...ArtifactRecordTypes.definitions,
    ...BestiaryRecordTypes.definitions,
    ...BloodlineRecordTypes.definitions,
    ...TravelRecordTypes.definitions,
    ...WeaponRecordTypes.definitions,
    ...ReligionRecordTypes.definitions,
    ...LanguageRecordTypes.definitions,
    ...LoreRecordTypes.definitions,
    ...MagicRecordTypes.definitions,
    ...PhilosophyRecordTypes.definitions,
    _historicalEvent,
    _item,
    _material,
    _series,
    _book,
    _entityState,
    _specialistSystemState,
    _curioActivation,
    CharacterChatRecordTypes.session,
    InterrogationRecordTypes.session,
    ..._derivedChildren(const {
      'organisation': ('Organisation', 'factions', 'faction'),
      'guild': ('Guild', 'factions', 'faction'),
      'company': ('Company', 'factions', 'faction'),
      'military-unit': ('Military Unit', 'factions', 'faction'),
    }),
    ..._children(const {
      'technology': ('Technology', 'technology'),
      'institution': ('Institution', 'factions'),
      'profession': ('Profession', 'characters'),
      'person': ('Person', 'characters'),
      'historical-figure': ('Historical Figure', 'characters'),
      'public-figure': ('Public Figure', 'characters'),
      'rule': ('Rule', 'world'),
      'theory': ('Theory', 'lore'),
      'secret': ('Secret', 'plot'),
      'mystery': ('Mystery', 'plot'),
      'clue': ('Clue', 'plot'),
      'plot-thread': ('Plot Thread', 'plot'),
      'theme': ('Theme', 'plot'),
      'symbol': ('Symbol', 'plot'),
      'motif': ('Motif', 'plot'),
      'disease': ('Disease', 'world'),
      'medicine': ('Medicine', 'world'),
      'location-type': ('Location Type', 'locations'),
      'architectural-feature': ('Architectural Feature', 'locations'),
      'organisation-role': ('Organisation Role', 'factions'),
      'occupation': ('Occupation', 'characters'),
      'calendar-system': ('Calendar System', 'history'),
      'calendar-event': ('Calendar Event', 'history'),
      'technology-system': ('Technology System', 'technology'),
      'world-rule': ('World Rule', 'world'),
      'reference': ('Reference', 'reference'),
      'glossary-term': ('Glossary Term', 'reference'),
      'author-note': ('Author Note', 'reference'),
      // Phase 8D. Ideas Studio kept these in a `SharedPreferences` bucket with
      // no project in the key; this is the type that makes an idea an ordinary
      // record. A `general-lore` child like `author-note`, and for the same
      // reason: it needs a title and a body, and nothing the shared template
      // does not already declare.
      'story-idea': ('Story Idea', 'reference'),
      'custom-entry': ('Custom Entry', 'custom'),
      'project': ('Project', 'manuscript'),
      'document': ('Document', 'reference'),
      'chapter': ('Chapter', 'manuscript'),
      'scene': ('Scene', 'manuscript'),
      'other-custom-entry': ('Other Custom Entry', 'custom'),
    }),
    _legacyAlias('place', 'Place', 'location', 'places'),
    _legacyAlias('object', 'Object', 'item', 'items'),
    _legacyAlias('lore', 'Lore', 'general-lore', 'lore'),
    // There were two Eras. This one was a bare child of `historical-period`
    // with no fields, sitting in the template list beside `timeline-era` under
    // the same name, so an author picking "Era" got whichever the list handed
    // them — and one of the two could record nothing.
    //
    // It is an alias now, which is the shape this file already uses for
    // exactly this: `event` aliases `timeline-event`, one line below. The
    // record type does not go away, because Lock 6 says deactivation hides and
    // never deletes and an author may have eras stored under this id; what
    // changes is that it resolves the era template's fields instead of
    // nothing, and stops being offered for new records.
    //
    // It therefore also becomes a timeline record, which it always should have
    // been: `isTimelineRecord` resolves through the base chain, so an era an
    // author wrote here appears on the timeline it was always describing.
    _legacyAlias('era', 'Era', TimelineRecordTypes.eraTypeId, 'history'),
    // And the same for the period, one level up, for the same reason: there
    // were two Historical Periods, and the one declared here had no fields and
    // no way to get any. It aliases the timeline's, which inherits the era —
    // so a period reads as what it is, an era a historian named.
    _legacyAlias('historical-period', 'Historical Period',
        'timeline-historical-period', 'history'),
    _selectableAlias('general', 'General', 'general-lore', 'lore'),
    _selectableAlias('glossary', 'Glossary', 'glossary-term', 'reference'),
    _selectableAlias('custom', 'Custom', 'custom-entry', 'custom'),
    _selectableAlias('event', 'Event', 'timeline-event', 'timeline'),
  ];

  /// The manuscript itself, rather than anything written about in it.
  ///
  /// A project holds series, a series holds books, a book holds chapters, a
  /// chapter holds scenes. These are the containers an author writes *into*;
  /// every other record type is something the writing is *about*.
  ///
  /// Named because relationship permission resolves through inheritance, and
  /// these five descend from `general-lore` like everything else. An edge that
  /// names a base type to mean "any Codex entry" therefore admits them unless
  /// it says otherwise, which is how `appearsIn` briefly came to accept a book
  /// as appearing in a book.
  ///
  /// Deliberately does **not** include `entity-state`, which sits in the same
  /// category and is not a container: it is a per-book record of what a thing
  /// was like at that point in the series, and it is a legitimate source for
  /// `appearsIn` — declared as one, by name, since before this list existed.
  static const List<String> manuscriptStructureTypeIds = [
    'project',
    'series',
    'book',
    'chapter',
    'scene',
  ];

  /// The record identities the Universal Records foundation guarantees.
  ///
  /// Every id resolves through [registry]. Several are aliases over a richer
  /// Studio type (`event` over `timeline-event`, `object` over `item`), which
  /// is why this is a name list and not a second registry.
  static const List<String> foundationTypeIds = [
    'book',
    'chapter',
    'character',
    'event',
    'faction',
    'location',
    'lore',
    'object',
    'project',
    'research',
    'scene',
    'series',
  ];

  static RecordTypeRegistry registry({
    Iterable<RecordTypeDefinition> additionalDefinitions = const [],
  }) =>
      RecordTypeRegistry([...definitions, ...additionalDefinitions]);
}

// No longer const: `knowledgeStatus` resolves its per-option help from the
// craft library, and a lookup is not a const expression. `definitions` is a
// `static final` list, so nothing that reads this needed to change.
final _generalLore = RecordTypeDefinition(
  id: 'general-lore',
  name: 'Basic Lore',
  description: 'Structured knowledge that does not require a narrower type.',
  icon: 'auto_stories',
  categoryId: 'lore',
  fields: [
    const RecordFieldDefinition(
      id: 'name',
      label: 'Name',
      type: RecordFieldType.shortText,
      order: 0,
      extensionData: {'recordProperty': 'title', 'templateOwned': true},
    ),
    const RecordFieldDefinition(
      id: 'aliases',
      label: 'Aliases',
      type: RecordFieldType.list,
      order: 1,
      searchable: true,
      extensionData: {'templateOwned': true},
    ),
    const RecordFieldDefinition(
      id: 'summary',
      label: 'Summary',
      type: RecordFieldType.longText,
      order: 2,
    ),
    const RecordFieldDefinition(
      id: 'description',
      label: 'Description',
      type: RecordFieldType.richText,
      order: 3,
    ),
    const RecordFieldDefinition(
      id: 'notes',
      label: 'Notes',
      type: RecordFieldType.longText,
      order: 4,
    ),
    RecordFieldDefinition(
      id: 'knowledgeStatus',
      label: 'Knowledge status',
      type: RecordFieldType.singleChoice,
      order: 5,
      defaultValue: 'Unknown',
      // What is true, what somebody believes, and what the reader has been
      // told are three different things, and this field has always been where
      // they are kept apart. It said so nowhere.
      optionDescriptions:
          CraftLibrary.describeOptions('builtin.general-lore.knowledgeStatus'),
      options: [
        'Confirmed',
        'Suspected',
        'Rumoured',
        'False',
        'Unknown',
        'Secret',
        'Revealed',
      ],
      extensionData: {'visibility': 'author', 'templateOwned': true},
    ),
    const RecordFieldDefinition(
      id: 'sourceReferences',
      label: 'Source references',
      type: RecordFieldType.list,
      order: 6,
      extensionData: {'stableIds': true, 'templateOwned': true},
    ),
  ],
  sections: [
    const RecordTemplateSection(
      id: 'overview',
      title: 'Overview',
      order: 0,
      fieldIds: ['name', 'aliases', 'summary', 'description'],
    ),
    const RecordTemplateSection(
      id: 'notes',
      title: 'Notes',
      order: 1,
      fieldIds: ['notes', 'knowledgeStatus', 'sourceReferences'],
      collapsedByDefault: true,
    ),
  ],
  suggestedLinkTypeIds: ['relatedTo', 'mentionedIn'],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
  exportBehavior: {'includeStructuredFields': true},
);

const _world = RecordTypeDefinition(
  id: 'world',
  name: 'World',
  description: 'A canonical world shared with World Studio.',
  icon: 'public',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
      id: 'geography',
      label: 'Geography',
      type: RecordFieldType.longText,
      order: 100,
    ),
    RecordFieldDefinition(
      id: 'politics',
      label: 'Politics',
      type: RecordFieldType.longText,
      order: 101,
    ),
    RecordFieldDefinition(
      id: 'economy',
      label: 'Economy',
      type: RecordFieldType.longText,
      order: 102,
    ),
    RecordFieldDefinition(
      id: 'history',
      label: 'History',
      type: RecordFieldType.longText,
      order: 103,
    ),
  ],
  sections: [
    RecordTemplateSection(
      id: 'worldbuilding',
      title: 'Worldbuilding',
      order: 10,
      fieldIds: ['geography', 'politics', 'economy', 'history'],
    ),
  ],
  suggestedLinkTypeIds: ['contains', 'governedBy'],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
);

final _location = _deepTemplate(
  id: 'location',
  name: 'Location',
  categoryId: 'locations',
  sectionId: 'geography',
  sectionTitle: 'Geography',
  fields: const [
    ('locationType', 'Type', RecordFieldType.shortText),
    ('geography', 'Geography', RecordFieldType.longText),
    ('climate', 'Climate', RecordFieldType.longText),
    ('population', 'Population', RecordFieldType.shortText),
    ('culture', 'Culture', RecordFieldType.recordReference),
    ('government', 'Government', RecordFieldType.recordReference),
    ('economy', 'Economy', RecordFieldType.longText),
    ('history', 'History', RecordFieldType.richText),
    ('importantPeople', 'Important People', RecordFieldType.list),
    ('factions', 'Factions', RecordFieldType.list),
    ('nearbyLocations', 'Nearby Locations', RecordFieldType.list),
    ('secrets', 'Secrets', RecordFieldType.richText),
  ],
  suggestedLinks: const ['locatedIn', 'contains', 'governedBy'],
);

final _faction = _deepTemplate(
  id: 'faction',
  name: 'Faction',
  categoryId: 'factions',
  sectionId: 'factions',
  sectionTitle: 'Faction',
  fields: const [
    ('factionType', 'Type', RecordFieldType.shortText),
    ('purpose', 'Purpose', RecordFieldType.longText),
    ('leadership', 'Leadership', RecordFieldType.list),
    ('members', 'Members', RecordFieldType.list),
    ('hierarchy', 'Hierarchy', RecordFieldType.richText),
    ('territory', 'Territory', RecordFieldType.recordReference),
    ('allies', 'Allies', RecordFieldType.list),
    ('enemies', 'Enemies', RecordFieldType.list),
    ('resources', 'Resources', RecordFieldType.longText),
    ('beliefs', 'Beliefs', RecordFieldType.richText),
    ('history', 'History', RecordFieldType.richText),
    ('secrets', 'Secrets', RecordFieldType.richText),
  ],
  suggestedLinks: const ['memberOf', 'alliedWith', 'enemyOf'],
  // Politics & Power's Phase 3 extension. The type stays unclaimed — Economy
  // and Bloodline are still free to claim it — because what is sold here is
  // four *fields*, not the record. A faction remains a free record an author
  // creates, edits, links, searches and exports whatever they own.
  //
  // The pairing is the point: `officialAllegiance` is what a faction says in
  // public and `actualAllegiance` is what is true, and a political story is
  // usually the distance between them. Free `leadership`, `allies` and
  // `secrets` cannot express that distance — they are one list each, with no
  // way to say that the published answer and the real one differ.
  specialistSectionId: 'faction-politics',
  specialistSectionTitle: 'Politics',
  // Gated on the same build flag as the room, because the fields are part of
  // the same unfinished thing: a build without Politics & Power offers a
  // faction the twelve free fields it has always had, and nothing that hints
  // at a room the author has not got.
  //
  // This withholds what is *offered*, never what is *kept*. A project authored
  // in a flagged build keeps every stored value when opened here — the free
  // types' readers preserve stored keys outside the template, which
  // `politics_and_power_gate_test.dart` holds as the property that matters.
  specialistFields: !politicsAndPowerEnabled
      ? const []
      : const [
    RecordFieldDefinition(
      id: 'officialAllegiance',
      label: 'Official allegiance',
      type: RecordFieldType.recordReference,
      order: 200,
      description: 'Who it answers to in public.',
      referenceTypeIds: ['government', 'faction', 'organisation', 'character'],
      soldWith: 'world.politicalModelling',
      extensionData: {'visibility': 'default', 'templateOwned': true},
    ),
    RecordFieldDefinition(
      id: 'actualAllegiance',
      label: 'Actual allegiance',
      type: RecordFieldType.recordReference,
      order: 201,
      description: 'Who it answers to in fact. Leave empty when they are the '
          'same — an empty field here says "no secret", which is itself worth '
          'being able to say.',
      referenceTypeIds: ['government', 'faction', 'organisation', 'character'],
      soldWith: 'world.politicalModelling',
      extensionData: {'visibility': 'default', 'templateOwned': true},
    ),
    RecordFieldDefinition(
      id: 'politicalStanding',
      label: 'Standing',
      type: RecordFieldType.singleChoice,
      order: 202,
      description: 'Where it sits as the story opens.',
      options: [
        'Ascendant',
        'Secure',
        'Holding',
        'Declining',
        'Suppressed',
        'Outlawed',
        'In exile',
        'Broken',
      ],
      allowCustomValues: true,
      soldWith: 'world.politicalModelling',
      extensionData: {'visibility': 'default', 'templateOwned': true},
    ),
    RecordFieldDefinition(
      id: 'leverage',
      label: 'Leverage',
      type: RecordFieldType.richText,
      order: 203,
      description: 'What it holds over others, and what is held over it.',
      searchable: false,
      soldWith: 'world.politicalModelling',
      extensionData: {'visibility': 'default', 'templateOwned': true},
    ),
  ],
);

/// A thing that happened, with a cause and a consequence.
///
/// **It is a timeline record now, and was not.** It inherited `general-lore`
/// and declared a single `date`, so the one type in AuthorOS actually called
/// *Historical Event* could not be dated the way the Timeline dates anything
/// and never appeared on it. `isTimelineRecord` walks the base chain and
/// answered no.
///
/// That is what five places in this codebase were working around by naming
/// two types to mean one thing — `['historical-event', 'timeline-event']` in
/// the connection definitions, in Character Chat twice, and
/// `'historical-event' || 'timeline-event' => ReferenceKind.timeline` in the
/// inspector. Those lists are harmless and still correct; they are no longer
/// load-bearing.
///
/// **Re-parented rather than aliased, and that is the difference from the two
/// Eras.** Those declared no fields at all, so an alias cost nothing. This
/// declares ten, and `weather-event` inherits it on purpose — the Climate
/// system's own comment says it takes `cause`, `consequences`,
/// `participants`, `publicKnowledge`, `hiddenTruth` and `relatedEvents` from
/// here "so none of those is re-declared under a weather-flavoured name."
/// Aliasing this onto `timeline-event` would have stripped six fields out of
/// a shipped specialist system to tidy a hierarchy.
///
/// So it keeps everything it had, joins the family it belongs to, and gains
/// the temporal fields — start, end, duration, precision, narrative time —
/// that let a historical event be dated like everything else that happened.
///
/// **`date` is gone from its own declaration**, because the base now carries
/// the dating and two ways to date one record is the thing Lock 1 objects to.
/// Nothing read it — no call site in `lib/` touches `fields['date']` — and any
/// value stored under it is kept on the record the way every undeclared value
/// is.
final _historicalEvent = _deepTemplate(
  id: 'historical-event',
  name: 'Historical Event',
  categoryId: 'history',
  baseTypeId: TimelineRecordTypes.baseTypeId,
  sectionId: 'timeline',
  sectionTitle: 'Timeline',
  fields: const [
    ('period', 'Period', RecordFieldType.recordReference),
    ('location', 'Location', RecordFieldType.locationReference),
    ('participants', 'Participants', RecordFieldType.list),
    ('cause', 'Cause', RecordFieldType.richText),
    ('event', 'Event', RecordFieldType.richText),
    ('consequences', 'Consequences', RecordFieldType.richText),
    ('publicKnowledge', 'Public Knowledge', RecordFieldType.richText),
    ('hiddenTruth', 'Hidden Truth', RecordFieldType.richText),
    ('relatedEvents', 'Related Events', RecordFieldType.list),
  ],
  suggestedLinks: const ['caused', 'resultedIn', 'precedes', 'follows'],
);

/// What something is made of, written once and referred to by everything made
/// of it.
///
/// A foundation type, in `authoros-core`, claimed by **no specialist system** —
/// and that is the whole design decision. Materials are wanted by Weapons
/// (a blade's steel), Architecture (a keep's granite), Artifacts (a relic's
/// olive wood), Travel (a hull's oak) and Economy (a coin's silver). Claiming
/// it for any one of those would make "what is this made of" conditional on
/// that system's toggle, which is the harm the declined base types exist to
/// prevent. `material` is not literally a base type — nothing inherits it —
/// but the reason behind that rule applies unchanged, so it belongs to nobody.
///
/// ## Nothing existing changes
///
/// Every `materials` field stays exactly as it is: `item.materials` is still a
/// list of free text, and so is the shared `materials` on Architecture's four
/// types. An author who has typed "Valyrian steel, weirwood, gold" into a
/// weapon keeps it, unchanged, with the same editor. This type is offered
/// *beside* those fields, not in place of them — a record to make when the same
/// substance turns up on the fifth thing made of it, and worth linking rather
/// than retyping.
///
/// Converting the lists into references would be the obvious next move and is
/// deliberately not made here: a list of strings cannot become a reference
/// without deciding, for the author, which of their strings was meant to be
/// which record.
///
/// ## Two id collisions that are not collisions
///
/// `writing-system.materials` is a `longText` meaning *what the script was
/// written on* — stone, wax, bark. `currency.material` is Economy's own list.
/// Both share a name with this type and mean something else, and both are left
/// alone; record type ids and field ids are separate namespaces.
///
/// Prior art: World Anvil promotes Material to its own article template for the
/// same reason — so a substance is described once and referenced by everything
/// that uses it.
final _material = _deepTemplate(
  id: 'material',
  name: 'Material',
  categoryId: 'items',
  sectionId: 'material',
  sectionTitle: 'Material',
  fields: const [
    ('materialType', 'Kind', RecordFieldType.shortText),
    ('appearance', 'Appearance', RecordFieldType.richText),
    ('properties', 'Properties', RecordFieldType.richText),
    ('origin', 'Found where', RecordFieldType.longText),
    ('workedBy', 'Worked by', RecordFieldType.richText),
    ('rarity', 'Rarity', RecordFieldType.shortText),
    ('worth', 'Worth', RecordFieldType.shortText),
    ('substitutes', 'Substitutes', RecordFieldType.list),
    ('history', 'History', RecordFieldType.richText),
  ],
  suggestedLinks: const [
    'originatedFrom',
    'usedBy',
    'requires',
    'associatedWith',
  ],
);

final _item = _deepTemplate(
  id: 'item',
  name: 'Item',
  categoryId: 'items',
  sectionId: 'items',
  sectionTitle: 'Item',
  fields: const [
    ('itemType', 'Type', RecordFieldType.shortText),
    ('creator', 'Creator', RecordFieldType.recordReference),
    ('owner', 'Owner', RecordFieldType.recordReference),
    ('materials', 'Materials', RecordFieldType.list),
    ('powers', 'Powers', RecordFieldType.richText),
    ('limitations', 'Limitations', RecordFieldType.richText),
    ('history', 'History', RecordFieldType.richText),
    ('currentLocation', 'Current Location', RecordFieldType.locationReference),
    ('knownUsers', 'Known Users', RecordFieldType.list),
    ('secrets', 'Secrets', RecordFieldType.richText),
  ],
  suggestedLinks: const ['createdBy', 'ownedBy', 'usedBy', 'locatedIn'],
);

RecordTypeDefinition _deepTemplate({
  required String id,
  required String name,
  required String categoryId,
  required String sectionId,
  required String sectionTitle,
  required List<(String, String, RecordFieldType)> fields,
  required List<String> suggestedLinks,
  String baseTypeId = 'general-lore',
  List<RecordFieldDefinition> specialistFields = const [],
  String specialistSectionId = '',
  String specialistSectionTitle = '',
}) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      categoryId: categoryId,
      baseTypeId: baseTypeId,
      fields: [
        for (var index = 0; index < fields.length; index++)
          RecordFieldDefinition(
            id: fields[index].$1,
            label: fields[index].$2,
            type: fields[index].$3,
            order: 100 + index,
            extensionData: const {
              'visibility': 'default',
              'templateOwned': true,
            },
          ),
        ...specialistFields,
      ],
      sections: [
        RecordTemplateSection(
          id: sectionId,
          title: sectionTitle,
          order: 10,
          fieldIds: fields.map((field) => field.$1).toList(),
        ),
        // A second section rather than more rows in the first, so that what a
        // free author sees keeps the shape it had. A withheld field keeps its
        // order (field_ownership.dart rule 2) but an empty *section* is what
        // tells a form there is nothing to draw.
        if (specialistFields.isNotEmpty)
          RecordTemplateSection(
            id: specialistSectionId,
            title: specialistSectionTitle,
            order: 11,
            fieldIds: specialistFields.map((field) => field.id).toList(),
          ),
      ],
      suggestedLinkTypeIds: suggestedLinks,
      builtIn: true,
      sourcePackId: 'authoros-core',
      permissions: const {'editableDefinition': false},
      extensionData: const {'codexTemplate': true, 'supportsSimpleMode': true},
    );

Iterable<RecordTypeDefinition> _children(
  Map<String, (String, String)> definitions,
) =>
    definitions.entries.map(
      (entry) => RecordTypeDefinition(
        id: entry.key,
        name: entry.value.$1,
        categoryId: entry.value.$2,
        baseTypeId: 'general-lore',
        fields: const [],
        sections: const [],
        builtIn: true,
        sourcePackId: 'authoros-core',
        permissions: const {'editableDefinition': false},
      ),
    );

/// The series a project's books belong to.
///
/// A project holds at most one of these. It is the anchor books hang off, and
/// the handle a future multi-project library would migrate against; it owns no
/// entity data of its own.
// No longer const: these fields resolve their descriptions from the
// craft library, and a lookup is not a const expression. The pattern
// `_generalLore` set above, for the same reason.
final _series = RecordTypeDefinition(
  id: 'series',
  name: 'Series',
  description: 'The series a project\'s books belong to.',
  icon: 'auto_stories',
  categoryId: 'manuscript',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
      id: 'status',
      description: CraftLibrary.describe('builtin.series.status'),
      label: 'Status',
      type: RecordFieldType.singleChoice,
      order: 100,
      defaultValue: 'Planning',
      options: ['Planning', 'Drafting', 'Publishing', 'Complete', 'Abandoned'],
    ),
    RecordFieldDefinition(
      id: 'plannedBooks',
      description: CraftLibrary.describe('builtin.series.plannedBooks'),
      label: 'Planned books',
      type: RecordFieldType.number,
      order: 101,
    ),
    RecordFieldDefinition(
      id: 'blurb',
      description: CraftLibrary.describe('builtin.series.blurb'),
      label: 'Blurb',
      type: RecordFieldType.longText,
      order: 102,
    ),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'series',
      title: 'Series',
      order: 10,
      fieldIds: ['status', 'plannedBooks', 'blurb'],
    ),
  ],
  suggestedLinkTypeIds: const ['contains'],
  builtIn: true,
  sourcePackId: 'authoros-series-core',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
);

/// One book inside a project.
///
/// A book record's own `bookId` is its own id (invariant B-2), so
/// [UniversalSearchService.searchByBook] returns the book alongside everything
/// scoped to it.
// No longer const: these fields resolve their descriptions from the
// craft library, and a lookup is not a const expression. The pattern
// `_generalLore` set above, for the same reason.
final _book = RecordTypeDefinition(
  id: 'book',
  name: 'Book',
  description: 'One book inside a project.',
  icon: 'menu_book',
  categoryId: 'manuscript',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
      id: 'order',
      description: CraftLibrary.describe('builtin.book.order'),
      label: 'Order',
      type: RecordFieldType.number,
      order: 100,
      defaultValue: 0,
    ),
    RecordFieldDefinition(
      id: 'subtitle',
      description: CraftLibrary.describe('builtin.book.subtitle'),
      label: 'Subtitle',
      type: RecordFieldType.shortText,
      order: 101,
    ),
    RecordFieldDefinition(
      id: 'status',
      description: CraftLibrary.describe('builtin.book.status'),
      label: 'Status',
      type: RecordFieldType.singleChoice,
      order: 102,
      defaultValue: 'Planned',
      options: [
        'Planned',
        'Outlining',
        'Drafting',
        'Revising',
        'Complete',
        'Published',
      ],
    ),
    RecordFieldDefinition(
      id: 'wordGoal',
      description: CraftLibrary.describe('builtin.book.wordGoal'),
      label: 'Word goal',
      type: RecordFieldType.number,
      order: 103,
    ),
    RecordFieldDefinition(
      id: 'blurb',
      description: CraftLibrary.describe('builtin.book.blurb'),
      label: 'Blurb',
      type: RecordFieldType.longText,
      order: 104,
    ),
    RecordFieldDefinition(
      id: 'publicationDate',
      description: CraftLibrary.describe('builtin.book.publicationDate'),
      label: 'Publication date',
      type: RecordFieldType.date,
      order: 105,
    ),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'book',
      title: 'Book',
      order: 10,
      fieldIds: [
        'order',
        'subtitle',
        'status',
        'wordGoal',
        'blurb',
        'publicationDate',
      ],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf'],
  builtIn: true,
  sourcePackId: 'authoros-series-core',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
);

/// What one entity looks like in one book, expressed as the difference from
/// series canon.
///
/// The record carries `bookId`, a `documents` link to the canonical entity, and
/// **only the fields whose values differ from canon** — plus `removedFieldIds`
/// for values the book drops. Unknown field ids are preserved verbatim by
/// [RecordValidator], which validates only the ids a definition declares, so a
/// state record can carry any field belonging to the entity's own type.
///
/// This is the sparse shape of `BranchRecordOverlayRows` without the table. A
/// branch overlay is a what-if kept out of canon; a book state *is* canon at a
/// point in the series, so it has to be searchable, linkable, versioned and
/// exported like any other record.
// No longer const: these fields resolve their descriptions from the
// craft library, and a lookup is not a const expression. The pattern
// `_generalLore` set above, for the same reason.
final _entityState = RecordTypeDefinition(
  id: 'entity-state',
  name: 'Entity State',
  description: 'How one entity differs from series canon inside one book.',
  icon: 'difference',
  categoryId: 'manuscript',
  baseTypeId: 'general-lore',
  fields: [
    RecordFieldDefinition(
      id: 'canonicalRecordId',
      description:
          CraftLibrary.describe('builtin.entity-state.canonicalRecordId'),
      label: 'Entity',
      type: RecordFieldType.recordReference,
      order: 100,
      required: true,
    ),
    RecordFieldDefinition(
      id: 'removedFieldIds',
      description:
          CraftLibrary.describe('builtin.entity-state.removedFieldIds'),
      label: 'Fields this book drops',
      type: RecordFieldType.list,
      order: 101,
    ),
    RecordFieldDefinition(
      id: 'changeReason',
      description: CraftLibrary.describe('builtin.entity-state.changeReason'),
      label: 'Why it changes',
      type: RecordFieldType.longText,
      order: 102,
    ),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'state',
      title: 'Book state',
      order: 10,
      fieldIds: ['canonicalRecordId', 'removedFieldIds', 'changeReason'],
    ),
  ],
  suggestedLinkTypeIds: const ['documents', 'partOf'],
  builtIn: true,
  sourcePackId: 'authoros-series-core',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
);

/// Which specialist systems a project has switched on.
///
/// Infrastructure, in the same sense as the Codex's category and collection
/// records: organisational metadata over ids, never graph truth. It is
/// registered here because [RecordService] validates every write against this
/// registry, and activation is written through [RecordService] like anything
/// else rather than through a store of its own.
///
/// Project scope only, and not offered when creating a record — an author
/// makes one of these by enabling a system, never by picking a template.
const _specialistSystemState = RecordTypeDefinition(
  id: kSpecialistSystemStateTypeId,
  name: 'Specialist Systems',
  description: 'Which specialist systems this project has enabled.',
  icon: 'tune',
  categoryId: 'custom',
  fields: [
    RecordFieldDefinition(
      id: kEnabledSystemIdsFieldId,
      label: 'Enabled systems',
      type: RecordFieldType.list,
      order: 0,
    ),
  ],
  sections: [],
  allowedScopeTypes: [RecordScopeType.project],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
  extensionData: {'selectableForNewRecords': false},
);

/// Which Curios a project has switched on.
///
/// The same kind of thing as [_specialistSystemState] and for the same reason,
/// over a different vocabulary: that one holds specialist system ids, this one
/// holds `PaidProduct` wire ids. They are deliberately two records rather than
/// two fields of one — `specialist_architecture_test.dart` holds a boundary
/// that only specialist sources may read that record, and a Curios surface
/// reading it would spend a guard written to stop a preference filtering a
/// repository.
///
/// Project scope only, and not offered when creating a record — an author makes
/// one of these by switching a Curio on, never by picking a template.
const _curioActivation = RecordTypeDefinition(
  id: kCurioActivationTypeId,
  name: 'Curios',
  description: 'Which owned Curios this project has switched on.',
  icon: 'auto_awesome',
  categoryId: 'custom',
  fields: [
    RecordFieldDefinition(
      id: kEnabledCurioIdsFieldId,
      label: 'Enabled Curios',
      type: RecordFieldType.list,
      order: 0,
    ),
  ],
  sections: [],
  allowedScopeTypes: [RecordScopeType.project],
  builtIn: true,
  sourcePackId: 'authoros-core',
  permissions: {'editableDefinition': false},
  extensionData: {'selectableForNewRecords': false},
);

Iterable<RecordTypeDefinition> _derivedChildren(
  Map<String, (String, String, String)> definitions,
) =>
    definitions.entries.map(
      (entry) => RecordTypeDefinition(
        id: entry.key,
        name: entry.value.$1,
        categoryId: entry.value.$2,
        baseTypeId: entry.value.$3,
        fields: const [],
        sections: const [],
        builtIn: true,
        sourcePackId: 'authoros-core',
        permissions: const {'editableDefinition': false},
        extensionData: const {'codexTemplate': true},
      ),
    );

RecordTypeDefinition _legacyAlias(
  String id,
  String name,
  String baseTypeId,
  String categoryId,
) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      categoryId: categoryId,
      baseTypeId: baseTypeId,
      fields: const [],
      sections: const [],
      builtIn: true,
      sourcePackId: 'authoros-core',
      permissions: const {'editableDefinition': false},
      extensionData: const {
        'legacyAlias': true,
        'selectableForNewRecords': false,
      },
    );

RecordTypeDefinition _selectableAlias(
  String id,
  String name,
  String baseTypeId,
  String categoryId,
) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      categoryId: categoryId,
      baseTypeId: baseTypeId,
      fields: const [],
      sections: const [],
      builtIn: true,
      sourcePackId: 'authoros-core',
      permissions: const {'editableDefinition': false},
    );
