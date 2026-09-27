/// Specialist systems — the declaration layer.
///
/// A specialist system is Magic, Languages, Religion, Economy, Bestiary and the
/// rest: a domain an author opts into per project. This file defines what one
/// *is*, and the definition is deliberately thin, because a specialist system
/// owns nothing.
///
/// It contributes **declarations**: which canonical record types belong to the
/// domain, which relationship types it leans on, what to call it and where it
/// files. It does not contribute a store, an identity space, an edge model, a
/// field system, a search index, or a navigation destination — every one of
/// those already exists once, and a system that brought its own would be a
/// second AuthorOS wearing a domain's name.
///
/// The authority for what a record type *is* stays in [RecordTypeRegistry], and
/// for what a relationship *is* in [ConnectionTypeRegistry]. A definition here
/// only ever names them. That is why there are no embedded field or type
/// definitions below: two homes for one definition is two answers, and one of
/// them is stale.
///
/// Pure Dart by construction. Nothing here imports Flutter, a store, a database
/// or a Studio, and `core_boundary_architecture_test.dart` holds that.
library;

/// One specialist system, declared.
///
/// Every property is a name or a flag. There is no `service`, no `view`, no
/// `settings` and no embedded definition, and their absence is the design: a
/// system that needs a service has stopped being a declaration, and that is a
/// conversation to have before the code is written rather than a field to add.
class SpecialistSystemDefinition {
  const SpecialistSystemDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.icon,
    required this.packId,
    required this.recordTypeIds,
    this.connectionTypeIds = const [],
    this.enabledByDefault = false,
    this.dependsOn = const [],
    this.soldWith,
  });

  /// Stable identity, used in activation state. Never rename one in place.
  final String id;

  final String name;
  final String description;

  /// The existing Codex category this system files under, so its records sit
  /// where the author already looks rather than in a category invented for it.
  final String categoryId;

  /// A Material icon name, in the same form [RecordTypeDefinition.icon] uses.
  /// A name, not a widget — a widget here would put Flutter in `core`.
  final String icon;

  /// The `sourcePackId` this system's canonical definitions carry.
  ///
  /// Reuses the pack identity the registries already have rather than inventing
  /// a second association mechanism. Note that a pack may be an *infrastructure*
  /// pack shared with unrelated types — see [kInfrastructurePackIds] — in which
  /// case [recordTypeIds] rather than the pack is what associates a type with
  /// this system.
  final String packId;

  /// Whether a project gets this system without asking.
  ///
  /// Every built-in system ships `false`. An existing project upgrading must
  /// not silently acquire twenty new domains it never chose.
  final bool enabledByDefault;

  /// The canonical record types this system presents. Each must resolve in
  /// [RecordTypeRegistry]; none is defined here.
  final List<String> recordTypeIds;

  /// The canonical relationship types this system leans on. Each must resolve
  /// in [ConnectionTypeRegistry]; none is defined here.
  final List<String> connectionTypeIds;

  /// Systems this one reads well alongside.
  ///
  /// **Advisory only, and enforced as advisory.** Nothing in this library reads
  /// [dependsOn] to decide what is enabled, and nothing may: enabling Magic
  /// must never switch Religion on behind the author's back. It exists so a
  /// future picker can say "works well with", and for no other purpose.
  final List<String> dependsOn;

  /// Which capability owns this system, or null when the system is free.
  ///
  /// **M2, the system ownership marker.** Eleven of the nineteen systems are
  /// [the ledger](../../docs/free-paid-gating-ledger.md)'s *gated whole* — a
  /// language's phonology, a climate model, a bloodline's inheritance rules —
  /// because each is a room's entire subject rather than depth inside a
  /// foundation type. Under D1 the gating unit is normally the field; a system
  /// is the unit only where every field of every type it declares belongs to
  /// the same room, and the ledger argues that case system by system.
  ///
  /// ## Why this is a permission check and not a new mechanism
  ///
  /// Every system already ships `enabledByDefault: false`, so a project only
  /// ever holds a system because an author switched it on. That switch is an
  /// existing decision point with an existing home —
  /// `specialist_presentation.dart` decides what a picker offers and what the
  /// settings list shows — and ownership is one more input to a question that
  /// is already being asked. Adding a second place systems could be filtered
  /// is precisely what G1 forbids.
  ///
  /// ## Why not [enabledByDefault]
  ///
  /// It is the author's own choice, and the same overloading refusal as
  /// [RecordFieldDefinition.soldWith]'s: *I have not switched this on* and *I
  /// have not bought this* are different sentences, and a surface that cannot
  /// tell them apart cannot say either one honestly.
  ///
  /// A capability id, a `String`, and a declaration that asks nothing —
  /// identical in kind to the field and type markers, for identical reasons.
  /// Resolution is in `core/system_ownership.dart`.
  final String? soldWith;

  /// Whether this system belongs to a room.
  bool get isSold => soldWith != null;
}

/// Pack ids that hold AuthorOS's own foundation types rather than one domain's.
///
/// The distinction matters for exactly one rule. "Every definition carrying this
/// system's pack belongs to this system" is a good invariant for a dedicated
/// pack and a false one for a shared foundation pack — `authoros-core` carries
/// roughly a hundred types across every domain in the product, so a system
/// declaring it cannot be held responsible for all of them.
///
/// Today every specialist domain's types still live in these packs, so the rule
/// is wired and inert. It becomes binding for a system the moment that system's
/// types are moved to a pack of their own, which is a change to those
/// definitions and therefore belongs to the phase that deepens them.
const Set<String> kInfrastructurePackIds = {
  'authoros-core',
  'authoros-world-core',
  'authoros-timeline-core',
  'authoros-codex-core',
  'authoros-series-core',
};

/// Whether [packId] is a dedicated specialist pack rather than a shared
/// foundation one.
bool isSpecialistPackId(String packId) =>
    !kInfrastructurePackIds.contains(packId);

/// The record type that carries a project's activation state.
///
/// Infrastructure, in the same sense as `codexCategory` — organisational
/// metadata over ids, never graph truth. It takes no links, and no connection
/// type accepts it as an endpoint.
///
/// This identity lives in the declaration layer rather than beside the service
/// that writes it, so `built_in_record_types.dart` can register the type
/// without its import graph reaching a service.
const String kSpecialistSystemStateTypeId = 'specialistSystemState';

/// The field holding the enabled ids. A `list`, so a project that has enabled
/// nothing holds an empty list rather than an absent key.
const String kEnabledSystemIdsFieldId = 'enabledSystemIds';

/// Record types that are specialist *infrastructure* rather than author
/// content.
///
/// Named here so a surface listing an author's records can exclude them, the
/// way `CodexInfrastructureTypes.all` already is.
const Set<String> kSpecialistInfrastructureTypeIds = {
  kSpecialistSystemStateTypeId,
};

/// The activation record's id for [projectId].
///
/// Derived, not minted. One activation record per project makes the id a
/// function of the project, so there is no timestamp, no counter and no
/// collision to design against — Follow-up #75's whole class of defect does not
/// arise here. It also makes the read a primary-key hit.
String specialistActivationRecordId(String projectId) =>
    'specialist-systems:$projectId';
