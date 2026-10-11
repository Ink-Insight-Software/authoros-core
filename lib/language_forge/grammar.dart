/// Language Forge Phase 4 — the Grammar Workshop's engine.
///
/// A `grammar-rule` record says a rule in prose: its `statement`, `examples`,
/// `exceptions` and `notes` stay exactly where they are, in the Codex, free.
/// What the Study adds beside it is a **formula** — the rule written so a
/// machine can apply it — kept in the working layer and keyed by the rule
/// record's id. Two kinds are modelled, because they are the two the rest of
/// the room can use:
///
/// | Formula | What it does | Who uses it |
/// |---|---|---|
/// | [InflectionFormula] | makes one form of a word — plural, genitive, past | the Grammar panel's paradigms, the Translation Workbench's glosses, Linguistic Continuity's ending check |
/// | [WordOrderFormula] | says where the verb and the adjective go | the Translation Workbench's word-order note |
///
/// A rule with no formula is still a rule: prose-only grammar is how most
/// languages in most novels are written, and nothing here requires otherwise.
///
/// ## Honest by construction
///
/// Every form this engine produces comes from a formula the author wrote, and
/// every analysis is the reverse of one. It never guesses a plural, never
/// reorders a sentence, and never corrects a word. A word it cannot derive or
/// analyse is reported as exactly that.
library;

import 'lexicon.dart';

/// What a grammar rule is about — the brief's list, each with the plain name
/// an author uses and the label a linguist would.
enum GrammarCategory {
  wordOrder('Word order', 'Syntax'),
  plural('Plurals', 'Number'),
  gender('Grammatical gender', 'Gender'),
  animacy('Animate and inanimate', 'Animacy'),
  grammaticalCase('Cases', 'Case'),
  possession('Possession', 'Possessive'),
  tense('Tense', 'Tense'),
  aspect('Aspect', 'Aspect'),
  mood('Mood', 'Mood'),
  voice('Voice', 'Voice'),
  negation('Negation', 'Polarity'),
  question('Questions', 'Interrogative'),
  command('Commands', 'Imperative'),
  comparison('Comparatives', 'Degree'),
  conditional('Conditionals', 'Conditional'),
  evidentiality('Evidentiality', 'Evidential'),
  politeness('Politeness', 'Honorific'),
  agreement('Agreement', 'Agreement'),
  pronoun('Pronouns', 'Pronominal'),
  article('Articles', 'Definiteness'),
  other('Other', 'Other');

  const GrammarCategory(this.plain, this.formal);

  final String plain;
  final String formal;
}

/// One way of making a form: for words ending in [ending], strip [strip]
/// from the end, then add [prefix] and [suffix].
class InflectionBranch {
  const InflectionBranch({
    this.ending = '',
    this.strip = '',
    this.prefix = '',
    this.suffix = '',
  });

  /// The ending a word must have for this branch; empty matches every word.
  final String ending;

  /// Removed from the end first. Must itself be an ending of the word.
  final String strip;

  final String prefix;
  final String suffix;

  bool matches(String word) => word.toLowerCase().endsWith(ending);

  /// The form of [word], or null when [strip] is not its ending.
  String? apply(String word) {
    final lower = word.toLowerCase();
    if (!lower.endsWith(strip)) return null;
    final stem = word.substring(0, word.length - strip.length);
    if (stem.isEmpty) return null;
    final capitalised = word[0] != word[0].toLowerCase();
    var form = '$prefix${prefix.isEmpty ? stem : stem.toLowerCase()}$suffix';
    if (capitalised && prefix.isNotEmpty) {
      form = form[0].toUpperCase() + form.substring(1);
    }
    return form;
  }

  /// `a => -a +ae`, the line the Grammar panel edits.
  String get text => [
        '${ending.isEmpty ? '*' : ending} =>',
        if (strip.isNotEmpty) '-$strip',
        if (prefix.isNotEmpty) '$prefix+',
        if (suffix.isNotEmpty) '+$suffix',
      ].join(' ');

  Map<String, Object?> toJson() => {
        if (ending.isNotEmpty) 'ending': ending,
        if (strip.isNotEmpty) 'strip': strip,
        if (prefix.isNotEmpty) 'prefix': prefix,
        if (suffix.isNotEmpty) 'suffix': suffix,
      };

  factory InflectionBranch.fromJson(Map<String, Object?> json) =>
      InflectionBranch(
        ending: json['ending'] as String? ?? '',
        strip: json['strip'] as String? ?? '',
        prefix: json['prefix'] as String? ?? '',
        suffix: json['suffix'] as String? ?? '',
      );
}

/// A rule's machine-readable half. Keyed by the `grammar-rule` record's id.
sealed class GrammarFormula {
  const GrammarFormula({required this.languageId, required this.category});

  /// The `language` or `dialect` the rule belongs to.
  final String languageId;

  final GrammarCategory category;

  Map<String, Object?> toJson();

  static GrammarFormula fromJson(Map<String, Object?> json) =>
      switch (json['kind']) {
        'inflection' => InflectionFormula.fromJson(json),
        'wordOrder' => WordOrderFormula.fromJson(json),
        final kind => throw FormatException('Unknown grammar formula "$kind".'),
      };
}

/// Makes one form of a word: `aran` → `arani`, PLURAL.
class InflectionFormula extends GrammarFormula {
  const InflectionFormula({
    required super.languageId,
    required super.category,
    required this.label,
    required this.abbreviation,
    this.wordClass = '',
    this.branches = const [],
    this.irregular = const {},
  });

  /// `Plural`, `Genitive`, `Past`.
  final String label;

  /// The gloss tag: `PL`, `GEN`, `PST`.
  final String abbreviation;

  /// The word class it applies to — `Noun` — or empty for every class.
  final String wordClass;

  /// Tried longest ending first, so `ia =>` wins over `a =>` over `* =>`.
  final List<InflectionBranch> branches;

  /// Word → form, for the exceptions. Keys lowercase.
  final Map<String, String> irregular;

  bool appliesTo(LexiconTerm term) =>
      wordClass.trim().isEmpty ||
      term.wordClass.trim().toLowerCase() == wordClass.trim().toLowerCase();

  List<InflectionBranch> get _ordered =>
      [...branches]..sort((a, b) => b.ending.length.compareTo(a.ending.length));

  /// The form of [word] this rule makes, or null when no branch fits.
  String? derive(String word) {
    final irregularForm = irregular[word.toLowerCase()];
    if (irregularForm != null) return irregularForm;
    for (final branch in _ordered) {
      if (branch.matches(word)) return branch.apply(word);
    }
    return null;
  }

  @override
  Map<String, Object?> toJson() => {
        'kind': 'inflection',
        'languageId': languageId,
        'category': category.name,
        'label': label,
        'abbreviation': abbreviation,
        if (wordClass.isNotEmpty) 'wordClass': wordClass,
        'branches': [for (final branch in branches) branch.toJson()],
        if (irregular.isNotEmpty) 'irregular': irregular,
      };

  factory InflectionFormula.fromJson(Map<String, Object?> json) =>
      InflectionFormula(
        languageId: json['languageId'] as String,
        category: GrammarCategory.values
            .byName(json['category'] as String? ?? 'other'),
        label: json['label'] as String? ?? '',
        abbreviation: json['abbreviation'] as String? ?? '',
        wordClass: json['wordClass'] as String? ?? '',
        branches: [
          for (final raw in json['branches'] as List? ?? const [])
            InflectionBranch.fromJson(Map<String, Object?>.from(raw as Map)),
        ],
        irregular: {
          for (final entry in (json['irregular'] as Map? ?? const {}).entries)
            '${entry.key}'.toLowerCase(): '${entry.value}',
        },
      );
}

/// Where the verb sits in a clause.
enum VerbPosition {
  initial('Verb first', 'VSO / VOS'),
  medial('Verb in the middle', 'SVO / OVS'),
  last('Verb last', 'SOV / OSV'),
  free('Free', 'Free');

  const VerbPosition(this.plain, this.formal);

  final String plain;
  final String formal;
}

/// Whether an adjective comes before or after its noun.
enum AdjectivePosition {
  before('Before the noun'),
  after('After the noun'),
  free('Either');

  const AdjectivePosition(this.plain);

  final String plain;
}

class WordOrderFormula extends GrammarFormula {
  const WordOrderFormula({
    required super.languageId,
    this.verb = VerbPosition.free,
    this.adjective = AdjectivePosition.free,
  }) : super(category: GrammarCategory.wordOrder);

  final VerbPosition verb;
  final AdjectivePosition adjective;

  @override
  Map<String, Object?> toJson() => {
        'kind': 'wordOrder',
        'languageId': languageId,
        'category': category.name,
        'verb': verb.name,
        'adjective': adjective.name,
      };

  factory WordOrderFormula.fromJson(Map<String, Object?> json) =>
      WordOrderFormula(
        languageId: json['languageId'] as String,
        verb: VerbPosition.values.byName(json['verb'] as String? ?? 'free'),
        adjective: AdjectivePosition.values
            .byName(json['adjective'] as String? ?? 'free'),
      );
}

/// One form a word takes under one rule.
class ParadigmCell {
  const ParadigmCell({
    required this.formula,
    required this.form,
    required this.recorded,
  });

  final InflectionFormula formula;

  /// Null when no branch of the rule fits the word.
  final String? form;

  /// Whether the author also wrote this form on the word's own record.
  final bool recorded;
}

/// A form read back to its word: `arani` → `aran` + PLURAL.
class Analysis {
  const Analysis({required this.term, required this.formula});

  final LexiconTerm term;
  final InflectionFormula formula;

  /// `sun-PL`, `walk-PST` — the first sense of the word's gloss, with a
  /// verb's *to* dropped, then the rule's tag.
  String get gloss {
    final senses = term.senses;
    final sense = senses.isEmpty ? term.term : senses.first;
    return '$sense-${formula.abbreviation}';
  }
}

/// A word-order note on one phrase. Advisory, like everything in the room.
class WordOrderNote {
  const WordOrderNote(this.message);

  final String message;
}

/// One language's formulas, applied.
class GrammarBook {
  GrammarBook(Iterable<GrammarFormula> formulas)
      : inflections =
            List.unmodifiable(formulas.whereType<InflectionFormula>()),
        wordOrder = formulas.whereType<WordOrderFormula>().firstOrNull;

  static final empty = GrammarBook(const []);

  final List<InflectionFormula> inflections;
  final WordOrderFormula? wordOrder;

  bool get isEmpty => inflections.isEmpty && wordOrder == null;

  /// Every form [term] takes, one per applicable rule, in rule order.
  List<ParadigmCell> paradigm(LexiconTerm term) {
    final recorded = term.spellings;
    return [
      for (final formula in inflections)
        if (formula.appliesTo(term))
          () {
            final form = formula.derive(term.term);
            return ParadigmCell(
              formula: formula,
              form: form,
              recorded: form != null && recorded.contains(form.toLowerCase()),
            );
          }(),
    ];
  }

  /// Every form the rules make of [term], lowercase.
  Set<String> derivedForms(LexiconTerm term) => {
        for (final cell in paradigm(term))
          if (cell.form != null) cell.form!.toLowerCase(),
      };

  /// Which words and rules make [word]. Empty when none do.
  List<Analysis> analyze(String word, Iterable<LexiconTerm> lexicon) {
    final lower = word.toLowerCase();
    return [
      for (final term in lexicon)
        for (final formula in inflections)
          if (formula.appliesTo(term) &&
              formula.derive(term.term)?.toLowerCase() == lower)
            Analysis(term: term, formula: formula),
    ];
  }

  /// Word-order notes on a phrase whose words have these [classes], in
  /// order — empty strings for words whose class is unknown. Only what the
  /// classes can show is checked: where the verb falls, and which side of a
  /// noun its adjective sits. Subject and object cannot be told apart from
  /// word classes, so SOV and OSV are one answer here, and said so.
  List<WordOrderNote> checkOrder(List<String> classes) {
    final order = wordOrder;
    if (order == null) return const [];
    final lower = [for (final each in classes) each.trim().toLowerCase()];
    final notes = <WordOrderNote>[];

    final verbs = [
      for (var i = 0; i < lower.length; i++)
        if (lower[i] == 'verb') i,
    ];
    if (verbs.length == 1 && lower.length >= 2) {
      final at = verbs.single;
      final ok = switch (order.verb) {
        VerbPosition.initial => at == 0,
        VerbPosition.last => at == lower.length - 1,
        VerbPosition.medial => at > 0 && at < lower.length - 1,
        VerbPosition.free => true,
      };
      if (!ok) {
        notes.add(WordOrderNote(
            'The verb is word ${at + 1} of ${lower.length}; this language '
            'puts it ${switch (order.verb) {
          VerbPosition.initial => 'first',
          VerbPosition.last => 'last',
          _ => 'between the others',
        }} (${order.verb.formal}).'));
      }
    }

    if (order.adjective != AdjectivePosition.free) {
      for (var i = 0; i < lower.length; i++) {
        if (lower[i] != 'adjective') continue;
        final nounBefore = i > 0 && lower[i - 1] == 'noun';
        final nounAfter = i + 1 < lower.length && lower[i + 1] == 'noun';
        if (order.adjective == AdjectivePosition.before &&
            nounBefore &&
            !nounAfter) {
          notes.add(WordOrderNote(
              'Word ${i + 1} is an adjective after its noun; this language '
              'puts adjectives before the noun.'));
        }
        if (order.adjective == AdjectivePosition.after &&
            nounAfter &&
            !nounBefore) {
          notes.add(WordOrderNote(
              'Word ${i + 1} is an adjective before its noun; this language '
              'puts adjectives after the noun.'));
        }
      }
    }
    return notes;
  }
}

/// Reads the Grammar panel's branch lines: `a => -a +ae`, `* => +i`,
/// `* => ka+`. Every unreadable line is reported, none dropped.
({List<InflectionBranch> branches, List<String> errors}) parseBranches(
    String source) {
  final branches = <InflectionBranch>[];
  final errors = <String>[];
  for (final raw in source.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final arrow = line.indexOf('=>');
    if (arrow < 0) {
      errors.add('"$line" should read like "a => -a +ae" or "* => +i".');
      continue;
    }
    final condition = line.substring(0, arrow).trim().toLowerCase();
    var strip = '';
    var prefix = '';
    var suffix = '';
    var ok = true;
    for (final token
        in line.substring(arrow + 2).trim().split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      if (token.startsWith('-') && token.length > 1) {
        strip = token.substring(1).toLowerCase();
      } else if (token.startsWith('+') && token.length > 1) {
        suffix = token.substring(1).toLowerCase();
      } else if (token.endsWith('+') && token.length > 1) {
        prefix = token.substring(0, token.length - 1).toLowerCase();
      } else {
        errors.add('"$token" in "$line" is not -strip, +suffix or prefix+.');
        ok = false;
      }
    }
    if (!ok) continue;
    if (strip.isEmpty && prefix.isEmpty && suffix.isEmpty) {
      errors.add('"$line" changes nothing.');
      continue;
    }
    final ending = condition == '*' ? '' : condition;
    if (strip.isNotEmpty && !ending.endsWith(strip)) {
      errors.add('"$line" strips "$strip" from words that may not end in it; '
          'make the condition end in "$strip".');
      continue;
    }
    branches.add(InflectionBranch(
        ending: ending, strip: strip, prefix: prefix, suffix: suffix));
  }
  return (branches: branches, errors: errors);
}

/// Reads irregular lines: `mena = menar`.
({Map<String, String> irregular, List<String> errors}) parseIrregulars(
    String source) {
  final irregular = <String, String>{};
  final errors = <String>[];
  for (final raw in source.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final parts = line.split('=');
    if (parts.length != 2 ||
        parts[0].trim().isEmpty ||
        parts[1].trim().isEmpty) {
      errors.add('"$line" should read like "mena = menar".');
      continue;
    }
    irregular[parts[0].trim().toLowerCase()] = parts[1].trim();
  }
  return (irregular: irregular, errors: errors);
}
