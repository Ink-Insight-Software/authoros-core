/// Language Forge Phase 1 — the Word and Name Generator.
///
/// Generates words that a [Phonology] accepts, and nothing else. Every
/// candidate is built from the language's own syllable templates and sound
/// weights, then put through the same [Phonology.validate] Linguistic
/// Continuity uses, so the generator cannot offer a word the checker would
/// later flag.
///
/// ## One seed engine
///
/// Randomness comes from `procedural/generation_seed.dart`, the engine
/// ADR-0008 made the only one: no `Random()`, no clock, no unordered
/// iteration. The same phonology, shape and seed phrase give the same list on
/// the desktop app and on the web build. A seed phrase is what an author types
/// — `'river names'` — and is what makes a list worth coming back to.
///
/// ## Suggestions, never records
///
/// This produces candidates. Accepting, editing, rejecting, reserving and
/// saving one to a `lexicon-entry`, a character or a place is the surface's
/// work and goes through the owning Studio's own write path. Nothing here
/// creates a record, and a rejected candidate leaves no trace.
library;

import '../procedural/generation_seed.dart';
import 'phonology.dart';

/// The shape of one kind of generated word — a given name, a river, a title.
///
/// The Naming Convention Builder's rules land here: a culture whose women's
/// names end in *-eth* is a shape with that suffix, not a second phonology.
class WordShape {
  const WordShape({
    this.label = 'Word',
    this.minSyllables,
    this.maxSyllables,
    this.prefixes = const [],
    this.suffixes = const [],
    this.optionalGroupChance = 0.5,
    this.capitalise = false,
  }) : assert(optionalGroupChance >= 0 && optionalGroupChance <= 1);

  /// A given name: two or three syllables, capitalised.
  static const givenName = WordShape(
    label: 'Given name',
    minSyllables: 2,
    maxSyllables: 3,
    capitalise: true,
  );

  /// A place name: capitalised, with the language's own length.
  static const placeName = WordShape(label: 'Place name', capitalise: true);

  final String label;

  /// Syllables in the stem, before affixes. Null takes the phonology's range.
  final int? minSyllables;
  final int? maxSyllables;

  /// Attached as spelled. Each must itself be sayable in the language, since
  /// the whole word is validated.
  final List<String> prefixes;
  final List<String> suffixes;

  /// How often an optional template group, such as a coda, is filled.
  final double optionalGroupChance;

  final bool capitalise;

  Map<String, Object?> toJson() => {
        'label': label,
        if (minSyllables != null) 'minSyllables': minSyllables,
        if (maxSyllables != null) 'maxSyllables': maxSyllables,
        if (prefixes.isNotEmpty) 'prefixes': prefixes,
        if (suffixes.isNotEmpty) 'suffixes': suffixes,
        'optionalGroupChance': optionalGroupChance,
        'capitalise': capitalise,
      };

  factory WordShape.fromJson(Map<String, Object?> json) => WordShape(
        label: json['label'] as String? ?? 'Word',
        minSyllables: (json['minSyllables'] as num?)?.toInt(),
        maxSyllables: (json['maxSyllables'] as num?)?.toInt(),
        prefixes: List<String>.from(json['prefixes'] as List? ?? const []),
        suffixes: List<String>.from(json['suffixes'] as List? ?? const []),
        optionalGroupChance:
            ((json['optionalGroupChance'] as num?) ?? 0.5).toDouble(),
        capitalise: json['capitalise'] as bool? ?? false,
      );
}

/// One candidate, and how it was made.
class GeneratedWord {
  const GeneratedWord({
    required this.spelling,
    required this.verdict,
    required this.seedPath,
  });

  /// As it would be written in the manuscript.
  final String spelling;

  /// The phonology's own reading of the candidate — syllables, stress and the
  /// pronunciation guide — so a surface never re-derives them.
  final PhonotacticVerdict verdict;

  /// Where in the seed tree the word came from. Stable, so a candidate can be
  /// reproduced or reserved by its address.
  final List<String> seedPath;

  String get pronunciationGuide => verdict.pronunciationGuide;
}

/// What a run produced, and what it could not.
class WordForgeResult {
  const WordForgeResult({required this.words, required this.shortfall});

  final List<GeneratedWord> words;

  /// How many of the requested words could not be found. Non-zero means the
  /// rules are tight enough to exhaust — a fact for the author, not an error.
  final int shortfall;
}

abstract final class WordForge {
  /// Draws per word before giving up on that slot.
  static const attemptsPerWord = 40;

  /// Generates up to [count] distinct words [phonology] accepts.
  ///
  /// [exclude] holds spellings already in use — the lexicon, the cast — so a
  /// generated name never collides with an existing one. Compared lowercase.
  static WordForgeResult generate(
    Phonology phonology,
    GenerationSeed seed, {
    int count = 12,
    WordShape shape = const WordShape(),
    Iterable<String> exclude = const [],
  }) {
    if (count <= 0) {
      return const WordForgeResult(words: [], shortfall: 0);
    }
    if (phonology.configurationIssues.isNotEmpty) {
      return WordForgeResult(words: const [], shortfall: count);
    }

    final minimum = shape.minSyllables ?? phonology.minSyllables;
    final maximum = shape.maxSyllables ?? phonology.maxSyllables;
    final taken = {for (final word in exclude) word.toLowerCase()};
    final words = <GeneratedWord>[];

    final run = seed.derive('word-forge:${shape.label}');
    for (var index = 0; index < count; index++) {
      final slot = run.derive('word:$index');
      GeneratedWord? found;
      for (var attempt = 0; attempt < attemptsPerWord; attempt++) {
        final attemptSeed = slot.derive('attempt:$attempt');
        final spelling = _draw(
          phonology,
          attemptSeed.random(),
          shape,
          minimum,
          maximum,
        );
        if (spelling == null || taken.contains(spelling)) continue;
        final verdict = phonology.validate(spelling);
        if (!verdict.conforms) continue;
        found = GeneratedWord(
          spelling: shape.capitalise ? _capitalise(spelling) : spelling,
          verdict: verdict,
          seedPath: attemptSeed.path,
        );
        taken.add(spelling);
        break;
      }
      if (found != null) words.add(found);
    }

    return WordForgeResult(
      words: List.unmodifiable(words),
      shortfall: count - words.length,
    );
  }

  static String? _draw(
    Phonology phonology,
    GenerationRandom random,
    WordShape shape,
    int minimum,
    int maximum,
  ) {
    if (maximum < minimum) return null;
    final syllables = minimum + random.nextInt(maximum - minimum + 1);
    final buffer = StringBuffer();
    if (shape.prefixes.isNotEmpty) buffer.write(random.pick(shape.prefixes));
    for (var i = 0; i < syllables; i++) {
      final template = random.pick(phonology.templates);
      for (final group in template.groups) {
        if (group.optional && !random.nextChance(shape.optionalGroupChance)) {
          continue;
        }
        for (final label in group.labels) {
          final phoneme = _weightedPick(phonology.members(label), random);
          if (phoneme == null) return null;
          buffer.write(phoneme.spelling);
        }
      }
    }
    if (shape.suffixes.isNotEmpty) buffer.write(random.pick(shape.suffixes));
    return buffer.toString().toLowerCase();
  }

  static Phoneme? _weightedPick(
      List<Phoneme> members, GenerationRandom random) {
    var total = 0;
    for (final phoneme in members) {
      total += phoneme.weight;
    }
    if (total <= 0) return null;
    var draw = random.nextInt(total);
    for (final phoneme in members) {
      if (draw < phoneme.weight) return phoneme;
      draw -= phoneme.weight;
    }
    return null;
  }

  static String _capitalise(String word) =>
      word.isEmpty ? word : word[0].toUpperCase() + word.substring(1);
}
