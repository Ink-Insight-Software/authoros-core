/// Language Forge Phase 1 — the Sound and Phonology Studio's engine.
///
/// A phonology here is the set of rules that decides whether a string could be
/// a word of one language: which sounds exist, how they group into syllables,
/// which sequences are never heard, and where the stress falls. Everything the
/// Word Forge generates and everything Linguistic Continuity checks against a
/// name is asked of this one object, so a rule the author sets in the Studio is
/// the rule both of them obey.
///
/// ## Spelled, not transcribed
///
/// A [Phoneme] is identified by its **romanised spelling** — `th`, `a`, `kh` —
/// because that is what an author types into a manuscript and what a checker
/// finds there. An IPA value may be recorded beside it for the pronunciation
/// guide; it is description, never identity. Splitting a word into phonemes is
/// longest-match over the inventory's spellings, which is the convention every
/// romanisation with digraphs already relies on: `ng` is one sound when the
/// inventory has `ng`, and two when it does not.
///
/// ## Plain Dart, no randomness
///
/// Nothing here draws a random number, reads the clock or touches a record.
/// Generation lives in `word_forge.dart` and takes its randomness from the one
/// procedural seed engine ADR-0008 settled on.
library;

/// Whether a sound can carry a syllable.
enum SegmentKind { consonant, vowel }

/// One sound of a language, as it is spelled in romanisation.
class Phoneme {
  const Phoneme(
    this.spelling, {
    required this.kind,
    this.weight = 1,
    this.ipa = '',
  })  : assert(spelling != ''),
        assert(weight >= 0);

  /// The romanised spelling, lowercase. This is the phoneme's identity.
  final String spelling;

  final SegmentKind kind;

  /// Relative frequency in generated words. Zero keeps a sound valid in the
  /// language while never offering it — a sound that exists only in loans.
  final int weight;

  /// The author's pronunciation note, in IPA or anything else. Descriptive.
  final String ipa;

  Map<String, Object?> toJson() => {
        'spelling': spelling,
        'kind': kind.name,
        'weight': weight,
        if (ipa.isNotEmpty) 'ipa': ipa,
      };

  factory Phoneme.fromJson(Map<String, Object?> json) => Phoneme(
        (json['spelling'] as String).toLowerCase(),
        kind: SegmentKind.values.byName(json['kind'] as String),
        weight: (json['weight'] as num?)?.toInt() ?? 1,
        ipa: json['ipa'] as String? ?? '',
      );
}

/// One run of class labels in a template, optional as a unit.
///
/// `(C)V(CC)` is three groups: `C` optional, `V` required, `CC` optional —
/// the two final consonants appear together or not at all.
class SyllableGroup {
  const SyllableGroup(this.labels, {required this.optional});

  final List<String> labels;
  final bool optional;
}

/// A syllable shape, written the way conlangers write them: `(C)V(C)`.
///
/// Each letter is a class label, parentheses mark an optional group. Labels
/// are single characters, so `CLV` is three slots.
class SyllableTemplate {
  SyllableTemplate._(this.pattern, this.groups, this.expansions);

  /// Parses [pattern]. Throws [FormatException] for an unbalanced or empty
  /// pattern rather than guessing what it meant.
  factory SyllableTemplate.parse(String pattern) {
    final source = pattern.replaceAll(' ', '');
    if (source.isEmpty) {
      throw const FormatException('A syllable template cannot be empty.');
    }
    final groups = <SyllableGroup>[];
    var index = 0;
    while (index < source.length) {
      final char = source[index];
      if (char == '(') {
        final close = source.indexOf(')', index);
        if (close < 0) {
          throw FormatException('Unclosed "(" in "$pattern".', pattern, index);
        }
        final inner = source.substring(index + 1, close);
        if (inner.isEmpty || inner.contains('(')) {
          throw FormatException(
              'An optional group must hold labels only.', pattern, index);
        }
        groups.add(SyllableGroup(inner.split(''), optional: true));
        index = close + 1;
      } else if (char == ')') {
        throw FormatException('Unopened ")" in "$pattern".', pattern, index);
      } else {
        groups.add(SyllableGroup([char], optional: false));
        index++;
      }
    }
    if (groups.every((group) => group.optional)) {
      throw FormatException(
          'A syllable needs at least one required slot.', pattern);
    }
    return SyllableTemplate._(
      source,
      List.unmodifiable(groups),
      List.unmodifiable(_expand(groups)),
    );
  }

  final String pattern;
  final List<SyllableGroup> groups;

  /// Every concrete label sequence the template allows, shortest first.
  final List<List<String>> expansions;

  Set<String> get labels => {
        for (final group in groups) ...group.labels,
      };

  static List<List<String>> _expand(List<SyllableGroup> groups) {
    var results = <List<String>>[const []];
    for (final group in groups) {
      final next = <List<String>>[];
      for (final prefix in results) {
        if (group.optional) next.add(prefix);
        next.add([...prefix, ...group.labels]);
      }
      results = next;
    }
    // Shortest first, and within a length in the order the pattern produced
    // them — bucketed rather than sorted, because `List.sort` promises no
    // stability and the order is what the generator draws from.
    final byLength = <int, Map<String, List<String>>>{};
    for (final labels in results) {
      (byLength[labels.length] ??= {})
          .putIfAbsent(labels.join(), () => List.unmodifiable(labels));
    }
    final lengths = byLength.keys.toList()..sort();
    return [
      for (final length in lengths) ...byLength[length]!.values,
    ];
  }
}

/// Where a word's main stress falls.
enum StressRule {
  initial,
  finalSyllable,
  penultimate,
  antepenultimate,

  /// The language marks no fixed stress; the guide shows none.
  unmarked;

  /// The stressed syllable of a word of [count] syllables, or null.
  int? stressedIndex(int count) {
    if (count <= 0) return null;
    return switch (this) {
      StressRule.initial => 0,
      StressRule.finalSyllable => count - 1,
      StressRule.penultimate => count >= 2 ? count - 2 : 0,
      StressRule.antepenultimate => count >= 3 ? count - 3 : 0,
      StressRule.unmarked => null,
    };
  }
}

/// Why a string is not a possible word.
enum PhonotacticProblemKind {
  empty,
  unknownSegment,
  unsyllabifiable,
  forbiddenSequence,
  disallowedCluster,
  tooFewSyllables,
  tooManySyllables,
}

class PhonotacticProblem {
  const PhonotacticProblem(this.kind, this.detail);

  final PhonotacticProblemKind kind;

  /// The rule broken, in the author's vocabulary.
  final String detail;

  @override
  String toString() => detail;
}

/// The answer to *could this be a word of the language?*, with its reasons.
class PhonotacticVerdict {
  const PhonotacticVerdict({
    required this.word,
    required this.segments,
    required this.syllables,
    required this.problems,
    this.stressIndex,
  });

  final String word;

  /// The word split into phonemes, or empty when it could not be.
  final List<Phoneme> segments;

  /// One syllabification that satisfies the templates, or empty.
  final List<List<Phoneme>> syllables;

  final List<PhonotacticProblem> problems;

  final int? stressIndex;

  bool get conforms => problems.isEmpty;

  /// `ka-RE-then`: syllables hyphenated, the stressed one in capitals.
  ///
  /// Empty when the word has no syllabification to show.
  String get pronunciationGuide {
    if (syllables.isEmpty) return '';
    final parts = <String>[];
    for (var i = 0; i < syllables.length; i++) {
      final text = syllables[i].map((phoneme) => phoneme.spelling).join();
      parts.add(i == stressIndex ? text.toUpperCase() : text);
    }
    return parts.join('-');
  }
}

/// The sound rules of one language.
class Phonology {
  Phonology({
    required List<Phoneme> inventory,
    required Map<String, List<String>> classes,
    required List<SyllableTemplate> templates,
    List<String> forbiddenSequences = const [],
    List<String> permittedClusters = const [],
    this.stress = StressRule.penultimate,
    this.minSyllables = 1,
    this.maxSyllables = 4,
  })  : assert(minSyllables >= 1),
        assert(maxSyllables >= minSyllables),
        inventory = List.unmodifiable(inventory),
        classes = Map.unmodifiable({
          for (final entry in classes.entries)
            entry.key: List<String>.unmodifiable(
                entry.value.map((spelling) => spelling.toLowerCase())),
        }),
        templates = List.unmodifiable(templates),
        forbiddenSequences = List.unmodifiable(
            forbiddenSequences.map((sequence) => sequence.toLowerCase())),
        permittedClusters = List.unmodifiable(
            permittedClusters.map((cluster) => cluster.toLowerCase())) {
    for (final phoneme in inventory) {
      _bySpelling.putIfAbsent(phoneme.spelling, () => phoneme);
    }
    _spellingsLongestFirst = _bySpelling.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
  }

  static const schemaVersion = 1;

  final List<Phoneme> inventory;

  /// Class label → member spellings. `C` and `V` are conventions, not rules;
  /// an author may define `N` for nasals or `L` for liquids and use them.
  final Map<String, List<String>> classes;

  final List<SyllableTemplate> templates;

  /// Sequences never heard. `^` anchors to the start of a word and `$` to its
  /// end, so `^ng` forbids an initial *ng* and `h$` a final *h*.
  final List<String> forbiddenSequences;

  /// When non-empty, the only consonant runs allowed inside one syllable.
  /// Runs across a syllable boundary are governed by [forbiddenSequences].
  final List<String> permittedClusters;

  final StressRule stress;
  final int minSyllables;
  final int maxSyllables;

  final Map<String, Phoneme> _bySpelling = {};
  late final List<String> _spellingsLongestFirst;

  Phoneme? phoneme(String spelling) => _bySpelling[spelling.toLowerCase()];

  /// Members of a class, resolved to phonemes. Unknown spellings are skipped;
  /// [configurationIssues] reports them.
  List<Phoneme> members(String label) => [
        for (final spelling in classes[label] ?? const <String>[])
          if (_bySpelling[spelling] != null) _bySpelling[spelling]!,
      ];

  /// What in the rules themselves cannot work, before any word is tested.
  List<String> get configurationIssues {
    final issues = <String>[];
    final seen = <String>{};
    for (final phoneme in inventory) {
      if (!seen.add(phoneme.spelling)) {
        issues.add('"${phoneme.spelling}" is in the inventory twice.');
      }
    }
    if (!inventory.any((phoneme) => phoneme.kind == SegmentKind.vowel)) {
      issues.add('The inventory has no vowels.');
    }
    for (final entry in classes.entries) {
      for (final spelling in entry.value) {
        if (!_bySpelling.containsKey(spelling)) {
          issues.add('Class ${entry.key} names "$spelling", which is not in '
              'the inventory.');
        }
      }
    }
    if (templates.isEmpty) issues.add('No syllable template is defined.');
    for (final template in templates) {
      for (final label in template.labels) {
        if (!classes.containsKey(label)) {
          issues.add('Template ${template.pattern} uses class $label, which '
              'is not defined.');
        } else if (members(label).isEmpty) {
          issues.add('Template ${template.pattern} uses class $label, which '
              'has no sounds.');
        }
      }
    }
    return issues;
  }

  /// Splits [word] into phonemes by longest match, or returns the index of
  /// the first character no phoneme spells.
  ({List<Phoneme> segments, int? unknownAt}) segment(String word) {
    final source = word.toLowerCase();
    final segments = <Phoneme>[];
    var index = 0;
    while (index < source.length) {
      Phoneme? match;
      for (final spelling in _spellingsLongestFirst) {
        if (source.startsWith(spelling, index)) {
          match = _bySpelling[spelling];
          break;
        }
      }
      if (match == null) return (segments: segments, unknownAt: index);
      segments.add(match);
      index += match.spelling.length;
    }
    return (segments: segments, unknownAt: null);
  }

  /// Could [word] be a word of this language?
  PhonotacticVerdict validate(String word) {
    final source = word.trim().toLowerCase();
    if (source.isEmpty) {
      return PhonotacticVerdict(
        word: word,
        segments: const [],
        syllables: const [],
        problems: const [
          PhonotacticProblem(
              PhonotacticProblemKind.empty, 'The word is empty.'),
        ],
      );
    }

    final problems = <PhonotacticProblem>[];
    final split = segment(source);
    if (split.unknownAt != null) {
      final at = split.unknownAt!;
      problems.add(PhonotacticProblem(
        PhonotacticProblemKind.unknownSegment,
        '"${source.substring(at, at + 1)}" at position ${at + 1} is not a '
        'sound of this language.',
      ));
    }

    for (final sequence in forbiddenSequences) {
      if (_containsForbidden(source, sequence)) {
        problems.add(PhonotacticProblem(
          PhonotacticProblemKind.forbiddenSequence,
          _describeForbidden(sequence),
        ));
      }
    }

    if (split.unknownAt != null) {
      return PhonotacticVerdict(
        word: word,
        segments: const [],
        syllables: const [],
        problems: List.unmodifiable(problems),
      );
    }

    final segments = split.segments;
    final syllables = _syllabify(segments);
    if (syllables == null) {
      problems.add(PhonotacticProblem(
        PhonotacticProblemKind.unsyllabifiable,
        'No arrangement of the syllable shapes '
        '${templates.map((template) => template.pattern).join(', ')} '
        'produces "$source".',
      ));
      return PhonotacticVerdict(
        word: word,
        segments: List.unmodifiable(segments),
        syllables: const [],
        problems: List.unmodifiable(problems),
      );
    }

    if (permittedClusters.isNotEmpty) {
      for (final syllable in syllables) {
        for (final cluster in _consonantRuns(syllable)) {
          if (!permittedClusters.contains(cluster)) {
            problems.add(PhonotacticProblem(
              PhonotacticProblemKind.disallowedCluster,
              '"$cluster" is not a permitted consonant cluster.',
            ));
          }
        }
      }
    }

    if (syllables.length < minSyllables) {
      problems.add(PhonotacticProblem(
        PhonotacticProblemKind.tooFewSyllables,
        'Words have at least $minSyllables syllable'
        '${minSyllables == 1 ? '' : 's'}; this has ${syllables.length}.',
      ));
    } else if (syllables.length > maxSyllables) {
      problems.add(PhonotacticProblem(
        PhonotacticProblemKind.tooManySyllables,
        'Words have at most $maxSyllables syllables; this has '
        '${syllables.length}.',
      ));
    }

    return PhonotacticVerdict(
      word: word,
      segments: List.unmodifiable(segments),
      syllables: List.unmodifiable(syllables),
      problems: List.unmodifiable(problems),
      stressIndex: stress.stressedIndex(syllables.length),
    );
  }

  /// One syllabification of [segments], or null when none exists.
  ///
  /// Solved from the end: `parse[i]` is a valid split of everything from `i`.
  /// At each position the shortest syllable that leaves a parseable remainder
  /// is taken, which hands consonants to the *following* syllable's onset when
  /// the templates allow either — the maximal-onset reading a speaker expects
  /// (`a-tha`, not `ath-a`).
  List<List<Phoneme>>? _syllabify(List<Phoneme> segments) {
    final length = segments.length;
    final parse = List<List<List<Phoneme>>?>.filled(length + 1, null);
    parse[length] = const [];
    for (var start = length - 1; start >= 0; start--) {
      for (final size in _syllableSizes) {
        final end = start + size;
        if (end > length || parse[end] == null) continue;
        final candidate = segments.sublist(start, end);
        if (_isSyllable(candidate)) {
          parse[start] = [candidate, ...parse[end]!];
          break;
        }
      }
    }
    return parse[0];
  }

  late final List<int> _syllableSizes = () {
    final sizes = <int>{
      for (final template in templates)
        for (final labels in template.expansions) labels.length,
    }.toList()
      ..sort();
    return sizes.where((size) => size > 0).toList();
  }();

  bool _isSyllable(List<Phoneme> candidate) {
    for (final template in templates) {
      for (final labels in template.expansions) {
        if (labels.length != candidate.length) continue;
        var fits = true;
        for (var i = 0; i < labels.length; i++) {
          final members = classes[labels[i]];
          if (members == null || !members.contains(candidate[i].spelling)) {
            fits = false;
            break;
          }
        }
        if (fits) return true;
      }
    }
    return false;
  }

  static Iterable<String> _consonantRuns(List<Phoneme> syllable) sync* {
    final run = StringBuffer();
    var count = 0;
    for (final phoneme in syllable) {
      if (phoneme.kind == SegmentKind.consonant) {
        run.write(phoneme.spelling);
        count++;
      } else {
        if (count >= 2) yield run.toString();
        run.clear();
        count = 0;
      }
    }
    if (count >= 2) yield run.toString();
  }

  static bool _containsForbidden(String word, String sequence) {
    final initial = sequence.startsWith('^');
    final last = sequence.endsWith(r'$');
    final core = sequence.substring(
        initial ? 1 : 0, last ? sequence.length - 1 : sequence.length);
    if (core.isEmpty) return false;
    if (initial && last) return word == core;
    if (initial) return word.startsWith(core);
    if (last) return word.endsWith(core);
    return word.contains(core);
  }

  static String _describeForbidden(String sequence) {
    if (sequence.startsWith('^') && sequence.endsWith(r'$')) {
      return '"${sequence.substring(1, sequence.length - 1)}" is forbidden as '
          'a whole word.';
    }
    if (sequence.startsWith('^')) {
      return '"${sequence.substring(1)}" is forbidden at the start of a word.';
    }
    if (sequence.endsWith(r'$')) {
      return '"${sequence.substring(0, sequence.length - 1)}" is forbidden at '
          'the end of a word.';
    }
    return '"$sequence" is a forbidden sequence.';
  }

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'inventory': [for (final phoneme in inventory) phoneme.toJson()],
        'classes': classes,
        'templates': [for (final template in templates) template.pattern],
        'forbiddenSequences': forbiddenSequences,
        'permittedClusters': permittedClusters,
        'stress': stress.name,
        'minSyllables': minSyllables,
        'maxSyllables': maxSyllables,
      };

  /// Reads a phonology back. A newer schema than this build knows is refused
  /// rather than half-read — the caller keeps the stored JSON untouched.
  factory Phonology.fromJson(Map<String, Object?> json) {
    final version = (json['schemaVersion'] as num?)?.toInt() ?? 1;
    if (version > schemaVersion) {
      throw FormatException('Phonology schema $version is newer than '
          '$schemaVersion; this build cannot read it.');
    }
    return Phonology(
      inventory: [
        for (final raw in json['inventory'] as List)
          Phoneme.fromJson(Map<String, Object?>.from(raw as Map)),
      ],
      classes: {
        for (final entry in (json['classes'] as Map).entries)
          entry.key as String: List<String>.from(entry.value as List),
      },
      templates: [
        for (final pattern in json['templates'] as List)
          SyllableTemplate.parse(pattern as String),
      ],
      forbiddenSequences:
          List<String>.from(json['forbiddenSequences'] as List? ?? const []),
      permittedClusters:
          List<String>.from(json['permittedClusters'] as List? ?? const []),
      stress:
          StressRule.values.byName(json['stress'] as String? ?? 'penultimate'),
      minSyllables: (json['minSyllables'] as num?)?.toInt() ?? 1,
      maxSyllables: (json['maxSyllables'] as num?)?.toInt() ?? 4,
    );
  }
}
