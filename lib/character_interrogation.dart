// Character Interrogation — the other direction of Character Chat.
//
// Phase 1 and 2 built an interview: the app asks, the author answers, and
// accepted answers land on the canonical record. This is the reverse. The
// author asks; the character answers from its own canonical data, cites where
// the answer came from, and when the canon holds nothing it says so in its own
// voice and turns the question back — which is how the interview and the
// conversation become one loop.
//
// Nothing here is generated. An answer is a field value the author wrote,
// repeated verbatim. A counter-question is a static, versioned line with one
// slot for a noun the author themselves just typed. The library below is the
// questionnaire's mirror image, and it is authored the same way.
//
// Everything is plain Dart: no Flutter, no persistence, no clock. Resolution
// that needs links or scenes lives in the service layer; what is here is the
// vocabulary and the pure matching over it.

import 'record_types.dart';

/// Recorded on a session so an exchange replays identically after the library
/// itself evolves — the same reproducibility posture as [ChatPromptSet].
const int kInterrogationLibraryVersion = 1;

/// What the author's message is doing.
///
/// Façade's lesson (Mateas & Stern 2004): do not parse to meaning, parse to a
/// small set of discourse acts. Six covers this domain, because the domain is
/// one character's traits rather than open conversation.
enum ChatDiscourseAct {
  /// "are you afraid of spiders" — a question about a topic.
  askAbout,

  /// "yes", "that's right" — confirming what the character just proposed.
  affirm,

  /// "no", "not really" — denying it. A denial is a fact, not an absence.
  deny,

  /// "you're afraid of heights" — asserting a value directly.
  tell,

  /// The rules could not read it. Never a guess; always a repair sequence.
  unrecognised,
}

/// Where an answer came from, which decides how the turn is drawn.
///
/// The rungs of the response ladder. Rungs 3 (graph inference) and 4 (adjacent
/// fallback) arrive in a later phase; the enum names them now so the codec and
/// the UI switch do not change shape when they do.
enum ChatAnswerKind {
  /// A field on the record holds it.
  canon,

  /// The manuscript holds it — scenes the character appears in.
  manuscript,

  /// Nothing holds it. The character asks back.
  unknown,

  /// The question itself could not be read.
  unrecognised,
}

/// The rhetorical shape of a counter-question.
///
/// Variety by topic kind, not one catch-all deflection: what a character says
/// when it does not know its favourite food should not be what it says when it
/// does not know its own core wound.
enum ChatCounterMove {
  /// Mirror the question back. "Should I be?"
  reflect,

  /// Invite the author to characterise. "What would someone like me eat?"
  inviteFrame,

  /// Propose from a small answer space. "Winter, I think. Or am I summer?"
  offerOptions,

  /// Answer what the manuscript holds, then mark the edge.
  citeThenFlag,

  /// Hand the question upward. "You'd know better than me."
  deferUpward,

  /// Offer something in return for a deep answer.
  trade,
}

/// One thing the character can be asked about.
///
/// A topic is not a field. It is a question with a *chain* of fields that
/// might answer it, because the character type carries two parallel id schemes
/// — the canonical one in `character_record_types.dart` and an older one still
/// written by `character_studio.dart`. A topic that resolved a single id would
/// have the character claim ignorance about something the author filled in
/// years ago.
class ChatTopic {
  const ChatTopic({
    required this.id,
    required this.question,
    required this.sectionId,
    this.fieldIds = const [],
    this.legacyFieldIds = const [],
    this.synonyms = const [],
    this.depth = 1,
    this.move = ChatCounterMove.reflect,
    this.readsManuscript = false,
  }) : assert(depth >= 1 && depth <= 5, 'Intimacy runs 1 to 5.');

  final String id;

  /// The canonical phrasing, shown as a suggested chip.
  final String question;

  /// Canonical field ids, in preference order. **Guard-validated** — a topic
  /// naming a field the registry does not have fails CI rather than failing an
  /// author.
  final List<String> fieldIds;

  /// Older field ids for the same idea, read after [fieldIds] and deliberately
  /// *not* validated: they belong to a scheme the registry never held, so a
  /// guard over them would fail on ids that are correct for real records.
  final List<String> legacyFieldIds;

  /// Words that route a typed question here. Matched whole-word, never fuzzy.
  final List<String> synonyms;

  /// Which section this belongs to — drives the mood lookup in the UI.
  final String sectionId;

  /// Intimacy, 1 to 5 (Altman & Taylor). Favourite food is 1; the core wound
  /// is 5. Depth unlocks as breadth accumulates, so the character earns its
  /// way inward rather than interrogating a stranger about their trauma.
  final int depth;

  /// The counter-question shape used when nothing answers this.
  final ChatCounterMove move;

  /// Whether the manuscript can answer this when no field does.
  final bool readsManuscript;

  /// Every field id this topic will read, canonical first.
  List<String> get allFieldIds => [...fieldIds, ...legacyFieldIds];
}

/// A named collection of topics for one record type.
class ChatTopicSet {
  const ChatTopicSet({
    required this.id,
    required this.title,
    required this.recordTypeId,
    required this.topics,
    this.description = '',
    this.version = kInterrogationLibraryVersion,
  });

  final String id;
  final String title;
  final String description;
  final String recordTypeId;
  final List<ChatTopic> topics;
  final int version;

  ChatTopic? topic(String id) {
    for (final topic in topics) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  /// Topics at or below [depth], which is what rapport gates.
  List<ChatTopic> upToDepth(int depth) =>
      topics.where((topic) => topic.depth <= depth).toList();

  /// The next rung down [topic]'s own section, or null at the bottom of it.
  ///
  /// This is what "go deeper" means here: not a cleverer answer to the same
  /// question, but the next question inward on the same subject. A lookup over
  /// authored structure — the depths are the social-penetration ladder the set
  /// already declares — so nothing is inferred and the same topic always leads
  /// to the same place.
  ///
  /// Returns the *shallowest* topic strictly deeper than [topic] in the same
  /// section, so the ladder is climbed a rung at a time rather than jumping to
  /// the bottom. Ties break on the set's own order.
  ///
  /// Null is a real answer and the surface renders it as the absence of the
  /// move. A section with one rung — `manuscript`, whose topics read the graph
  /// rather than a field — has nowhere deeper to go, and saying so is better
  /// than inventing a rung that asks the same question twice.
  ChatTopic? deeperThan(ChatTopic topic) {
    ChatTopic? best;
    for (final candidate in topics) {
      if (candidate.sectionId != topic.sectionId) continue;
      if (candidate.depth <= topic.depth) continue;
      if (best == null || candidate.depth < best.depth) best = candidate;
    }
    return best;
  }
}

/// Topic sets available to a project.
///
/// Same shape as [ChatPromptSetRegistry]: built-ins plus project-scoped
/// additions resolved by id, so author-defined sets need no model change.
class ChatTopicRegistry {
  ChatTopicRegistry(Iterable<ChatTopicSet> sets)
      : _sets = {for (final set in sets) set.id: set};

  final Map<String, ChatTopicSet> _sets;

  List<ChatTopicSet> get all => _sets.values.toList();

  List<ChatTopicSet> setsFor(String recordTypeId) =>
      all.where((set) => set.recordTypeId == recordTypeId).toList();

  ChatTopicSet resolve(String id) {
    final set = _sets[id];
    if (set == null) {
      throw StateError('Unknown chat topic set: $id.');
    }
    return set;
  }
}

class BuiltInChatTopics {
  const BuiltInChatTopics._();

  /// The character interrogation set.
  ///
  /// Field chains are canonical-first with the `character_studio.dart` legacy
  /// ids behind them. Depths follow social penetration: appearance and habits
  /// are surface, the wound and the secret are the centre of the onion.
  ///
  /// ## Every section is a ladder, because "go deeper" walks one
  ///
  /// [ChatTopicSet.deeperThan] steps from a topic to the next rung *in the same
  /// section*, so a section with a single rung has no depth to offer. Each of
  /// `appearance`, `voice`, `goals`, `backstory`, `personality` and
  /// `psychology` therefore carries at least three rungs at increasing depth.
  ///
  /// `manuscript` is the deliberate exception and has exactly one. Its topics
  /// answer from `appearsIn` / `mentionedIn` links rather than from fields, so
  /// a second rung would read the same links and return the same citations in
  /// different words — padding that looks like depth. It gains real rungs when
  /// the graph does, and not before.
  ///
  /// Topics are ordered by depth. `gapsFor` returns them in this order, so the
  /// suggestions an author is offered run surface-first, and the matcher breaks
  /// score ties on it too.
  static const ChatTopicSet characterCore = ChatTopicSet(
    id: 'character-core',
    title: 'Talk to them',
    description: 'Ask a character about itself. It answers from what you '
        'have written, and tells you when you have not written it.',
    recordTypeId: 'character',
    topics: [
      ChatTopic(
        id: 'appearance',
        question: 'What do you look like?',
        synonyms: ['look', 'looks', 'appearance', 'appear', 'face'],
        fieldIds: ['appearance.physicalPresence', 'appearance.distinguishingFeatures'],
        sectionId: 'appearance',
        depth: 1,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'habit',
        question: 'What do you do with yourself?',
        synonyms: ['habit', 'habits', 'quirk', 'quirks', 'hobby', 'hobbies',
            'spare', 'pastime'],
        fieldIds: ['personality.habits', 'personality.quirks'],
        sectionId: 'personality',
        depth: 1,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'whereabouts',
        question: 'Where have you been lately?',
        synonyms: ['where', 'been', 'lately', 'recently', 'seen'],
        sectionId: 'manuscript',
        depth: 1,
        move: ChatCounterMove.citeThenFlag,
        readsManuscript: true,
      ),
      ChatTopic(
        id: 'catchphrase',
        question: 'Do you say anything twice?',
        synonyms: ['catchphrase', 'catchphrases', 'saying', 'sayings',
            'phrase', 'repeat'],
        fieldIds: ['voice.catchphrases', 'voice.favouriteWords'],
        sectionId: 'voice',
        depth: 1,
        move: ChatCounterMove.offerOptions,
      ),
      ChatTopic(
        id: 'humour',
        question: 'What makes you laugh?',
        synonyms: ['laugh', 'funny', 'humour', 'humor', 'joke', 'jokes'],
        fieldIds: ['personality.senseOfHumour'],
        sectionId: 'personality',
        depth: 2,
        move: ChatCounterMove.offerOptions,
      ),
      ChatTopic(
        id: 'voice',
        question: 'How do you talk?',
        synonyms: ['talk', 'speak', 'voice', 'accent', 'sound'],
        fieldIds: ['voice.speechStyle', 'voice.dialogueExamples', 'appearance.voice'],
        legacyFieldIds: ['voice.verbalHabits'],
        sectionId: 'voice',
        depth: 2,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'dress',
        question: 'What do you wear?',
        synonyms: ['wear', 'wears', 'wearing', 'clothes', 'clothing', 'dress',
            'dressed', 'outfit'],
        fieldIds: ['appearance.typicalClothing', 'appearance.accessories'],
        sectionId: 'appearance',
        depth: 2,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'obstacle',
        question: 'What is in your way?',
        synonyms: ['obstacle', 'obstacles', 'stopping', 'blocking', 'stands',
            'prevents'],
        fieldIds: ['goals.obstacles'],
        sectionId: 'goals',
        depth: 2,
        move: ChatCounterMove.reflect,
      ),
      ChatTopic(
        id: 'family',
        question: 'Who raised you?',
        synonyms: ['family', 'parents', 'parent', 'mother', 'father',
            'siblings', 'brother', 'sister'],
        fieldIds: ['backstory.family'],
        sectionId: 'backstory',
        depth: 2,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'belief',
        question: 'What do you believe?',
        synonyms: ['believe', 'belief', 'beliefs', 'faith', 'creed'],
        fieldIds: ['psychology.coreBelief', 'personality.beliefs'],
        legacyFieldIds: ['psychology.misbeliefs'],
        sectionId: 'psychology',
        depth: 3,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'flaw',
        question: 'What is wrong with you?',
        synonyms: ['flaw', 'flaws', 'weakness', 'weaknesses', 'fault', 'worst'],
        fieldIds: ['personality.flaws', 'personality.weaknesses'],
        sectionId: 'personality',
        depth: 3,
        move: ChatCounterMove.reflect,
      ),
      ChatTopic(
        id: 'want',
        question: 'What do you want?',
        synonyms: ['want', 'wants', 'after', 'goal', 'goals', 'chasing'],
        fieldIds: ['psychology.externalWant', 'goals.primaryGoal'],
        legacyFieldIds: ['psychology.wants'],
        sectionId: 'goals',
        depth: 3,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'marks',
        question: 'What has your body been through?',
        synonyms: ['scar', 'scars', 'tattoo', 'tattoos', 'marks', 'body',
            'injured'],
        fieldIds: [
          'appearance.scars',
          'appearance.limitations',
          'appearance.tattoos',
        ],
        sectionId: 'appearance',
        depth: 3,
        move: ChatCounterMove.reflect,
      ),
      ChatTopic(
        id: 'turningPoint',
        question: 'What changed everything?',
        synonyms: ['changed', 'turning', 'moment', 'event', 'events'],
        fieldIds: ['backstory.turningPoints', 'backstory.majorLifeEvents'],
        sectionId: 'backstory',
        depth: 3,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'fear',
        question: 'What are you afraid of?',
        synonyms: ['afraid', 'fear', 'fears', 'scared', 'terrified',
            'frightened', 'dread'],
        fieldIds: ['psychology.fear', 'personality.fears'],
        sectionId: 'psychology',
        depth: 4,
        move: ChatCounterMove.reflect,
      ),
      ChatTopic(
        id: 'trust',
        question: 'Who do you trust?',
        synonyms: ['trust', 'trusts', 'rely', 'depend'],
        fieldIds: ['personality.trustStyle', 'personality.attachmentStyle'],
        sectionId: 'personality',
        depth: 4,
        move: ChatCounterMove.reflect,
      ),
      ChatTopic(
        id: 'need',
        question: 'What do you actually need?',
        synonyms: ['need', 'needs', 'missing', 'lack'],
        fieldIds: ['psychology.internalNeed', 'psychology.emotionalNeeds'],
        legacyFieldIds: ['psychology.needs'],
        sectionId: 'psychology',
        depth: 4,
        move: ChatCounterMove.inviteFrame,
      ),
      ChatTopic(
        id: 'childhood',
        question: 'What was your childhood like?',
        synonyms: ['childhood', 'child', 'young', 'grew', 'growing', 'raised'],
        fieldIds: ['backstory.childhood', 'backstory.earlyExperiences'],
        legacyFieldIds: ['history.childhood'],
        sectionId: 'backstory',
        depth: 4,
        move: ChatCounterMove.citeThenFlag,
      ),
      ChatTopic(
        id: 'innerVoice',
        question: 'What do you sound like when nobody is listening?',
        synonyms: ['inner', 'head', 'thinking', 'thoughts', 'alone',
            'private'],
        fieldIds: ['voice.internalVoice', 'voice.emotionalVoice'],
        sectionId: 'voice',
        depth: 4,
        move: ChatCounterMove.reflect,
      ),
      ChatTopic(
        id: 'motivation',
        question: 'Why does it matter to you?',
        // Deliberately not 'why'. It is the natural synonym and it is too
        // common: one stray "why do you hide?" would score a tie with the
        // secret topic and win it on set order, routing the author somewhere
        // they did not ask to go.
        synonyms: ['matter', 'matters', 'motivation', 'motivates', 'reason',
            'reasons', 'stakes'],
        fieldIds: ['goals.motivation', 'goals.stakes'],
        sectionId: 'goals',
        depth: 4,
        move: ChatCounterMove.deferUpward,
      ),
      ChatTopic(
        id: 'secret',
        question: 'What are you hiding?',
        synonyms: ['secret', 'secrets', 'hiding', 'hide', 'conceal'],
        fieldIds: ['psychology.secrets', 'backstory.secrets'],
        sectionId: 'psychology',
        depth: 5,
        move: ChatCounterMove.trade,
      ),
      ChatTopic(
        id: 'wound',
        question: 'What happened to you?',
        synonyms: ['wound', 'hurt', 'broke', 'broken', 'shame', 'happened'],
        fieldIds: ['psychology.coreWound', 'psychology.shame'],
        legacyFieldIds: ['psychology.emotionalWounds'],
        sectionId: 'psychology',
        depth: 5,
        move: ChatCounterMove.trade,
      ),
      ChatTopic(
        id: 'regret',
        question: 'What do you wish you had not done?',
        synonyms: ['regret', 'regrets', 'mistake', 'mistakes', 'wish', 'lost',
            'loss'],
        fieldIds: ['backstory.majorMistakes', 'backstory.importantLosses'],
        sectionId: 'backstory',
        depth: 5,
        move: ChatCounterMove.trade,
      ),
    ],
  );

  static const List<ChatTopicSet> definitions = [characterCore];

  static ChatTopicRegistry registry({
    Iterable<ChatTopicSet> additionalDefinitions = const [],
  }) =>
      ChatTopicRegistry([...definitions, ...additionalDefinitions]);
}

// ---------------------------------------------------------------------------
// Reading what the author typed
// ---------------------------------------------------------------------------

/// What the rules made of one message.
///
/// [understood] is the honest part: the terms the matcher actually used, which
/// the UI shows back as chips. A rule-based reader that cannot show its working
/// is indistinguishable from one that guessed.
class ChatQuestionMatch {
  const ChatQuestionMatch({
    required this.act,
    this.topic,
    this.subject,
    this.understood = const [],
  });

  final ChatDiscourseAct act;

  /// The topic the question routed to, when [act] is [ChatDiscourseAct.askAbout].
  final ChatTopic? topic;

  /// The noun that sat in the frame's object slot, echoed verbatim.
  ///
  /// The character never needs to know what a spider *is* — only that
  /// "spiders" was the object, so it can hand it straight back as
  /// "Should I be?". Comprehension is not required and is never attempted.
  final String? subject;

  final List<String> understood;

  static const ChatQuestionMatch none =
      ChatQuestionMatch(act: ChatDiscourseAct.unrecognised);
}

/// Reads a message into a [ChatQuestionMatch].
///
/// Exact, case-insensitive, whole-word matching over a vocabulary the topic set
/// carries — the discipline `entity_recognition.dart` uses for names and
/// `command_grammar.dart` uses for commands. No stemming, no fuzzy matching, no
/// scoring against a threshold. A message the rules cannot read becomes
/// [ChatDiscourseAct.unrecognised] rather than being rounded to the nearest
/// topic, because a wrong answer costs the author far more than no answer.
///
/// Parsing never throws.
class ChatTopicMatcher {
  const ChatTopicMatcher(this.set);

  final ChatTopicSet set;

  static const _affirmations = <String>[
    'yes', 'yeah', 'yep', 'yup', 'correct', 'right', 'true', 'exactly',
    'definitely', 'sure',
  ];

  static const _denials = <String>[
    'no', 'nope', 'nah', 'never', 'wrong', 'false', 'not',
  ];

  /// Prepositions that introduce the object slot: everything after the last one
  /// is the subject the character echoes.
  static const _slotMarkers = <String>['of', 'about', 'at', 'with', 'for'];

  ChatQuestionMatch match(String input) {
    final words = _words(input);
    if (words.isEmpty) return ChatQuestionMatch.none;

    // A bare yes or no answers whatever was just proposed. Checked first, and
    // only when the message is short: "no one knows what I want" is not a
    // denial, and treating it as one would silently write the wrong canon.
    if (words.length <= 4) {
      for (final word in words) {
        if (_affirmations.contains(word)) {
          return ChatQuestionMatch(
              act: ChatDiscourseAct.affirm, understood: [word]);
        }
        if (_denials.contains(word)) {
          return ChatQuestionMatch(
              act: ChatDiscourseAct.deny, understood: [word]);
        }
      }
    }

    ChatTopic? best;
    var bestScore = 0;
    var bestTerms = const <String>[];
    for (final topic in set.topics) {
      final hits = topic.synonyms.where(words.contains).toList();
      // Ties go to the earlier topic in the set, which makes the parse a pure
      // function of the library's order rather than of map iteration.
      if (hits.length > bestScore) {
        best = topic;
        bestScore = hits.length;
        bestTerms = hits;
      }
    }

    if (best == null) return ChatQuestionMatch.none;

    return ChatQuestionMatch(
      act: ChatDiscourseAct.askAbout,
      topic: best,
      subject: _subject(words),
      understood: bestTerms,
    );
  }

  /// The words after the last slot marker, rejoined.
  ///
  /// "are you afraid of the dark" gives "the dark". Nothing is looked up and
  /// nothing is validated — the value exists only to be echoed.
  String? _subject(List<String> words) {
    var marker = -1;
    for (var i = 0; i < words.length; i++) {
      if (_slotMarkers.contains(words[i])) marker = i;
    }
    if (marker == -1 || marker == words.length - 1) return null;
    return words.sublist(marker + 1).join(' ');
  }

  static List<String> _words(String input) => input
      .toLowerCase()
      .split(RegExp(r"[^a-z0-9']+"))
      .where((word) => word.isNotEmpty)
      .toList();
}

// ---------------------------------------------------------------------------
// What the character says
// ---------------------------------------------------------------------------

/// A static line the character can speak.
///
/// Two slots, filled from material the author already owns: `{subject}` is the
/// noun they just typed, `{label}` is the name of the field being discussed.
/// Nothing else is substituted, and no line ever carries a fact — the fact is
/// the field value, spoken in its own turn. Keeping the framing and the content
/// apart is what makes this honest, and is why no templating engine is needed.
class ChatSpokenLine {
  const ChatSpokenLine(this.move, this.text);

  final ChatCounterMove move;
  final String text;

  String fill({String? subject, String? label}) => text
      .replaceAll('{subject}', subject ?? 'that')
      .replaceAll('{label}', label ?? 'that');
}

/// The counter-question library.
///
/// Authored, versioned, and covered by a structural guard: every
/// [ChatCounterMove] must have at least one line, so a topic pointing at an
/// unwritten move fails CI rather than leaving a character mute.
///
/// Persona-tagged variants arrive with the persona axes; until then every line
/// is neutral and selection is the first match, which keeps this phase's output
/// perfectly replayable.
class BuiltInSpokenLines {
  const BuiltInSpokenLines._();

  static const List<ChatSpokenLine> counterQuestions = [
    ChatSpokenLine(ChatCounterMove.reflect, 'Should I be?'),
    ChatSpokenLine(ChatCounterMove.reflect, '{subject}? Should I be?'),
    ChatSpokenLine(ChatCounterMove.inviteFrame,
        "I don't know yet. What would someone like me say?"),
    ChatSpokenLine(ChatCounterMove.offerOptions,
        "You haven't decided. Give me something and I'll hold onto it."),
    ChatSpokenLine(ChatCounterMove.citeThenFlag,
        "Nowhere you've written down yet."),
    ChatSpokenLine(ChatCounterMove.deferUpward,
        "You'd know better than me."),
    ChatSpokenLine(ChatCounterMove.trade,
        "That's not a small question. Ask me, and I'll answer it once you've "
        'decided what the answer is.'),
  ];

  /// Phatic brackets. A character that only answers questions is a form with a
  /// face; an opening and a closing cost almost nothing and carry more than
  /// they cost.
  static const List<String> openings = [
    'Back again?',
    'Go on, then.',
  ];

  static const List<String> closings = [
    "That's me, as far as you've written me.",
  ];

  /// The line for [move], or the [ChatCounterMove.deferUpward] fallback.
  ///
  /// Degrades rather than failing: a move with no line yields the neutral
  /// deferral instead of an empty bubble. The guard test makes that path
  /// unreachable for the built-in library, but a project set could reach it.
  static ChatSpokenLine forMove(ChatCounterMove move, {bool withSubject = false}) {
    final candidates =
        counterQuestions.where((line) => line.move == move).toList();
    if (candidates.isEmpty) {
      return counterQuestions
          .firstWhere((line) => line.move == ChatCounterMove.deferUpward);
    }
    if (withSubject) {
      for (final line in candidates) {
        if (line.text.contains('{subject}')) return line;
      }
    }
    for (final line in candidates) {
      if (!line.text.contains('{subject}')) return line;
    }
    return candidates.first;
  }
}

// ---------------------------------------------------------------------------
// The answer
// ---------------------------------------------------------------------------

/// One scene the answer can be traced to.
class ChatCitation {
  const ChatCitation({required this.nodeId, required this.title});

  final String nodeId;
  final String title;
}

/// What the character says back, and everything the UI needs to draw it.
///
/// [value] is never composed — it is the author's own field value, repeated. A
/// turn that has something to say carries both [value] and [framing]; the
/// framing is the character's manner and the value is the canon, and they are
/// rendered as separate things so the author can always tell which is which.
class InterrogationAnswer {
  const InterrogationAnswer({
    required this.kind,
    required this.framing,
    this.topicId,
    this.value,
    this.sourceFieldId,
    this.sourceFieldLabel,
    this.canonStatus,
    this.citations = const [],
    this.understood = const [],
    this.sectionId,
  });

  final ChatAnswerKind kind;

  /// The character's own words around the answer — or, when there is no answer,
  /// the whole turn.
  final String framing;

  final String? topicId;

  /// The canonical value, verbatim. Null unless [kind] is
  /// [ChatAnswerKind.canon].
  final String? value;

  final String? sourceFieldId;
  final String? sourceFieldLabel;

  /// The per-field canon status, for the byline. Typed as a string so this
  /// library stays independent of `canon_facts.dart`'s enum, which the service
  /// layer resolves.
  final String? canonStatus;

  final List<ChatCitation> citations;

  /// The terms the matcher used, shown back to the author.
  final List<String> understood;

  final String? sectionId;

  bool get isAnswered =>
      kind == ChatAnswerKind.canon || kind == ChatAnswerKind.manuscript;

  /// Whether this turn invites the author to fill the topic's field.
  bool get invitesAnswer => kind == ChatAnswerKind.unknown && topicId != null;
}

// ---------------------------------------------------------------------------
// Rendering a stored value as something spoken
// ---------------------------------------------------------------------------

/// How a field value is spoken.
///
/// Lists become their entries; everything else becomes its own string. Nothing
/// is truncated or summarised — the author wrote it, so the character says it.
/// The list case reads through [splitList] so a `list` field that actually
/// holds a comma-separated string still speaks as separate items, which is the
/// shape real records are in.
class ChatValueSpeech {
  const ChatValueSpeech._();

  static String? speak(
    Object? value,
    RecordFieldType? type,
    List<String> Function(Object?) splitList,
  ) {
    if (value == null) return null;
    if (type == RecordFieldType.list ||
        type == RecordFieldType.tags ||
        value is Iterable) {
      final items = splitList(value);
      if (items.isEmpty) return null;
      return items.join('\n');
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is Map) {
      // A table field. Rows are structured and speaking them verbatim would be
      // noise, so this phase reports the count and leaves the detail to the
      // record. Better an honest pointer than an invented sentence.
      return value.isEmpty ? null : null;
    }
    return '$value';
  }
}
