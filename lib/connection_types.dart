import 'record_types.dart';

enum ConnectionDirection { directed, undirected }

enum ConnectionCardinality { oneToOne, oneToMany, manyToOne, manyToMany }

class ConnectionTypeDefinition {
  const ConnectionTypeDefinition({
    required this.id,
    required this.displayName,
    required this.sourceTypeIds,
    required this.targetTypeIds,
    required this.inverseLabel,
    this.excludedSourceTypeIds = const [],
    this.excludedTargetTypeIds = const [],
    this.direction = ConnectionDirection.directed,
    this.cardinality = ConnectionCardinality.manyToMany,
    this.metadataFields = const [],
    this.temporalSupport = false,
    this.builtIn = false,
    this.scopeId = 'authoros',
    this.sourcePackId,
    this.extensionData = const {},
  })  : _permittedSourceTypeIds = null,
        _permittedTargetTypeIds = null;

  /// A copy carrying the type ids permission actually accepts.
  ///
  /// Only [ConnectionTypeRegistry] builds these, and only when it was given a
  /// record registry to resolve inheritance against. The declared lists are
  /// carried through untouched, so what an author wrote is what is exported.
  const ConnectionTypeDefinition._resolved({
    required this.id,
    required this.displayName,
    required this.sourceTypeIds,
    required this.targetTypeIds,
    required this.inverseLabel,
    required this.excludedSourceTypeIds,
    required this.excludedTargetTypeIds,
    required this.direction,
    required this.cardinality,
    required this.metadataFields,
    required this.temporalSupport,
    required this.builtIn,
    required this.scopeId,
    required this.sourcePackId,
    required this.extensionData,
    required Set<String> permittedSourceTypeIds,
    required Set<String> permittedTargetTypeIds,
  })  : _permittedSourceTypeIds = permittedSourceTypeIds,
        _permittedTargetTypeIds = permittedTargetTypeIds;

  final String id;
  final String displayName;
  final List<String> sourceTypeIds;
  final List<String> targetTypeIds;

  /// Source types this edge refuses, even when a declared id would admit them.
  ///
  /// Inclusion resolves through inheritance, so naming a base type admits every
  /// type beneath it — which is usually what an edge means and occasionally
  /// more than it means. `appearsIn` names `general-lore`, the root of the
  /// record tree, so without this it would take a chapter as a source and let
  /// a book be recorded as appearing in a book.
  ///
  /// Exclusion resolves through inheritance too, and wins: a type is refused
  /// when it, or anything it descends from, is named here. An id cannot appear
  /// in both lists — the registry rejects a definition that says both.
  final List<String> excludedSourceTypeIds;

  /// Target types this edge refuses. The mirror of [excludedSourceTypeIds].
  final List<String> excludedTargetTypeIds;

  final ConnectionDirection direction;
  final String inverseLabel;
  final ConnectionCardinality cardinality;
  final List<RecordFieldDefinition> metadataFields;
  final bool temporalSupport;
  final bool builtIn;
  final String scopeId;
  final String? sourcePackId;
  final Map<String, Object?> extensionData;

  /// Whether the author has retired this type. An archived type is never
  /// offered for a new link, and still resolves for every link that already
  /// uses it — Lock 6, deactivation hides and never deletes.
  bool get isArchived => extensionData['archived'] == true;

  final Set<String>? _permittedSourceTypeIds;
  final Set<String>? _permittedTargetTypeIds;

  /// The source ids this edge accepts, inheritance included.
  ///
  /// Equal to [sourceTypeIds] until a [ConnectionTypeRegistry] with a record
  /// registry resolves the definition; after that it also holds every type
  /// that descends from a declared id.
  Iterable<String> get permittedSourceTypeIds =>
      _permittedSourceTypeIds ?? sourceTypeIds;

  /// The target ids this edge accepts, inheritance included.
  Iterable<String> get permittedTargetTypeIds =>
      _permittedTargetTypeIds ?? targetTypeIds;

  /// The metadata fields this type actually carries.
  ///
  /// [metadataFields] as declared, plus [timeBoundedMetadataFields] when
  /// [temporalSupport] is set and the definition declares no date of its own.
  ///
  /// The composition is the same rule the record half of the model already
  /// uses: `RecordTypeRegistry` merges a parent's fields into a child and lets
  /// the child override by id, and `temporalSupport` composes the standard time
  /// pair and lets a definition override it by declaring a date. Before this,
  /// the flag composed nothing: every type that declared no date said it was
  /// time-bounded with nowhere to put a time, and nothing read the flag at
  /// all.
  ///
  /// The "no date of its own" proviso is what makes the rule apply *once*
  /// rather than twice. Three families already carry a pair under three
  /// different names — `beginning`/`ending` on character relationships,
  /// `startDate`/`endDate` on codex relationships and `locatedIn`,
  /// `joinedDate`/`leftDate` on `memberOf` — and composing blindly would give
  /// `partnerOf` four date fields meaning two things.
  ///
  /// `appearsIn` gains the pair despite holding `firstAppearance` and
  /// `lastAppearance`, and should: those are `shortText` because they hold
  /// *"Chapter 8"*, which is a manuscript position rather than a date, and the
  /// two axes are different questions.
  ///
  /// [metadataFields] still reports exactly what was declared, so what an
  /// author wrote is what is exported — the same distinction this class draws
  /// between [sourceTypeIds] and [permittedSourceTypeIds].
  List<RecordFieldDefinition> get resolvedMetadataFields {
    if (!temporalSupport) return metadataFields;
    if (metadataFields.any(_isDate)) return metadataFields;
    // After everything declared, so composing never reorders an author-facing
    // form that a definition arranged deliberately.
    var order = 0;
    for (final field in metadataFields) {
      if (field.order >= order) order = field.order + 1;
    }
    final declared = {for (final field in metadataFields) field.id};
    return [
      ...metadataFields,
      for (final field in timeBoundedMetadataFields)
        // A definition that declares one of these ids under another type keeps
        // its own. Composing over it would put two fields with one id in the
        // list, and the map built from that list would silently drop one.
        if (!declared.contains(field.id))
          RecordFieldDefinition(
            id: field.id,
            label: field.label,
            type: field.type,
            order: order++,
            description: field.description,
          ),
    ];
  }

  /// The metadata keys that say *when* this edge held, and in what state.
  ///
  /// Every `date` this type resolves, plus `status` — the field that says what
  /// state the edge was in over that span, and the reason a romance reads
  /// *Complicated* rather than merely *current*.
  ///
  /// Derived rather than listed. Two call sites — the record inspector and the
  /// manuscript service — each carried the same hard-coded set of five names,
  /// and both were blind to the twelve character relationship types, whose
  /// pair is `beginning`/`ending`. A character's whole relationship history
  /// therefore reported no temporal metadata at all. One derivation from the
  /// definition covers all three naming families and any a pack adds later.
  Set<String> get temporalMetadataKeys {
    final fields = resolvedMetadataFields;
    return {
      for (final field in fields)
        if (_isDate(field)) field.id,
      if (fields.any((field) => field.id == 'status')) 'status',
    };
  }

  static bool _isDate(RecordFieldDefinition field) =>
      field.type == RecordFieldType.date ||
      field.type == RecordFieldType.dateRange;

  /// The standard pair a time-bounded edge carries.
  ///
  /// One declaration, so an edge that runs from one moment to another says so
  /// the same way everywhere.
  static const timeBoundedMetadataFields = <RecordFieldDefinition>[
    RecordFieldDefinition(
      id: 'startDate',
      label: 'Start date',
      type: RecordFieldType.date,
      order: 0,
      description: 'When this became true.',
    ),
    RecordFieldDefinition(
      id: 'endDate',
      label: 'End date',
      type: RecordFieldType.date,
      order: 1,
      description: 'When it stopped being true. Empty while it still is.',
    ),
  ];

  bool permits(String sourceTypeId, String targetTypeId) =>
      _permitsType(permittedSourceTypeIds, sourceTypeId) &&
      _permitsType(permittedTargetTypeIds, targetTypeId);

  /// This definition with permission resolved through [ancestorsOf].
  ///
  /// A declared id permits every type that *is* one — `item` permits `weapon`,
  /// because a weapon is an item and can stand wherever an item can. The
  /// reverse never holds: naming `weapon` does not admit every item.
  ConnectionTypeDefinition _resolveAgainst(
    Iterable<String> allTypeIds,
    Set<String> Function(String) ancestorsOf,
  ) {
    Set<String> expand(List<String> declared, List<String> excluded) {
      // A short cut, not a rule: no type has `*` as an ancestor, so expanding
      // a wildcard list would walk every type and add none. Removing this line
      // changes nothing but the work done, which a mutation confirmed.
      if (declared.contains('*')) return declared.toSet();
      final permitted = declared.toSet();
      for (final typeId in allTypeIds) {
        if (permitted.contains(typeId)) continue;
        if (ancestorsOf(typeId).any(permitted.contains)) permitted.add(typeId);
      }
      if (excluded.isEmpty) return permitted;
      // Exclusion resolves through the same tree and is applied last, so an
      // excluded base takes its descendants out with it however they arrived.
      permitted.removeWhere(
        (typeId) => ancestorsOf(typeId).any(excluded.contains),
      );
      return permitted;
    }

    return ConnectionTypeDefinition._resolved(
      id: id,
      displayName: displayName,
      sourceTypeIds: sourceTypeIds,
      targetTypeIds: targetTypeIds,
      inverseLabel: inverseLabel,
      excludedSourceTypeIds: excludedSourceTypeIds,
      excludedTargetTypeIds: excludedTargetTypeIds,
      direction: direction,
      cardinality: cardinality,
      metadataFields: metadataFields,
      temporalSupport: temporalSupport,
      builtIn: builtIn,
      scopeId: scopeId,
      sourcePackId: sourcePackId,
      extensionData: extensionData,
      permittedSourceTypeIds: expand(sourceTypeIds, excludedSourceTypeIds),
      permittedTargetTypeIds: expand(targetTypeIds, excludedTargetTypeIds),
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'displayName': displayName,
        'sourceTypeIds': sourceTypeIds,
        'targetTypeIds': targetTypeIds,
        // Omitted when empty so every definition that excludes nothing — which
        // is all but one — serialises exactly as it did before exclusion
        // existed.
        if (excludedSourceTypeIds.isNotEmpty)
          'excludedSourceTypeIds': excludedSourceTypeIds,
        if (excludedTargetTypeIds.isNotEmpty)
          'excludedTargetTypeIds': excludedTargetTypeIds,
        'direction': direction.name,
        'inverseLabel': inverseLabel,
        'cardinality': cardinality.name,
        'metadataFields':
            metadataFields.map((field) => field.toJson()).toList(),
        'temporalSupport': temporalSupport,
        'builtIn': builtIn,
        'scopeId': scopeId,
        'sourcePackId': sourcePackId,
        'extensionData': extensionData,
      };

  factory ConnectionTypeDefinition.fromJson(Map<String, dynamic> json) =>
      ConnectionTypeDefinition(
        id: _requiredString(json['id'], 'Connection type id'),
        displayName:
            _requiredString(json['displayName'], 'Connection display name'),
        sourceTypeIds: _stringList(json['sourceTypeIds']),
        targetTypeIds: _stringList(json['targetTypeIds']),
        excludedSourceTypeIds: _stringList(json['excludedSourceTypeIds']),
        excludedTargetTypeIds: _stringList(json['excludedTargetTypeIds']),
        direction: _enumValue(
          ConnectionDirection.values,
          json['direction'] ?? ConnectionDirection.directed.name,
          'connection direction',
        ),
        inverseLabel:
            _requiredString(json['inverseLabel'], 'Connection inverse label'),
        cardinality: _enumValue(
          ConnectionCardinality.values,
          json['cardinality'] ?? ConnectionCardinality.manyToMany.name,
          'connection cardinality',
        ),
        metadataFields: _mapList(json['metadataFields'])
            .map(RecordFieldDefinition.fromJson)
            .toList(),
        temporalSupport: json['temporalSupport'] as bool? ?? false,
        builtIn: json['builtIn'] as bool? ?? false,
        scopeId: _requiredString(
          json['scopeId'] ?? 'authoros',
          'Connection definition scope id',
        ),
        sourcePackId: _optionalString(json['sourcePackId']),
        extensionData: _objectMap(json['extensionData']),
      );
}

class ConnectionTypeRegistry {
  /// Builds the registry, resolving relationship permission through
  /// [recordTypes] when one is given.
  ///
  /// **Issue #84.** Permission used to be exact string matching over the ids a
  /// definition names, so an edge that named `item` rejected `weapon` — a type
  /// that *is* an item. Every new child of a base type was therefore invisible
  /// to the edges its parent could use until somebody hand-added its id, and
  /// hand-adding is what produced the inconsistencies in the first place:
  /// `weapon` was added to three lists over the years and `armour` to none, so
  /// a character could own a sword and not a breastplate.
  ///
  /// With [recordTypes] supplied, a declared id admits every type that
  /// descends from it. The direction matters and only one way round is true:
  /// naming `item` admits `weapon`, because a weapon can stand wherever an
  /// item can; naming `weapon` does not admit `item`, because most items are
  /// not weapons.
  ///
  /// Without [recordTypes] the old exact matching stands, which is what a
  /// registry built to validate one definition in isolation wants — there is
  /// no tree to resolve against there.
  ///
  /// The declared lists are never rewritten. [ConnectionTypeDefinition.toJson]
  /// still exports what an author wrote, so resolving here cannot leak an
  /// expanded list into persistence or into a pack.
  ConnectionTypeRegistry(
    Iterable<ConnectionTypeDefinition> definitions, {
    RecordTypeRegistry? recordTypes,
  }) : _definitions = {
          for (final definition in _resolveAll(definitions, recordTypes))
            definition.id: definition,
        } {
    if (_definitions.length != definitions.length) {
      throw const FormatException('Connection type ids must be unique.');
    }
    for (final definition in _definitions.values) {
      _validateDefinition(definition);
    }
  }

  static Iterable<ConnectionTypeDefinition> _resolveAll(
    Iterable<ConnectionTypeDefinition> definitions,
    RecordTypeRegistry? recordTypes,
  ) {
    if (recordTypes == null) return definitions;
    final allTypeIds = [
      for (final definition in recordTypes.definitions) definition.id,
    ];
    return [
      for (final definition in definitions)
        definition._resolveAgainst(allTypeIds, recordTypes.selfAndAncestors),
    ];
  }

  final Map<String, ConnectionTypeDefinition> _definitions;

  List<ConnectionTypeDefinition> get definitions => _definitions.values.toList()
    ..sort((left, right) => left.id.compareTo(right.id));

  ConnectionTypeDefinition resolve(String id) {
    final definition = _definitions[id];
    if (definition == null) {
      throw StateError('Unknown connection type: $id');
    }
    return definition;
  }

  void validateConnection({
    required String typeId,
    required String sourceTypeId,
    required String targetTypeId,
    Map<String, Object?> metadata = const {},
  }) {
    final definition = resolve(typeId);
    if (!definition.permits(sourceTypeId, targetTypeId)) {
      throw StateError(
        '$typeId does not permit $sourceTypeId -> $targetTypeId.',
      );
    }
    _validateMetadata(definition, metadata);
  }

  void _validateDefinition(ConnectionTypeDefinition definition) {
    _requiredString(definition.id, 'Connection type id');
    _requiredString(definition.displayName, 'Connection display name');
    _requiredString(definition.inverseLabel, 'Connection inverse label');
    _requiredString(definition.scopeId, 'Connection definition scope id');
    if (definition.sourceTypeIds.isEmpty || definition.targetTypeIds.isEmpty) {
      throw FormatException(
        'Connection type ${definition.id} requires source and target types.',
      );
    }
    // Saying both would leave the reader of the definition unable to tell what
    // it means, and the answer — exclusion wins — would be a rule nobody could
    // see. Better to refuse it at construction.
    for (final (side, declared, excluded) in [
      ('source', definition.sourceTypeIds, definition.excludedSourceTypeIds),
      ('target', definition.targetTypeIds, definition.excludedTargetTypeIds),
    ]) {
      final both = declared.toSet().intersection(excluded.toSet());
      if (both.isNotEmpty) {
        throw FormatException(
          'Connection type ${definition.id} both declares and excludes '
          '$side ${both.join(', ')}.',
        );
      }
    }
    final fieldIds = <String>{};
    for (final field in definition.metadataFields) {
      if (!fieldIds.add(field.id)) {
        throw FormatException('Duplicate metadata field id: ${field.id}');
      }
    }
  }

  /// Check [metadata] against what [definition] declares it may hold.
  ///
  /// Three questions, and the third was missing until the
  /// relationship-metadata work: a key nobody declared is refused, a required
  /// key that is absent is refused, and — new — a value of the wrong type is
  /// refused. Before that a `date` could hold `false` and a `rating` could
  /// hold a sentence, because this checked that a key was *known* and never
  /// what was in it.
  ///
  /// That is the same defect the Lock 9 review found on the record side, where
  /// an undeclared field skipped validation entirely. Records had
  /// [recordFieldAccepts]; links had nothing, and the gap was silent rather
  /// than loud.
  ///
  /// A **disabled** field is skipped entirely, matching `RecordValidator`: a
  /// field that does not apply is neither demanded nor type-checked, and its
  /// stored value is left alone, because disabling must never be a way to lose
  /// what an author wrote.
  void _validateMetadata(
    ConnectionTypeDefinition definition,
    Map<String, Object?> metadata,
  ) {
    final fields = {
      for (final field in definition.resolvedMetadataFields) field.id: field,
    };
    for (final key in metadata.keys) {
      if (!fields.containsKey(key)) {
        throw StateError('Unknown metadata field $key for ${definition.id}.');
      }
    }
    for (final field in fields.values) {
      if (!field.enabled) continue;
      final value = metadata[field.id];
      if (field.required && recordFieldIsEmpty(value)) {
        throw StateError(
          'Required metadata field ${field.id} is missing for ${definition.id}.',
        );
      }
      // Empty is absent, not wrong. An `endDate` on a relationship that has
      // not ended is the ordinary case.
      if (!recordFieldIsEmpty(value) &&
          !recordFieldAccepts(field, value, choices: field.options)) {
        throw StateError(
          'Metadata field ${field.id} has an invalid value '
          'for ${definition.id}.',
        );
      }
    }
  }
}

bool _permitsType(Iterable<String> allowedTypes, String typeId) =>
    allowedTypes.contains('*') || allowedTypes.contains(typeId);

String _requiredString(Object? value, String label) {
  final normalized = value is String ? value.trim() : '';
  if (normalized.isEmpty) {
    throw FormatException('$label is required.');
  }
  return normalized;
}

String? _optionalString(Object? value) {
  final normalized = value is String ? value.trim() : '';
  return normalized.isEmpty ? null : normalized;
}

T _enumValue<T extends Enum>(List<T> values, Object? raw, String label) {
  for (final value in values) {
    if (value.name == raw) {
      return value;
    }
  }
  throw FormatException('Unknown $label: $raw');
}

Map<String, Object?> _objectMap(Object? value) => value is Map
    ? value.map((key, item) => MapEntry(key.toString(), item))
    : <String, Object?>{};

List<String> _stringList(Object? value) =>
    value is List ? value.map((item) => item.toString()).toList() : [];

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value.map((item) => Map<String, dynamic>.from(item as Map)).toList()
    : [];
