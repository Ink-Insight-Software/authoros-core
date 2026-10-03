/// One conversation with a character, kept.
///
/// Character Chat interviews a record and persists the interview as an
/// [AuthorRecord]; `character_interrogation.dart` is the other direction — the
/// author asks and the character answers from its own canon — and until now
/// that direction kept nothing. `talk_view.dart` held its turns in a private
/// field on a `State`, so closing the room dropped them.
///
/// This is the same shape as [ChatSessionState], for the other direction, and
/// it copies it deliberately rather than inventing a second one. A session is
/// an [AuthorRecord] like everything else (Lock 1): it rides archive, export,
/// versioning, sync and audit with no store of its own.
///
/// ## What a turn stores, and what it must not
///
/// This is the whole design, and it is a Lock 1 question rather than a schema
/// one. [InterrogationAnswer] carries a `value` — the character's answer — and
/// a `framing`, the authored sentence around it. **Neither is stored here.**
///
///  * **`value` is canon.** It is a field on the character record, repeated
///    verbatim. Copying it onto a session would be a second copy of the
///    author's own words, going stale the moment they edit the field.
///    [ChatSessionState] states the rule: *the session record is provenance —
///    nothing reads an accepted answer back from here as the value; the
///    interviewed record's field is the only authority.*
///  * **`framing` is authored and reproducible.** It comes from
///    `BuiltInSpokenLines` under a recorded [libraryVersion], so it can be
///    produced again rather than kept.
///
/// What is stored is what cannot be recovered: what the author typed, which
/// topic was asked, what kind of answer came back, which field answered it,
/// which manuscript nodes were cited, and when.
///
/// **The consequence is deliberate.** Reopening an old session shows *today's*
/// canon under yesterday's question. If the author has since changed what a
/// character is afraid of, the old turn says the new thing. That is the honest
/// reading — the alternative is a stored session asserting a fact the project
/// no longer holds — and it is the trade the interview direction already made.
///
/// Everything here is plain Dart: no Flutter, no persistence, no clock. The
/// service layer owns the writes.
library;

import 'character_interrogation.dart';
import 'connected_domain.dart';
import 'record_types.dart';
import 'story_vocabulary.dart';

/// The id of the record type an interrogation session persists as.
const String kInterrogationSessionTypeId = 'interrogation-session';

/// Who spoke.
enum InterrogationSpeaker {
  /// The author asked, told, affirmed or denied.
  author,

  /// The character answered, or said it could not.
  character,
}

/// One turn of one conversation, as provenance.
class InterrogationTurn {
  const InterrogationTurn({
    required this.speaker,
    required this.at,
    this.text = '',
    this.topicId,
    this.kind,
    this.counterMove,
    this.sourceFieldId,
    this.citationNodeIds = const [],
  });

  final InterrogationSpeaker speaker;

  /// When the turn happened, in UTC.
  final DateTime at;

  /// What the author typed, verbatim, and empty on a character turn.
  ///
  /// The author's own words, so they are kept. A character's words are not,
  /// for the reason the library comment gives: they are either canon that
  /// lives on the record or an authored line that can be produced again.
  final String text;

  /// The topic the turn was about, when the matcher resolved one.
  final String? topicId;

  /// What kind of answer came back, when this is a character turn.
  final ChatAnswerKind? kind;

  /// The move the character made when the canon did not answer.
  final ChatCounterMove? counterMove;

  /// The field that answered, for a [ChatAnswerKind.canon] turn.
  ///
  /// The field id rather than its value: which field spoke is provenance, and
  /// what it said is canon that lives on the record.
  final String? sourceFieldId;

  /// The manuscript nodes the turn cited, by id.
  final List<String> citationNodeIds;

  Map<String, Object?> toJson() => {
        'speaker': speaker.name,
        'at': at.toUtc().toIso8601String(),
        if (text.isNotEmpty) 'text': text,
        if (topicId != null) 'topicId': topicId,
        if (kind != null) 'kind': kind!.name,
        if (counterMove != null) 'counterMove': counterMove!.name,
        if (sourceFieldId != null) 'sourceFieldId': sourceFieldId,
        if (citationNodeIds.isNotEmpty) 'citationNodeIds': citationNodeIds,
      };

  /// Reads a turn back.
  ///
  /// Unknown enum names resolve to null rather than throwing, for the reason
  /// `PaidProduct.byId` gives about unknown products: a session written by a
  /// newer build is not a corrupt one, and a turn whose kind this build has
  /// never heard of is still a turn that happened.
  factory InterrogationTurn.fromJson(Map<String, dynamic> json) =>
      InterrogationTurn(
        speaker: InterrogationSpeaker.values.firstWhere(
          (value) => value.name == json['speaker'],
          orElse: () => InterrogationSpeaker.character,
        ),
        at: DateTime.tryParse(json['at'] as String? ?? '')?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        text: json['text'] as String? ?? '',
        topicId: json['topicId'] as String?,
        kind: _byName(ChatAnswerKind.values, json['kind']),
        counterMove: _byName(ChatCounterMove.values, json['counterMove']),
        sourceFieldId: json['sourceFieldId'] as String?,
        citationNodeIds: [
          for (final entry in (json['citationNodeIds'] as List? ?? const []))
            if (entry is String) entry,
        ],
      );
}

T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

/// One conversation's state, as stored on its session record's fields.
///
/// The codec is deliberately dumb: fields in, fields out, nothing derived —
/// the same posture [ChatSessionState] takes.
class InterrogationSessionState {
  const InterrogationSessionState({
    required this.recordId,
    this.libraryVersion = kInterrogationLibraryVersion,
    this.openedBy,
    this.openedAtNodeId,
    this.turns = const [],
  });

  /// The character this conversation was with.
  final String recordId;

  /// The version of the topic and line libraries the exchange ran under.
  ///
  /// Recorded so an exchange can be read back knowing which vocabulary
  /// produced it — the reproducibility posture `ChatPromptSet` already has,
  /// and which [kInterrogationLibraryVersion]'s own comment anticipated.
  final int libraryVersion;

  /// How the author got here — the name of the intent they chose.
  ///
  /// A string rather than an enum, and deliberately. The six ways in are
  /// `CompanionIntent`, which lives in a widget file, and Lock 12 fixes the
  /// dependency direction: core does not import the UI. The caller supplies
  /// the name, exactly as it supplies `promptSetId` on the other direction.
  ///
  /// This is the field the Creative Fit work reads: *which way in preceded a
  /// session after which the author wrote.*
  final String? openedBy;

  /// The manuscript node the author was on when the conversation opened.
  final String? openedAtNodeId;

  /// The turns, in the order they happened.
  final List<InterrogationTurn> turns;

  /// This state with [turn] appended.
  ///
  /// Append only. A conversation is a thing that happened, and editing a turn
  /// after the fact would make the record a draft of the past rather than a
  /// record of it. An author who wants a conversation gone deletes the
  /// session, which is a different act and says so.
  InterrogationSessionState withTurn(InterrogationTurn turn) =>
      InterrogationSessionState(
        recordId: recordId,
        libraryVersion: libraryVersion,
        openedBy: openedBy,
        openedAtNodeId: openedAtNodeId,
        turns: [...turns, turn],
      );

  /// Every topic this conversation reached, in the order it reached them.
  ///
  /// Derived rather than stored: it is a read of [turns], and storing it would
  /// be a second copy that could disagree with them.
  List<String> get topicsReached {
    final seen = <String>{};
    final reached = <String>[];
    for (final turn in turns) {
      final topicId = turn.topicId;
      if (topicId != null && seen.add(topicId)) reached.add(topicId);
    }
    return reached;
  }

  Map<String, Object?> toFields() => {
        'canonicalRecordId': recordId,
        'libraryVersion': libraryVersion,
        if (openedBy != null) 'openedBy': openedBy,
        if (openedAtNodeId != null) 'openedAtNodeId': openedAtNodeId,
        'turns': turns.map((turn) => turn.toJson()).toList(),
      };

  factory InterrogationSessionState.fromRecord(AuthorRecord record) {
    if (record.typeId != kInterrogationSessionTypeId) {
      throw StateError('${record.id} is not an interrogation session.');
    }
    final rawTurns = record.fields['turns'];
    return InterrogationSessionState(
      recordId: record.fields['canonicalRecordId'] as String? ?? '',
      libraryVersion: (record.fields['libraryVersion'] as num?)?.toInt() ??
          kInterrogationLibraryVersion,
      openedBy: record.fields['openedBy'] as String?,
      openedAtNodeId: record.fields['openedAtNodeId'] as String?,
      turns: [
        if (rawTurns is List)
          for (final entry in rawTurns)
            if (entry is Map)
              InterrogationTurn.fromJson(Map<String, dynamic>.from(entry)),
      ],
    );
  }
}

/// The session record type.
class InterrogationRecordTypes {
  const InterrogationRecordTypes._();

  /// Follows `character-chat-session` exactly: a record that annotates another
  /// record through a required `canonicalRecordId` reference, registered as a
  /// built-in so [RecordService] validates every write, and never offered as a
  /// creation template — a session exists because a conversation happened, not
  /// because an author picked it from a list.
  static const RecordTypeDefinition session = RecordTypeDefinition(
    id: kInterrogationSessionTypeId,
    name: 'Character Conversation',
    description:
        'One conversation with a character: what was asked, what kind of '
        'answer came back, and where it came from.',
    icon: 'forum',
    // Not 'characters': a session is a note about a character, not one.
    // See [characterNotesCategoryId].
    categoryId: characterNotesCategoryId,
    baseTypeId: 'general-lore',
    fields: [
      RecordFieldDefinition(
        id: 'canonicalRecordId',
        label: 'Character',
        type: RecordFieldType.recordReference,
        order: 100,
        required: true,
        // Narrower than the interview's list on purpose: the interrogation
        // engine answers from a character's own fields, and the group shapes
        // an interview can reach have no equivalent. A location or faction
        // conversation is Stage 2 and will widen this when it exists.
        referenceTypeIds: ['character'],
      ),
      RecordFieldDefinition(
        id: 'libraryVersion',
        label: 'Library version',
        type: RecordFieldType.number,
        order: 101,
      ),
      RecordFieldDefinition(
        id: 'openedBy',
        label: 'Opened by',
        type: RecordFieldType.shortText,
        order: 102,
      ),
      RecordFieldDefinition(
        id: 'openedAtNodeId',
        label: 'Opened at',
        type: RecordFieldType.shortText,
        order: 103,
      ),
      RecordFieldDefinition(
        id: 'turns',
        label: 'Turns',
        type: RecordFieldType.table,
        order: 104,
      ),
    ],
    sections: [
      RecordTemplateSection(
        id: 'conversation',
        title: 'Conversation',
        order: 10,
        fieldIds: [
          'canonicalRecordId',
          'libraryVersion',
          'openedBy',
          'openedAtNodeId',
          'turns',
        ],
      ),
    ],
    builtIn: true,
    sourcePackId: 'authoros-character-core',
    permissions: {'editableDefinition': false},
    exportBehavior: {'includeStructuredFields': true},
    extensionData: {'interrogation': true},
  );
}
