/// Language Forge — the room's read of the canonical lexicon.
///
/// A [LexiconTerm] is a projection of one `lexicon-entry` record: its id, its
/// `term`, its `gloss`, the `language` it references, its `wordClass`, and the
/// inflected forms read out of its `inflections` table. It is built from the
/// record and discarded; it is never saved, and there is no second word list.
/// Editing a word is editing the record, in the owning Studio's write path.
///
/// Kept separate from the record type so that the engines in this directory
/// stay plain Dart and can be tested without a repository.
library;

final _wordPattern =
    RegExp(r"[\p{L}\p{M}]+(?:['’][\p{L}\p{M}]+)*", unicode: true);

/// Words in [text], with their offsets. Letters and combining marks, joined
/// through an internal apostrophe — `Kael'thas` is one word.
Iterable<({String word, int start})> wordsIn(String text) sync* {
  for (final match in _wordPattern.allMatches(text)) {
    yield (word: match.group(0)!, start: match.start);
  }
}

class LexiconTerm {
  const LexiconTerm({
    required this.recordId,
    required this.term,
    required this.gloss,
    this.languageId = '',
    this.wordClass = '',
    this.forms = const [],
    this.themes = const [],
  });

  /// The canonical `lexicon-entry` record.
  final String recordId;

  /// As the language writes it.
  final String term;

  /// `lexicon-entry.gloss`: the shortest true translation. Several senses may
  /// be separated by `;`, `,` or `/`.
  final String gloss;

  /// The `language` or `dialect` record the entry references.
  final String languageId;

  final String wordClass;

  /// Every inflected form the author has written down — plural, case, tense.
  /// A form listed here is established, so continuity never flags it.
  final List<String> forms;

  /// The entry's Codex tags, by name — *Warfare*, *Endearments*, *Court*.
  /// Themed collections and phrasebook sections are these tags, read; the
  /// Study keeps no word lists of its own.
  final List<String> themes;

  /// A whole phrase rather than a word: the phrasebook's entries.
  bool get isPhrase => wordClass.trim().toLowerCase() == 'phrase';

  /// The term and its forms, lowercase.
  Set<String> get spellings => {
        term.toLowerCase(),
        for (final form in forms)
          if (form.trim().isNotEmpty) form.trim().toLowerCase(),
      };

  /// The gloss split into senses, lowercase, a leading *to* dropped from verb
  /// senses so `to walk` answers a lookup of `walk`.
  List<String> get senses => [
        for (final raw in gloss.split(RegExp(r'[;,/]')))
          if (raw.trim().isNotEmpty) _normaliseSense(raw),
      ];

  static String _normaliseSense(String raw) {
    final sense = raw.trim().toLowerCase();
    return sense.startsWith('to ') ? sense.substring(3).trim() : sense;
  }
}

/// A new Lexicon Entry the Study asks the Codex to make — a word accepted from
/// the Sound Change panel, with what the Study knows about it. The Codex makes
/// the record through its own create path; this is only the request.
class LexiconEntryDraft {
  const LexiconEntryDraft({
    required this.languageId,
    required this.term,
    this.gloss = '',
    this.wordClass = '',
    this.etymology = '',
    this.originRecordId,
  });

  final String languageId;
  final String term;
  final String gloss;
  final String wordClass;

  /// Written to the entry's own `etymology` field.
  final String etymology;

  /// The word it came from. The Codex links the new entry to it with the
  /// language system's `originatedFrom`, so the history is a real edge in the
  /// Loom and not only a sentence.
  final String? originRecordId;
}
