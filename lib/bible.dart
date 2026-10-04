/// The Codex Bible System: any deep bible — a magic system, a faction, a
/// crime case, a romance, a government, a calendar — as one engine
/// (AOS-Write `PLAN.md` §3.56).
///
/// **Nothing here is a second record model.** A bible *type* is a
/// project-scoped [RecordTypeDefinition], stored, synced and archived the way
/// every custom template already is; what makes it a bible is
/// `extensionData['bible']`, which names its **entry sections** — the lists
/// of other records the bible gathers (its spells, its suspects, its laws).
/// A bible is an [AuthorRecord] of that type: its own page is its fields, its
/// entries are ordinary records joined to it by the wildcard `partOf` edge,
/// and the section an entry sits in rides on that edge's metadata. Search,
/// canon status, links, history, sync, the archive and field selling all
/// apply unchanged, because none of them was told a bible exists.
///
/// The rest of the system rides the same record:
///
/// * **Rules** the author writes about their world live on the bible record
///   under `_bible.rules` ([BibleRule]); `detectBibleRules` checks them.
/// * **Hidden truths** live under `_truth.values` (`hidden_truth.dart`), on
///   any record, for any field.
library;

import 'record_scope.dart';
import 'record_types.dart';

/// The link that joins an entry to its bible: the entry is `partOf` it.
const bibleEntryLinkType = 'partOf';

/// The `partOf` metadata key naming the entry section an entry sits in.
const bibleSectionMetadataKey = 'bibleSection';

/// One list of entries a bible gathers.
class BibleEntrySection {
  const BibleEntrySection({
    required this.id,
    required this.title,
    required this.typeIds,
    this.description = '',
    this.order = 0,
  });

  final String id;
  final String title;
  final String description;

  /// The record types a new entry here may be. The first is the default. An
  /// existing record of any type may still be added.
  final List<String> typeIds;
  final int order;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        if (description.isNotEmpty) 'description': description,
        'typeIds': typeIds,
        'order': order,
      };

  factory BibleEntrySection.fromJson(Map<String, Object?> json) =>
      BibleEntrySection(
        id: '${json['id'] ?? ''}',
        title: '${json['title'] ?? ''}',
        description: '${json['description'] ?? ''}',
        typeIds: [
          for (final id in (json['typeIds'] as List?) ?? const [])
            if ('$id'.isNotEmpty) '$id',
        ],
        order: (json['order'] as num?)?.toInt() ?? 0,
      );

  BibleEntrySection copyWith({
    String? title,
    String? description,
    List<String>? typeIds,
    int? order,
  }) =>
      BibleEntrySection(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        typeIds: typeIds ?? this.typeIds,
        order: order ?? this.order,
      );
}

/// Reading and writing what makes a record type a bible type.
abstract final class BibleTypes {
  /// The `extensionData` key on a bible type.
  static const extensionKey = 'bible';

  /// The category bible types file under.
  static const categoryId = 'custom';

  static bool isBible(RecordTypeDefinition type) =>
      type.extensionData[extensionKey] is Map &&
      type.extensionData['archived'] != true;

  static Map<String, Object?> _data(RecordTypeDefinition type) {
    final data = type.extensionData[extensionKey];
    return data is Map ? Map<String, Object?>.from(data) : const {};
  }

  /// The type's entry sections, in order.
  static List<BibleEntrySection> entrySections(RecordTypeDefinition type) {
    final raw = _data(type)['entrySections'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map)
          BibleEntrySection.fromJson(Map<String, Object?>.from(item)),
    ]..sort((a, b) => a.order.compareTo(b.order));
  }

  /// The starter template a type was made from, or empty for one built from
  /// nothing.
  static String templateOf(RecordTypeDefinition type) =>
      '${_data(type)['template'] ?? ''}';

  /// What kind of page opens this bible: `fields` for the general page, or
  /// a specialised editor's name (`calendar`).
  static String editorOf(RecordTypeDefinition type) =>
      '${_data(type)['editor'] ?? 'fields'}';

  /// A bible type, project-scoped to [projectId].
  static RecordTypeDefinition build({
    required String id,
    required String name,
    required String projectId,
    String description = '',
    String icon = 'menu_book',
    List<RecordFieldDefinition> fields = const [],
    List<RecordTemplateSection> sections = const [],
    List<BibleEntrySection> entrySections = const [],
    String template = '',
    int templateVersion = 1,
  }) =>
      RecordTypeDefinition(
        id: id,
        name: name,
        description: description,
        icon: icon,
        categoryId: categoryId,
        fields: fields,
        sections: sections,
        scopeType: RecordScopeType.project,
        scopeId: projectId,
        templateVersion: templateVersion,
        sourcePackId: 'project:$projectId',
        extensionData: {
          extensionKey: {
            if (template.isNotEmpty) 'template': template,
            'entrySections': [for (final item in entrySections) item.toJson()],
          },
        },
      );

  /// [type] with its definition replaced, keeping its identity and scope.
  static RecordTypeDefinition revise(
    RecordTypeDefinition type, {
    String? name,
    String? description,
    List<RecordFieldDefinition>? fields,
    List<RecordTemplateSection>? sections,
    List<BibleEntrySection>? entrySections,
  }) =>
      RecordTypeDefinition(
        id: type.id,
        name: name ?? type.name,
        description: description ?? type.description,
        icon: type.icon,
        categoryId: type.categoryId,
        fields: fields ?? type.fields,
        sections: sections ?? type.sections,
        optionSets: type.optionSets,
        tags: type.tags,
        suggestedLinkTypeIds: type.suggestedLinkTypeIds,
        scopeType: type.scopeType,
        scopeId: type.scopeId,
        allowedScopeTypes: type.allowedScopeTypes,
        permissions: type.permissions,
        exportBehavior: type.exportBehavior,
        templateVersion: type.templateVersion + 1,
        sourcePackId: type.sourcePackId,
        soldWith: type.soldWith,
        extensionData: {
          ...type.extensionData,
          extensionKey: {
            ..._data(type),
            if (entrySections != null)
              'entrySections': [
                for (final item in entrySections) item.toJson(),
              ],
          },
        },
      );
}

/// A field id from what the author called it: lower camel case, unique among
/// [taken].
String bibleFieldId(String label, Iterable<String> taken) {
  final words = label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList();
  var base = words.isEmpty
      ? 'field'
      : words.first +
          words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
  if (RegExp(r'^[0-9]').hasMatch(base)) base = 'f$base';
  final used = taken.toSet();
  var id = base;
  for (var n = 2; used.contains(id); n++) {
    id = '$base$n';
  }
  return id;
}

// ---------------------------------------------------------------------------
// Rules
// ---------------------------------------------------------------------------

/// The kinds of rule an author can write about their world.
///
/// Each is a question the records can answer exactly — the Continuity
/// Engine's rule that prose is never parsed for facts holds here too.
enum BibleRuleKind {
  /// Every record of a type fills a field: *every House has a sigil*.
  required('Every … has …'),

  /// No two records of a type share a field's value: *no two Houses share a
  /// sigil*.
  unique('No two … share …'),

  /// No record is the target of more than one link of a kind: *a throne has
  /// one ruler*.
  oneLink('Only one …'),

  /// No record of a type holds two values together: *no Saint is a witch*.
  neverTogether('Never both …'),

  /// Along every link of a kind, the source is dated before the target: *a
  /// parent is born before their child*.
  before('Always before …');

  const BibleRuleKind(this.label);

  final String label;

  static BibleRuleKind? byName(String name) {
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return null;
  }
}

/// One rule, in the author's words and in terms the records can check.
class BibleRule {
  const BibleRule({
    required this.id,
    required this.kind,
    this.statement = '',
    this.typeId = '',
    this.fieldId = '',
    this.value = '',
    this.otherFieldId = '',
    this.otherValue = '',
    this.linkTypeId = '',
    this.enabled = true,
  });

  final String id;
  final BibleRuleKind kind;

  /// The rule as the author says it: *"The Saints never ordain a witch."*
  final String statement;

  /// The record type it is about (not used by [BibleRuleKind.oneLink] and
  /// [BibleRuleKind.before], which are about links).
  final String typeId;
  final String fieldId;

  /// For [BibleRuleKind.neverTogether]: the first field's value.
  final String value;

  /// For [BibleRuleKind.neverTogether]: the second field and its value.
  final String otherFieldId;
  final String otherValue;

  /// For [BibleRuleKind.oneLink] and [BibleRuleKind.before].
  final String linkTypeId;

  final bool enabled;

  /// Whether enough is filled in for the rule to be checked.
  bool get isComplete => switch (kind) {
        BibleRuleKind.required ||
        BibleRuleKind.unique =>
          typeId.isNotEmpty && fieldId.isNotEmpty,
        BibleRuleKind.neverTogether => typeId.isNotEmpty &&
            fieldId.isNotEmpty &&
            otherFieldId.isNotEmpty &&
            value.isNotEmpty &&
            otherValue.isNotEmpty,
        BibleRuleKind.oneLink || BibleRuleKind.before => linkTypeId.isNotEmpty,
      };

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        if (statement.isNotEmpty) 'statement': statement,
        if (typeId.isNotEmpty) 'typeId': typeId,
        if (fieldId.isNotEmpty) 'fieldId': fieldId,
        if (value.isNotEmpty) 'value': value,
        if (otherFieldId.isNotEmpty) 'otherFieldId': otherFieldId,
        if (otherValue.isNotEmpty) 'otherValue': otherValue,
        if (linkTypeId.isNotEmpty) 'linkTypeId': linkTypeId,
        if (!enabled) 'enabled': false,
      };

  static BibleRule? fromJson(Map<String, Object?> json) {
    final kind = BibleRuleKind.byName('${json['kind'] ?? ''}');
    if (kind == null) return null;
    String text(String key) => '${json[key] ?? ''}';
    return BibleRule(
      id: text('id'),
      kind: kind,
      statement: text('statement'),
      typeId: text('typeId'),
      fieldId: text('fieldId'),
      value: text('value'),
      otherFieldId: text('otherFieldId'),
      otherValue: text('otherValue'),
      linkTypeId: text('linkTypeId'),
      enabled: json['enabled'] != false,
    );
  }

  BibleRule copyWith({
    BibleRuleKind? kind,
    String? statement,
    String? typeId,
    String? fieldId,
    String? value,
    String? otherFieldId,
    String? otherValue,
    String? linkTypeId,
    bool? enabled,
  }) =>
      BibleRule(
        id: id,
        kind: kind ?? this.kind,
        statement: statement ?? this.statement,
        typeId: typeId ?? this.typeId,
        fieldId: fieldId ?? this.fieldId,
        value: value ?? this.value,
        otherFieldId: otherFieldId ?? this.otherFieldId,
        otherValue: otherValue ?? this.otherValue,
        linkTypeId: linkTypeId ?? this.linkTypeId,
        enabled: enabled ?? this.enabled,
      );
}

/// Where a bible's rules live on its record.
abstract final class BibleRules {
  static const key = '_bible.rules';

  static List<BibleRule> of(Map<String, Object?> fields) {
    final raw = fields[key];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map)
          if (BibleRule.fromJson(Map<String, Object?>.from(item))
              case final rule?)
            rule,
    ];
  }

  /// [fields] with [rules] written in, or the key removed when there are none.
  static Map<String, Object?> withRules(
    Map<String, Object?> fields,
    List<BibleRule> rules,
  ) =>
      {
        for (final entry in fields.entries)
          if (entry.key != key) entry.key: entry.value,
        if (rules.isNotEmpty) key: [for (final rule in rules) rule.toJson()],
      };
}
