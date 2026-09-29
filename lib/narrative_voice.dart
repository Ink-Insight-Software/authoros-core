/// Who is telling this, about whom, and when.
///
/// Three choices an author makes per chapter and then lives with: the point of
/// view, the character it belongs to, and the tense. AuthorOS keeps them as
/// data rather than as a note to self, because once they are data the
/// manuscript can answer questions about itself — which chapters are Cassian's,
/// whether a book drifts between tenses, whether a scene knows something its
/// POV character could not.
///
/// ## The descriptions are the feature
///
/// Anyone can list five points of view. What makes the choice easier is being
/// told what each one *does to the reader* at the moment of choosing, which is
/// why every value carries [describe]. It is craft guidance, written down, at
/// the point of use.
///
/// This is also what AI-free looks like when it is done well: the author is
/// helped to decide, and never decided for. Nothing here generates prose,
/// suggests a choice, or scores one against another.
///
/// ## Where the words live now
///
/// The sentences themselves moved to `core/craft/craft_library.dart` — the
/// same words, read back through [describe]. This file said them first and
/// said them correctly; what changed is that a browsable craft shelf now needs
/// the same eight explanations, and two copies of a sentence agree only until
/// somebody edits one of them.
///
/// So the rule this file established is unchanged and now applies to thirty
/// more terms than it did. See `docs/craft-library-design.md`.
library;

import 'craft/craft_library.dart';

/// Who the narration belongs to.
enum PovMode {
  thirdLimited,
  thirdObjective,
  thirdOmniscient,
  first,
  second,
}

extension PovModeX on PovMode {
  /// The persisted value. Stable — a stored chapter must survive a rename.
  String get id => name;

  static PovMode? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final mode in PovMode.values) {
      if (mode.name == id) return mode;
    }
    return null;
  }

  String get label => switch (this) {
        PovMode.thirdLimited => 'Third person limited',
        PovMode.thirdObjective => 'Third person objective',
        PovMode.thirdOmniscient => 'Third person omniscient',
        PovMode.first => 'First person',
        PovMode.second => 'Second person',
      };

  /// What choosing this does to the reader.
  ///
  /// Resolved from the craft library, which holds the wording for every term
  /// AuthorOS explains. `test/narrative_voice_test.dart` fails on an empty
  /// one, so a mode that lost its entry is caught here rather than showing an
  /// author a blank line in the picker.
  String get describe => CraftLibrary.describe('manuscript.pov.$name');

  /// Whether this point of view belongs to one character.
  ///
  /// Omniscient and objective do not: asking who an omniscient chapter
  /// belongs to is asking the wrong question, and a picker that demanded an
  /// answer would be inventing a constraint the form does not have.
  bool get hasPovCharacter => switch (this) {
        PovMode.thirdLimited || PovMode.first || PovMode.second => true,
        PovMode.thirdObjective || PovMode.thirdOmniscient => false,
      };

  /// The one most manuscripts use, offered first.
  static const PovMode common = PovMode.thirdLimited;
}

/// When the telling happens relative to the events.
enum NarrativeTense { past, present, future }

extension NarrativeTenseX on NarrativeTense {
  String get id => name;

  static NarrativeTense? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final tense in NarrativeTense.values) {
      if (tense.name == id) return tense;
    }
    return null;
  }

  String get label => switch (this) {
        NarrativeTense.past => 'Past tense',
        NarrativeTense.present => 'Present tense',
        NarrativeTense.future => 'Future tense',
      };

  /// What choosing this does to the reader. Resolved from the craft library,
  /// as [PovModeX.describe] is.
  String get describe => CraftLibrary.describe('manuscript.tense.$name');

  static const NarrativeTense common = NarrativeTense.past;
}

/// The three choices together, as one value.
class NarrativeVoice {
  const NarrativeVoice({this.mode, this.povCharacterId, this.tense});

  final PovMode? mode;

  /// The record whose point of view this is.
  ///
  /// A record id rather than a name, so it is a real connection: renaming a
  /// character does not break it, and the manuscript can answer "which
  /// chapters are Cassian's". The name is kept alongside it in the chapter's
  /// existing `pov` field, which several filters already read.
  final String? povCharacterId;

  final NarrativeTense? tense;

  static const NarrativeVoice unset = NarrativeVoice();

  bool get isUnset => mode == null && povCharacterId == null && tense == null;

  /// Whether this voice wants a character and has not been given one.
  ///
  /// An observation for a reader to act on, never an error: a chapter part-way
  /// through being set up is not a chapter with a mistake in it.
  bool get wantsPovCharacter =>
      (mode?.hasPovCharacter ?? false) && povCharacterId == null;

  NarrativeVoice copyWith({
    PovMode? mode,
    String? povCharacterId,
    NarrativeTense? tense,
    bool clearPovCharacter = false,
  }) =>
      NarrativeVoice(
        mode: mode ?? this.mode,
        povCharacterId:
            clearPovCharacter ? null : (povCharacterId ?? this.povCharacterId),
        tense: tense ?? this.tense,
      );

  /// Drops the character when the chosen point of view has no room for one.
  ///
  /// Choosing omniscient after naming a POV character leaves a value nothing
  /// can mean. Cleared here rather than left for every reader to remember.
  NarrativeVoice normalised() =>
      (mode != null && !mode!.hasPovCharacter && povCharacterId != null)
          ? copyWith(clearPovCharacter: true)
          : this;

  Map<String, Object?> toJson() => {
        if (mode != null) 'povMode': mode!.id,
        if (povCharacterId != null) 'povCharacterId': povCharacterId,
        if (tense != null) 'tense': tense!.id,
      };

  factory NarrativeVoice.fromJson(Map<String, Object?> json) => NarrativeVoice(
        mode: PovModeX.fromId(json['povMode'] as String?),
        povCharacterId:
            (json['povCharacterId'] as String?)?.trim().isEmpty ?? true
                ? null
                : (json['povCharacterId'] as String?),
        tense: NarrativeTenseX.fromId(json['tense'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      other is NarrativeVoice &&
      other.mode == mode &&
      other.povCharacterId == povCharacterId &&
      other.tense == tense;

  @override
  int get hashCode => Object.hash(mode, povCharacterId, tense);

  @override
  String toString() =>
      'NarrativeVoice(${mode?.id}, $povCharacterId, ${tense?.id})';
}
