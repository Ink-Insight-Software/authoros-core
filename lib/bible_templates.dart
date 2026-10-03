/// The starter bibles (AOS-Write `PLAN.md` §3.51).
///
/// A template is a starting point and nothing more: choosing one writes a
/// project-scoped bible type the author then owns and may reshape freely —
/// rename a section, add a field, drop an entry list. None of them carries
/// any one author's lore. The calendar bible is one of them, and opens the
/// Calendar Bible's own editor rather than the general page, because a
/// calendar counts days and the general page does not.
library;

import 'bible.dart';
import 'record_types.dart';

/// One field a template's page starts with.
class BibleTemplateField {
  const BibleTemplateField(
    this.label, {
    this.type = RecordFieldType.longText,
    this.options = const [],
    this.description = '',
  });

  final String label;
  final RecordFieldType type;
  final List<String> options;
  final String description;
}

/// One section of a template's page.
class BibleTemplateSection {
  const BibleTemplateSection(this.title, this.fields);

  final String title;
  final List<BibleTemplateField> fields;
}

class BibleTemplate {
  const BibleTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.icon = 'menu_book',
    this.sections = const [],
    this.entrySections = const [],
    this.editor = 'fields',
    this.soldWith,
  });

  /// The capability that sells this template, or null for a free one —
  /// the same marker a field carries (`RecordFieldDefinition.soldWith`),
  /// resolved the same way. AOS-Write `PLAN.md` §3.51 has the line.
  final String? soldWith;

  final String id;
  final String name;
  final String description;
  final String icon;
  final List<BibleTemplateSection> sections;
  final List<BibleEntrySection> entrySections;

  /// `fields` for the general page; `calendar` for the Calendar Bible.
  final String editor;

  bool get isCalendar => editor == 'calendar';

  /// The bible type this template starts, for [projectId].
  RecordTypeDefinition build({
    required String id,
    required String projectId,
    String? name,
  }) {
    final fields = <RecordFieldDefinition>[];
    final pageSections = <RecordTemplateSection>[];
    for (final (index, section) in sections.indexed) {
      final ids = <String>[];
      for (final field in section.fields) {
        final fieldId = bibleFieldId(field.label, fields.map((f) => f.id));
        ids.add(fieldId);
        fields.add(RecordFieldDefinition(
          id: fieldId,
          label: field.label,
          type: field.type,
          order: fields.length,
          options: field.options,
          description: field.description,
        ));
      }
      pageSections.add(RecordTemplateSection(
        id: bibleFieldId(section.title, pageSections.map((s) => s.id)),
        title: section.title,
        order: index,
        fieldIds: ids,
      ));
    }
    final type = BibleTypes.build(
      id: id,
      name: name ?? this.name,
      projectId: projectId,
      description: description,
      icon: icon,
      fields: fields,
      sections: pageSections,
      entrySections: entrySections,
      template: this.id,
    );
    if (editor == 'fields') return type;
    return RecordTypeDefinition.fromJson({
      ...type.toJson(),
      'extensionData': {
        ...type.extensionData,
        BibleTypes.extensionKey: {
          ...(type.extensionData[BibleTypes.extensionKey] as Map),
          'editor': editor,
        },
      },
    });
  }
}

const _overview = BibleTemplateSection('Overview', [
  BibleTemplateField('Summary'),
  BibleTemplateField('Public belief',
      description: 'What most people in the world think is true.'),
  BibleTemplateField('Hidden truth',
      description: 'What is actually true. For you, not for the page.'),
]);

/// Every starter bible, blank first.
const bibleTemplates = <BibleTemplate>[
  BibleTemplate(
    id: 'blank',
    name: 'Blank bible',
    description: 'Start with one page and no lists. Add the sections and '
        'fields your world needs.',
    icon: 'note_add',
    sections: [
      BibleTemplateSection('Overview', [BibleTemplateField('Summary')]),
    ],
  ),
  BibleTemplate(
    id: 'calendar',
    name: 'Calendar bible',
    description: 'Months, weeks, eras, festivals, astrology and the ways a '
        'date is written — in the Calendar Bible.',
    icon: 'calendar_month',
    editor: 'calendar',
  ),
  BibleTemplate(
    id: 'magic',
    soldWith: 'bibles.lore',
    name: 'Magic bible',
    description: 'Where power comes from, what it costs, who may use it, and '
        'the spells, schools and limits that follow.',
    icon: 'auto_awesome',
    sections: [
      _overview,
      BibleTemplateSection('The source', [
        BibleTemplateField('Where it comes from'),
        BibleTemplateField('What it costs'),
        BibleTemplateField('Who can use it'),
      ]),
      BibleTemplateSection('Limits', [
        BibleTemplateField('What it cannot do'),
        BibleTemplateField('Forbidden practices'),
        BibleTemplateField('What happens when it goes wrong'),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'systems', title: 'Systems', typeIds: ['magic-system'], order: 0),
      BibleEntrySection(
          id: 'schools', title: 'Schools', typeIds: ['magic-school'], order: 1),
      BibleEntrySection(
          id: 'spells',
          title: 'Spells and abilities',
          typeIds: ['spell', 'magic-ability'],
          order: 2),
      BibleEntrySection(
          id: 'rules',
          title: 'Rules and limitations',
          typeIds: ['magic-rule', 'magic-limitation'],
          order: 3),
    ],
  ),
  BibleTemplate(
    id: 'faction',
    name: 'Faction bible',
    description: 'The powers in the world: what they want, what they show, '
        'what they hide, who leads them and what they hold.',
    icon: 'groups',
    sections: [
      _overview,
      BibleTemplateSection('Power', [
        BibleTemplateField('What they want'),
        BibleTemplateField('Where their power comes from'),
        BibleTemplateField('Public face'),
        BibleTemplateField('Hidden agenda'),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'factions',
          title: 'Factions',
          typeIds: ['faction', 'house', 'guild', 'organisation', 'clan'],
          order: 0),
      BibleEntrySection(
          id: 'leaders', title: 'Leaders', typeIds: ['character'], order: 1),
      BibleEntrySection(
          id: 'holdings', title: 'Holdings', typeIds: ['location'], order: 2),
    ],
  ),
  BibleTemplate(
    id: 'creature',
    name: 'Creature bible',
    description: 'What lives in the world, what it eats, what people believe '
        'about it, and how dangerous it really is.',
    icon: 'pets',
    sections: [
      _overview,
      BibleTemplateSection('Ecology', [
        BibleTemplateField('Where they live'),
        BibleTemplateField('What they eat'),
        BibleTemplateField('Danger',
            type: RecordFieldType.singleChoice,
            options: ['Harmless', 'Wary', 'Dangerous', 'Deadly']),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'species',
          title: 'Species and peoples',
          typeIds: ['species', 'race'],
          order: 0),
      BibleEntrySection(
          id: 'creatures',
          title: 'Creatures',
          typeIds: ['creature', 'monster', 'animal'],
          order: 1),
    ],
  ),
  BibleTemplate(
    id: 'case',
    soldWith: 'bibles.case',
    name: 'Crime case bible',
    description: 'One case, solved on paper before it is written: the crime, '
        'the suspects, the clues, the secrets, and the solution.',
    icon: 'search',
    sections: [
      BibleTemplateSection('The crime', [
        BibleTemplateField('What happened'),
        BibleTemplateField('The victim'),
        BibleTemplateField('Where and when'),
        BibleTemplateField('How it was discovered'),
      ]),
      BibleTemplateSection('The solution', [
        BibleTemplateField('Who did it, and why',
            description: 'The truth of the case.'),
        BibleTemplateField('How it is proved'),
        BibleTemplateField('The red herrings'),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'suspects', title: 'Suspects', typeIds: ['character'], order: 0),
      BibleEntrySection(
          id: 'witnesses', title: 'Witnesses', typeIds: ['character'], order: 1),
      BibleEntrySection(
          id: 'clues', title: 'Clues and evidence', typeIds: ['clue'], order: 2),
      BibleEntrySection(
          id: 'secrets', title: 'Secrets', typeIds: ['secret'], order: 3),
    ],
  ),
  BibleTemplate(
    id: 'romance',
    soldWith: 'hearts.romanceBible',
    name: 'Romance tension bible',
    description: 'Two people, the wound each carries, what keeps them apart, '
        'and the beats that bring them together.',
    icon: 'favorite',
    sections: [
      BibleTemplateSection('The pairing', [
        BibleTemplateField('Who they are to each other'),
        BibleTemplateField('What draws them'),
        BibleTemplateField('What keeps them apart'),
      ]),
      BibleTemplateSection('Wounds', [
        BibleTemplateField('Their wound'),
        BibleTemplateField('Their other wound'),
        BibleTemplateField('The turn', description: 'When it changes.'),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'people', title: 'The people', typeIds: ['character'], order: 0),
      BibleEntrySection(
          id: 'arcs',
          title: 'Arcs',
          typeIds: ['romance-arc', 'relationship-arc'],
          order: 1),
      BibleEntrySection(
          id: 'beats',
          title: 'Key moments',
          typeIds: ['timeline-relationship-event'],
          order: 2),
    ],
  ),
  BibleTemplate(
    id: 'politics',
    soldWith: 'bibles.politics',
    name: 'Political system bible',
    description: 'Who rules, how, and by what right: governments, laws, '
        'offices, treaties and the factions around them.',
    icon: 'account_balance',
    sections: [
      _overview,
      BibleTemplateSection('Power', [
        BibleTemplateField('Who holds power'),
        BibleTemplateField('How power passes on'),
        BibleTemplateField('What the people are told'),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'governments',
          title: 'Governments',
          typeIds: ['government', 'political-system'],
          order: 0),
      BibleEntrySection(id: 'laws', title: 'Laws', typeIds: ['law'], order: 1),
      BibleEntrySection(
          id: 'offices', title: 'Offices', typeIds: ['political-office'], order: 2),
      BibleEntrySection(
          id: 'treaties', title: 'Treaties', typeIds: ['treaty'], order: 3),
    ],
  ),
  BibleTemplate(
    id: 'myth',
    soldWith: 'bibles.lore',
    name: 'Mythology bible',
    description: 'Gods, legends, sacred stories and the faiths built on them.',
    icon: 'temple_buddhist',
    sections: [
      _overview,
      BibleTemplateSection('Belief', [
        BibleTemplateField('How the world began'),
        BibleTemplateField('What the faithful must do'),
      ]),
    ],
    entrySections: [
      BibleEntrySection(
          id: 'deities', title: 'Deities', typeIds: ['deity'], order: 0),
      BibleEntrySection(
          id: 'stories',
          title: 'Myths and legends',
          typeIds: ['myth', 'legend', 'folklore'],
          order: 1),
      BibleEntrySection(
          id: 'faiths', title: 'Faiths', typeIds: ['religion'], order: 2),
    ],
  ),
];

BibleTemplate? bibleTemplateById(String id) {
  for (final template in bibleTemplates) {
    if (template.id == id) return template;
  }
  return null;
}
