import 'record_scope.dart';

enum RecordFieldType {
  shortText,
  longText,
  number,
  date,
  dateRange,
  boolean,
  singleChoice,
  multipleChoice,
  tags,
  rating,
  image,
  fileReference,
  recordReference,
  relationship,
  richText,
  list,
  table,
  timelineReference,
  locationReference,
  characterReference,
  plotThreadReference,
  url,
  checklist,
}

/// A named list of choices that more than one field can point at.
///
/// `options` on a field is an inline list, so "Rarity: common / rare / unique"
/// had to be retyped for every field that wanted it, and the copies drifted.
/// An option set is that list given a stable id, declared once and referenced
/// by [RecordFieldDefinition.optionSetId].
///
/// Sets are declared on [RecordTypeDefinition.optionSets] rather than in a
/// table of their own. That is deliberate: type definitions already serialise
/// and already persist in `record_type_definition_rows`, so a set reaches the
/// database, the archive and the registry with no schema change. Because the
/// registry aggregates the sets from every definition it holds, a field on one
/// type can reference a set declared on another — declaring it is not the same
/// as owning it.
class RecordOptionSet {
  const RecordOptionSet({
    required this.id,
    required this.name,
    required this.values,
    this.description = '',
    this.optionDescriptions = const {},
  });

  final String id;
  final String name;

  /// What the set is. Distinct from [optionDescriptions], which is what each
  /// value in it means.
  final String description;
  final List<String> values;

  /// What each value means, keyed by the value itself.
  ///
  /// Sparse on purpose: a set may explain some of its values and not others,
  /// and most sets ("common / rare / unique") explain themselves. Keys that
  /// name no value in [values] are refused at validation rather than ignored,
  /// because that is always a typo.
  final Map<String, String> optionDescriptions;

  /// What [value] means here, or the empty string.
  String describe(String value) => optionDescriptions[value] ?? '';

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'values': values,
        'optionDescriptions': optionDescriptions,
      };

  factory RecordOptionSet.fromJson(Map<String, dynamic> json) =>
      RecordOptionSet(
        id: _requiredString(json['id'], 'Option set id'),
        name: _requiredString(json['name'], 'Option set name'),
        description: json['description'] as String? ?? '',
        values: _stringList(json['values']),
        optionDescriptions: _stringMap(json['optionDescriptions']),
      );
}

class RecordFieldDefinition {
  const RecordFieldDefinition({
    required this.id,
    required this.label,
    required this.type,
    required this.order,
    this.description = '',
    this.required = false,
    this.hidden = false,
    this.enabled = true,
    this.quickCreateVisible = false,
    this.mainViewVisible = true,
    this.searchable = true,
    this.allowCustomValues = false,
    this.defaultValue,
    this.options = const [],
    this.optionDescriptions = const {},
    this.optionSetId,
    this.referenceTypeIds = const [],
    this.extensionData = const {},
    this.soldWith,
  });

  final String id;
  final String label;
  final RecordFieldType type;
  final int order;
  final String description;
  final bool required;

  /// Whether a form draws this field.
  ///
  /// Distinct from [enabled], and deliberately unchanged: the six form
  /// builders that filter on `!field.hidden` behave exactly as before.
  final bool hidden;

  /// Whether this field is active at all.
  ///
  /// [hidden] answers "should the form draw it"; this answers "does it apply".
  /// A disabled field is not offered, not required and not validated — but its
  /// stored values are left untouched, so re-enabling restores them. Nothing
  /// used to express that, and `hidden` was the nearest thing, which is why it
  /// had started being used for both.
  final bool enabled;

  /// Whether the field appears on the abbreviated create form.
  ///
  /// Opt-in: a quick-create form that showed every field by default would not
  /// be quick. No existing template sets it, so no existing form changes.
  final bool quickCreateVisible;

  /// Whether the field appears in the record's main view.
  ///
  /// Defaults true, which is what every template gets today — [hidden] was the
  /// only lever, and it is a form-level one. Separating them lets a field be
  /// editable but absent from the summary, which `hidden` could not say.
  final bool mainViewVisible;

  /// Whether the field's value reaches the search index.
  ///
  /// Defaults **true**, and that default is load-bearing: the indexer writes
  /// `jsonEncode(record.fields)`, so every field is searchable today. Opt-out
  /// preserves that exactly; opt-in would have silently emptied the index.
  final bool searchable;

  /// Whether a choice field accepts a value outside its options.
  ///
  /// Defaults false, so every existing closed choice stays closed.
  final bool allowCustomValues;

  final Object? defaultValue;

  /// This field's own options, used when [optionSetId] is null.
  final List<String> options;

  /// The reusable set this field draws its options from, if any.
  ///
  /// Resolved through [RecordTypeRegistry.optionSet]; [options] is the
  /// fallback, so a field can be moved onto a shared set without rewriting
  /// the records that already hold its values.
  /// What each option means, keyed by the option value.
  ///
  /// The fourth Lock 4 capability to land, and the one the craft library
  /// raised: `options` is a `List<String>`, so until now a field could say
  /// *"Roles: Protagonist, Foil, Deuteragonist"* and had nowhere to say what a
  /// foil is *for*. A field-level description covers the field, not the
  /// fifteen different things it offers.
  ///
  /// Sparse on purpose. Most choice lists explain themselves — `Alive / Dead /
  /// Missing` needs nothing — and an entry is written only where the option is
  /// a term of art. A key naming an option the field does not declare is
  /// refused by [RecordTypeDefinition.validate]: it is always a typo, and a
  /// silently ignored one would leave an author looking for help that the
  /// definition believes it is giving.
  ///
  /// Resolved through [RecordTypeRegistry.optionDescriptionsFor], which reads
  /// a referenced option set the same way [RecordTypeRegistry.optionsFor]
  /// reads its values.
  final Map<String, String> optionDescriptions;

  final String? optionSetId;

  /// What [option] means on this field, or the empty string.
  ///
  /// Ignores any option set: a field that references one resolves through the
  /// registry, which is the only thing that can see other definitions.
  String describeOption(String option) => optionDescriptions[option] ?? '';

  final List<String> referenceTypeIds;
  final Map<String, Object?> extensionData;

  /// Which capability owns this field's depth, or null when the field is free.
  ///
  /// **M1, the field ownership marker.**
  /// [ADR-0017](../../docs/architecture/ADR-0017-write-is-complete-expansions-are-rooms.md)'s
  /// D1: *the gating unit is the field, not the record type.* An author gets
  /// every record type; some of the depth inside a few of them belongs to a
  /// room, and this is where a definition says which.
  ///
  /// ## A capability id, not a product and not a room
  ///
  /// `'language.deepPhonology'`, never `'aos-worldsmith'` and never
  /// `AuthorRoom.languageForge`. The chain is **field → capability → product**,
  /// and each link is stated exactly once:
  ///
  ///   * `core/capabilities.dart` is the one place the free/paid line is
  ///     stated, and it already maps a capability to the product that sells
  ///     it. A field naming a product would be a second copy of that mapping,
  ///     and the copies would drift the first time a capability moved between
  ///     products — which is Lock 1's whole subject.
  ///   * `entitlement.dart` names products and deliberately never names rooms.
  ///     This inherits that.
  ///
  /// ## A `String`, not an enum
  ///
  /// A definition serialises to `record_type_definition_rows` and into
  /// `.authoros`. One written by a newer build has to round-trip through an
  /// older one without losing the marker, which is the argument
  /// [Entitlements.unknown] already makes for keeping a purchase it cannot
  /// name. An enum would drop what it could not parse.
  ///
  /// ## It is a declaration. It asks nothing.
  ///
  /// Nothing here reads an entitlement, and nothing may:
  /// `entitlement_reads_are_owned_test.dart` forbids Core from asking, and the
  /// rule is phrased against *reading* rather than *naming* precisely so this
  /// marker is legal. Resolution happens in `core/field_ownership.dart`, which
  /// is handed the answer.
  ///
  /// ## Why not [hidden], and why not [enabled]
  ///
  /// Both are the **author's own** configuration. Overloading either would
  /// leave an author unable to tell *I turned this off* from *I have not
  /// bought this* — the exact confusion the Lock 7 amendment exists to
  /// prevent. [enabled] would be worse still: `ProjectFieldConfiguration`
  /// writes it, so a project configuration could grant an entitlement by
  /// switching a field back on.
  final String? soldWith;

  /// Whether this field's depth belongs to a room.
  bool get isSold => soldWith != null;

  /// This field with [enabled] changed.
  ///
  /// Deliberately narrow. Project configuration is the only caller, it only
  /// ever switches a field off, and a general-purpose copyWith over sixteen
  /// properties would invite exactly the template mutation this layer exists
  /// to prevent.
  RecordFieldDefinition copyWith({bool? enabled}) => RecordFieldDefinition(
        id: id,
        label: label,
        type: type,
        order: order,
        description: description,
        required: required,
        hidden: hidden,
        enabled: enabled ?? this.enabled,
        quickCreateVisible: quickCreateVisible,
        mainViewVisible: mainViewVisible,
        searchable: searchable,
        allowCustomValues: allowCustomValues,
        defaultValue: defaultValue,
        options: options,
        optionDescriptions: optionDescriptions,
        optionSetId: optionSetId,
        referenceTypeIds: referenceTypeIds,
        extensionData: extensionData,
        // Ownership is not the author's to change, so it is carried rather
        // than accepted. There is no parameter for it here and there must not
        // be: a `copyWith(soldWith: null)` would be a paywall removed by a
        // caller, and a `copyWith(soldWith: ...)` one added by one.
        soldWith: soldWith,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
        'type': type.name,
        'order': order,
        'description': description,
        'required': required,
        'hidden': hidden,
        'enabled': enabled,
        'quickCreateVisible': quickCreateVisible,
        'mainViewVisible': mainViewVisible,
        'searchable': searchable,
        'allowCustomValues': allowCustomValues,
        'defaultValue': defaultValue,
        'options': options,
        'optionDescriptions': optionDescriptions,
        'optionSetId': optionSetId,
        'referenceTypeIds': referenceTypeIds,
        'extensionData': extensionData,
        'soldWith': soldWith,
      };

  factory RecordFieldDefinition.fromJson(Map<String, dynamic> json) =>
      RecordFieldDefinition(
        id: _requiredString(json['id'], 'Field id'),
        label: _requiredString(json['label'], 'Field label'),
        type: _enumValue(RecordFieldType.values, json['type'], 'field type'),
        order: _nonNegativeInt(json['order'], 'Field order'),
        description: json['description'] as String? ?? '',
        required: json['required'] as bool? ?? false,
        hidden: json['hidden'] as bool? ?? false,
        // Every new property defaults to the behaviour a definition written
        // before it existed already had, so an old field deserialises into
        // exactly the field it was.
        enabled: json['enabled'] as bool? ?? true,
        quickCreateVisible: json['quickCreateVisible'] as bool? ?? false,
        mainViewVisible: json['mainViewVisible'] as bool? ?? true,
        searchable: json['searchable'] as bool? ??
            // The pre-S0a convention: `extensionData: {'searchable': true}`.
            // Read once here so the canonical property is the only thing the
            // rest of AuthorOS ever consults.
            _legacySearchable(json) ??
            true,
        allowCustomValues: json['allowCustomValues'] as bool? ?? false,
        defaultValue: json['defaultValue'],
        options: _stringList(json['options']),
        optionDescriptions: _stringMap(json['optionDescriptions']),
        optionSetId: _optionalString(json['optionSetId']),
        referenceTypeIds: _stringList(json['referenceTypeIds']),
        extensionData: _objectMap(json['extensionData']),
        // Null by default, so every definition written before the marker
        // existed deserialises into exactly the field it was — free.
        soldWith: _optionalString(json['soldWith']),
      );
}

class RecordTemplateSection {
  const RecordTemplateSection({
    required this.id,
    required this.title,
    required this.order,
    this.fieldIds = const [],
    this.collapsedByDefault = false,
    this.extensionData = const {},
  });

  final String id;
  final String title;
  final int order;
  final List<String> fieldIds;
  final bool collapsedByDefault;
  final Map<String, Object?> extensionData;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'order': order,
        'fieldIds': fieldIds,
        'collapsedByDefault': collapsedByDefault,
        'extensionData': extensionData,
      };

  factory RecordTemplateSection.fromJson(Map<String, dynamic> json) =>
      RecordTemplateSection(
        id: _requiredString(json['id'], 'Section id'),
        title: _requiredString(json['title'], 'Section title'),
        order: _nonNegativeInt(json['order'], 'Section order'),
        fieldIds: _stringList(json['fieldIds']),
        collapsedByDefault: json['collapsedByDefault'] as bool? ?? false,
        extensionData: _objectMap(json['extensionData']),
      );
}

class RecordTypeDefinition {
  const RecordTypeDefinition({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.fields,
    required this.sections,
    this.optionSets = const [],
    this.description = '',
    this.icon = 'description',
    this.baseTypeId,
    this.tags = const [],
    this.suggestedLinkTypeIds = const [],
    this.scopeType = RecordScopeType.library,
    this.scopeId = 'authoros',
    this.allowedScopeTypes = RecordScopeType.values,
    this.permissions = const {},
    this.exportBehavior = const {},
    this.templateVersion = 1,
    this.builtIn = false,
    this.sourcePackId,
    this.soldWith,
    this.extensionData = const {},
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final String categoryId;
  final String? baseTypeId;
  final List<RecordFieldDefinition> fields;
  final List<RecordTemplateSection> sections;

  /// Reusable option sets this type declares.
  ///
  /// Declared here rather than in a table of their own so they persist and
  /// serialise with the definition that carries them. The registry pools every
  /// definition's sets, so declaring a set is not the same as owning it — any
  /// field on any type may reference it by id.
  final List<RecordOptionSet> optionSets;

  /// The set [id] names, if this definition declares it.
  ///
  /// A definition sees only its own sets. [RecordTypeRegistry.optionSet] sees
  /// every definition's, which is the difference between the two and the
  /// reason a form builder holding one definition may still find nothing.
  RecordOptionSet? optionSet(String? id) {
    if (id == null) return null;
    for (final set in optionSets) {
      if (set.id == id) return set;
    }
    return null;
  }

  /// What [field] offers, resolved against this definition's own sets.
  ///
  /// For a form builder that holds the record's definition and no registry.
  /// Degrades to the field's inline options when the set is declared
  /// elsewhere, which is the same fallback [RecordTypeRegistry.optionsFor]
  /// makes when a set has gone missing.
  List<String> optionsFor(RecordFieldDefinition field) =>
      resolveOptions(field, optionSet(field.optionSetId));

  /// What each of [field]'s options means, resolved as [optionsFor] resolves
  /// the values.
  Map<String, String> optionDescriptionsFor(RecordFieldDefinition field) =>
      resolveOptionDescriptions(field, optionSet(field.optionSetId));
  final List<String> tags;
  final List<String> suggestedLinkTypeIds;
  final RecordScopeType scopeType;
  final String scopeId;
  final List<RecordScopeType> allowedScopeTypes;
  final Map<String, Object?> permissions;
  final Map<String, Object?> exportBehavior;
  final int templateVersion;
  final bool builtIn;
  final String? sourcePackId;

  /// Which capability owns this record type **whole**, or null when the type
  /// itself is free.
  ///
  /// **M2, the type ownership marker**, and the exception rather than the rule.
  /// [ADR-0017](../../docs/architecture/ADR-0017-write-is-complete-expansions-are-rooms.md)'s
  /// D1 says the gating unit is the *field*, so a type carrying this is a
  /// deliberate departure that has to be argued in
  /// [the ledger](../../docs/free-paid-gating-ledger.md), never a convenience.
  ///
  /// It is for a type that has no free reading at all — one whose entire
  /// subject is a room's, so that keeping a basic version would mean inventing
  /// a shallower thing nobody asked for. The ledger's example is `reveal`: nine
  /// fields about who knew what and when, which is CaseBook's whole axis.
  ///
  /// ## What it does *not* do
  ///
  /// It withholds the type from a **create picker**. It never hides, filters,
  /// unlinks or de-indexes a record — the G0 guarantee is that *a surface may
  /// be absent for an unowned system; it may never be absent while it holds
  /// the author's records*, and `specialist_presentation.dart` is where that
  /// distinction is kept.
  ///
  /// Same shape and same reasons as [RecordFieldDefinition.soldWith]: a
  /// capability id rather than a product, a `String` rather than an enum so a
  /// newer build's definition round-trips through an older one, and a
  /// declaration that asks nothing. Resolution is in
  /// `core/system_ownership.dart`.
  final String? soldWith;

  /// Whether this record type belongs to a room in its entirety.
  bool get isSold => soldWith != null;

  final Map<String, Object?> extensionData;

  /// This definition with [fields] replaced.
  ///
  /// Narrow for the same reason as [RecordFieldDefinition.copyWith]: applying
  /// project configuration produces a view of a template, and a view should
  /// differ from the original in exactly one respect.
  RecordTypeDefinition copyWith({List<RecordFieldDefinition>? fields}) =>
      RecordTypeDefinition(
        id: id,
        name: name,
        categoryId: categoryId,
        fields: fields ?? this.fields,
        sections: sections,
        optionSets: optionSets,
        description: description,
        icon: icon,
        baseTypeId: baseTypeId,
        tags: tags,
        suggestedLinkTypeIds: suggestedLinkTypeIds,
        scopeType: scopeType,
        scopeId: scopeId,
        allowedScopeTypes: allowedScopeTypes,
        permissions: permissions,
        exportBehavior: exportBehavior,
        templateVersion: templateVersion,
        builtIn: builtIn,
        sourcePackId: sourcePackId,
        // Carried, never accepted — the same rule and the same reason as
        // `RecordFieldDefinition.copyWith`. Applying project configuration
        // produces a view of a template, and a view may not change who owns it.
        soldWith: soldWith,
        extensionData: extensionData,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'categoryId': categoryId,
        'baseTypeId': baseTypeId,
        'fields': fields.map((field) => field.toJson()).toList(),
        'sections': sections.map((section) => section.toJson()).toList(),
        'optionSets': optionSets.map((set) => set.toJson()).toList(),
        'tags': tags,
        'suggestedLinkTypeIds': suggestedLinkTypeIds,
        'scopeType': scopeType.name,
        'scopeId': scopeId,
        'allowedScopeTypes':
            allowedScopeTypes.map((scope) => scope.name).toList(),
        'permissions': permissions,
        'exportBehavior': exportBehavior,
        'templateVersion': templateVersion,
        'builtIn': builtIn,
        'sourcePackId': sourcePackId,
        'soldWith': soldWith,
        'extensionData': extensionData,
      };

  factory RecordTypeDefinition.fromJson(Map<String, dynamic> json) =>
      RecordTypeDefinition(
        id: _requiredString(json['id'], 'Record type id'),
        name: _requiredString(json['name'], 'Record type name'),
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? 'description',
        categoryId: _requiredString(json['categoryId'], 'Category id'),
        baseTypeId: _optionalString(json['baseTypeId']),
        fields: _mapList(json['fields'])
            .map(RecordFieldDefinition.fromJson)
            .toList(),
        sections: _mapList(json['sections'])
            .map(RecordTemplateSection.fromJson)
            .toList(),
        optionSets:
            _mapList(json['optionSets']).map(RecordOptionSet.fromJson).toList(),
        tags: _stringList(json['tags']),
        suggestedLinkTypeIds: _stringList(json['suggestedLinkTypeIds']),
        scopeType: _enumValue(
          RecordScopeType.values,
          json['scopeType'] ?? RecordScopeType.library.name,
          'definition scope',
        ),
        scopeId: _requiredString(
          json['scopeId'] ?? 'authoros',
          'Definition scope id',
        ),
        allowedScopeTypes: _stringList(json['allowedScopeTypes'])
            .map((value) =>
                _enumValue(RecordScopeType.values, value, 'record scope'))
            .toList(),
        permissions: _objectMap(json['permissions']),
        exportBehavior: _objectMap(json['exportBehavior']),
        templateVersion:
            _positiveInt(json['templateVersion'], 'Template version'),
        builtIn: json['builtIn'] as bool? ?? false,
        sourcePackId: _optionalString(json['sourcePackId']),
        soldWith: _optionalString(json['soldWith']),
        extensionData: _objectMap(json['extensionData']),
      );
}

class RecordTypeRegistry {
  RecordTypeRegistry(Iterable<RecordTypeDefinition> definitions)
      : _definitions = {
          for (final definition in definitions) definition.id: definition,
        } {
    if (_definitions.length != definitions.length) {
      throw const FormatException('Record type ids must be unique.');
    }
    for (final definition in _definitions.values) {
      _validateDefinition(definition);
    }
  }

  final Map<String, RecordTypeDefinition> _definitions;

  List<RecordTypeDefinition> get definitions => _definitions.values.toList()
    ..sort((left, right) => left.id.compareTo(right.id));

  /// Every option set declared by any definition in this registry, by id.
  ///
  /// Pooled rather than per-type so a field can reference a set another type
  /// declares — reuse across templates is the point of the concept.
  late final Map<String, RecordOptionSet> _optionSets = {
    for (final definition in _definitions.values)
      for (final set in definition.optionSets) set.id: set,
  };

  /// The option set [id] names, or null when nothing declares it.
  RecordOptionSet? optionSet(String id) => _optionSets[id];

  /// The choices [field] offers, from its set when it references one.
  ///
  /// Falls back to the field's own [RecordFieldDefinition.options] — including
  /// when the referenced set is missing, so a definition that names a set no
  /// longer present degrades to its inline options instead of losing them.
  List<String> optionsFor(RecordFieldDefinition field) =>
      resolveOptions(field, optionSet(field.optionSetId ?? ''));

  /// What each of [field]'s options means, resolved the way its values are.
  ///
  /// A field referencing a set takes the set's descriptions, and its own
  /// override any the set gives for the same option — the same precedence a
  /// reader would assume from `optionsFor`, where the nearer declaration wins.
  /// That lets one shared set carry the general explanation while a field that
  /// uses the vocabulary differently corrects a single entry.
  ///
  /// Falls back to the field's own map when the referenced set is missing, so
  /// a definition naming a set no longer present degrades exactly as
  /// [optionsFor] does rather than losing its help.
  Map<String, String> optionDescriptionsFor(RecordFieldDefinition field) =>
      resolveOptionDescriptions(field, optionSet(field.optionSetId ?? ''));

  /// What [option] means on [field], or the empty string.
  String describeOption(RecordFieldDefinition field, String option) =>
      optionDescriptionsFor(field)[option] ?? '';

  RecordTypeDefinition resolve(String id) => _resolve(id, <String>[]);

  /// [typeId] and every type it inherits from, nearest first.
  ///
  /// The substitutability chain: a record of [typeId] is usable anywhere any
  /// id in this set is accepted, because each one is a type it *is*. Cached
  /// per registry because the connection registry asks for every type at once
  /// when it resolves relationship permission.
  ///
  /// An unknown id yields just itself rather than throwing — permission is a
  /// question about a type, and a type nobody declared simply has no ancestors.
  Set<String> selfAndAncestors(String typeId) =>
      _selfAndAncestors[typeId] ??= _walkAncestors(typeId);

  final Map<String, Set<String>> _selfAndAncestors = {};

  Set<String> _walkAncestors(String typeId) {
    final chain = <String>{};
    String? currentId = typeId;
    while (currentId != null && chain.add(currentId)) {
      currentId = _definitions[currentId]?.baseTypeId;
    }
    return chain;
  }

  bool isTemplateCompatible(String templateId, String recordTypeId) {
    String? currentId = templateId;
    final visited = <String>{};
    while (currentId != null && visited.add(currentId)) {
      if (currentId == recordTypeId) return true;
      currentId = _definitions[currentId]?.baseTypeId;
    }
    return false;
  }

  RecordTypeDefinition _resolve(String id, List<String> path) {
    final definition = _definitions[id];
    if (definition == null) {
      throw StateError('Unknown record type: $id');
    }
    if (path.contains(id)) {
      throw StateError(
        'Record type inheritance cycle: ${[...path, id].join(' -> ')}',
      );
    }
    final baseTypeId = definition.baseTypeId;
    if (baseTypeId == null) {
      return definition;
    }
    final parent = _resolve(baseTypeId, [...path, id]);
    return _merge(parent, definition);
  }

  RecordTypeDefinition _merge(
    RecordTypeDefinition parent,
    RecordTypeDefinition child,
  ) {
    final fields = <String, RecordFieldDefinition>{
      for (final field in parent.fields) field.id: field,
    };
    for (final field in child.fields) {
      final inherited = fields[field.id];
      if (field.hidden && inherited?.required == true) {
        throw StateError('Required field ${field.id} cannot be hidden.');
      }
      fields[field.id] = field;
    }

    final sections = <String, RecordTemplateSection>{
      for (final section in parent.sections) section.id: section,
      for (final section in child.sections) section.id: section,
    };
    final merged = RecordTypeDefinition(
      id: child.id,
      name: child.name,
      description:
          child.description.isEmpty ? parent.description : child.description,
      icon: child.icon,
      categoryId: child.categoryId,
      baseTypeId: child.baseTypeId,
      fields: fields.values.toList()
        ..sort((left, right) => left.order.compareTo(right.order)),
      sections: sections.values.toList()
        ..sort((left, right) => left.order.compareTo(right.order)),
      // Option sets inherit the way fields do: a child may redefine one of its
      // parent's sets by declaring the same id, and inherits the rest.
      optionSets: {
        for (final set in parent.optionSets) set.id: set,
        for (final set in child.optionSets) set.id: set,
      }.values.toList(),
      tags: {...parent.tags, ...child.tags}.toList(),
      suggestedLinkTypeIds: {
        ...parent.suggestedLinkTypeIds,
        ...child.suggestedLinkTypeIds,
      }.toList(),
      scopeType: child.scopeType,
      scopeId: child.scopeId,
      allowedScopeTypes: child.allowedScopeTypes,
      permissions: {...parent.permissions, ...child.permissions},
      exportBehavior: {...parent.exportBehavior, ...child.exportBehavior},
      templateVersion: child.templateVersion,
      builtIn: child.builtIn,
      sourcePackId: child.sourcePackId ?? parent.sourcePackId,
      extensionData: {...parent.extensionData, ...child.extensionData},
    );
    _validateDefinition(merged);
    return merged;
  }

  void _validateDefinition(RecordTypeDefinition definition) {
    _requiredString(definition.id, 'Record type id');
    _requiredString(definition.name, 'Record type name');
    _requiredString(definition.categoryId, 'Category id');
    _requiredString(definition.scopeId, 'Definition scope id');
    if (definition.templateVersion < 1) {
      throw const FormatException('Template version must be positive.');
    }
    if (definition.allowedScopeTypes.isEmpty) {
      throw FormatException(
        'Record type ${definition.id} must allow at least one scope.',
      );
    }

    // A set explains its own values, and is checked where it is declared —
    // which is what lets the field-level check below skip a field that
    // references one.
    for (final set in definition.optionSets) {
      for (final option in set.optionDescriptions.keys) {
        if (!set.values.contains(option)) {
          throw FormatException(
            'Option set ${set.id} describes a value it does not hold: '
            '"$option".',
          );
        }
      }
    }

    final fieldIds = <String>{};
    for (final field in definition.fields) {
      if (!fieldIds.add(field.id)) {
        throw FormatException('Duplicate field id: ${field.id}');
      }
      _requiredString(field.id, 'Field id');
      _requiredString(field.label, 'Field label');
      if (field.order < 0) {
        throw FormatException('Field ${field.id} has a negative order.');
      }
      if (field.required && field.hidden) {
        throw FormatException('Required field ${field.id} cannot be hidden.');
      }
      if ((field.type == RecordFieldType.singleChoice ||
              field.type == RecordFieldType.multipleChoice) &&
          field.options.isEmpty &&
          field.optionSetId == null &&
          !field.allowCustomValues) {
        throw FormatException('Choice field ${field.id} requires options.');
      }
      // An explanation for an option that does not exist is always a typo,
      // and one that is ignored leaves the definition believing it offers
      // help the author will never see. Only checked against inline options:
      // a field referencing a set is explained by the set, which is validated
      // where it is declared.
      if (field.optionSetId == null) {
        for (final option in field.optionDescriptions.keys) {
          if (!field.options.contains(option)) {
            throw FormatException(
              'Field ${field.id} describes an option it does not offer: '
              '"$option".',
            );
          }
        }
      }
      _validateDefault(field);
    }

    final sectionIds = <String>{};
    for (final section in definition.sections) {
      if (!sectionIds.add(section.id)) {
        throw FormatException('Duplicate section id: ${section.id}');
      }
      if (section.order < 0) {
        throw FormatException('Section ${section.id} has a negative order.');
      }
      for (final fieldId in section.fieldIds) {
        if (!fieldIds.contains(fieldId)) {
          throw FormatException(
            'Section ${section.id} references unknown field $fieldId.',
          );
        }
      }
    }
  }
}

void _validateDefault(RecordFieldDefinition field) {
  final value = field.defaultValue;
  if (value == null) {
    return;
  }
  final valid = switch (field.type) {
    RecordFieldType.number || RecordFieldType.rating => value is num,
    RecordFieldType.boolean => value is bool,
    RecordFieldType.multipleChoice ||
    RecordFieldType.tags ||
    RecordFieldType.list ||
    RecordFieldType.table ||
    RecordFieldType.checklist =>
      value is List,
    RecordFieldType.singleChoice =>
      value is String && field.options.contains(value),
    _ => value is String,
  };
  if (!valid) {
    throw FormatException('Invalid default value for field ${field.id}.');
  }
}

/// The `extensionData: {'searchable': true}` convention S0a replaces.
///
/// Read only here, at the deserialisation boundary, so a definition written
/// against the old convention still resolves to the canonical property and no
/// second representation survives anywhere else in the tree.
bool? _legacySearchable(Map<String, dynamic> json) {
  final extension = json['extensionData'];
  if (extension is! Map) return null;
  final value = extension['searchable'];
  return value is bool ? value : null;
}

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

int _positiveInt(Object? value, String label) {
  final number = value is num ? value.toInt() : int.tryParse('$value');
  if (number == null || number < 1) {
    throw FormatException('$label must be a positive integer.');
  }
  return number;
}

int _nonNegativeInt(Object? value, String label) {
  final number = value is num ? value.toInt() : int.tryParse('$value');
  if (number == null || number < 0) {
    throw FormatException('$label must be a non-negative integer.');
  }
  return number;
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

/// What [field] offers, given the option set it references, if any.
///
/// The one answer to that question. [RecordTypeRegistry.optionsFor] passes the
/// set it found by aggregating every definition it holds; a form builder
/// holding only the record's own definition passes what that definition
/// declares. Two copies of this would be two answers, and the second one
/// would be silent.
///
/// Falls back to the field's inline options when [set] is null — including
/// when the field names a set nothing declares, so a definition that outlives
/// its set degrades to its own list instead of offering nothing.
List<String> resolveOptions(RecordFieldDefinition field, RecordOptionSet? set) {
  if (field.optionSetId == null || set == null) return field.options;
  return set.values;
}

/// What each of [field]'s options means, resolved as [resolveOptions] resolves
/// the values themselves.
///
/// The field's own entries override the set's for the same option: the nearer
/// declaration wins, so one shared set can carry the general explanation while
/// a field using the vocabulary differently corrects a single entry.
Map<String, String> resolveOptionDescriptions(
  RecordFieldDefinition field,
  RecordOptionSet? set,
) {
  if (field.optionSetId == null || set == null) return field.optionDescriptions;
  return {...set.optionDescriptions, ...field.optionDescriptions};
}

List<String> _stringList(Object? value) =>
    value is List ? value.map((item) => item.toString()).toList() : [];

/// A `{option: description}` map, from JSON that may hold anything.
///
/// Both halves are stringified rather than type-checked, matching
/// [_stringList] beside it: a definition written by an older build is read as
/// well as it can be, never refused.
Map<String, String> _stringMap(Object? value) => value is Map
    ? {
        for (final entry in value.entries)
          entry.key.toString(): entry.value.toString(),
      }
    : <String, String>{};

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value.map((item) => Map<String, dynamic>.from(item as Map)).toList()
    : [];

/// Whether [value] counts as *not set* for a field.
///
/// Absence is not an error. An `endDate` on a relationship that has not ended
/// is empty, and that is the normal case rather than a wrong value — only
/// `required` decides whether absence is a problem.
bool recordFieldIsEmpty(Object? value) =>
    value == null ||
    (value is String && value.trim().isEmpty) ||
    (value is Iterable && value.isEmpty) ||
    (value is Map && value.isEmpty);

/// Whether [value] is an acceptable value for [field].
///
/// The one answer to *"does this value fit this field"*. Records have always
/// asked it; connection metadata did not, and so accepted a boolean in a date
/// and a sentence in a rating until the relationship-metadata work pointed both
/// halves of the model here. Two copies of this question would be two answers,
/// and the second one was silent.
///
/// It lives beside the field system rather than in `record_validation.dart`
/// because it is a fact about a field, not about a record — and because
/// `connection_types.dart` can reach this file without closing an import
/// cycle.
///
/// [choices] is what a `singleChoice` may hold. A record resolves it through
/// [RecordTypeRegistry.optionsFor], which understands shared option sets; a
/// connection type has no option sets, so it passes the field's own [options].
bool recordFieldAccepts(
  RecordFieldDefinition field,
  Object? value, {
  List<String> choices = const [],
}) =>
    switch (field.type) {
      RecordFieldType.number || RecordFieldType.rating => value is num,
      RecordFieldType.boolean => value is bool,
      // A date in a made-up world is not a calendar date. `MapWorldClock`
      // already reads three shapes and the world simulation depends on all of
      // them: a `num` is an in-world year ("405"), a `String` is either an ISO
      // date or a year written out, and a `Map` is a structured `TimelineDate`.
      // This accepts what that reader accepts, rather than inventing a
      // narrower rule that would reject an author's own calendar.
      //
      // What it still catches is the wrong kind of value entirely — a boolean
      // in a date — which is the case connection metadata was letting through.
      RecordFieldType.date ||
      RecordFieldType.dateRange =>
        value is String || value is num || value is Map,
      RecordFieldType.multipleChoice ||
      RecordFieldType.tags ||
      RecordFieldType.list ||
      RecordFieldType.table ||
      RecordFieldType.checklist =>
        value is List,
      // A closed choice still rejects anything outside its options. A field
      // that declares `allowCustomValues` accepts a value the template never
      // listed — which is the difference between "pick one of these" and
      // "pick one of these, or say your own".
      RecordFieldType.singleChoice =>
        value is String && (field.allowCustomValues || choices.contains(value)),
      _ => value is String,
    };
