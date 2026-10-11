/// Language Forge Phase 1 — Linguistic Continuity: terminology and naming.
///
/// Holds a manuscript, and the names in the cast and the atlas, against the
/// rules the Linguist's Study has established. Phase 1 is the half of the
/// brief's checks that can be decided from spelling alone:
///
/// | Check | Reads |
/// |---|---|
/// | [LinguisticCheck.spellingVariant] | manuscript words near a term or name but not it |
/// | [LinguisticCheck.capitalisation] | a proper term lowercased, or a common one capitalised mid-sentence |
/// | [LinguisticCheck.anglicisedPlural] | an English *-s* on a term with no such form recorded |
/// | [LinguisticCheck.competingMeaning] | one spelling, one language, two glosses |
/// | [LinguisticCheck.nameSoundRule] | a name its own language's phonology cannot produce |
///
/// Grammar, social usage and historical checks need grammar rules, character
/// fluency and a calendar respectively, and are phased in the build plan
/// rather than approximated here.
///
/// ## Advisory, and the author decides
///
/// Like every continuity engine in AuthorOS: this reads, and changes nothing.
/// Each finding carries the rule, the evidence, the contradiction, the records
/// and passages it touches, a severity on the shared scale, and the
/// [LinguisticResolution]s that apply to it. Carrying them out — ignoring,
/// explaining, correcting a passage, replacing project-wide or updating the
/// rule — belongs to the surface and the owning Studio's write path.
///
/// **It reuses the free severity scale**, `ContinuitySeverity`, for the reason
/// Politics & Power gives: a second scale is a second answer to *how bad is
/// this*.
library;

import '../continuity_domain.dart';
import 'grammar.dart';
import 'lexicon.dart';
import 'phonology.dart';

enum LinguisticCheck {
  spellingVariant,
  capitalisation,
  anglicisedPlural,
  competingMeaning,
  nameSoundRule,
  inflection;

  String get label => switch (this) {
        LinguisticCheck.spellingVariant => 'Inconsistent spelling',
        LinguisticCheck.capitalisation => 'Conflicting capitalisation',
        LinguisticCheck.anglicisedPlural => 'Accidental plural',
        LinguisticCheck.competingMeaning => 'Contradictory meanings',
        LinguisticCheck.nameSoundRule => 'Name breaks sound rules',
        LinguisticCheck.inflection => 'Wrong inflection',
      };
}

/// What the author may do about a finding. The engine lists; it never acts.
enum LinguisticResolution {
  ignore,
  explain,
  correctPassage,
  replaceProjectWide,
  updateRule,
}

/// One passage of manuscript, as the survey loaded it.
class ManuscriptPassage {
  const ManuscriptPassage({required this.nodeId, required this.text});

  /// The chapter or scene.
  final String nodeId;
  final String text;
}

/// A name held by a canonical record, and the language it belongs to.
class LinguisticName {
  const LinguisticName({
    required this.recordId,
    required this.name,
    required this.languageId,
  });

  /// The character, place or House the name is on.
  final String recordId;
  final String name;

  /// The `language` or `dialect` record whose rules the name should follow.
  final String languageId;
}

class LinguisticFinding {
  const LinguisticFinding({
    required this.check,
    required this.severity,
    required this.title,
    required this.rule,
    required this.contradiction,
    required this.resolutions,
    this.subject = '',
    this.evidence = '',
    this.recordIds = const [],
    this.manuscriptNodeIds = const [],
    this.occurrences = 0,
    this.suggestedReplacement,
  });

  final LinguisticCheck check;
  final ContinuitySeverity severity;

  final String title;

  /// The word or name the finding is about, as the author wrote it — what an
  /// Ignore decision remembers.
  final String subject;

  /// The established rule, as the Study records it.
  final String rule;

  /// What seems to contradict it.
  final String contradiction;

  /// The first passage it appears in, trimmed around the word.
  final String evidence;

  final List<String> recordIds;
  final List<String> manuscriptNodeIds;

  /// How many times the contradiction appears in the manuscript.
  final int occurrences;

  /// The established form, when there is one to replace with.
  final String? suggestedReplacement;

  final List<LinguisticResolution> resolutions;

  bool get reachesTheManuscript => manuscriptNodeIds.isNotEmpty;
}

class LinguisticContinuityReport {
  const LinguisticContinuityReport({required this.findings});

  static const empty = LinguisticContinuityReport(findings: []);

  /// Most severe first, then by check, then by title — stable across reloads.
  final List<LinguisticFinding> findings;

  bool get isClean => findings.isEmpty;

  Iterable<LinguisticFinding> of(LinguisticCheck check) =>
      findings.where((finding) => finding.check == check);
}

abstract final class LinguisticContinuity {
  /// Words shorter than this are never read as misspellings: at four letters
  /// one edit reaches half the language's own words and most of English.
  static const minimumVariantLength = 5;

  /// Inspects the manuscript and names against the lexicon and phonologies.
  ///
  /// [ignored] holds words the author has already dismissed, lowercase — the
  /// ignore resolution's decisions, read back so a dismissed finding stays
  /// dismissed.
  static LinguisticContinuityReport inspect({
    required Iterable<LexiconTerm> lexicon,
    Iterable<ManuscriptPassage> passages = const [],
    Iterable<LinguisticName> names = const [],
    Map<String, Phonology> phonologyByLanguage = const {},
    Set<String> ignored = const {},
    Map<String, GrammarBook> grammarByLanguage = const {},
  }) {
    final terms = lexicon.toList();
    final nameList = names.toList();
    final findings = <LinguisticFinding>[
      ..._competingMeanings(terms),
      ..._nameSoundRules(nameList, phonologyByLanguage, ignored),
      ..._manuscriptChecks(
          terms, nameList, passages.toList(), ignored, grammarByLanguage),
    ];
    findings.sort((a, b) {
      final severity = b.severity.index.compareTo(a.severity.index);
      if (severity != 0) return severity;
      final check = a.check.index.compareTo(b.check.index);
      if (check != 0) return check;
      return a.title.compareTo(b.title);
    });
    return LinguisticContinuityReport(findings: List.unmodifiable(findings));
  }

  static Iterable<LinguisticFinding> _competingMeanings(
      List<LexiconTerm> terms) sync* {
    final grouped = <String, List<LexiconTerm>>{};
    for (final term in terms) {
      final key = '${term.languageId}\u0000${term.term.toLowerCase()}';
      (grouped[key] ??= []).add(term);
    }
    for (final group in grouped.values) {
      final glosses = group.map((term) => term.gloss.trim()).toSet();
      if (glosses.length < 2) continue;
      yield LinguisticFinding(
        check: LinguisticCheck.competingMeaning,
        severity: ContinuitySeverity.warning,
        title: '"${group.first.term}" is defined ${group.length} times',
        subject: group.first.term,
        rule: 'One word, one entry: senses belong together on one record.',
        contradiction: 'The same spelling is glossed as '
            '${glosses.map((gloss) => '"$gloss"').join(' and ')}.',
        recordIds: [for (final term in group) term.recordId],
        resolutions: const [
          LinguisticResolution.explain,
          LinguisticResolution.updateRule,
        ],
      );
    }
  }

  static Iterable<LinguisticFinding> _nameSoundRules(
    List<LinguisticName> names,
    Map<String, Phonology> phonologies,
    Set<String> ignored,
  ) sync* {
    for (final name in names) {
      final phonology = phonologies[name.languageId];
      if (phonology == null) continue;
      if (ignored.contains(name.name.toLowerCase())) continue;
      final problems = <String>[];
      for (final (:word, start: _) in wordsIn(name.name)) {
        final verdict = phonology.validate(word.replaceAll(RegExp("['’]"), ''));
        problems.addAll(verdict.problems.map((problem) => problem.detail));
      }
      if (problems.isEmpty) continue;
      yield LinguisticFinding(
        check: LinguisticCheck.nameSoundRule,
        severity: ContinuitySeverity.notice,
        title: '${name.name} does not follow its language\'s sound rules',
        subject: name.name,
        rule: 'Names in this language are built from its sounds and '
            'syllable shapes.',
        contradiction: problems.join(' '),
        recordIds: [name.recordId, name.languageId],
        resolutions: const [
          LinguisticResolution.ignore,
          LinguisticResolution.explain,
          LinguisticResolution.correctPassage,
          LinguisticResolution.updateRule,
        ],
      );
    }
  }

  static Iterable<LinguisticFinding> _manuscriptChecks(
    List<LexiconTerm> terms,
    List<LinguisticName> names,
    List<ManuscriptPassage> passages,
    Set<String> ignored,
    Map<String, GrammarBook> grammar,
  ) sync* {
    if (passages.isEmpty) return;

    // Every established spelling, lowercase, to the canonical form and the
    // records that establish it. Names count: a misspelt name is the commonest
    // terminology error there is.
    final established = <String, _Established>{};
    for (final term in terms) {
      for (final spelling in term.spellings) {
        established
            .putIfAbsent(spelling, () => _Established(term.term))
            .recordIds
            .add(term.recordId);
      }
    }
    // Forms the author's grammar makes are established too: a correct plural
    // is not a misspelling of its singular.
    for (final term in terms) {
      final book = grammar[term.languageId];
      if (book == null) continue;
      for (final cell in book.paradigm(term)) {
        final form = cell.form;
        if (form == null) continue;
        established
            .putIfAbsent(form.toLowerCase(), () => _Established(form))
            .recordIds
            .add(term.recordId);
      }
    }
    for (final name in names) {
      for (final (:word, start: _) in wordsIn(name.name)) {
        established
            .putIfAbsent(word.toLowerCase(), () => _Established(word))
            .recordIds
            .add(name.recordId);
      }
    }
    if (established.isEmpty) return;

    // And the forms a rule would make if its wrong branch were used — the
    // consonant ending on a word that ends in a vowel — each pointing at the
    // form the rule actually gives. Only endings the author's own rules
    // contain are ever looked for.
    final wrongForms = <String, _WrongForm>{};
    for (final term in terms) {
      final book = grammar[term.languageId];
      if (book == null) continue;
      for (final formula in book.inflections) {
        if (!formula.appliesTo(term)) continue;
        final correct = formula.derive(term.term);
        if (correct == null) continue;
        for (final branch in formula.branches) {
          for (final candidate in [
            branch.apply(term.term),
            if (branch.suffix.isNotEmpty && branch.prefix.isEmpty)
              '${term.term}${branch.suffix}',
          ]) {
            if (candidate == null) continue;
            final key = candidate.toLowerCase();
            if (key == correct.toLowerCase() || established.containsKey(key)) {
              continue;
            }
            wrongForms.putIfAbsent(
                key, () => _WrongForm(term, formula, correct));
          }
        }
      }
    }

    final occurrences = <String, List<_Occurrence>>{};
    for (final passage in passages) {
      for (final (:word, :start) in wordsIn(passage.text)) {
        final bare = _stripPossessive(word);
        (occurrences[bare.toLowerCase()] ??= [])
            .add(_Occurrence(passage, bare, start));
      }
    }

    final byLength = <int, List<String>>{};
    for (final spelling in established.keys) {
      (byLength[spelling.length] ??= []).add(spelling);
    }

    for (final entry in occurrences.entries) {
      final lower = entry.key;
      final seen = entry.value;
      if (ignored.contains(lower)) continue;

      final exact = established[lower];
      if (exact != null) {
        final finding = _capitalisation(exact, seen);
        if (finding != null) yield finding;
        continue;
      }

      final wrong = wrongForms[lower];
      if (wrong != null) {
        yield _finding(
          check: LinguisticCheck.inflection,
          severity: ContinuitySeverity.warning,
          title: '"${seen.first.surface}" is not the '
              '${wrong.formula.label.toLowerCase()} of "${wrong.term.term}"',
          rule: 'The ${wrong.formula.label.toLowerCase()} rule makes '
              '"${wrong.correct}" from "${wrong.term.term}".',
          contradiction: '"${seen.first.surface}" uses one of that rule\'s '
              'endings on a word it does not fit.',
          established: _Established(wrong.correct)
            ..recordIds.add(wrong.term.recordId),
          seen: seen,
          resolutions: const [
            LinguisticResolution.ignore,
            LinguisticResolution.explain,
            LinguisticResolution.correctPassage,
            LinguisticResolution.replaceProjectWide,
            LinguisticResolution.updateRule,
          ],
        );
        continue;
      }

      final plural = _pluralBase(lower, established);
      if (plural != null) {
        yield _finding(
          check: LinguisticCheck.anglicisedPlural,
          severity: ContinuitySeverity.notice,
          title: '"${seen.first.surface}" adds an English plural to '
              '"${plural.canonical}"',
          rule: '"${plural.canonical}" has no recorded form '
              '"${seen.first.surface}".',
          contradiction: 'An English -s may be standing in for the '
              'language\'s own plural.',
          established: plural,
          seen: seen,
          resolutions: const [
            LinguisticResolution.ignore,
            LinguisticResolution.explain,
            LinguisticResolution.correctPassage,
            LinguisticResolution.updateRule,
          ],
        );
        continue;
      }

      if (lower.length < minimumVariantLength) continue;
      final target = _nearest(lower, byLength, established);
      if (target == null) continue;
      yield _finding(
        check: LinguisticCheck.spellingVariant,
        severity: ContinuitySeverity.warning,
        title: '"${seen.first.surface}" may be a misspelling of '
            '"${target.canonical}"',
        rule: 'The established spelling is "${target.canonical}".',
        contradiction: '"${seen.first.surface}" appears ${seen.length} '
            'time${seen.length == 1 ? '' : 's'} and is not a recorded word, '
            'form or name.',
        established: target,
        seen: seen,
        resolutions: const [
          LinguisticResolution.ignore,
          LinguisticResolution.explain,
          LinguisticResolution.correctPassage,
          LinguisticResolution.replaceProjectWide,
          LinguisticResolution.updateRule,
        ],
      );
    }
  }

  static LinguisticFinding? _capitalisation(
      _Established established, List<_Occurrence> seen) {
    final canonical = established.canonical;
    final proper = _isCapitalised(canonical);
    final wrong = seen.where((occurrence) {
      final surface = occurrence.surface;
      if (surface == canonical) return false;
      if (surface.length > 1 && surface == surface.toUpperCase()) return false;
      if (proper) return !_isCapitalised(surface);
      return _isCapitalised(surface) && !occurrence.startsSentence;
    }).toList();
    if (wrong.isEmpty) return null;
    return _finding(
      check: LinguisticCheck.capitalisation,
      severity: ContinuitySeverity.notice,
      title: '"${wrong.first.surface}" is capitalised differently from '
          '"$canonical"',
      rule: proper
          ? '"$canonical" is a proper name and is always capitalised.'
          : '"$canonical" is a common word and is capitalised only where a '
              'sentence begins.',
      contradiction: 'Written "${wrong.first.surface}" ${wrong.length} '
          'time${wrong.length == 1 ? '' : 's'}.',
      established: established,
      seen: wrong,
      resolutions: const [
        LinguisticResolution.ignore,
        LinguisticResolution.explain,
        LinguisticResolution.correctPassage,
        LinguisticResolution.replaceProjectWide,
      ],
    );
  }

  static LinguisticFinding _finding({
    required LinguisticCheck check,
    required ContinuitySeverity severity,
    required String title,
    required String rule,
    required String contradiction,
    required _Established established,
    required List<_Occurrence> seen,
    required List<LinguisticResolution> resolutions,
  }) {
    final nodes = <String>[];
    for (final occurrence in seen) {
      if (!nodes.contains(occurrence.passage.nodeId)) {
        nodes.add(occurrence.passage.nodeId);
      }
    }
    return LinguisticFinding(
      check: check,
      severity: severity,
      title: title,
      subject: seen.first.surface,
      rule: rule,
      contradiction: contradiction,
      evidence: seen.first.excerpt,
      recordIds: List.unmodifiable(established.recordIds),
      manuscriptNodeIds: List.unmodifiable(nodes),
      occurrences: seen.length,
      suggestedReplacement: established.canonical,
      resolutions: resolutions,
    );
  }

  static _Established? _pluralBase(
      String lower, Map<String, _Established> established) {
    for (final ending in const ['es', 's']) {
      if (!lower.endsWith(ending) || lower.length <= ending.length + 2) {
        continue;
      }
      final base =
          established[lower.substring(0, lower.length - ending.length)];
      if (base != null) return base;
    }
    return null;
  }

  /// The single closest established word within the length's allowance, or
  /// null when there is none or two different words are equally close — a tie
  /// is not a finding, because the engine cannot say which was meant. Two forms
  /// of the *same* word at the same distance are not a tie.
  static _Established? _nearest(
    String word,
    Map<int, List<String>> byLength,
    Map<String, _Established> established,
  ) {
    final allowance = word.length >= 8 ? 2 : 1;
    var bestDistance = allowance + 1;
    final best = <_Established>{};
    for (var length = word.length - allowance;
        length <= word.length + allowance;
        length++) {
      for (final candidate in byLength[length] ?? const <String>[]) {
        if (candidate.length < minimumVariantLength) continue;
        final distance = _boundedDistance(word, candidate, allowance);
        if (distance > allowance || distance > bestDistance) continue;
        if (distance < bestDistance) {
          bestDistance = distance;
          best.clear();
        }
        best.add(established[candidate]!);
      }
    }
    return best.length == 1 ? best.single : null;
  }

  /// Edit distance with adjacent transposition, abandoned once every cell of a
  /// row exceeds [limit].
  static int _boundedDistance(String a, String b, int limit) {
    var twoBack = List<int>.filled(b.length + 1, 0);
    var previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 1; i <= a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0)..[0] = i;
      var rowMinimum = current[0];
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        var value = [
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
        if (i > 1 &&
            j > 1 &&
            a[i - 1] == b[j - 2] &&
            a[i - 2] == b[j - 1] &&
            twoBack[j - 2] + 1 < value) {
          value = twoBack[j - 2] + 1;
        }
        current[j] = value;
        if (value < rowMinimum) rowMinimum = value;
      }
      if (rowMinimum > limit) return limit + 1;
      twoBack = previous;
      previous = current;
    }
    return previous[b.length];
  }

  static String _stripPossessive(String word) {
    for (final suffix in const ["'s", '’s']) {
      if (word.length > suffix.length + 1 && word.endsWith(suffix)) {
        return word.substring(0, word.length - suffix.length);
      }
    }
    return word;
  }

  static bool _isCapitalised(String word) =>
      word.isNotEmpty &&
      word[0] != word[0].toLowerCase() &&
      word[0] == word[0].toUpperCase();
}

class _WrongForm {
  _WrongForm(this.term, this.formula, this.correct);

  final LexiconTerm term;
  final InflectionFormula formula;
  final String correct;
}

class _Established {
  _Established(this.canonical);

  final String canonical;
  final Set<String> recordIds = {};
}

class _Occurrence {
  _Occurrence(this.passage, this.surface, this.start);

  final ManuscriptPassage passage;
  final String surface;
  final int start;

  /// Whether the word opens a sentence, where capitalising a common word is
  /// ordinary English and not a finding.
  bool get startsSentence {
    var index = start - 1;
    final text = passage.text;
    while (index >= 0 && ' \t\n"“‘\'(—–-'.contains(text[index])) {
      index--;
    }
    return index < 0 || '.!?…:'.contains(text[index]);
  }

  String get excerpt {
    const margin = 40;
    final text = passage.text;
    final from = start - margin < 0 ? 0 : start - margin;
    final end = start + surface.length + margin;
    final to = end > text.length ? text.length : end;
    final body =
        text.substring(from, to).replaceAll(RegExp(r'\s+'), ' ').trim();
    return '${from > 0 ? '…' : ''}$body${to < text.length ? '…' : ''}';
  }
}
