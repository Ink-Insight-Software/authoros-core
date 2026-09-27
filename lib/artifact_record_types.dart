/// The Artifacts specialist system's record types.
///
/// One type. `artefact` was a bare `_derivedChildren` of `item` with zero
/// fields of its own, so the object a whole plot turns on was described with
/// the same ten generic fields as a cooking pot.
///
/// ## Why only one type, and why that is not a gap
///
/// Language added four types beside `language`, and each earned its place by a
/// stated test: a writing system is *shared between* languages so it cannot be
/// a value one record owns; a lexicon is *unbounded* so it must be records.
/// Applying the same test here yields nothing:
///
/// * An artifact's powers and costs are few and belong to it alone — fields.
/// * Its bearers are a chain of other records — that is what edges are for,
///   and only an edge can be traversed by search, the graph or the map.
/// * A *set* of relics is shared, and would pass the test — but an author can
///   already make a lore record named "The Seven" and hang `partOf` edges on
///   it. A dedicated type would buy nothing an edge does not already give.
///
/// So Artifacts is the smallest system in the programme, and inventing a
/// second type to make it look larger would be the opposite of the discipline
/// the other five were built under.
///
/// ## Inheritance is kept
///
/// An artifact is an item, so `baseTypeId: 'item'` stays and all ten inherited
/// fields keep their ids, types and editors. Same reasoning as Weapons: the
/// Magic and Religion corrections were about inheritance asserted rather than
/// observed, not about inheritance itself.
///
/// ## What an artifact has that an item does not
///
/// `item` already carries Powers, Limitations, Creator, History, Known Users
/// and Secrets, which is most of what a generic object needs. The nine fields
/// added here are the ones that only apply when an object is *singular*:
/// why it matters, what it costs to use, what it is bound to, how it could be
/// unmade, and whose hands it has passed through. `limitations` says what it
/// cannot do; `cost` says what it takes from whoever makes it do anything —
/// a different question, and usually the interesting one.
///
/// ## `item` is not claimed
///
/// `item` stays in `authoros-core` and belongs to no system, because it is the
/// generic every project needs whether or not it opens Artifacts. A foundation
/// type is always offered — [isTemplateOffered] returns true for any type no
/// system claims — so claiming `item` here would have made "a thing exists"
/// conditional on a toggle. There is a test for that.
///
/// Its display name changes from "Item / Artifact" to "Item", which this
/// system's arrival makes necessary: with `artefact` presented as **Artefact**
/// beside a generic called **Item / Artifact**, an author is offered the same
/// word twice for two different things. Display name only — the id, the
/// fields, the pack and every stored record are untouched.
///
/// ## Relationships
///
/// Unlike Weapons, this system needs no workaround. `artefact` was hand-added
/// to every relevant edge list, so the natural vocabulary is available:
///
///     artefact -locatedIn-> place    PERMITTED
///     artefact -appearsIn-> scene    PERMITTED
///     character -owns->     artefact PERMITTED
///     character -carries->  artefact PERMITTED
///
/// That is the same #84 exact-match mechanism that leaves `armour` unable to
/// be owned — it simply happened to fall the other way here. The contrast is
/// recorded in the tests, because "one sibling is fully connected and the
/// other is not, and no one decided that" is the clearest statement of what
/// #84 costs.
///
/// ## Compatibility
///
/// Nothing is re-parented and nothing is removed; `artefact` had no fields to
/// strand. `artifact_compatibility_test.dart` proves it against records built
/// in the shape the old definition produced.
library;

import 'record_types.dart';

class ArtifactRecordTypes {
  const ArtifactRecordTypes._();

  static const artefactTypeId = 'artefact';

  /// Every type the Artifacts system presents. The manifest names exactly
  /// these.
  static const List<String> recordTypeIds = [artefactTypeId];

  /// The generic this system deliberately does not own.
  ///
  /// `item` is foundation: always offered, claimed by nobody. Named so the
  /// test that asserts it has something to assert against.
  static const String foundationTypeId = 'item';

  /// The ten field ids `artefact` inherits from `item` and keeps unchanged.
  ///
  /// Named because the compatibility guarantee depends on them: nothing here
  /// may shadow one with a different type, or an existing record's value would
  /// lose its editor.
  static const List<String> inheritedItemFieldIds = [
    'itemType',
    'creator',
    'owner',
    'materials',
    'powers',
    'limitations',
    'history',
    'currentLocation',
    'knownUsers',
    'secrets',
  ];

  static final List<RecordTypeDefinition> definitions = [_artefact];
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
  String? soldWith,
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      soldWith: soldWith,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

/// The capability that owns an artefact's mechanics.
///
/// **M1d — the first field ownership markers in the tree.** The line is
/// [the gating ledger](../../docs/free-paid-gating-ledger.md) §4.3's, and it
/// is the smallest of the five it draws: nine fields, five free, four sold,
/// one owner.
///
/// > Free records what a thing **is**; the expansion models how it **works on
/// > people**.
///
/// So *significance*, *uniqueness*, *origin*, *provenance* and *sightings* stay
/// free — why the object matters, whether there is another, where it came
/// from, whose hands it passed through, where it has been seen. What is sold is
/// **how it works**: what activates it, what using it costs, what binds it, and
/// how it can be unmade.
///
/// `provenance` is the ledger's own test case for the one-owner rule. A chain
/// of ownership reads as Lorekeeper's discipline, but a record's depth has a
/// single owner and splitting artefacts across two rooms would leave an author
/// unable to say which pack fills in a relic. It resolves without a split
/// because provenance is *description* — where a thing has been — and lands
/// free.
///
/// ## They withhold nothing yet
///
/// Which is the sequencing rather than an oversight.
///
/// `world.simulation` is **reserved** for WorldSmith, not sold by it: no
/// `PaidProduct` names WorldSmith, so `field_ownership.dart` resolves these
/// four as free and every author gets all nine. The marker is the ledger's
/// decision written where the code can check it, and
/// `artifact_field_ownership_test.dart` asserts both halves — that the line is
/// right, and that nothing is being taken away today.
///
/// They start withholding the day WorldSmith graduates, which
/// [ReservedSpecialist] describes as three deliberate acts: a `PaidProduct`
/// value, a room service, and a checkout slug. That is **M4**, and no field
/// here changes when it happens.
const _worldsmithDepth = 'world.simulation';

// ---------------------------------------------------------------------------

/// A singular object: why it matters, what it costs, and whose hands it has
/// passed through.
///
/// Stays a child of `item`. The ten inherited fields still answer for an
/// artifact — it has materials, a maker, powers and secrets like anything else
/// — so this adds only what being *singular* implies.
final _artefact = RecordTypeDefinition(
  id: ArtifactRecordTypes.artefactTypeId,
  name: 'Artefact',
  description: 'A singular object: why it matters, what it costs, and whose '
      'hands it has passed through.',
  icon: 'diamond',
  categoryId: 'items',
  baseTypeId: 'item',
  fields: [
    _field('significance', 'Significance', RecordFieldType.richText, 100,
        description: 'Why this object matters to the story, rather than what '
            'it does.'),
    _field('uniqueness', 'Uniqueness', RecordFieldType.shortText, 101,
        description: 'One of a kind, one of seven, one of many that were '
            'made and one that survived.'),
    _field('activation', 'Activation', RecordFieldType.richText, 102,
        description: 'What it takes to make it work — a word, a wound, a '
            'name, an heir.',
        soldWith: _worldsmithDepth),
    // `limitations` (inherited) says what it cannot do. This says what it
    // charges whoever makes it do anything, which is usually the question the
    // story is actually about.
    _field('cost', 'Cost', RecordFieldType.richText, 110,
        description: 'What using it takes from whoever uses it.',
        soldWith: _worldsmithDepth),
    _field('bindings', 'Bindings', RecordFieldType.list, 111,
        description: 'Who or what it is bound to, and what breaks the bond.',
        soldWith: _worldsmithDepth),
    _field('destruction', 'Unmaking', RecordFieldType.richText, 112,
        description: 'How it could be destroyed, if it can be. Often the '
            'plot.',
        soldWith: _worldsmithDepth),
    _field('origin', 'Origin', RecordFieldType.richText, 120,
        description: 'How it came to exist. `Creator` is who; this is how '
            'and why.'),
    _field('provenance', 'Provenance', RecordFieldType.richText, 121,
        description: 'The chain of hands it has passed through. `History` is '
            'what happened; this is who held it.'),
    _field('sightings', 'Sightings', RecordFieldType.list, 122,
        description: 'Where it is rumoured to be, as against where it is.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'artefact',
      title: 'Artefact',
      order: 10,
      fieldIds: ['significance', 'uniqueness', 'activation'],
    ),
    RecordTemplateSection(
      id: 'artefact-cost',
      title: 'Cost and unmaking',
      order: 11,
      fieldIds: ['cost', 'bindings', 'destruction'],
    ),
    RecordTemplateSection(
      id: 'artefact-provenance',
      title: 'Provenance',
      order: 12,
      fieldIds: ['origin', 'provenance', 'sightings'],
    ),
  ],
  // The natural forward edges, verified permitted for this type. No workaround
  // was needed here — `artefact` was hand-added to these lists where `armour`
  // was not, which is #84 falling the other way rather than a decision.
  suggestedLinkTypeIds: const [
    'locatedIn',
    'appearsIn',
    'ownedBy',
    'createdBy',
  ],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-artifacts-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
