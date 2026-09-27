import 'craft/craft_entry.dart';
import 'craft/craft_library.dart';
import 'craft_fields.dart';
import 'record_scope.dart';
import 'record_types.dart';

class CharacterRecordTypes {
  const CharacterRecordTypes._();

  static final RecordTypeDefinition character = RecordTypeDefinition(
    id: 'character',
    name: 'Character',
    description:
        'A canonical character shared by Character Studio and every connected AuthorOS view.',
    icon: 'person',
    categoryId: 'characters',
    baseTypeId: 'general-lore',
    fields: _fields,
    sections: _sections,
    suggestedLinkTypeIds: const [
      'appearsIn',
      'mentionedIn',
      'relatedTo',
      'parentOf',
      'memberOf',
      'livesIn',
      'bornIn',
      'owns',
      'uses',
      'pursues',
      'hasArc',
      'knows',
    ],
    templateVersion: 2,
    builtIn: true,
    sourcePackId: 'authoros-core',
    permissions: const {'editableDefinition': false},
    exportBehavior: const {'includeStructuredFields': true},
    extensionData: const {
      'studio': 'character',
      'supportsSparseProfiles': true,
      'authorKnowledgeSeparated': true,
    },
  );

  /// The built-in character templates.
  ///
  /// **Two of these narrow the sheet and ten do not.** `character-basic` shows
  /// four sections of twenty-four and `character-supporting` shows eight; the
  /// other ten declare no `visibleSections` and resolve to the whole sheet, so
  /// they are identical in behaviour and differ only in the name stored on the
  /// record.
  ///
  /// That is said plainly in each description rather than papered over with
  /// ten sentences implying a difference that is not there. Whether ten labels
  /// over one form is the right offer is a product question — they are stored
  /// on records, so consolidating them is not a refactor — and naming it here
  /// is the useful half of describing them at all.
  static final List<RecordTypeDefinition> templates = [
    _template(
      'character-basic',
      'Basic Character',
      visibleSections: const ['identity', 'appearance', 'personality', 'notes'],
      describe: 'Identity, appearance, personality and notes — four sections '
          'of twenty-four. The short sheet, for a character you want on the '
          'page before you know much about them.',
    ),
    _template('character-main', 'Main Character',
        describe: 'The whole sheet, including the psychology block. A label '
            'on the record; every section is open on any of the full '
            'templates.'),
    _template(
      'character-supporting',
      'Supporting Character',
      visibleSections: const [
        'identity',
        'appearance',
        'personality',
        'backstory',
        'relationships',
        'storyRole',
        'goals',
        'notes',
      ],
      describe: 'Eight sections: the short sheet plus backstory, '
          'relationships, story role and goals. Leaves out the depth work a '
          'lead carries and keeps what a scene needs.',
    ),
    _template('character-antagonist', 'Antagonist',
        describe: 'The whole sheet. A label on the record — what an '
            'antagonist is for is on the Craft shelf, not in this list.'),
    _template('character-love-interest', 'Love Interest',
        describe: 'The whole sheet. A label on the record.'),
    _template('character-villain', 'Villain',
        describe: 'The whole sheet. A label on the record.'),
    _template('character-hero', 'Hero',
        describe: 'The whole sheet. A label on the record.'),
    _template('character-pov', 'POV Character',
        describe: 'The whole sheet. A label on the record.'),
    _template('character-fae', 'Fae Character',
        describe: 'The whole sheet. A label on the record — no fae-specific '
            'fields come with it.'),
    _template('character-fantasy', 'Fantasy Character',
        describe: 'The whole sheet. A label on the record.'),
    _template('character-modern', 'Modern Character',
        describe: 'The whole sheet. A label on the record.'),
    _template('character-historical', 'Historical Character',
        describe: 'The whole sheet. A label on the record.'),
  ];

  static RecordTypeDefinition customTemplate({
    required String id,
    required String name,
    required String projectId,
    List<RecordFieldDefinition> fields = const [],
    List<RecordTemplateSection> sections = const [],
    int templateVersion = 1,
  }) =>
      RecordTypeDefinition(
        id: id,
        name: name,
        description: 'Project-scoped custom character template.',
        icon: 'person_edit',
        categoryId: 'characters',
        baseTypeId: 'character',
        fields: fields,
        sections: sections,
        scopeType: RecordScopeType.project,
        scopeId: projectId,
        templateVersion: templateVersion,
        extensionData: const {'customCharacterTemplate': true},
      );
}

/// One built-in character template.
///
/// [describe] says what choosing it *does*, which for these means one thing:
/// **which sections of the character sheet it opens.** That is the only thing
/// a template varies — `_characterTemplateSections` reads `visibleSections`
/// and shows the rest of the sheet whole — so it is the only honest thing a
/// description can promise.
///
/// The formula this replaced was `'\$name character template.'`, which
/// restated the label and printed "Character character template" for three of
/// the twelve. A description that says the label back is worse than none: it
/// occupies the place an author looks for an answer.
///
/// ## Why these are not craft library entries
///
/// The library's rule is that an entry earns its place by having a non-obvious
/// answer to *what does this do in the story*. A template does nothing in the
/// story — it decides which boxes are on screen, which is a fact about this
/// application. Six of the twelve names are also roles the library already
/// explains (Villain, Hero, Antagonist, Love Interest, POV Character,
/// Supporting Character), and a template entry for *Villain* would be a second
/// explanation of a word that has one, which is the exact drift
/// `lib/core/craft/` exists to prevent.
///
/// So they are inline glosses, the second half of §9.2's contract — a field
/// takes its description from the library **or** declares a gloss inline,
/// never both — and the same call `timeline.precision` made in §9.9.
RecordTypeDefinition _template(
  String id,
  String name, {
  List<String>? visibleSections,
  required String describe,
}) =>
    RecordTypeDefinition(
      id: id,
      name: name,
      description: describe,
      icon: 'person',
      categoryId: 'characters',
      baseTypeId: 'character',
      fields: const [],
      sections: const [],
      templateVersion: 1,
      builtIn: true,
      sourcePackId: 'authoros-character-core',
      extensionData: {
        if (visibleSections != null) 'visibleSections': visibleSections,
        'supportsSparseProfiles': true,
      },
    );

/// One character field, with its craft guidance resolved from the library.
///
/// A field takes its description from [CraftLibrary] when an entry explains
/// it, and otherwise from [description] passed here. **Never both** — a field
/// with an entry and an inline string would be two sources for one sentence,
/// which is the thing the library exists to prevent, and
/// `test/craft_library_test.dart` fails the build if one appears.
///
/// The library wins where it has something to say, because the browsable
/// surface reads the same entry: what an author is told under the input and
/// what they are told on the shelf are then the same object, not two strings
/// that happen to agree today.
/// The character sheet's Companion depth, stated as a rule rather than a list.
///
/// [the gating ledger](../../docs/free-paid-gating-ledger.md) §3 puts four
/// whole sections and seven `appearance` fields behind AOS Companion, and
/// `characters.specialist` is the capability that gates them —
/// `lib/core/capabilities.dart` has the line, and
/// `lib/services/fireside_room.dart` is the door.
///
/// ## Why a rule and not sixty-one `soldWith:` arguments
///
/// The same argument [_mergedFields] makes, and one more that this sheet has
/// already been bitten by.
///
/// Sixty-one arguments scattered through `_fields` are sixty-one unrelated
/// decisions. The decision is actually two sentences: *psychology, voice, POV
/// and arcs are Companion's sections*, and *these seven appearance fields are
/// performance rather than looks*. Written that way it can be read, argued
/// with, and checked.
///
/// **And a literal list would go stale the way the ledger's count did.** The
/// ledger says 48 fields across the four sections; there are **54** today,
/// because the sheet grew after the ledger was written. A list of sixty-one
/// ids would have the same problem the moment somebody adds a fifty-fifth
/// psychology field: the new field arrives **free**, silently, because nothing
/// says otherwise — and free-by-omission is the failure this whole gating
/// layer exists to prevent. A section rule cannot fail that way. A new
/// `psychology.` field is Companion's the moment it is written, which is what
/// the ledger decided.
///
/// ## The appearance seven
///
/// `appearance` splits three ways and only this third is Companion's. The
/// ledger names them and they resolve exactly: voice, accent, mannerisms,
/// posture, movement, scent, sensory traits. **These are how a character comes
/// across**, which is what a conversation needs; the visual eleven — scars,
/// tattoos, clothing, weapons — are **Character Atelier's** and are not wired
/// here, and the basics are free.
///
/// This one is a list rather than a rule because there is no prefix for it:
/// it is a judgement about which half of one section is performance, so a new
/// `appearance.` field is free until somebody decides otherwise. That is the
/// right default for a section whose other two thirds are not Companion's.
const _companionSections = <String>{'psychology', 'voice', 'pov', 'arcs'};

const _companionAppearanceFields = <String>{
  'appearance.voice',
  'appearance.accent',
  'appearance.mannerisms',
  'appearance.posture',
  'appearance.movement',
  'appearance.scent',
  'appearance.sensoryTraits',
};

/// The capability that sells a field, or null when it is free.
///
/// Null for everything outside the rule above, which is most of the sheet —
/// the 77 free fields the ledger counts, and every section another pack will
/// one day claim. A pack that wants some of this sheet adds its own clause
/// here and its own capability there; it does not get to edit this one.
String? _soldWith(String id) {
  final section = id.split('.').first;
  if (_companionSections.contains(section)) return 'characters.specialist';
  if (_companionAppearanceFields.contains(id)) return 'characters.specialist';
  return null;
}

RecordFieldDefinition _field(
  String id,
  String label,
  RecordFieldType type,
  int order, {
  bool required = false,
  List<String> options = const [],
  List<String> referenceTypeIds = const [],
  String description = '',
}) {
  final fromLibrary = CraftLibrary.describe('character.$id');
  return RecordFieldDefinition(
    id: id,
    label: label,
    type: type,
    order: order,
    required: required,
    options: options,
    referenceTypeIds: referenceTypeIds,
    description: fromLibrary.isEmpty ? description : fromLibrary,
    // Resolved by the same key as the field's own description, for every
    // field rather than wired onto the ones that have option entries today.
    // A choice field picks up per-option help by existing; one the library
    // says nothing about gets an empty map and is unchanged, which is most of
    // them, and the next set of options to be explained needs no edit here.
    //
    // The registry refuses a description for an option a field does not
    // offer, so a key naming an option that has been renamed fails the build
    // rather than quietly explaining nothing.
    optionDescriptions: CraftLibrary.describeOptions('character.$id'),
    // Read from `_mergedFields` rather than passed at each call site, so the
    // fifty retirements read as one reviewable table instead of fifty
    // arguments scattered through the list below.
    extensionData: {
      if (_mergedFields.containsKey(id)) 'mergedInto': _mergedFields[id]!,
    },
    // Read from `_soldWith` for the reason the description and `mergedInto`
    // are read from their own sources: the decision belongs in one reviewable
    // place, not spread across the call sites that happen to be affected by
    // it. See `_companionSections`.
    soldWith: _soldWith(id),
  );
}

/// Fields the character sheet no longer offers, and the field each folded into.
///
/// **Nothing is deleted.** A retired field keeps its definition — its craft
/// library entry still resolves to it, `RecordValidation` still knows its type,
/// and a record that already holds a value under it keeps that value and still
/// shows the box, labelled with where the field went. What changes is that a
/// fresh sheet never draws an empty one, and the *Add detail* picker never
/// offers it.
///
/// ## Why a table and not a flag on each field
///
/// Fifty of the sheet's one hundred and sixty-five fields are here. Read as
/// fifty `mergedInto:` arguments scattered through `_fields` they are fifty
/// unrelated decisions; read as one table they are a claim that can be
/// checked: every value on the right is a field that exists, no field is both
/// a key and a value, and the pairs can be read side by side to see whether
/// the survivor really does cover what it absorbed.
/// `test/character_field_policy_test.dart` asserts the first two.
///
/// ## What counted as a duplicate
///
/// One question. If an author would write the *same sentence* into both
/// boxes, one of them goes. "Speech style" and "Speech patterns" get the same
/// sentence. "Shame" and "Guilt" do not — the craft library spends a
/// paragraph on the difference — so both stay, and the psychology block is
/// almost untouched for that reason.
const Map<String, String> _mergedFields = {
  // Identity kept twelve boxes for a person's name. Four of them — first,
  // middle, last, and the full name they compose — asked for the same string
  // twice, and five more (nicknames, former names, secret names, code names,
  // known as) were one list each for what is one list: the names this
  // character goes by that are not the name on the record.
  'identity.firstName': 'identity.fullName',
  'identity.middleName': 'identity.fullName',
  'identity.lastName': 'identity.fullName',
  'identity.nicknames': 'identity.aliases',
  'identity.formerNames': 'identity.aliases',
  'identity.secretNames': 'identity.aliases',
  'identity.codeNames': 'identity.aliases',
  // `identity.titles` survives separately: a title is not a name, and
  // `CharacterEpithet` reads it for the line above the name in the Companion.
  'identity.knownAs': 'identity.aliases',

  // Appearance described the same body more than once, and described three
  // things the Voice section owns outright.
  'appearance.bodyType': 'appearance.build',
  'appearance.hairTexture': 'appearance.hair',
  'appearance.hairColour': 'appearance.hair',
  'appearance.formalClothing': 'appearance.typicalClothing',
  'appearance.combatClothing': 'appearance.typicalClothing',
  'appearance.posture': 'appearance.movement',
  'appearance.voice': 'voice.speechStyle',
  'appearance.accent': 'voice.accent',
  'appearance.mannerisms': 'personality.mannerisms',

  // Personality had five lists for "what they are like" and three for "how
  // they hold up", and asked psychology's questions a second time in plainer
  // words. Where a field and a psychology field overlapped, psychology keeps
  // it: those are the ones the craft library explains.
  'personality.positiveTraits': 'personality.strengths',
  'personality.negativeTraits': 'personality.flaws',
  'personality.weaknesses': 'personality.flaws',
  'personality.habits': 'personality.mannerisms',
  'personality.quirks': 'personality.mannerisms',
  'personality.beliefs': 'personality.values',
  'personality.moralsEthics': 'personality.values',
  'personality.temperament': 'personality.emotionalBaseline',
  'personality.fears': 'psychology.fear',
  'personality.insecurities': 'psychology.shame',
  'personality.emotionalTriggers': 'psychology.triggers',
  'personality.stressResponse': 'psychology.defences',
  'personality.copingMechanisms': 'psychology.defences',
  'personality.communicationStyle': 'voice.speechStyle',

  // Secrets are a section. They were also a psychology list and a backstory
  // list, so a secret could be written in three places and read in one.
  'psychology.secrets': 'secrets.entries',
  'backstory.secrets': 'secrets.entries',

  // Backstory carried four boxes for the people in a character's past, which
  // is what the Relationships section is for, and three for events.
  'backstory.earlyExperiences': 'backstory.childhood',
  'backstory.friendships': 'backstory.previousRelationships',
  'backstory.enemies': 'backstory.previousRelationships',
  'backstory.mentors': 'backstory.previousRelationships',
  'backstory.importantVictories': 'backstory.majorLifeEvents',
  'backstory.importantLosses': 'backstory.majorLifeEvents',
  'backstory.majorMistakes': 'psychology.regrets',
  'backstory.turningPoints': 'arcs.turningPoints',

  // "Motivation" and "Primary motivation" are the same question asked in two
  // sections. Psychology keeps it — it is the one with the craft entry.
  'goals.motivation': 'psychology.primaryMotivation',

  // Voice and POV both described how a character sounds on the page, and
  // "Internal voice" was declared twice under that exact label.
  'voice.sentenceLength': 'voice.dialogueRhythm',
  'voice.speechPatterns': 'voice.speechStyle',
  'pov.internalVoice': 'voice.internalVoice',
  'pov.narrativeVoice': 'voice.internalVoice',
  'pov.emotionalBias': 'voice.emotionalVoice',

  // Six notes boxes, three of which meant "a note".
  'notes.writer': 'notes.general',
  'notes.development': 'notes.general',
  'notes.private': 'notes.general',
};

/// Which fields a section draws before the author asks for more.
///
/// The sheet used to draw all one hundred and sixty-five at once, so Appearance
/// opened on eight empty boxes for scars, tattoos, birthmarks, piercings and
/// four kinds of clothing before an author had said what the character looked
/// like. An empty box is a question, and a screen of them is an interrogation
/// nobody asked for.
///
/// So a section opens with the handful below, adds any field that already
/// holds a value — nothing an author has written can hide — and puts the rest
/// behind *Add detail*, which lists them with their craft guidance so the
/// depth is still findable. Sections not named here open with whatever they
/// hold plus the picker; that is the right default for the connection-backed
/// ones and for `secrets`, which is a single table.
const Map<String, List<String>> _openFields = {
  'identity': [
    'identity.displayName',
    'identity.fullName',
    'identity.pronouns',
    'identity.age',
    'identity.roles',
    'identity.characterStatus',
  ],
  'appearance': [
    'appearance.height',
    'appearance.build',
    'appearance.hair',
    'appearance.eyeColour',
    'appearance.skin',
    'appearance.distinguishingFeatures',
  ],
  'personality': [
    'personality.summary',
    'personality.coreTraits',
    'personality.strengths',
    'personality.flaws',
  ],
  'psychology': [
    'psychology.coreWound',
    'psychology.falseBelief',
    'psychology.internalNeed',
    'psychology.externalWant',
  ],
  'backstory': [
    'backstory.childhood',
    'backstory.majorLifeEvents',
  ],
  'goals': [
    'goals.entries',
    'goals.primaryGoal',
    'goals.obstacles',
    'goals.stakes',
  ],
  'arcs': [
    'arcs.entries',
    'arcs.startingState',
    'arcs.endState',
  ],
  'secrets': ['secrets.entries'],
  'knowledge': ['knowledge.entries', 'knowledge.authorNotes'],
  'voice': [
    'voice.speechStyle',
    'voice.accent',
    'voice.dialogueExamples',
  ],
  // Not `pov.internalVoice`: that is the field that folded into Voice, and a
  // section cannot open with a box it has retired.
  'pov': ['pov.enabled', 'pov.priority', 'pov.narrativeReliability'],
  'notes': ['notes.general'],
  'media': ['media.primaryPortrait', 'media.referenceImages'],
};

/// What the character sheet offers, and what it has folded away.
///
/// The one place that answers both questions. Character Studio's renderer, the
/// completion counters in its header and the *Add detail* picker all read this
/// rather than each deciding for themselves which fields count — that
/// divergence is how the header came to report "0 optional details completed"
/// against a hundred and forty boxes an author was never going to fill.
class CharacterFieldPolicy {
  const CharacterFieldPolicy._();

  /// The field [field] was folded into, or null if it is still offered.
  static String? mergedInto(RecordFieldDefinition field) {
    final target = field.extensionData['mergedInto'];
    return target is String && target.isNotEmpty ? target : null;
  }

  /// Whether the sheet still offers [field] on a character that has no value
  /// for it.
  static bool isOffered(RecordFieldDefinition field) =>
      mergedInto(field) == null;

  /// Whether [fieldId] is drawn as soon as its section opens.
  static bool opensWith(String sectionId, String fieldId) =>
      _openFields[sectionId]?.contains(fieldId) ?? false;

  /// The label of the field a retired field folded into.
  ///
  /// Falls back to the raw id, which cannot happen while the test asserting
  /// every target exists passes, and is still more use than an empty string
  /// if it ever does.
  static String labelOf(String fieldId) =>
      CharacterRecordTypes.character.fields
          .where((field) => field.id == fieldId)
          .firstOrNull
          ?.label ??
      fieldId;

  /// Every retired field, paired with what it folded into.
  ///
  /// Exposed for tests and for anything that has to explain the change to an
  /// author; the sheet itself reads [mergedInto] off the field it is drawing.
  static Map<String, String> get merges => Map.unmodifiable(_mergedFields);
}

final List<RecordFieldDefinition> _fields = [
  _field(
      'identity.displayName', 'Display name', RecordFieldType.shortText, 100),
  _field('identity.fullName', 'Full name', RecordFieldType.shortText, 101,
      required: true,
      description: 'The whole name, written the way the book writes it. First, '
          'middle and last are no longer three more boxes asking for the same '
          'string.'),
  _field('identity.firstName', 'First name', RecordFieldType.shortText, 102),
  _field('identity.middleName', 'Middle name', RecordFieldType.shortText, 103),
  _field('identity.lastName', 'Last name', RecordFieldType.shortText, 104),
  // The one list of other names, and the survivor of eight.
  _field('identity.aliases', 'Other names', RecordFieldType.list, 105,
      description: 'Nicknames, aliases, code names, former names, what people '
          'call them when they are not in the room — every name this '
          'character answers to that is not the one above. Titles and '
          'honorifics stay separate: a title is not a name.'),
  _field('identity.nicknames', 'Nicknames', RecordFieldType.list, 106),
  _field('identity.titles', 'Titles and honorifics', RecordFieldType.list, 107),
  _field('identity.formerNames', 'Former names', RecordFieldType.list, 108),
  _field('identity.secretNames', 'Secret names', RecordFieldType.list, 109),
  _field('identity.codeNames', 'Code names', RecordFieldType.list, 110),
  _field('identity.knownAs', 'Known as', RecordFieldType.list, 111),
  _field('identity.pronouns', 'Pronouns', RecordFieldType.shortText, 112),
  _field('identity.gender', 'Gender', RecordFieldType.shortText, 113),
  _field('identity.age', 'Age', RecordFieldType.number, 114),
  _field('identity.dateOfBirth', 'Date of birth', RecordFieldType.date, 115),
  _field('identity.dateOfDeath', 'Date of death', RecordFieldType.date, 116,
      description: 'Left empty for a character who is still alive; the family '
          'tree reads an empty death as "Present".'),
  _field('identity.placeOfBirth', 'Place of birth',
      RecordFieldType.locationReference, 117,
      referenceTypeIds: const ['location', 'place']),
  _field('identity.species', 'Species', RecordFieldType.recordReference, 118,
      referenceTypeIds: const ['species', 'creature']),
  _field('identity.raceType', 'Race / type', RecordFieldType.shortText, 119),
  _field('identity.nationalityOrigin', 'Nationality / origin',
      RecordFieldType.shortText, 120),
  _field(
      'identity.occupation', 'Occupation', RecordFieldType.recordReference, 121,
      referenceTypeIds: const ['occupation']),
  // Fifteen role names, fifteen explanations. This field is the one that
  // raised the per-option gap: the craft library could spend a single line on
  // it and no more, because `options` is a List<String> and there was nowhere
  // to hang help off one value. `optionDescriptions` closed that, and this is
  // the entry the old comment promised would move.
  //
  // Read from the library rather than written here — resolved by `_field`
  // for every field at once, the same way it resolves the field description
  // — so a role is explained in one place and the shelf and the field cannot
  // drift into two accounts of what a Foil is.
  //
  // They render. `OptionChooser` replaced the comma-separated text box that
  // had kept these fifteen options off an author's screen entirely, and it
  // draws each option's description under it — so this field is the one place
  // where all three halves of the work meet: somewhere to put the help, a
  // chooser to draw it in, and the fifteen explanations themselves.
  _field('identity.roles', 'Roles', RecordFieldType.multipleChoice, 122,
      options: const [
        'Protagonist',
        'Antagonist',
        'Deuteragonist',
        'Supporting Character',
        'Love Interest',
        'Mentor',
        'Foil',
        'Rival',
        'Villain',
        'Hero',
        'Antihero',
        'Comic Relief',
        'Narrator',
        'POV Character',
        'Minor Character'
      ]),
  _field('identity.affiliations', 'Affiliations', RecordFieldType.list, 123),
  _field('identity.characterStatus', 'Character status',
      RecordFieldType.singleChoice, 124,
      options: const [
        'Alive',
        'Dead',
        'Missing',
        'Unknown',
        'Undead',
        'Transformed',
        'Retired',
        'Inactive',
        'Other'
      ]),
  // The applied lens on the character sheet — the author's own claim about
  // what this person is doing in the story, not a reading of one. It sits
  // beside Roles because the two answer the same kind of question: `roles`
  // says what this character is *for*, and this says what convention they are
  // *part of*. See `lib/core/craft_fields.dart`.
  //
  // Five of the nine claimable tropes reach a character; the other four are
  // things a book does rather than things a person can be, and the library
  // decides which is which — this file names no terms of its own.
  CraftFields.assertion(
    id: 'identity.conventions',
    label: 'Conventions at work',
    family: CraftFamily.tropes,
    subject: CraftSubject.character,
    order: 125,
    description: 'Conventions this character is part of, as you read them. '
        'Tick what applies, add anything the list has not heard of, or leave '
        'it empty — nothing else in AuthorOS reads this except you.',
  ),
  _field('appearance.height', 'Height', RecordFieldType.shortText, 200),
  _field('appearance.build', 'Build', RecordFieldType.shortText, 201,
      description: 'Frame and body type. Height has its own box.'),
  _field('appearance.bodyType', 'Body type', RecordFieldType.shortText, 202),
  _field('appearance.hair', 'Hair', RecordFieldType.shortText, 203,
      description: 'Colour, length, texture, and how they wear it.'),
  _field(
      'appearance.hairTexture', 'Hair texture', RecordFieldType.shortText, 204),
  _field(
      'appearance.hairColour', 'Hair colour', RecordFieldType.shortText, 205),
  _field('appearance.eyeColour', 'Eye colour', RecordFieldType.shortText, 206),
  _field('appearance.skin', 'Skin', RecordFieldType.shortText, 207),
  _field('appearance.distinguishingFeatures', 'Distinguishing features',
      RecordFieldType.longText, 208,
      description: 'What a reader would notice and describe. Scars, tattoos, '
          'birthmarks and piercings each keep their own box under Add detail '
          'for a character who needs them itemised.'),
  _field('appearance.scars', 'Scars', RecordFieldType.longText, 209),
  _field('appearance.tattoos', 'Tattoos', RecordFieldType.longText, 210),
  _field('appearance.birthmarks', 'Birthmarks', RecordFieldType.longText, 211),
  _field('appearance.piercings', 'Piercings', RecordFieldType.longText, 212),
  _field('appearance.limitations', 'Disabilities / limitations',
      RecordFieldType.longText, 213),
  _field('appearance.typicalClothing', 'Clothing and dress',
      RecordFieldType.longText, 214,
      description: 'What they wear day to day, and what changes when the '
          'occasion does.'),
  _field('appearance.formalClothing', 'Formal clothing',
      RecordFieldType.longText, 215),
  _field('appearance.combatClothing', 'Combat clothing',
      RecordFieldType.longText, 216),
  _field(
      'appearance.accessories', 'Accessories', RecordFieldType.longText, 217),
  _field('appearance.weapons', 'Weapons', RecordFieldType.list, 218),
  _field('appearance.physicalPresence', 'Physical presence',
      RecordFieldType.longText, 219),
  _field('appearance.voice', 'Voice', RecordFieldType.longText, 220),
  _field('appearance.accent', 'Accent', RecordFieldType.shortText, 221),
  _field('appearance.mannerisms', 'Mannerisms', RecordFieldType.longText, 222),
  _field('appearance.posture', 'Posture', RecordFieldType.shortText, 223),
  _field('appearance.movement', 'Posture and movement',
      RecordFieldType.longText, 224),
  _field('appearance.scent', 'Scent', RecordFieldType.shortText, 225),
  _field('appearance.sensoryTraits', 'Other sensory traits',
      RecordFieldType.longText, 226),
  _field('personality.summary', 'Personality summary', RecordFieldType.longText,
      300),
  _field('personality.coreTraits', 'Core traits', RecordFieldType.list, 301),
  _field('personality.positiveTraits', 'Positive traits', RecordFieldType.list,
      302),
  _field('personality.negativeTraits', 'Negative traits', RecordFieldType.list,
      303),
  _field('personality.strengths', 'Strengths', RecordFieldType.list, 304),
  _field('personality.weaknesses', 'Weaknesses', RecordFieldType.list, 305),
  _field('personality.flaws', 'Flaws and weaknesses', RecordFieldType.list,
      306),
  _field('personality.fears', 'Fears', RecordFieldType.list, 307),
  _field('personality.insecurities', 'Insecurities', RecordFieldType.list, 308),
  _field('personality.habits', 'Habits', RecordFieldType.list, 309),
  _field('personality.quirks', 'Quirks', RecordFieldType.list, 310),
  _field('personality.mannerisms', 'Mannerisms, habits and quirks',
      RecordFieldType.list, 311),
  _field('personality.values', 'Values and beliefs', RecordFieldType.list,
      312),
  _field('personality.beliefs', 'Beliefs', RecordFieldType.list, 313),
  _field('personality.moralsEthics', 'Morals / ethics',
      RecordFieldType.longText, 314),
  _field('personality.boundaries', 'Boundaries', RecordFieldType.longText, 315),
  _field(
      'personality.temperament', 'Temperament', RecordFieldType.shortText, 316),
  _field('personality.emotionalBaseline', 'Emotional baseline',
      RecordFieldType.longText, 317),
  _field('personality.emotionalTriggers', 'Emotional triggers',
      RecordFieldType.list, 318),
  _field('personality.stressResponse', 'Stress response',
      RecordFieldType.longText, 319),
  _field('personality.copingMechanisms', 'Coping mechanisms',
      RecordFieldType.list, 320),
  _field('personality.senseOfHumour', 'Sense of humour',
      RecordFieldType.longText, 321),
  _field('personality.communicationStyle', 'Communication style',
      RecordFieldType.longText, 322),
  _field('personality.socialBehaviour', 'Social behaviour',
      RecordFieldType.longText, 323),
  _field(
      'personality.trustStyle', 'Trust style', RecordFieldType.shortText, 324),
  _field('personality.attachmentStyle', 'Attachment style',
      RecordFieldType.shortText, 325),
  _field('personality.conflictStyle', 'Conflict style',
      RecordFieldType.shortText, 326),
  // The psychology block is where a character stops being a description and
  // starts being a person, and every field in it is a term of art. Each one is
  // explained by a craft library entry rather than by a string here — see
  // `core/craft/craft_library.dart`, where the wording lives once and serves
  // both the helper text under the input and the browsable shelf.
  _field('psychology.coreWound', 'Core wound', RecordFieldType.longText, 400),
  _field(
      'psychology.falseBelief', 'False belief', RecordFieldType.longText, 401),
  _field('psychology.coreBelief', 'Core belief', RecordFieldType.longText, 402),
  _field('psychology.internalNeed', 'Internal need', RecordFieldType.longText,
      403),
  _field('psychology.externalWant', 'External want', RecordFieldType.longText,
      404),
  _field('psychology.fear', 'Fear', RecordFieldType.longText, 405),
  _field('psychology.desire', 'Desire', RecordFieldType.longText, 406),
  _field('psychology.primaryMotivation', 'Primary motivation',
      RecordFieldType.longText, 407),
  _field('psychology.secondaryMotivations', 'Secondary motivations',
      RecordFieldType.list, 408),
  _field('psychology.emotionalNeeds', 'Emotional needs', RecordFieldType.list,
      409),
  _field('psychology.secrets', 'Secrets', RecordFieldType.list, 410),
  _field('psychology.shame', 'Shame', RecordFieldType.longText, 411),
  _field('psychology.guilt', 'Guilt', RecordFieldType.longText, 412),
  _field('psychology.regrets', 'Regrets', RecordFieldType.list, 413),
  _field('psychology.obsessions', 'Obsessions', RecordFieldType.list, 414),
  _field('psychology.avoidances', 'Avoidances', RecordFieldType.list, 415),
  _field('psychology.triggers', 'Triggers', RecordFieldType.list, 416),
  _field('psychology.defences', 'Defences', RecordFieldType.list, 417),
  _field(
      'psychology.contradictions', 'Contradictions', RecordFieldType.list, 418),
  _field('psychology.internalConflict', 'Internal conflict',
      RecordFieldType.longText, 419),
  _field('psychology.externalConflict', 'External conflict',
      RecordFieldType.longText, 420),
  _field('backstory.childhood', 'Childhood', RecordFieldType.longText, 500),
  _field('backstory.family', 'Family background', RecordFieldType.longText,
      501,
      description: 'The shape of the household they came out of. The people '
          'themselves belong in the Family section, which links to their own '
          'records.'),
  _field('backstory.education', 'Education', RecordFieldType.longText, 502),
  _field('backstory.earlyExperiences', 'Early experiences',
      RecordFieldType.longText, 503),
  _field('backstory.majorLifeEvents', 'Major life events', RecordFieldType.list,
      504,
      description: 'What happened to them that mattered — the wins and the '
          'losses in one list, because a life does not sort them.'),
  _field('backstory.friendships', 'Friendships', RecordFieldType.longText, 505),
  _field('backstory.enemies', 'Enemies', RecordFieldType.longText, 506),
  _field('backstory.mentors', 'Mentors', RecordFieldType.longText, 507),
  _field('backstory.previousOccupations', 'Previous occupations',
      RecordFieldType.list, 508),
  _field('backstory.previousRelationships', 'Formative relationships',
      RecordFieldType.longText, 509,
      description: 'The friends, enemies, mentors and partners who shaped '
          'them. Anyone with a record of their own belongs in Relationships; '
          'this is the prose a link cannot hold.'),
  _field(
      'backstory.majorMistakes', 'Major mistakes', RecordFieldType.list, 510),
  _field('backstory.importantVictories', 'Important victories',
      RecordFieldType.list, 511),
  _field('backstory.importantLosses', 'Important losses', RecordFieldType.list,
      512),
  _field('backstory.secrets', 'Backstory secrets', RecordFieldType.list, 513),
  _field(
      'backstory.turningPoints', 'Turning points', RecordFieldType.list, 514),
  _field('goals.entries', 'Further goals', RecordFieldType.table, 600,
      description: 'Goals beyond the primary one below, each with its own '
          'priority, motivation, obstacles, stakes, progress, status, '
          'deadline and links.'),
  _field('goals.primaryGoal', 'Primary goal', RecordFieldType.longText, 601),
  _field('goals.motivation', 'Motivation', RecordFieldType.longText, 602),
  _field('goals.obstacles', 'Obstacles', RecordFieldType.longText, 603),
  _field('goals.stakes', 'Stakes', RecordFieldType.longText, 604),
  _field('arcs.entries', 'Further arcs', RecordFieldType.table, 700,
      description: 'Arcs beyond the one described below — internal, external, '
          'emotional, relationship, moral and belief arcs each get an entry.'),
  _field('arcs.startingState', 'Starting state', RecordFieldType.longText, 701),
  _field(
      'arcs.incitingChange', 'Inciting change', RecordFieldType.longText, 702),
  _field('arcs.turningPoints', 'Turning points', RecordFieldType.list, 703),
  _field('arcs.lowestPoint', 'Lowest point', RecordFieldType.longText, 704),
  _field('arcs.majorChoices', 'Major choices', RecordFieldType.list, 705),
  _field('arcs.consequences', 'Consequences', RecordFieldType.list, 706),
  _field('arcs.endState', 'End state', RecordFieldType.longText, 707),
  _field('secrets.entries', 'Secrets', RecordFieldType.table, 800,
      description:
          'Structured secrets with knowledge, risk, consequence, reveal state, and stable references.'),
  _field('knowledge.entries', 'Character knowledge', RecordFieldType.table, 810,
      description:
          'What the character knows, does not know, suspects, believes, misunderstands, or has forgotten.'),
  _field('knowledge.authorNotes', 'Author knowledge', RecordFieldType.longText,
      811),
  _field('voice.speechStyle', 'Speech style', RecordFieldType.longText, 900,
      description: 'How they talk — register, tics, the turns they reach for '
          'and the ones they never use. Accent has its own box.'),
  _field('voice.vocabulary', 'Vocabulary', RecordFieldType.longText, 901),
  _field('voice.sentenceLength', 'Sentence length', RecordFieldType.shortText,
      902),
  // Ordered where "Sentence length" used to sit, because it absorbed it.
  _field('voice.dialogueRhythm', 'Rhythm and sentence length',
      RecordFieldType.longText, 909),
  _field('voice.formality', 'Formality', RecordFieldType.shortText, 903),
  _field('voice.favouriteWords', 'Favourite words', RecordFieldType.list, 904),
  _field('voice.wordsNeverUsed', 'Words never used', RecordFieldType.list, 905),
  _field(
      'voice.swearingStyle', 'Swearing style', RecordFieldType.longText, 906),
  _field('voice.metaphors', 'Metaphors', RecordFieldType.longText, 907),
  _field('voice.catchphrases', 'Catchphrases', RecordFieldType.list, 908),
  _field('voice.internalVoice', 'Internal voice', RecordFieldType.longText,
      910,
      description: 'How their narration and inner monologue read. This is the '
          'voice a chapter in their point of view is written in, which is why '
          'POV no longer asks for it a second time.'),
  _field(
      'voice.emotionalVoice', 'Emotional voice', RecordFieldType.longText, 911),
  _field('voice.accent', 'Accent', RecordFieldType.shortText, 912),
  _field('voice.speechPatterns', 'Speech patterns', RecordFieldType.list, 913),
  _field('voice.dialogueExamples', 'Example dialogue', RecordFieldType.longText,
      914),
  _field('pov.enabled', 'POV enabled', RecordFieldType.boolean, 1000),
  _field('pov.priority', 'POV priority', RecordFieldType.number, 1001),
  _field(
      'pov.narrativeVoice', 'Narrative voice', RecordFieldType.longText, 1002),
  _field('pov.internalVoice', 'Internal voice', RecordFieldType.longText, 1003),
  _field('pov.sensoryBias', 'Sensory bias', RecordFieldType.longText, 1004),
  _field('pov.emotionalBias', 'Emotional bias', RecordFieldType.longText, 1005),
  _field('pov.knowledgeBoundaries', 'Knowledge boundaries',
      RecordFieldType.longText, 1006),
  _field('pov.narrativeReliability', 'Narrative reliability',
      RecordFieldType.shortText, 1007),
  _field('pov.typicalChapterLength', 'Typical chapter length',
      RecordFieldType.number, 1008),
  _field('pov.notes', 'POV notes', RecordFieldType.longText, 1009),
  _field('notes.general', 'Notes', RecordFieldType.longText, 1100),
  _field('notes.writer', 'Writer notes', RecordFieldType.longText, 1101),
  _field(
      'notes.development', 'Development notes', RecordFieldType.longText, 1102),
  _field(
      'notes.continuity', 'Continuity notes', RecordFieldType.longText, 1103),
  _field('notes.research', 'Research notes', RecordFieldType.longText, 1104),
  _field('notes.private', 'Private notes', RecordFieldType.longText, 1105),
  _field(
      'media.primaryPortrait', 'Primary portrait', RecordFieldType.image, 1200),
  _field(
      'media.referenceImages', 'Reference images', RecordFieldType.list, 1201),
];

final List<RecordTemplateSection> _sections = [
  _section('identity', 'Identity', 100),
  _section('appearance', 'Appearance', 200),
  _section('personality', 'Personality', 300),
  _section('psychology', 'Psychology', 400),
  _section('backstory', 'Backstory', 500),
  _section('goals', 'Goals and motivations', 600),
  _section('arcs', 'Character arcs', 700),
  _section('secrets', 'Secrets', 800),
  _section('knowledge', 'Knowledge', 810),
  _section('voice', 'Voice', 900),
  _section('pov', 'POV profile', 1000),
  _section('notes', 'Notes', 1100),
  _section('media', 'Portraits and references', 1200),
  ...[
    ('family', 'Family'),
    ('relationships', 'Relationships'),
    ('factions', 'Factions and organisations'),
    ('locations', 'Locations'),
    ('items', 'Items and possessions'),
    ('storyRole', 'Role in story'),
    ('timeline', 'Timeline'),
    ('manuscript', 'Manuscript appearances'),
    ('codex', 'Story Codex'),
    ('world', 'World'),
  ].indexed.map((entry) => RecordTemplateSection(
        id: entry.$2.$1,
        title: entry.$2.$2,
        order: 1300 + entry.$1,
        fieldIds: const [],
        collapsedByDefault: true,
        extensionData: const {'connectionBacked': true},
      )),
];

RecordTemplateSection _section(String id, String title, int order) =>
    RecordTemplateSection(
      id: id,
      title: title,
      order: order,
      fieldIds: _fields
          .where((field) => field.id.startsWith('$id.'))
          .map((field) => field.id)
          .toList(),
      collapsedByDefault: id != 'identity',
    );
