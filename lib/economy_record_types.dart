/// The Economy specialist system's record types.
///
/// Two types — `currency` and `resource` — both bare `general-lore` children
/// with **no fields of their own**. An author could name a coin and then had a
/// title, a summary and a blank page: nowhere to say who mints it, what backs
/// it, where it is refused, or what happens when trust in it fails.
///
/// ## The reservation, redeemed
///
/// Culture declined `currency` in Wave 1, naming Economy as its owner and
/// recording it in `CultureRecordTypes.reservedForOtherSystems`. This claims
/// it. That is the second reservation to run its course — Culture reserved
/// `language` and Language took it; Weapons reserved `vehicle` and Travel took
/// it — and the mechanism has now worked three times without a collision,
/// because one owner per record type is enforced at registry construction.
///
/// ## Two types, and no invented third
///
/// `trade-route`, `market`, `industry` and `trade-good` do not exist in the
/// registry, and none is added here. Applying Language's test for whether a
/// concept earns an entity of its own:
///
/// * A **trade route** is a use of a route, not a new kind of thing. Travel
///   owns ten route kinds and `travel-route` is foundation; a route that
///   carries grain is a route with an edge to grain.
/// * A **market** is a place. `settlement`, `district` and `building` already
///   exist and belong to World and Architecture.
/// * A **trade good** is a `resource` or an `item`, depending on whether it is
///   dug up or made.
///
/// So the system is two types. That is the same conclusion Artifacts reached
/// at one, and reached the same way rather than by shipping less.
///
/// ## Inheritance is kept
///
/// Both stay `general-lore` children. Neither was ever mis-parented — this is
/// the Culture case, purely additive, with nothing to undo and no value that
/// can be orphaned.
library;

import 'record_types.dart';

class EconomyRecordTypes {
  const EconomyRecordTypes._();

  static const currencyTypeId = 'currency';
  static const resourceTypeId = 'resource';

  /// Every type the Economy system presents. The manifest names exactly these.
  static const List<String> recordTypeIds = [currencyTypeId, resourceTypeId];

  /// Concepts deliberately not given a type of their own, with the reason
  /// recorded so a later wave inherits the argument rather than reopening it.
  static const Map<String, String> declinedTypes = {
    'trade-route': 'a use of a route; Travel owns the route family',
    'market': 'a place; settlement, district and building already exist',
    'trade-good': 'a resource if dug up, an item if made',
    'industry': 'what a faction does; expressible as a faction and its edges',
  };

  /// The seven `general-lore` ids both types inherit and keep unchanged.
  static const List<String> inheritedLoreFieldIds = [
    'name',
    'aliases',
    'summary',
    'description',
    'notes',
    'knowledgeStatus',
    'sourceReferences',
  ];

  /// Field ids that mean the same thing on both types and carry the same id
  /// and type on each.
  static const List<String> sharedFieldIds = [
    'worth',
    'scarcity',
    'history',
  ];

  static final List<RecordTypeDefinition> definitions = [_currency, _resource];
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
}) =>
    RecordFieldDefinition(
      id: id,
      label: label,
      type: type,
      order: order,
      description: description,
      extensionData: const {'visibility': 'default', 'templateOwned': true},
    );

/// The fields both types carry, with one id and one type each.
///
/// `worth` rather than `value`: `value` is a word the field system uses for
/// the contents of a field, and a template field called Value reads as a
/// placeholder rather than a question.
List<RecordFieldDefinition> _shared({int from = 120}) => [
      _field('worth', 'Worth', RecordFieldType.richText, from,
          description: 'What it is worth, to whom, and whether they agree.'),
      _field('scarcity', 'Scarcity', RecordFieldType.shortText, from + 1,
          description: 'How much there is, and who knows.'),
      _field('history', 'History', RecordFieldType.richText, from + 2,
          description: 'What it has been through. Currencies and mines both '
              'have bad years.'),
    ];

const _sharedSection = RecordTemplateSection(
  id: 'economy-worth',
  title: 'Worth',
  order: 12,
  fieldIds: ['worth', 'scarcity', 'history'],
);

// ---------------------------------------------------------------------------

/// Money: who issues it, what backs it, and where it is refused.
final _currency = RecordTypeDefinition(
  id: EconomyRecordTypes.currencyTypeId,
  name: 'Currency',
  description: 'Money: who issues it, what backs it, and where it is refused.',
  icon: 'payments',
  categoryId: 'culture',
  baseTypeId: 'general-lore',
  fields: [
    _field('issuer', 'Issuer', RecordFieldType.shortText, 100,
        description: 'Who mints it. Link the faction for detail.'),
    _field('denominations', 'Denominations', RecordFieldType.list, 101,
        description: 'The coins and notes, smallest first.'),
    _field('material', 'Material', RecordFieldType.list, 102,
        description: 'What it is made of, which is usually the whole '
            'argument.'),
    _field('backing', 'Backing', RecordFieldType.richText, 110,
        description: 'What it can be exchanged for, if anything, and who '
            'promises that.'),
    _field('acceptedWhere', 'Accepted where', RecordFieldType.longText, 111,
        description: 'Where it spends, and — more usefully — where it does '
            'not.'),
    ..._shared(),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'currency',
      title: 'Coin',
      order: 10,
      fieldIds: ['issuer', 'denominations', 'material'],
    ),
    RecordTemplateSection(
      id: 'currency-trust',
      title: 'Trust',
      order: 11,
      fieldIds: ['backing', 'acceptedWhere'],
    ),
    _sharedSection,
  ],
  suggestedLinkTypeIds: const ['createdBy', 'usedBy', 'associatedWith'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-economy-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);

/// Something a place has that others want.
final _resource = RecordTypeDefinition(
  id: EconomyRecordTypes.resourceTypeId,
  name: 'Resource',
  description: 'Something a place has that others want.',
  icon: 'diamond',
  categoryId: 'world',
  baseTypeId: 'general-lore',
  fields: [
    _field('source', 'Found where', RecordFieldType.longText, 100,
        description: 'Where it comes from. Link the places for detail.'),
    _field('extraction', 'Extraction', RecordFieldType.richText, 101,
        description: 'How it is got out, and what that costs the people who '
            'do it.'),
    _field('uses', 'Uses', RecordFieldType.list, 110,
        description: 'What it is for. Often more than one thing, and they '
            'compete.'),
    _field('byproducts', 'Byproducts', RecordFieldType.list, 111,
        description: 'What else comes out, wanted or not.'),
    ..._shared(),
  ],
  sections: const [
    RecordTemplateSection(
      id: 'resource',
      title: 'Source',
      order: 10,
      fieldIds: ['source', 'extraction'],
    ),
    RecordTemplateSection(
      id: 'resource-use',
      title: 'Use',
      order: 11,
      fieldIds: ['uses', 'byproducts'],
    ),
    _sharedSection,
  ],
  suggestedLinkTypeIds: const ['originatedFrom', 'usedBy', 'associatedWith'],
  templateVersion: 2,
  builtIn: true,
  sourcePackId: 'authoros-economy-system',
  permissions: const {'editableDefinition': false},
  exportBehavior: const {'includeStructuredFields': true},
  extensionData: _codexTemplate,
);
