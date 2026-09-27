/// The Magic specialist system's record types.
///
/// Lifted out of `built_in_record_types.dart` into a file of its own, the way
/// Character, Plot, Timeline, World and Research types already live in theirs.
/// Nothing new about the mechanism: these are ordinary
/// [RecordTypeDefinition]s in the canonical registry, and the Magic manifest
/// names them without defining anything.
///
/// ## The defect this file corrects
///
/// `magic-ability` and `spell` were declared with `baseTypeId: 'magic-system'`.
/// Inheritance in this registry merges the parent's fields into the child, so
/// every Spell record presented the *system's* eleven fields: an author
/// entering one spell was asked for its Source, its Abilities, its Users, its
/// Cultural Impact and its Political Impact. A spell has none of those; the
/// system it belongs to does.
///
/// The corrected shape says what each thing actually is:
///
///     general-lore
///     ├── magic-system      the system: where magic comes from and what it costs
///     ├── magic-school      a tradition or discipline within a system
///     ├── magic-ability     one thing magic can do
///     │   └── spell         a named, formalised ability
///     ├── magic-rule        one rule of a system
///     └── magic-limitation  one boundary on a system
///
/// `spell` keeps an inheritance edge, and this one is real: a spell *is* an
/// ability, with a name and a form. That is the difference between inheritance
/// that models the domain and inheritance that was reached for because a field
/// list happened to be nearby.
///
/// ## How existing records survive it
///
/// Re-parenting removes fields from a *definition*. It does not remove them
/// from a *record*, and three separate mechanisms already guarantee that:
///
/// * Nothing prunes. `StoryCodexService.updateCodexEntry` merges
///   (`Map.from(existing.fields)..addAll(...)`), so a value outside the
///   template survives every subsequent save.
/// * Nothing rejects. [RecordValidator] iterates the *definition's* fields; a
///   value it no longer knows about is not an error.
/// * Nothing hides. The Codex entry pane builds an editor for every field key
///   the record carries that the template does not, so the author still sees
///   the text and can still change it.
///
/// On top of that, this file does the migration the cheap way wherever it can:
/// **a field that still means something on the child keeps its id.**
/// `limitations`, `costs`, `risks`, `history` and `users` are all real
/// properties of an ability as well as of a system, so an existing
/// `magic-ability` record keeps them *with their labels and typed editors
/// intact*. Only the five that are genuinely system-level — `source`, `rules`,
/// `abilities`, `exceptions`, `culturalImpact`, `politicalImpact` — leave the
/// definition, and their values remain visible as author-editable keys.
///
/// `magic_compatibility_test.dart` proves each of those claims against real
/// records written under the old definitions.
library;

import 'craft/craft_library.dart';
import 'record_types.dart';

class MagicRecordTypes {
  const MagicRecordTypes._();

  static const systemTypeId = 'magic-system';
  static const schoolTypeId = 'magic-school';
  static const abilityTypeId = 'magic-ability';
  static const spellTypeId = 'spell';
  static const ruleTypeId = 'magic-rule';
  static const limitationTypeId = 'magic-limitation';

  /// Every type the Magic system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [
    systemTypeId,
    schoolTypeId,
    abilityTypeId,
    spellTypeId,
    ruleTypeId,
    limitationTypeId,
  ];

  /// Field ids that were inherited from `magic-system` by `magic-ability` and
  /// `spell` before the correction, and are *kept* on the ability family
  /// because they describe an ability as truthfully as a system.
  ///
  /// Named rather than merely used, because the migration guarantee depends on
  /// them: an existing record's value for one of these keeps its label and its
  /// typed editor rather than becoming a loose key.
  static const List<String> retainedAbilityFieldIds = [
    'costs',
    'limitations',
    'risks',
    'history',
    'users',
  ];

  /// Field ids that leave the ability family, because they belong to the
  /// system and never to one ability.
  ///
  /// A record that carries one keeps the value — see the library comment — it
  /// simply stops being offered a dedicated editor for it.
  static const List<String> releasedAbilityFieldIds = [
    'source',
    'rules',
    'abilities',
    'exceptions',
    'culturalImpact',
    'politicalImpact',
  ];

  static final List<RecordTypeDefinition> definitions = [
    _system,
    _school,
    _ability,
    _spell,
    _rule,
    _limitation,
  ];
}

/// Shared extension data, matching what the generated Codex templates carried
/// before this file existed so nothing downstream sees a change.
const _codexTemplate = <String, Object?>{
  'codexTemplate': true,
  'supportsSimpleMode': true,
};

/// One field, taking its description from the craft library when the library
/// has one for it.
///
/// [typeId] qualifies the key because magic field ids are not unique across
/// these six types: `costs`, `limitations`, `risks`, `system`, `history`,
/// `practitioners` and `exceptions` each appear on more than one, and a flat
/// `magic.costs` would explain a spell's price with the system's sentence.
/// The shape is `plot_record_types.dart`'s, for the same reason.
///
/// Resolved for every field rather than wired onto the ten that have an entry
/// today, so the next term the library learns needs no edit here. A field the
/// library says nothing about keeps whatever gloss it declares, which is the
/// other half of one-source-per-field.
RecordFieldDefinition _field(
  String typeId,
  String id,
  String label,
  RecordFieldType type,
  int order, {
  String description = '',
  List<String> referenceTypeIds = const [],
}) {
  final fromLibrary = CraftLibrary.describe('magic.$typeId.$id');
  return RecordFieldDefinition(
    id: id,
    label: label,
    type: type,
    order: order,
    description: fromLibrary.isEmpty ? description : fromLibrary,
    referenceTypeIds: referenceTypeIds,
    extensionData: const {'visibility': 'default', 'templateOwned': true},
  );
}

// ---------------------------------------------------------------------------
// The system
// ---------------------------------------------------------------------------

/// A magic system: where the magic comes from, what it costs, and what it does
/// to the world that has it.
///
/// Every field the previous definition carried is still here, with the same id
/// and the same type, so no existing `magic-system` record changes at all.
/// What is new is shape — four sections instead of one flat list — and three
/// fields that the old definition left an author to improvise in prose.
final _system = RecordTypeDefinition(
  id: MagicRecordTypes.systemTypeId,
  name: 'Magic System',
  description: 'A system of magic: its source, its rules and its price.',
  icon: 'auto_fix_high',
  categoryId: 'magic',
  baseTypeId: 'general-lore',
  fields: [
    _field(MagicRecordTypes.systemTypeId, 'source', 'Source',
        RecordFieldType.longText, 100,
        description: 'Where the magic comes from.'),
    _field(MagicRecordTypes.systemTypeId, 'rules', 'Rules',
        RecordFieldType.richText, 101),
    _field(MagicRecordTypes.systemTypeId, 'practitioners', 'Who can use it',
        RecordFieldType.longText, 102),
    _field(MagicRecordTypes.systemTypeId, 'costs', 'Costs',
        RecordFieldType.richText, 110),
    _field(MagicRecordTypes.systemTypeId, 'limitations', 'Limitations',
        RecordFieldType.richText, 111),
    _field(MagicRecordTypes.systemTypeId, 'risks', 'Risks',
        RecordFieldType.richText, 112),
    _field(MagicRecordTypes.systemTypeId, 'exceptions', 'Exceptions',
        RecordFieldType.richText, 113),
    _field(MagicRecordTypes.systemTypeId, 'abilities', 'Abilities',
        RecordFieldType.list, 120),
    _field(MagicRecordTypes.systemTypeId, 'users', 'Users',
        RecordFieldType.list, 121),
    _field(MagicRecordTypes.systemTypeId, 'history', 'History',
        RecordFieldType.richText, 130),
    _field(MagicRecordTypes.systemTypeId, 'culturalImpact', 'Cultural Impact',
        RecordFieldType.richText, 131),
    _field(MagicRecordTypes.systemTypeId, 'politicalImpact', 'Political Impact',
        RecordFieldType.richText, 132),
    _field(MagicRecordTypes.systemTypeId, 'publicKnowledge',
        'What the public knows', RecordFieldType.richText, 133,
        description: 'What ordinary people believe, which need not be true.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'magic',
      title: 'Magic',
      order: 10,
      fieldIds: ['source', 'rules', 'practitioners'],
    ),
    RecordTemplateSection(
      id: 'magic-price',
      title: 'Price and limits',
      order: 11,
      fieldIds: ['costs', 'limitations', 'risks', 'exceptions'],
    ),
    RecordTemplateSection(
      id: 'magic-reach',
      title: 'Reach',
      order: 12,
      fieldIds: ['abilities', 'users'],
    ),
    RecordTemplateSection(
      id: 'magic-world',
      title: 'In the world',
      order: 13,
      fieldIds: [
        'history',
        'culturalImpact',
        'politicalImpact',
        'publicKnowledge',
      ],
    ),
  ],
  suggestedLinkTypeIds: const ['usedBy', 'requires', 'influences'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-magic-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The school
// ---------------------------------------------------------------------------

/// A tradition, discipline or school within a magic system.
///
/// New in this phase. It is the missing middle: without it an author has a
/// system and a pile of abilities, and nowhere to say that half of them are
/// taught one way and half another.
final _school = RecordTypeDefinition(
  id: MagicRecordTypes.schoolTypeId,
  name: 'Magic School',
  description: 'A tradition or discipline within a magic system.',
  icon: 'school_outlined',
  categoryId: 'magic',
  baseTypeId: 'general-lore',
  fields: [
    _field(MagicRecordTypes.schoolTypeId, 'system', 'Magic system',
        RecordFieldType.recordReference, 100,
        referenceTypeIds: [MagicRecordTypes.systemTypeId]),
    _field(MagicRecordTypes.schoolTypeId, 'philosophy', 'Philosophy',
        RecordFieldType.richText, 101,
        description: 'What this school believes magic is for.'),
    _field(MagicRecordTypes.schoolTypeId, 'focus', 'Focus',
        RecordFieldType.longText, 102),
    _field(MagicRecordTypes.schoolTypeId, 'techniques', 'Techniques',
        RecordFieldType.list, 110),
    _field(MagicRecordTypes.schoolTypeId, 'training', 'Training',
        RecordFieldType.richText, 111),
    _field(MagicRecordTypes.schoolTypeId, 'prerequisites', 'Prerequisites',
        RecordFieldType.longText, 112),
    _field(MagicRecordTypes.schoolTypeId, 'practitioners', 'Practitioners',
        RecordFieldType.list, 120),
    _field(MagicRecordTypes.schoolTypeId, 'rivals', 'Rival schools',
        RecordFieldType.list, 121),
    _field(MagicRecordTypes.schoolTypeId, 'reputation', 'Reputation',
        RecordFieldType.richText, 122),
    _field(MagicRecordTypes.schoolTypeId, 'history', 'History',
        RecordFieldType.richText, 130),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'school',
      title: 'School',
      order: 10,
      fieldIds: ['system', 'philosophy', 'focus'],
    ),
    RecordTemplateSection(
      id: 'school-practice',
      title: 'Practice',
      order: 11,
      fieldIds: ['techniques', 'training', 'prerequisites'],
    ),
    RecordTemplateSection(
      id: 'school-standing',
      title: 'Standing',
      order: 12,
      fieldIds: ['practitioners', 'rivals', 'reputation', 'history'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'usedBy', 'influences'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: 'authoros-magic-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// The ability family
// ---------------------------------------------------------------------------

/// One thing magic can do.
///
/// Re-parented from `magic-system` to `general-lore`. The five ids in
/// [MagicRecordTypes.retainedAbilityFieldIds] are deliberately unchanged in id
/// and type, so an existing record's values for them keep their labels and
/// their editors across the change.
final _ability = RecordTypeDefinition(
  id: MagicRecordTypes.abilityTypeId,
  name: 'Magic Ability',
  description: 'One thing magic can do.',
  icon: 'flare_outlined',
  categoryId: 'magic',
  baseTypeId: 'general-lore',
  fields: [
    _field(MagicRecordTypes.abilityTypeId, 'system', 'Magic system',
        RecordFieldType.recordReference, 100,
        referenceTypeIds: [MagicRecordTypes.systemTypeId]),
    _field(MagicRecordTypes.abilityTypeId, 'school', 'School',
        RecordFieldType.recordReference, 101,
        referenceTypeIds: [MagicRecordTypes.schoolTypeId]),
    _field(MagicRecordTypes.abilityTypeId, 'effect', 'Effect',
        RecordFieldType.richText, 102,
        description: 'What it actually does.'),
    // Retained ids — an existing record keeps these with their editors.
    _field(MagicRecordTypes.abilityTypeId, 'costs', 'Cost',
        RecordFieldType.richText, 110),
    _field(MagicRecordTypes.abilityTypeId, 'limitations', 'Limitations',
        RecordFieldType.richText, 111),
    _field(MagicRecordTypes.abilityTypeId, 'risks', 'Risks',
        RecordFieldType.richText, 112),
    _field(MagicRecordTypes.abilityTypeId, 'range', 'Range',
        RecordFieldType.shortText, 113),
    _field(MagicRecordTypes.abilityTypeId, 'duration', 'Duration',
        RecordFieldType.shortText, 114),
    _field(MagicRecordTypes.abilityTypeId, 'prerequisites', 'Prerequisites',
        RecordFieldType.longText, 115),
    _field(MagicRecordTypes.abilityTypeId, 'users', 'Users',
        RecordFieldType.list, 120),
    _field(MagicRecordTypes.abilityTypeId, 'history', 'History',
        RecordFieldType.richText, 130),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'ability',
      title: 'Ability',
      order: 10,
      fieldIds: ['system', 'school', 'effect'],
    ),
    RecordTemplateSection(
      id: 'ability-price',
      title: 'Price and limits',
      order: 11,
      fieldIds: [
        'costs',
        'limitations',
        'risks',
        'range',
        'duration',
        'prerequisites',
      ],
    ),
    RecordTemplateSection(
      id: 'ability-use',
      title: 'Use',
      order: 12,
      fieldIds: ['users', 'history'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'usedBy', 'requires'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-magic-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// A named, formalised ability.
///
/// The one inheritance edge in this family that models the domain rather than
/// a convenient field list: a spell *is* an ability, so it inherits every
/// ability field and adds the four things that make it a spell.
final _spell = RecordTypeDefinition(
  id: MagicRecordTypes.spellTypeId,
  name: 'Spell',
  description: 'A named, formalised magical ability.',
  icon: 'auto_awesome_outlined',
  categoryId: 'magic',
  baseTypeId: MagicRecordTypes.abilityTypeId,
  fields: [
    _field(MagicRecordTypes.spellTypeId, 'incantation', 'Incantation',
        RecordFieldType.longText, 140),
    _field(MagicRecordTypes.spellTypeId, 'components', 'Components',
        RecordFieldType.list, 141),
    _field(MagicRecordTypes.spellTypeId, 'castingTime', 'Casting time',
        RecordFieldType.shortText, 142),
    _field(MagicRecordTypes.spellTypeId, 'counter', 'Counter',
        RecordFieldType.richText, 143,
        description: 'How it is resisted, broken or undone.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'spell',
      title: 'Casting',
      order: 13,
      fieldIds: ['incantation', 'components', 'castingTime', 'counter'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'usedBy', 'requires'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-magic-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

// ---------------------------------------------------------------------------
// Rules and limits
// ---------------------------------------------------------------------------

/// One rule of a magic system.
///
/// Previously a bare child of `general-lore` with no fields of its own, so an
/// author writing down a rule had a title and a description and nothing to say
/// what the rule *applies to* or what happens when it is broken.
final _rule = RecordTypeDefinition(
  id: MagicRecordTypes.ruleTypeId,
  name: 'Magic Rule',
  description: 'One rule of a magic system.',
  icon: 'gavel_outlined',
  categoryId: 'magic',
  baseTypeId: 'general-lore',
  fields: [
    _field(MagicRecordTypes.ruleTypeId, 'system', 'Magic system',
        RecordFieldType.recordReference, 100,
        referenceTypeIds: [MagicRecordTypes.systemTypeId]),
    _field(MagicRecordTypes.ruleTypeId, 'statement', 'Rule',
        RecordFieldType.richText, 101),
    _field(MagicRecordTypes.ruleTypeId, 'appliesTo', 'Applies to',
        RecordFieldType.longText, 102),
    _field(MagicRecordTypes.ruleTypeId, 'exceptions', 'Exceptions',
        RecordFieldType.richText, 110),
    _field(MagicRecordTypes.ruleTypeId, 'consequence', 'If broken',
        RecordFieldType.richText, 111),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'rule',
      title: 'Rule',
      order: 10,
      fieldIds: ['system', 'statement', 'appliesTo'],
    ),
    RecordTemplateSection(
      id: 'rule-edges',
      title: 'Edges',
      order: 11,
      fieldIds: ['exceptions', 'consequence'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'requires'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: 'authoros-magic-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// One boundary on what a magic system can do.
final _limitation = RecordTypeDefinition(
  id: MagicRecordTypes.limitationTypeId,
  name: 'Magic Limitation',
  description: 'One boundary on what a magic system can do.',
  icon: 'block_outlined',
  categoryId: 'magic',
  baseTypeId: 'general-lore',
  fields: [
    _field(MagicRecordTypes.limitationTypeId, 'system', 'Magic system',
        RecordFieldType.recordReference, 100,
        referenceTypeIds: [MagicRecordTypes.systemTypeId]),
    _field(MagicRecordTypes.limitationTypeId, 'boundary', 'Limitation',
        RecordFieldType.richText, 101),
    _field(MagicRecordTypes.limitationTypeId, 'reason', 'Why it holds',
        RecordFieldType.richText, 102),
    _field(MagicRecordTypes.limitationTypeId, 'cost', 'Cost of pushing it',
        RecordFieldType.richText, 110),
    _field(MagicRecordTypes.limitationTypeId, 'workarounds',
        'Known workarounds', RecordFieldType.list, 111),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'limitation',
      title: 'Limitation',
      order: 10,
      fieldIds: ['system', 'boundary', 'reason'],
    ),
    RecordTemplateSection(
      id: 'limitation-edges',
      title: 'Pressure',
      order: 11,
      fieldIds: ['cost', 'workarounds'],
    ),
  ],
  suggestedLinkTypeIds: const ['partOf', 'requires'],
  templateVersion: 1,
  builtIn: true,
  sourcePackId: 'authoros-magic-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
