// Character Chat — the conversational questionnaire over canonical records.
//
// M26 §6.2 requires questionnaires whose answers populate mapped character
// fields only after explicit author action, with unmapped answers preserved
// as linked questionnaire responses. Character Chat delivers that contract
// as a chat-style interview: the prompt library below is the questionnaire,
// and ChatSessionState is the response record.
//
// Everything here is plain Dart. Prompts are a static, versioned library —
// nothing is generated, and the author writes every answer.

import 'connected_domain.dart';
import 'record_types.dart';
import 'story_vocabulary.dart';

/// The id of the record type a chat session persists as.
///
/// A session is an [AuthorRecord] like everything else (Lock 1): it rides
/// archive, export, versioning and audit with no store of its own. The
/// canonical value of an accepted answer lives on the interviewed record;
/// the session keeps the raw answer as provenance.
const String kCharacterChatSessionTypeId = 'character-chat-session';

/// What answering a prompt can do to canonical data.
enum ChatPromptTargetKind {
  /// The answer can be written to one field on the interviewed record.
  field,

  /// The answer resolves to another record and becomes a typed link.
  link,

  /// The answer only ever lives on the session as a kept response.
  none,
}

class ChatPromptDefinition {
  const ChatPromptDefinition({
    required this.id,
    required this.text,
    this.targetFieldId,
    this.targetLinkTypeId,
    this.targetRecordTypeIds = const [],
  }) : assert(
          targetFieldId == null || targetLinkTypeId == null,
          'A prompt maps to a field or a link, never both.',
        );

  final String id;

  /// The question the author is asked, in the interview's voice.
  final String text;

  /// The field on the interviewed record an accepted answer writes to.
  final String? targetFieldId;

  /// The connection type an accepted answer creates a link with.
  final String? targetLinkTypeId;

  /// The record types a link answer may resolve to (record-picker filter).
  final List<String> targetRecordTypeIds;

  ChatPromptTargetKind get targetKind => targetFieldId != null
      ? ChatPromptTargetKind.field
      : targetLinkTypeId != null
          ? ChatPromptTargetKind.link
          : ChatPromptTargetKind.none;
}

class ChatPromptSet {
  const ChatPromptSet({
    required this.id,
    required this.title,
    required this.recordTypeId,
    required this.prompts,
    this.description = '',
    this.version = 1,
  });

  final String id;
  final String title;
  final String description;

  /// The record type this interview is written for ('character' today;
  /// 'faction' and friends when Group Chat lands).
  final String recordTypeId;

  final List<ChatPromptDefinition> prompts;

  /// Recorded on every session so identical inputs replay identically after
  /// the set itself evolves (the M26 §6.3 reproducibility posture).
  final int version;

  ChatPromptDefinition? prompt(String id) {
    for (final prompt in prompts) {
      if (prompt.id == id) return prompt;
    }
    return null;
  }
}

/// Prompt sets available to a project.
///
/// Mirrors the registry shape of the type registries: built-ins plus
/// project-scoped additions, resolved by id. Author-defined sets arrive in a
/// later slice through [additionalDefinitions]; the hook exists so the core
/// model never needs to change for them.
class ChatPromptSetRegistry {
  ChatPromptSetRegistry(Iterable<ChatPromptSet> sets)
      : _sets = {for (final set in sets) set.id: set};

  final Map<String, ChatPromptSet> _sets;

  List<ChatPromptSet> get all => _sets.values.toList();

  List<ChatPromptSet> setsFor(String recordTypeId) =>
      all.where((set) => set.recordTypeId == recordTypeId).toList();

  ChatPromptSet resolve(String id) {
    final set = _sets[id];
    if (set == null) {
      throw StateError('Unknown chat prompt set: $id.');
    }
    return set;
  }
}

class BuiltInChatPromptSets {
  const BuiltInChatPromptSets._();

  /// The Fears & Secrets interview — phase 1's built-in character set.
  ///
  /// Four field prompts over the character's psychology fields and one link
  /// prompt that resolves to a faction or organisation membership. The
  /// wording follows the Character Chat prompt library document.
  static const ChatPromptSet fearsAndSecrets = ChatPromptSet(
    id: 'fears-and-secrets',
    title: 'Fears & Secrets',
    description:
        'A short in-character interview about what your character fears, '
        'hides, and carries.',
    recordTypeId: 'character',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'fear-losing',
        text: 'What does your character fear losing most?',
        targetFieldId: 'psychology.fear',
      ),
      ChatPromptDefinition(
        id: 'secret-kept',
        text: 'What secret do they guard, and what would it cost them '
            'if it came out?',
        targetFieldId: 'psychology.secrets',
      ),
      ChatPromptDefinition(
        id: 'deepest-shame',
        text: 'What are they most ashamed of — and who must never learn it?',
        targetFieldId: 'psychology.shame',
      ),
      ChatPromptDefinition(
        id: 'core-wound',
        text: 'What old wound still shapes how they act today?',
        targetFieldId: 'psychology.coreWound',
      ),
      ChatPromptDefinition(
        id: 'secret-loyalty',
        text: 'Which faction or organisation claims their loyalty — '
            'even in secret?',
        targetLinkTypeId: 'memberOf',
        targetRecordTypeIds: ['faction', 'organisation'],
      ),
    ],
  );

  /// The Group Identity interview — Group Chat's first built-in set.
  ///
  /// Written for 'faction' and everything derived from it (organisation,
  /// house, clan, guild, company, military-unit), so one set interviews any
  /// group shape. Four field prompts over the faction fields and one link
  /// prompt that places the group inside a larger power — the Widow's Nine
  /// being one cell of the Widow Network, in the prompt library's terms.
  static const ChatPromptSet groupIdentity = ChatPromptSet(
    id: 'group-identity',
    title: 'Group Identity',
    description: 'An interview answered as the group: what it promises, '
        'what it hides, and what holds it together.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'public-promise',
        text: 'What does the group promise those it wants to win over?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'hidden-aim',
        text: 'What does it quietly want that it would never say aloud?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'binding-rule',
        text: 'What rule, oath, or tradition binds its members together?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'leadership',
        text: 'Who leads — and how is that leadership earned?',
        targetFieldId: 'leadership',
      ),
      ChatPromptDefinition(
        id: 'larger-power',
        text: 'Which larger power is it part of — openly or in secret?',
        targetLinkTypeId: 'partOf',
        targetRecordTypeIds: ['faction', 'organisation'],
      ),
    ],
  );

  /// The Political Party interview — the prompt library's Ashen Concord
  /// example as a reusable set. Faction-based like every group set, so any
  /// faction-derived record can answer as a party.
  static const ChatPromptSet politicalParty = ChatPromptSet(
    id: 'political-party',
    title: 'Political Party',
    description: 'An interview answered as the party: what it promises, '
        'what it quietly wants, who backs it, and what would splinter it.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'public-promise',
        text: 'What does the party promise the people it wants to win over?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'hidden-aim',
        text: 'What does it quietly want that it would never say aloud?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'support-base',
        text: 'Who backs the party openly?',
        targetFieldId: 'allies',
      ),
      ChatPromptDefinition(
        id: 'binding-belief',
        text: 'What belief holds the party together — and would splinter '
            'it if betrayed?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'founding-event',
        text: 'What event made the party necessary?',
        targetLinkTypeId: 'relatedTo',
        targetRecordTypeIds: ['historical-event', 'timeline-event'],
      ),
    ],
  );

  /// The Cult interview — the prompt library's Veil of the Red Moon example
  /// as a reusable set. A cult is a hidden faith, so its prompts ask what
  /// the group believes, promises, fears, and binds its believers with.
  static const ChatPromptSet cult = ChatPromptSet(
    id: 'cult',
    title: 'Cult',
    description: 'An interview answered as the cult: the truth it keeps, '
        'the promise it makes, and the oath that cannot be undone.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'hidden-truth',
        text: 'What truth does the cult believe that the world denies?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'promise-and-price',
        text: 'What does it promise the desperate — and what does it take '
            'from them?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'voice-of-the-faith',
        text: 'Who speaks for the faith, and where did their authority '
            'come from?',
        targetFieldId: 'leadership',
      ),
      ChatPromptDefinition(
        id: 'deepest-fear',
        text: 'What does the cult fear more than its own destruction?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'oath-object',
        text: 'What object seals a believer\'s oath — beyond undoing?',
        targetLinkTypeId: 'uses',
        targetRecordTypeIds: ['item', 'artefact', 'weapon'],
      ),
    ],
  );

  /// The Royal Court interview — the prompt library's Court of the River
  /// Crown example as a reusable set: who truly holds power, what protocol
  /// binds the court, and where its seat stands.
  static const ChatPromptSet royalCourt = ChatPromptSet(
    id: 'royal-court',
    title: 'Royal Court',
    description: 'An interview answered as the court: the throne, the ear '
        'behind it, the protocol, and the secret that protects the crown.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'throne-and-ear',
        text: 'Who sits the throne — and who truly has the monarch\'s ear?',
        targetFieldId: 'leadership',
      ),
      ChatPromptDefinition(
        id: 'binding-protocol',
        text: 'What ritual must every courtier observe, on pain of exile?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'rising-falling',
        text: 'Which houses are rising at court — and which are falling?',
        targetFieldId: 'hierarchy',
      ),
      ChatPromptDefinition(
        id: 'buried-secret',
        text: 'What secret does the court keep to protect the crown?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'seat-of-power',
        text: 'Where does the court hold its seat of power?',
        targetLinkTypeId: 'locatedIn',
        targetRecordTypeIds: ['location'],
      ),
    ],
  );

  /// The Criminal Network interview — the prompt library's Widow Network
  /// example as a reusable set: what it deals in, how its cells are cut,
  /// who it owns, and what it holds outright.
  static const ChatPromptSet criminalNetwork = ChatPromptSet(
    id: 'criminal-network',
    title: 'Criminal Network',
    description: 'An interview answered as the network: its trade and its '
        'taboo, its cells, its insiders, and the price of talking.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'trade-and-taboo',
        text: 'What does the network deal in — and what does it never '
            'touch?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'cell-structure',
        text: 'How is it organised so that no one can betray the whole?',
        targetFieldId: 'hierarchy',
      ),
      ChatPromptDefinition(
        id: 'owned-insiders',
        text: 'Who does it own inside the law?',
        targetFieldId: 'allies',
      ),
      ChatPromptDefinition(
        id: 'price-of-talking',
        text: 'What happens to those who talk?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'controlled-ground',
        text: 'What ground, trade, or front does it control outright?',
        targetLinkTypeId: 'controls',
        targetRecordTypeIds: [
          'location',
          'resource',
          'faction',
          'organisation'
        ],
      ),
    ],
  );

  /// The Team interview — the prompt library's Widow's Nine example: the
  /// crew's one rule, who leads and who keeps them alive, and the job that
  /// pulled them together.
  static const ChatPromptSet team = ChatPromptSet(
    id: 'team',
    title: 'Team',
    description: 'An interview answered as the crew: its one rule, its '
        'leaders, its signature skill, and the crack that could break it.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'unbreakable-rule',
        text: 'What is the team\'s one unbreakable rule?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'who-leads',
        text: 'Who leads — and who actually keeps them alive?',
        targetFieldId: 'leadership',
      ),
      ChatPromptDefinition(
        id: 'signature-skill',
        text: 'What does the team do best that no one else can?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'fracture-line',
        text: 'What is the crack that could break the team apart?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'origin-job',
        text: 'What job pulled them together in the first place?',
        targetLinkTypeId: 'relatedTo',
        targetRecordTypeIds: [
          'chapter',
          'scene',
          'historical-event',
          'timeline-event',
        ],
      ),
    ],
  );

  /// The Guild interview — the prompt library's Dockhands' Compact example:
  /// the trade it holds, how membership is earned and lost, and the power
  /// it answers to.
  static const ChatPromptSet guild = ChatPromptSet(
    id: 'guild',
    title: 'Guild',
    description: 'An interview answered as the guild: its trade, its '
        'ranks, its binding tradition, and the power it answers to.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'trade-held',
        text: 'What trade does the guild control — and how tightly?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'earning-membership',
        text: 'How does someone earn membership — and how do they lose it?',
        targetFieldId: 'hierarchy',
      ),
      ChatPromptDefinition(
        id: 'rank-ladder',
        text: 'What ranks lie between newest initiate and guildmaster?',
        targetFieldId: 'leadership',
      ),
      ChatPromptDefinition(
        id: 'binding-tradition',
        text: 'What oath or tradition binds the members together?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'answers-to',
        text: 'Which greater power does the guild answer to?',
        targetLinkTypeId: 'partOf',
        targetRecordTypeIds: ['faction', 'organisation', 'government'],
      ),
    ],
  );

  /// The Military Unit interview — the prompt library's Ninth Ward
  /// Garrison example: who truly gives the orders, where the chain of
  /// command bends, and the battle that made or broke it.
  static const ChatPromptSet militaryUnit = ChatPromptSet(
    id: 'military-unit',
    title: 'Military Unit',
    description: 'An interview answered as the unit: its true orders, its '
        'chain of command, its mark, and its defining battle.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'true-orders',
        text: 'Who does the unit serve — and who actually gives its '
            'orders?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'chain-of-command',
        text: 'What is the chain of command — and where does it bend?',
        targetFieldId: 'hierarchy',
      ),
      ChatPromptDefinition(
        id: 'sworn-duty',
        text: 'What is the unit sworn to hold or defend?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'mark-of-the-unit',
        text: 'What do its soldiers carry that marks them as the unit\'s '
            'own?',
        targetFieldId: 'resources',
      ),
      ChatPromptDefinition(
        id: 'defining-battle',
        text: 'What battle forged its reputation — or broke it?',
        targetLinkTypeId: 'relatedTo',
        targetRecordTypeIds: ['historical-event', 'timeline-event'],
      ),
    ],
  );

  /// The Religion interview — the prompt library's Tidefaith example: an
  /// established public faith, deliberately contrasted with the hidden
  /// Cult.
  static const ChatPromptSet religion = ChatPromptSet(
    id: 'religion',
    title: 'Religion',
    description: 'An interview answered as the faith: what it worships and '
        'promises, its rites, its clergy, and the heresy it will not name.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'worship-and-promise',
        text: 'What does the faith worship — and what does it promise the '
            'faithful?',
        targetFieldId: 'purpose',
      ),
      ChatPromptDefinition(
        id: 'life-rites',
        text: 'What rite marks every life, from naming to funeral?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'clergy',
        text: 'Who leads the faith — and how is that leadership earned?',
        targetFieldId: 'leadership',
      ),
      ChatPromptDefinition(
        id: 'unnamed-heresy',
        text: 'What heresy does the faith refuse to name aloud?',
        targetFieldId: 'enemies',
      ),
      ChatPromptDefinition(
        id: 'holy-ground',
        text: 'Where does the faith keep its holiest ground?',
        targetLinkTypeId: 'locatedIn',
        targetRecordTypeIds: ['location'],
      ),
    ],
  );

  /// The Noble House interview — the prompt library's House Noxmere
  /// capstone: the words and the truth beneath them, the succession
  /// crisis, and the oldest sin.
  static const ChatPromptSet nobleHouse = ChatPromptSet(
    id: 'noble-house',
    title: 'Noble House',
    description: 'An interview answered as the house: its words, its true '
        'holdings, its succession crisis, and its oldest sin.',
    recordTypeId: 'faction',
    version: 1,
    prompts: [
      ChatPromptDefinition(
        id: 'house-words',
        text: 'What are the house\'s words — and what truth do they '
            'conceal?',
        targetFieldId: 'beliefs',
      ),
      ChatPromptDefinition(
        id: 'true-holdings',
        text: 'What does the house actually hold, beyond its titles?',
        targetFieldId: 'resources',
      ),
      ChatPromptDefinition(
        id: 'succession-crisis',
        text: 'What is the house\'s succession crisis?',
        targetFieldId: 'secrets',
      ),
      ChatPromptDefinition(
        id: 'oldest-sin',
        text: 'What is the house\'s oldest sin?',
        targetFieldId: 'history',
      ),
      ChatPromptDefinition(
        id: 'ancestral-seat',
        text: 'Where does the house keep its ancestral seat?',
        targetLinkTypeId: 'locatedIn',
        targetRecordTypeIds: ['location'],
      ),
    ],
  );

  static const List<ChatPromptSet> definitions = [
    fearsAndSecrets,
    groupIdentity,
    politicalParty,
    cult,
    royalCourt,
    criminalNetwork,
    team,
    guild,
    militaryUnit,
    religion,
    nobleHouse,
  ];

  static ChatPromptSetRegistry registry({
    Iterable<ChatPromptSet> additionalDefinitions = const [],
  }) =>
      ChatPromptSetRegistry([...definitions, ...additionalDefinitions]);
}

/// What has happened to one answered prompt.
enum ChatAnswerDisposition {
  /// Answered, not yet dispatched — the author has not chosen yet.
  pending,

  /// Written to the prompt's target field on the interviewed record.
  savedToField,

  /// Turned into a typed link from the interviewed record.
  savedAsLink,

  /// Deliberately kept as a session response only. Never discarded.
  keptAsResponse,
}

class ChatPromptResponse {
  const ChatPromptResponse({
    required this.promptId,
    required this.answer,
    required this.answeredAt,
    this.disposition = ChatAnswerDisposition.pending,
    this.targetFieldId,
    this.linkId,
    this.targetRecordId,
  });

  final String promptId;
  final String answer;
  final DateTime answeredAt;
  final ChatAnswerDisposition disposition;

  /// Provenance for a field save: which field received the value.
  final String? targetFieldId;

  /// Provenance for a link save: the created link and its far end.
  final String? linkId;
  final String? targetRecordId;

  ChatPromptResponse copyWith({
    String? answer,
    DateTime? answeredAt,
    ChatAnswerDisposition? disposition,
    String? targetFieldId,
    String? linkId,
    String? targetRecordId,
  }) =>
      ChatPromptResponse(
        promptId: promptId,
        answer: answer ?? this.answer,
        answeredAt: answeredAt ?? this.answeredAt,
        disposition: disposition ?? this.disposition,
        targetFieldId: targetFieldId ?? this.targetFieldId,
        linkId: linkId ?? this.linkId,
        targetRecordId: targetRecordId ?? this.targetRecordId,
      );

  Map<String, Object?> toJson() => {
        'promptId': promptId,
        'answer': answer,
        'answeredAt': answeredAt.toUtc().toIso8601String(),
        'disposition': disposition.name,
        if (targetFieldId != null) 'targetFieldId': targetFieldId,
        if (linkId != null) 'linkId': linkId,
        if (targetRecordId != null) 'targetRecordId': targetRecordId,
      };

  factory ChatPromptResponse.fromJson(Map<String, dynamic> json) =>
      ChatPromptResponse(
        promptId: json['promptId'] as String,
        answer: json['answer'] as String? ?? '',
        answeredAt: DateTime.parse(json['answeredAt'] as String? ?? '').toUtc(),
        disposition: ChatAnswerDisposition.values.firstWhere(
          (value) => value.name == json['disposition'],
          orElse: () => ChatAnswerDisposition.pending,
        ),
        targetFieldId: json['targetFieldId'] as String?,
        linkId: json['linkId'] as String?,
        targetRecordId: json['targetRecordId'] as String?,
      );
}

/// One interview's state, as stored on its session record's fields.
///
/// The codec is deliberately dumb: fields in, fields out, nothing derived.
/// The session record is provenance — nothing reads an accepted answer back
/// from here as the value; the interviewed record's field or link is the
/// only authority.
class ChatSessionState {
  const ChatSessionState({
    required this.recordId,
    required this.promptSetId,
    required this.promptSetVersion,
    this.responses = const [],
  });

  final String recordId;
  final String promptSetId;
  final int promptSetVersion;
  final List<ChatPromptResponse> responses;

  ChatPromptResponse? responseFor(String promptId) {
    for (final response in responses) {
      if (response.promptId == promptId) return response;
    }
    return null;
  }

  /// This state with [response] added, replacing any response to the same
  /// prompt. Order of first answering is preserved.
  ChatSessionState withResponse(ChatPromptResponse response) {
    final next = [...responses];
    final index = next.indexWhere((item) => item.promptId == response.promptId);
    if (index >= 0) {
      next[index] = response;
    } else {
      next.add(response);
    }
    return ChatSessionState(
      recordId: recordId,
      promptSetId: promptSetId,
      promptSetVersion: promptSetVersion,
      responses: next,
    );
  }

  Map<String, Object?> toFields() => {
        'canonicalRecordId': recordId,
        'promptSetId': promptSetId,
        'promptSetVersion': promptSetVersion,
        'responses': responses.map((response) => response.toJson()).toList(),
      };

  factory ChatSessionState.fromRecord(AuthorRecord record) {
    if (record.typeId != kCharacterChatSessionTypeId) {
      throw StateError('${record.id} is not a character chat session.');
    }
    final rawResponses = record.fields['responses'];
    return ChatSessionState(
      recordId: record.fields['canonicalRecordId'] as String? ?? '',
      promptSetId: record.fields['promptSetId'] as String? ?? '',
      promptSetVersion:
          (record.fields['promptSetVersion'] as num?)?.toInt() ?? 1,
      responses: [
        if (rawResponses is List)
          for (final entry in rawResponses)
            if (entry is Map)
              ChatPromptResponse.fromJson(Map<String, dynamic>.from(entry)),
      ],
    );
  }
}

class CharacterChatRecordTypes {
  const CharacterChatRecordTypes._();

  /// The session record type.
  ///
  /// Follows the `entity-state` precedent: a record that annotates another
  /// record through a required `canonicalRecordId` reference, registered as
  /// a built-in so [RecordService] validates every write, and never offered
  /// as a creation template — a session exists because an interview started,
  /// not because an author picked it from a list.
  static const RecordTypeDefinition session = RecordTypeDefinition(
    id: kCharacterChatSessionTypeId,
    name: 'Character Chat Session',
    description:
        'One Character Chat interview: its prompts, answers, and where each '
        'accepted answer went.',
    icon: 'forum',
    // Not 'characters': a session is a note about a character, not one.
    // See [characterNotesCategoryId].
    categoryId: characterNotesCategoryId,
    baseTypeId: 'general-lore',
    fields: [
      RecordFieldDefinition(
        id: 'canonicalRecordId',
        label: 'Interviewed record',
        type: RecordFieldType.recordReference,
        order: 100,
        required: true,
        // A session interviews whatever record type its prompt set is
        // written for — characters, and any group shape derived from
        // faction. The list mirrors the built-in prompt-set targets.
        referenceTypeIds: [
          'character',
          'faction',
          'organisation',
          'house',
          'clan',
          'guild',
          'company',
          'military-unit',
        ],
      ),
      RecordFieldDefinition(
        id: 'promptSetId',
        label: 'Prompt set',
        type: RecordFieldType.shortText,
        order: 101,
        required: true,
      ),
      RecordFieldDefinition(
        id: 'promptSetVersion',
        label: 'Prompt set version',
        type: RecordFieldType.number,
        order: 102,
      ),
      RecordFieldDefinition(
        id: 'responses',
        label: 'Responses',
        type: RecordFieldType.table,
        order: 103,
      ),
    ],
    sections: [
      RecordTemplateSection(
        id: 'interview',
        title: 'Interview',
        order: 10,
        fieldIds: [
          'canonicalRecordId',
          'promptSetId',
          'promptSetVersion',
          'responses',
        ],
      ),
    ],
    builtIn: true,
    sourcePackId: 'authoros-character-core',
    permissions: {'editableDefinition': false},
    exportBehavior: {'includeStructuredFields': true},
    extensionData: {'characterChat': true},
  );
}
