/// The Travel specialist system's record types.
///
/// Eleven types: `vehicle`, and the ten named kinds of route. The base
/// `travel-route` is deliberately **not** among them.
///
/// ## The gap is entirely in the vehicle
///
/// `travel-route` is already a deep template — route type, start, end,
/// distance, travel time, difficulty, cost and danger — and the ten kinds
/// inherit all eight. Routes were never the missing half of travel.
///
/// `vehicle` was. It was a bare child of `item`, so a ship, a caravan or a
/// skiff was described with the ten generic item fields and had nowhere to say
/// what moves it, who crews it, what it can carry, how fast, how far, or over
/// what. That is what this system adds, and it adds it in one place.
///
/// ## Why the ten route kinds are claimed but not deepened
///
/// They gain no fields, and that is the point rather than an omission. A road
/// route and a ferry route differ in kind, not in structure: both need a
/// start, an end, a duration and a danger, and `travel-route` already gives
/// them all four. Adding fields to the kinds but not to the base they inherit
/// from would split the family — an author using plain "Travel Route" would
/// silently get less than one using "Road Route".
///
/// What claiming them buys is the thing specialist systems exist for:
/// **a project that has no portals can stop being offered Portal Route, Gate
/// Route, Space Route and Magical Route.** A historical novelist currently
/// sees all four in a picker beside Road Route. That is the whole benefit, and
/// it does not require inventing a field.
///
/// ## `travel-route` stays foundation
///
/// It is the generic every route descends from, it drives the World Studio's
/// own Routes tab, and `WorldService._isWorldTemplate` resolves route
/// membership through `isTemplateCompatible(id, 'travel-route')`. A type no
/// system claims is always offered, so leaving it unclaimed keeps "a way from
/// here to there exists" unconditional. Same reasoning that kept `item` out of
/// Artifacts and `location` out of Architecture — the third time this
/// programme has declined to claim a base type, and the rule is now the
/// pattern rather than a judgement call.
///
/// ## Inheritance is kept
///
/// `vehicle` stays a child of `item`; the ten kinds stay children of
/// `travel-route`. Every inherited field keeps its id, type and editor, and
/// nothing is re-parented. `vehicle` had no fields of its own to strand, and
/// the route kinds had none either.
///
/// ## The id sets are untouched
///
/// The ten kinds move to a dedicated pack, but their ids stay in
/// [WorldRecordTypes.routeTypeIds], which drives `isBuiltInWorldType` and the
/// World Studio's route iconography. Only the definitions move.
library;

import 'record_types.dart';
import 'world_record_types.dart';

class TravelRecordTypes {
  const TravelRecordTypes._();

  static const vehicleTypeId = 'vehicle';

  /// The base every route descends from, deliberately left unclaimed.
  static const String routeFoundationTypeId = 'travel-route';

  /// The ten named kinds of route, in the order [WorldRecordTypes] declares
  /// them.
  ///
  /// Written out rather than derived from [WorldRecordTypes.routeTypeIds],
  /// because a derived list cannot be `const` and the manifest — like every
  /// other system's — should be a compile-time constant.
  ///
  /// The protection a derived list would have given is kept instead by
  /// [coversEveryRouteKind], asserted in the tests: a kind added to the
  /// canonical set and not added here fails the build rather than silently
  /// escaping the system.
  static const List<String> routeKindTypeIds = [
    'road-route',
    'path-route',
    'portal-route',
    'gate-route',
    'ferry-route',
    'bridge-route',
    'tunnel-route',
    'flight-path',
    'space-route',
    'magical-route',
  ];

  /// Every type the Travel system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [
    vehicleTypeId,
    ...routeKindTypeIds,
  ];

  /// Whether [routeKindTypeIds] still accounts for every route kind the world
  /// declares, `travel-route` aside.
  ///
  /// The one thing the hand-written list above could get wrong. Asserted in
  /// `travel_compatibility_test.dart` rather than trusted.
  static bool get coversEveryRouteKind =>
      WorldRecordTypes.routeTypeIds
          .difference({routeFoundationTypeId})
          .difference(routeKindTypeIds.toSet())
          .isEmpty &&
      routeKindTypeIds
          .toSet()
          .difference(WorldRecordTypes.routeTypeIds)
          .isEmpty;

  /// The ten field ids `vehicle` inherits from `item` and keeps unchanged.
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

  /// The eight field ids the route kinds inherit from `travel-route` and keep
  /// unchanged.
  static const List<String> inheritedRouteFieldIds = [
    'routeType',
    'startId',
    'endId',
    'distance',
    'travelTime',
    'difficulty',
    'cost',
    'danger',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _vehicle,
    ..._routeKinds,
  ];
}

const _codexTemplate = <String, Object?>{
  'codexTemplate': true,
  'supportsSimpleMode': true,
};

const _worldTemplate = <String, Object?>{
  'worldDomain': true,
  'worldTemplate': true,
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

/// A thing that carries people or cargo: what moves it, who crews it, and what
/// it can cross.
///
/// Stays a child of `item`, because it is one. The ten inherited fields still
/// answer — a ship has materials, a maker, an owner and a history — so this
/// adds only what being a *conveyance* implies.
final _vehicle = RecordTypeDefinition(
  id: TravelRecordTypes.vehicleTypeId,
  name: 'Vehicle',
  description: 'A thing that carries people or cargo: what moves it, who '
      'crews it, and what it can cross.',
  icon: 'sailing',
  categoryId: 'items',
  baseTypeId: 'item',
  fields: [
    _field('propulsion', 'Propulsion', RecordFieldType.shortText, 100,
        description: 'Sail, oar, steam, beast, wind that owes someone a '
            'favour.'),
    _field('terrain', 'Travels on', RecordFieldType.list, 101,
        description: 'Water, road, rail, air, sand, the space between '
            'places.'),
    _field('speed', 'Speed', RecordFieldType.shortText, 102,
        description: 'In terms the world would use, not miles per hour.'),
    _field('range', 'Range', RecordFieldType.shortText, 103,
        description: 'How far before it must stop, and what it must stop '
            'for.'),
    _field('crew', 'Crew', RecordFieldType.richText, 110,
        description: 'How many it takes to work, and what happens with '
            'fewer.'),
    _field('capacity', 'Capacity', RecordFieldType.shortText, 111,
        description: 'Passengers, cargo, or both at each other\'s expense.'),
    _field('quarters', 'Quarters', RecordFieldType.richText, 112,
        description: 'What it is like to be aboard for a long time. Often '
            'where the scene actually happens.'),
    _field('upkeep', 'Upkeep', RecordFieldType.longText, 120,
        description: 'What keeps it moving, and what happens when that is '
            'neglected.'),
    _field('vulnerabilities', 'Vulnerabilities', RecordFieldType.list, 121,
        description: 'What stops it. Usually weather, rarely enemies.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'vehicle',
      title: 'Vehicle',
      order: 10,
      fieldIds: ['propulsion', 'terrain', 'speed', 'range'],
    ),
    RecordTemplateSection(
      id: 'vehicle-aboard',
      title: 'Aboard',
      order: 11,
      fieldIds: ['crew', 'capacity', 'quarters'],
    ),
    RecordTemplateSection(
      id: 'vehicle-upkeep',
      title: 'Upkeep',
      order: 12,
      fieldIds: ['upkeep', 'vulnerabilities'],
    ),
  ],
  // The `*`-typed edges, verified permitted. `vehicle` is an `item` child that
  // #84's hand-written lists never reached, so owns/uses/carries and locatedIn
  // all reject it — the same shape as `armour` in the Weapons system, and not
  // worked around here either.
  suggestedLinkTypeIds: const ['ownedBy', 'usedBy', 'createdBy'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-travel-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// The ten named kinds of route.
///
/// Field-less by design: each inherits `travel-route`'s eight, and the kinds
/// differ in nature rather than structure. Declared here rather than in
/// `world_record_types.dart` so the pack is wholly owned and the registry can
/// enforce that a new kind is declared to this system.
final _routeKinds = [
  for (final id in TravelRecordTypes.routeKindTypeIds)
    RecordTypeDefinition(
      id: id,
      name: _title(id),
      categoryId: 'routes',
      baseTypeId: TravelRecordTypes.routeFoundationTypeId,
      fields: const [],
      sections: const [],
      builtIn: true,
      sourcePackId: 'authoros-travel-system',
      extensionData: _worldTemplate,
    ),
];

String _title(String id) => id
    .split('-')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
