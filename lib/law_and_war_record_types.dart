/// The War Room's four record types (AOS Worldsmith build plan, Phase 7,
/// October 10, 2026): `legal-code`, `court`, `military-force` and
/// `intelligence-service`.
///
/// Each was checked against `faction`, `law` and `timeline-event` first, as
/// the plan's §3 requires:
///
/// * **`legal-code`** groups laws; it does not replace `law`, which stays in
///   the Government system. It names its laws by reference, so a law is one
///   record however many codes cite it.
/// * **`court`**, **`military-force`** and **`intelligence-service`** are
///   bodies of people with leaders, members and a hierarchy: factions. Each
///   inherits `faction` as `military-unit` does and adds only what a faction
///   cannot say. A `military-force` is an army or a navy; a `military-unit`
///   is a company within one, joined to it by `memberOf` or `partOf`.
///
/// A war and its battles are Timeline's `timeline-war` and `timeline-battle`
/// already; nothing here describes a campaign.
library;

import 'record_types.dart';

class LawAndWarRecordTypes {
  const LawAndWarRecordTypes._();

  static const legalCodeTypeId = 'legal-code';
  static const courtTypeId = 'court';
  static const militaryForceTypeId = 'military-force';
  static const intelligenceServiceTypeId = 'intelligence-service';

  static const packId = 'authoros-law-and-war-system';

  static const List<String> recordTypeIds = [
    legalCodeTypeId,
    courtTypeId,
    militaryForceTypeId,
    intelligenceServiceTypeId,
  ];

  static final List<RecordTypeDefinition> definitions = [
    _legalCode,
    _court,
    _force,
    _intelligence,
  ];
}

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
  List<String> referenceTypeIds = const [],
  String? optionSetId,
  bool allowCustomValues = false,
  bool quickCreateVisible = false,
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      referenceTypeIds: referenceTypeIds,
      optionSetId: optionSetId,
      allowCustomValues: allowCustomValues,
      quickCreateVisible: quickCreateVisible,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

const _jurisdictionTypes = [
  'government',
  'country',
  'nation',
  'region',
  'city',
  'settlement',
  'civilisation',
];

const _forceKind = RecordOptionSet(
  id: 'military-force-kind',
  name: 'Kind of force',
  description: 'What it fights on, or how.',
  values: [
    'Army',
    'Navy',
    'Air or sky force',
    'Militia',
    'Mercenary company',
    'Order of knights',
    'Guard',
  ],
);

RecordTypeDefinition _definition({
  required String id,
  required String name,
  required String description,
  required String icon,
  required String categoryId,
  required String baseTypeId,
  required List<RecordFieldDefinition> fields,
  required String sectionTitle,
  List<RecordOptionSet> optionSets = const [],
  List<String> suggestedLinks = const ['associatedWith'],
}) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      description: description,
      icon: icon,
      categoryId: categoryId,
      baseTypeId: baseTypeId,
      optionSets: optionSets,
      fields: fields,
      sections: [
        RecordTemplateSection(
          id: id,
          title: sectionTitle,
          order: 20,
          fieldIds: [for (final field in fields) field.id],
        ),
      ],
      suggestedLinkTypeIds: suggestedLinks,
      builtIn: true,
      sourcePackId: LawAndWarRecordTypes.packId,
      permissions: const {'editableDefinition': false},
      exportBehavior: const {'includeStructuredFields': true},
      extensionData: _codexTemplate,
    );

final _legalCode = _definition(
  id: LawAndWarRecordTypes.legalCodeTypeId,
  name: 'Legal Code',
  description: 'A body of law under one name: what it gathers, where it '
      'runs, and who enforces it.',
  icon: 'gavel',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  sectionTitle: 'The code',
  fields: [
    _field('laws', 'Laws it gathers', RecordFieldType.recordReference, 200,
        referenceTypeIds: const ['law'],
        description: 'Each law is its own record; the code names it.'),
    _field(
        'jurisdiction', 'Where it runs', RecordFieldType.recordReference, 201,
        referenceTypeIds: _jurisdictionTypes, quickCreateVisible: true),
    _field('enforcedBy', 'Enforced by', RecordFieldType.recordReference, 202,
        referenceTypeIds: const ['court', 'government', 'faction']),
    _field('principles', 'Principles', RecordFieldType.richText, 203,
        description: 'What it holds to be just.'),
    _field('punishments', 'Punishments', RecordFieldType.list, 204),
    _field('enacted', 'Enacted', RecordFieldType.shortText, 205),
  ],
);

final _court = _definition(
  id: LawAndWarRecordTypes.courtTypeId,
  name: 'Court',
  description: 'A body that judges: who sits on it, what it may hear, and '
      'whose law it applies.',
  icon: 'account_balance',
  categoryId: 'factions',
  baseTypeId: 'faction',
  sectionTitle: 'The court',
  fields: [
    _field('applies', 'Law it applies', RecordFieldType.recordReference, 220,
        referenceTypeIds: const ['legal-code', 'law']),
    _field('jurisdiction', 'Jurisdiction', RecordFieldType.recordReference, 221,
        referenceTypeIds: _jurisdictionTypes, quickCreateVisible: true),
    _field('hears', 'What it may hear', RecordFieldType.list, 222),
    _field('appealsTo', 'Appeals go to', RecordFieldType.recordReference, 223,
        referenceTypeIds: const ['court', 'government', 'character']),
  ],
);

final _force = _definition(
  id: LawAndWarRecordTypes.militaryForceTypeId,
  name: 'Military Force',
  description: 'An army, a navy, a sworn company: who commands it, whom it '
      'serves, and what it can field.',
  icon: 'shield',
  categoryId: 'factions',
  baseTypeId: 'faction',
  optionSets: const [_forceKind],
  sectionTitle: 'The force',
  suggestedLinks: const ['memberOf', 'atWarWith', 'associatedWith'],
  fields: [
    _field('kind', 'Kind', RecordFieldType.singleChoice, 220,
        optionSetId: 'military-force-kind',
        allowCustomValues: true,
        quickCreateVisible: true),
    _field('serves', 'Serves', RecordFieldType.recordReference, 221,
        referenceTypeIds: const [
          'government',
          'faction',
          'civilisation',
          'character',
        ]),
    _field('commander', 'Commander', RecordFieldType.recordReference, 222,
        referenceTypeIds: const ['character']),
    _field('strength', 'Strength', RecordFieldType.shortText, 223,
        description: 'As exact or as rumoured as the world knows it.'),
    _field('doctrine', 'Doctrine', RecordFieldType.richText, 224,
        description: 'How it fights.'),
    _field('garrison', 'Garrison', RecordFieldType.recordReference, 225,
        referenceTypeIds: const ['location', 'settlement', 'city', 'building']),
  ],
);

final _intelligence = _definition(
  id: LawAndWarRecordTypes.intelligenceServiceTypeId,
  name: 'Intelligence Service',
  description: 'Those who learn what others hide: whom they serve, whom they '
      'watch, and what they are known to know.',
  icon: 'visibility',
  categoryId: 'factions',
  baseTypeId: 'faction',
  sectionTitle: 'The service',
  fields: [
    _field('serves', 'Serves', RecordFieldType.recordReference, 220,
        referenceTypeIds: const [
          'government',
          'faction',
          'civilisation',
          'character',
        ],
        quickCreateVisible: true),
    _field('spymaster', 'Spymaster', RecordFieldType.recordReference, 221,
        referenceTypeIds: const ['character']),
    _field('targets', 'Whom it watches', RecordFieldType.list, 222),
    _field('methods', 'Methods', RecordFieldType.richText, 223),
    _field('cover', 'Its public face', RecordFieldType.shortText, 224,
        description: 'What the world thinks it is.'),
  ],
);
