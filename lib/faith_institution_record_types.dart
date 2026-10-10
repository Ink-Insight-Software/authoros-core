/// The Sanctum's two institutions of faith: the religious order and the
/// denomination (AOS Worldsmith build plan, Phase 6, October 10, 2026).
///
/// Both were checked against the tree first, as the plan's §3 requires.
///
/// * **`religious-order`** is a body of people under a rule: monks, templars,
///   a mendicant sisterhood. That is a faction (members, leadership,
///   hierarchy, territory), so it inherits `faction` as `guild` and
///   `military-unit` do, and adds only what a faction cannot say: the faith
///   it serves, its rule, its vows and its founding.
/// * **`denomination`** is a branch of a faith with its own doctrine: a faith
///   in its own right, so it inherits `religion` and keeps every field of
///   one, and adds what makes it a branch: the faith it parted from, what it
///   parted over, and how the parent regards it.
///
/// Neither copies the religion it belongs to. The order names its faith in a
/// reference field and the denomination names its parent the same way, so
/// one religion stays one record (Lock 1).
library;

import 'record_types.dart';

class FaithInstitutionRecordTypes {
  const FaithInstitutionRecordTypes._();

  static const orderTypeId = 'religious-order';
  static const denominationTypeId = 'denomination';

  static const packId = 'authoros-faith-institutions-system';

  static const List<String> recordTypeIds = [orderTypeId, denominationTypeId];

  static final List<RecordTypeDefinition> definitions = [
    _order,
    _denomination,
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

const _standing = RecordOptionSet(
  id: 'denomination-standing',
  name: 'Standing with its parent faith',
  description: 'How the faith it branched from regards it.',
  values: [
    'Recognised',
    'Tolerated',
    'Disputed',
    'Heretical',
    'Reconciled',
  ],
);

final _order = RecordTypeDefinition(
  id: FaithInstitutionRecordTypes.orderTypeId,
  name: 'Religious Order',
  description: 'A body of the faithful under a rule: monks, templars, a '
      'sisterhood sworn to a vow.',
  icon: 'church',
  categoryId: 'factions',
  baseTypeId: 'faction',
  fields: [
    _field('faith', 'Faith it serves', RecordFieldType.recordReference, 220,
        referenceTypeIds: const ['religion', 'denomination', 'deity'],
        quickCreateVisible: true),
    _field('rule', 'Its rule', RecordFieldType.richText, 221,
        description: 'How its members are to live.'),
    _field('vows', 'Vows', RecordFieldType.list, 222),
    _field('founded', 'Founded', RecordFieldType.shortText, 223,
        description: 'When, in the world\'s reckoning, and by whom.'),
    _field('motherHouse', 'Mother house', RecordFieldType.recordReference, 224,
        referenceTypeIds: const ['location', 'settlement', 'city', 'building'],
        description: 'Where it is ruled from.'),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'religious-order',
      title: 'The order',
      order: 20,
      fieldIds: ['faith', 'rule', 'vows', 'founded', 'motherHouse'],
    ),
  ],
  suggestedLinkTypeIds: const ['memberOf', 'worships', 'associatedWith'],
  builtIn: true,
  sourcePackId: FaithInstitutionRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

final _denomination = RecordTypeDefinition(
  id: FaithInstitutionRecordTypes.denominationTypeId,
  name: 'Denomination',
  description: 'A branch of a faith, with a doctrine of its own: what it '
      'holds that its parent does not.',
  icon: 'account_tree',
  categoryId: 'religion',
  baseTypeId: 'religion',
  optionSets: const [_standing],
  fields: [
    _field('parentFaith', 'Branch of', RecordFieldType.recordReference, 200,
        referenceTypeIds: const ['religion', 'denomination'],
        quickCreateVisible: true),
    _field('divergence', 'Where it parts from its parent',
        RecordFieldType.richText, 201,
        description: 'The doctrine, practice or authority it disputes.'),
    _field('split', 'When it split', RecordFieldType.shortText, 202),
    _field('standing', 'Standing with its parent', RecordFieldType.singleChoice,
        203,
        optionSetId: 'denomination-standing', allowCustomValues: true),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'denomination',
      title: 'The branch',
      order: 9,
      fieldIds: ['parentFaith', 'divergence', 'split', 'standing'],
    ),
  ],
  suggestedLinkTypeIds: const ['worships', 'associatedWith'],
  builtIn: true,
  sourcePackId: FaithInstitutionRecordTypes.packId,
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
