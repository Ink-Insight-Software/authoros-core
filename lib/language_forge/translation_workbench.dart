/// Language Forge Phase 1 — the Translation Workbench's engine.
///
/// The workbench does exactly one thing an author could not do by hand faster:
/// it holds a phrase against the lexicon and says, word by word, what is
/// defined and what is not.
///
/// ## It never pretends
///
/// The product brief's own rule: *it should not pretend to translate
/// vocabulary or grammatical constructions the author has not yet defined.*
/// So there is no fallback, no guess and no nearest match. A word the lexicon
/// does not hold is shown as undefined; a word it holds twice with different
/// meanings is shown as ambiguous; and a breakdown with either is a
/// [TranslationStatus.draft], whatever the author's natural translation says.
/// Only a phrase every word of which is defined, once, is
/// [TranslationStatus.complete].
///
/// Grammar is not applied. The workbench shows the literal, word-by-word layer
/// the author's natural translation is written against; it does not conjugate,
/// decline or reorder, because those rules are the author's and a rule applied
/// by inference is a translation the author did not make.
library;

import 'grammar.dart';
import 'lexicon.dart';

enum TranslationStatus { complete, draft }

/// One word of the phrase, and every entry it could be.
class GlossedToken {
  const GlossedToken({
    required this.surface,
    required this.matches,
    this.analyses = const [],
  });

  /// As it appears in the phrase.
  final String surface;

  final List<LexiconTerm> matches;

  /// Inflected readings: a word the lexicon does not hold as written, made
  /// from one it does by one of the author's grammar formulas. Only read when
  /// [matches] is empty — a written entry always wins over a derivation.
  final List<Analysis> analyses;

  bool get defined => matches.isNotEmpty || analyses.isNotEmpty;

  /// Every gloss this word could carry: `sun`, or `sun-PL`.
  Set<String> get glosses => matches.isNotEmpty
      ? {for (final term in matches) term.gloss}
      : {for (final analysis in analyses) analysis.gloss};

  /// More than one meaning, recorded or derived.
  bool get ambiguous =>
      glosses.map((gloss) => gloss.toLowerCase()).toSet().length > 1;

  /// The word class, when the word has exactly one.
  String get wordClass {
    final classes = matches.isNotEmpty
        ? {for (final term in matches) term.wordClass}
        : {for (final analysis in analyses) analysis.term.wordClass};
    return classes.length == 1 ? classes.single : '';
  }
}

/// A phrase held against the lexicon.
class TranslationBreakdown {
  const TranslationBreakdown({
    required this.source,
    required this.tokens,
    this.orderNotes = const [],
  });

  final String source;
  final List<GlossedToken> tokens;

  /// What the language's word-order formula says about this phrase. Advisory:
  /// a note never makes a phrase a draft, because poetry reorders and the
  /// author may mean it.
  final List<WordOrderNote> orderNotes;

  TranslationStatus get status => tokens.isNotEmpty &&
          tokens.every((token) => token.defined && !token.ambiguous)
      ? TranslationStatus.complete
      : TranslationStatus.draft;

  bool get isDraft => status == TranslationStatus.draft;

  List<String> get undefined => [
        for (final token in tokens)
          if (!token.defined) token.surface,
      ];

  List<String> get ambiguous => [
        for (final token in tokens)
          if (token.ambiguous) token.surface,
      ];

  /// The records every word resolved to, for the workbench's links.
  Set<String> get recordIds => {
        for (final token in tokens)
          for (final term in token.matches) term.recordId,
        for (final token in tokens)
          for (final analysis in token.analyses) analysis.term.recordId,
      };
}

class TranslationWorkbench {
  /// A workbench over [lexicon], limited to [languageId] when one is given —
  /// so a dialect's phrase is not glossed with its parent's words by accident.
  TranslationWorkbench(
    Iterable<LexiconTerm> lexicon, {
    String? languageId,
    GrammarBook? grammar,
  }) : _grammar = grammar ?? GrammarBook.empty {
    for (final term in lexicon) {
      if (languageId != null && term.languageId != languageId) continue;
      _terms.add(term);
      for (final spelling in term.spellings) {
        (_bySpelling[spelling] ??= []).add(term);
      }
      for (final sense in term.senses) {
        (_bySense[sense] ??= []).add(term);
      }
    }
  }

  final Map<String, List<LexiconTerm>> _bySpelling = {};
  final Map<String, List<LexiconTerm>> _bySense = {};
  final List<LexiconTerm> _terms = [];
  final GrammarBook _grammar;

  /// A phrase in the language, glossed word by word into meanings.
  ///
  /// A word not in the lexicon as written is read back through the language's
  /// grammar formulas, so `arani` glosses as `sun-PL` when the author's plural
  /// rule makes `arani` from `aran`. That is the author's rule applied, not a
  /// guess: with no formula that makes the word, it stays undefined.
  TranslationBreakdown gloss(String phrase) {
    final tokens = [
      for (final (:word, start: _) in wordsIn(phrase))
        () {
          final matches =
              _bySpelling[word.toLowerCase()] ?? const <LexiconTerm>[];
          return GlossedToken(
            surface: word,
            matches: List.unmodifiable(matches),
            analyses: matches.isNotEmpty
                ? const []
                : List.unmodifiable(_grammar.analyze(word, _terms)),
          );
        }(),
    ];
    return TranslationBreakdown(
      source: phrase,
      tokens: tokens,
      orderNotes:
          _grammar.checkOrder([for (final token in tokens) token.wordClass]),
    );
  }

  /// A phrase in the author's language, looked up word by word by meaning.
  ///
  /// Reverse lookup, not translation: *the*, *of* and every other word with no
  /// entry come back undefined, which is the true state of a language whose
  /// articles have not been decided.
  TranslationBreakdown lookUp(String phrase) => TranslationBreakdown(
        source: phrase,
        tokens: [
          for (final (:word, start: _) in wordsIn(phrase))
            GlossedToken(
              surface: word,
              matches: List.unmodifiable(
                  _bySense[word.toLowerCase()] ?? const <LexiconTerm>[]),
            ),
        ],
      );

  /// Interlinear lines for [breakdown]: the words, and beneath each its gloss.
  /// Undefined words gloss as `?`, ambiguous ones as their meanings joined by
  /// `|`, so nothing in the gloss line reads as settled when it is not.
  static ({String words, String glosses}) interlinear(
      TranslationBreakdown breakdown) {
    final words = <String>[];
    final glosses = <String>[];
    for (final token in breakdown.tokens) {
      final gloss = !token.defined ? '?' : token.glosses.join('|');
      final width = token.surface.length > gloss.length
          ? token.surface.length
          : gloss.length;
      words.add(token.surface.padRight(width));
      glosses.add(gloss.padRight(width));
    }
    return (
      words: words.join('  ').trimRight(),
      glosses: glosses.join('  ').trimRight(),
    );
  }
}
