/// Language Forge Phase 5 — the sound change engine.
///
/// How a dialect drifts from its language, or a descendant from its ancestor,
/// written the way historical linguists write it:
///
/// ```
/// a > e / _i        a becomes e before i
/// k > ch / _[ie]    k becomes ch before i or e
/// t > d / V_V       t becomes d between vowels
/// h > ∅ / #_        a word-initial h is lost
/// s > z / _#        a final s becomes z
/// ```
///
/// A [SoundChangeSet] is an ordered list of such rules from one language to
/// another. Applied to the source language's lexicon it **proposes** forms for
/// the target — each with the trace of every rule that touched it, which is
/// the word's sound history. A proposal is only a proposal: it becomes a word
/// when the author accepts it, through the Codex's own write path, and nothing
/// here writes anything.
///
/// ## The notation, exactly
///
/// - `target > replacement` — both are spellings; `∅` or `0` as the
///   replacement deletes the target. An empty target is refused: insertion
///   needs an environment to be anything but noise, and is written as a
///   replacement of the neighbouring sound instead.
/// - `/ environment` (optional) — `_` marks where the target stands. Around it:
///   - `#` — the edge of the word;
///   - `[ie]` — any one of the letters inside;
///   - an uppercase letter — any sound of that class in the source language's
///     phonology (`V`, `C`, or the author's own `N`, `L` …);
///   - anything else — itself, literally.
/// - Rules apply in order, each to the output of the one before, left to right
///   across the word, never re-reading its own output.
library;

import 'lexicon.dart';

/// One piece of an environment: a literal, a letter set, a class, or `#`.
sealed class _Slot {
  const _Slot();
}

class _Literal extends _Slot {
  const _Literal(this.text);
  final String text;
}

class _AnyOf extends _Slot {
  const _AnyOf(this.options);
  final List<String> options;
}

class _Boundary extends _Slot {
  const _Boundary();
}

class SoundChange {
  SoundChange._(
    this.text,
    this.target,
    this.replacement,
    this._before,
    this._after,
  );

  /// Parses one rule. [classes] are the source language's phonology classes,
  /// label → spellings, for environment letters like `V`.
  ///
  /// Throws [FormatException] with a sentence an author can act on.
  factory SoundChange.parse(
    String rule, {
    Map<String, List<String>> classes = const {},
  }) {
    final source = rule.trim();
    final arrow = source.indexOf('>');
    if (arrow < 0) {
      throw FormatException('"$source" should read like "a > e / _i".');
    }
    final target = source.substring(0, arrow).trim().toLowerCase();
    final rest = source.substring(arrow + 1);
    final slash = rest.indexOf('/');
    var replacement =
        (slash < 0 ? rest : rest.substring(0, slash)).trim().toLowerCase();
    final environment = slash < 0 ? '' : rest.substring(slash + 1).trim();

    if (target.isEmpty || target == '∅' || target == '0') {
      throw FormatException('"$source" changes nothing into something; '
          'write it as a change to the sound beside it.');
    }
    if (replacement.isEmpty) {
      throw FormatException('"$source" has nothing after ">"; use ∅ for a '
          'sound that is lost.');
    }
    if (replacement == '∅' || replacement == '0') replacement = '';

    var before = <_Slot>[];
    var after = <_Slot>[];
    if (environment.isNotEmpty) {
      final underscore = environment.indexOf('_');
      if (underscore < 0 || environment.indexOf('_', underscore + 1) >= 0) {
        throw FormatException(
            '"$source" needs exactly one "_" after "/" to mark the sound.');
      }
      before = _slots(environment.substring(0, underscore), classes, source);
      after = _slots(environment.substring(underscore + 1), classes, source);
    }
    return SoundChange._(source, target, replacement, before, after);
  }

  static List<_Slot> _slots(
    String text,
    Map<String, List<String>> classes,
    String rule,
  ) {
    final slots = <_Slot>[];
    var index = 0;
    final literal = StringBuffer();
    void flush() {
      if (literal.isNotEmpty) {
        slots.add(_Literal(literal.toString().toLowerCase()));
        literal.clear();
      }
    }

    while (index < text.length) {
      final char = text[index];
      if (char == ' ') {
        index++;
        continue;
      }
      if (char == '#') {
        flush();
        slots.add(const _Boundary());
        index++;
      } else if (char == '[') {
        flush();
        final close = text.indexOf(']', index);
        if (close < 0) throw FormatException('"$rule" has an unclosed "[".');
        final options = [
          for (final option in text.substring(index + 1, close).split(''))
            if (option.trim().isNotEmpty) option.toLowerCase(),
        ];
        if (options.isEmpty) {
          throw FormatException('"$rule" has an empty "[]".');
        }
        slots.add(_AnyOf(options));
        index = close + 1;
      } else if (char.toUpperCase() == char && char.toLowerCase() != char) {
        flush();
        final members = classes[char];
        if (members == null || members.isEmpty) {
          throw FormatException('"$rule" uses class $char, which the source '
              'language\'s sound rules do not define.');
        }
        slots.add(_AnyOf([
          for (final member in members) member.toLowerCase(),
        ]..sort((a, b) => b.length.compareTo(a.length))));
        index++;
      } else {
        literal.write(char);
        index++;
      }
    }
    flush();
    return slots;
  }

  /// The rule as the author wrote it.
  final String text;

  final String target;

  /// Empty for a loss.
  final String replacement;

  final List<_Slot> _before;
  final List<_Slot> _after;

  /// [word] with this rule applied everywhere it fits, left to right.
  String apply(String word) {
    final source = word.toLowerCase();
    final output = StringBuffer();
    var index = 0;
    while (index < source.length) {
      if (source.startsWith(target, index) &&
          _matchesBefore(source, index) &&
          _matchesAfter(source, index + target.length)) {
        output.write(replacement);
        index += target.length;
      } else {
        output.write(source[index]);
        index++;
      }
    }
    return output.toString();
  }

  /// Whether the environment before position [end] fits, reading leftwards.
  bool _matchesBefore(String word, int end) {
    var position = end;
    for (final slot in _before.reversed) {
      switch (slot) {
        case _Boundary():
          if (position != 0) return false;
        case _Literal(:final text):
          if (position < text.length ||
              word.substring(position - text.length, position) != text) {
            return false;
          }
          position -= text.length;
        case _AnyOf(:final options):
          final hit = options.where((option) =>
              position >= option.length &&
              word.substring(position - option.length, position) == option);
          if (hit.isEmpty) return false;
          position -= hit.first.length;
      }
    }
    return true;
  }

  /// Whether the environment from position [start] fits, reading rightwards.
  bool _matchesAfter(String word, int start) {
    var position = start;
    for (final slot in _after) {
      switch (slot) {
        case _Boundary():
          if (position != word.length) return false;
        case _Literal(:final text):
          if (!word.startsWith(text, position)) return false;
          position += text.length;
        case _AnyOf(:final options):
          final hit =
              options.where((option) => word.startsWith(option, position));
          if (hit.isEmpty) return false;
          position += hit.first.length;
      }
    }
    return true;
  }
}

/// One rule that changed a word, and what it changed.
class SoundChangeStep {
  const SoundChangeStep({
    required this.rule,
    required this.before,
    required this.after,
  });

  final String rule;
  final String before;
  final String after;
}

/// Rules from one language to another, in order.
class SoundChangeSet {
  const SoundChangeSet({
    required this.id,
    required this.name,
    required this.fromLanguageId,
    required this.toLanguageId,
    this.rules = const [],
    this.notes = '',
  });

  final String id;

  /// `Old Elvish to Coastal`, `The Great Vowel Shift`.
  final String name;

  /// The ancestor, or the standard a dialect drifts from.
  final String fromLanguageId;

  /// The descendant or dialect.
  final String toLanguageId;

  /// The rules as written, one per entry. Parsed against the source's classes
  /// when applied, so a phonology edit is felt at once.
  final List<String> rules;

  final String notes;

  /// The rules parsed, and every rule that would not parse, by line.
  ({List<SoundChange> changes, List<String> errors}) parse(
      Map<String, List<String>> classes) {
    final changes = <SoundChange>[];
    final errors = <String>[];
    for (final rule in rules) {
      if (rule.trim().isEmpty) continue;
      try {
        changes.add(SoundChange.parse(rule, classes: classes));
      } on FormatException catch (error) {
        errors.add(error.message);
      }
    }
    return (changes: changes, errors: errors);
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'fromLanguageId': fromLanguageId,
        'toLanguageId': toLanguageId,
        'rules': rules,
        if (notes.isNotEmpty) 'notes': notes,
      };

  factory SoundChangeSet.fromJson(Map<String, Object?> json) => SoundChangeSet(
        id: json['id'] as String,
        name: json['name'] as String,
        fromLanguageId: json['fromLanguageId'] as String,
        toLanguageId: json['toLanguageId'] as String,
        rules: List<String>.from(json['rules'] as List? ?? const []),
        notes: json['notes'] as String? ?? '',
      );

  SoundChangeSet copyWith({
    String? name,
    String? fromLanguageId,
    String? toLanguageId,
    List<String>? rules,
    String? notes,
  }) =>
      SoundChangeSet(
        id: id,
        name: name ?? this.name,
        fromLanguageId: fromLanguageId ?? this.fromLanguageId,
        toLanguageId: toLanguageId ?? this.toLanguageId,
        rules: rules ?? this.rules,
        notes: notes ?? this.notes,
      );
}

/// A word carried through a set of changes.
class EvolvedWord {
  const EvolvedWord({
    required this.source,
    required this.form,
    required this.steps,
  });

  final LexiconTerm source;

  /// The proposed form in the target language.
  final String form;

  /// Every rule that changed it, in order. Empty: the word came through
  /// unchanged.
  final List<SoundChangeStep> steps;

  bool get changed => steps.isNotEmpty;

  /// `aran > eran (a > e / _r)`, for the new word's etymology.
  String etymology(String sourceLanguage) {
    final history = steps.isEmpty
        ? 'unchanged'
        : steps.map((step) => '${step.after} (${step.rule})').join(' > ');
    return 'From $sourceLanguage "${source.term}" (${source.gloss}): '
        '${source.term.toLowerCase()} > $history.';
  }
}

abstract final class SoundChangeEngine {
  /// [word] through [changes] in order, with the trace.
  static ({String form, List<SoundChangeStep> steps}) evolve(
    String word,
    List<SoundChange> changes,
  ) {
    var current = word.toLowerCase();
    final steps = <SoundChangeStep>[];
    for (final change in changes) {
      final next = change.apply(current);
      if (next != current) {
        steps.add(
            SoundChangeStep(rule: change.text, before: current, after: next));
        current = next;
      }
    }
    return (form: current, steps: steps);
  }

  /// Every word of [lexicon] carried through [changes]. A capitalised source
  /// word keeps its capital.
  static List<EvolvedWord> propose(
    Iterable<LexiconTerm> lexicon,
    List<SoundChange> changes,
  ) =>
      [
        for (final term in lexicon)
          () {
            final result = evolve(term.term, changes);
            final capital = term.term.isNotEmpty &&
                term.term[0] != term.term[0].toLowerCase();
            final form = capital && result.form.isNotEmpty
                ? result.form[0].toUpperCase() + result.form.substring(1)
                : result.form;
            return EvolvedWord(source: term, form: form, steps: result.steps);
          }(),
      ];

  /// The share of [proposals] no rule touched, 0–1.
  ///
  /// A measure of *sound* only — how much of the vocabulary still sounds the
  /// same — and labelled that way wherever it is shown. It is not mutual
  /// intelligibility, which also turns on grammar, meaning and contact, and
  /// the author decides that; this is one piece of evidence for it.
  static double unchangedShare(List<EvolvedWord> proposals) => proposals.isEmpty
      ? 1
      : proposals.where((word) => !word.changed).length / proposals.length;
}
