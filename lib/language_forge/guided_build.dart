/// Language Forge Phase 3 — the Guided Build.
///
/// The Constructed Language Builder's middle level: five plain-language
/// questions — how the language feels, how its syllables are built, how long
/// its words run, where the weight falls, and what it never says — answered
/// into the same [PhonologyText] the Sound panel edits. There is no second
/// model and no hidden step: an author who finishes the guide lands in the
/// Advanced fields with every rule written out, and can change any of them.
///
/// The four levels are four ways into one set of rules:
///
/// | Level | Starts from |
/// |---|---|
/// | Quick | [starterPhonology] — one tap |
/// | Guided | [guidedPhonology] — five questions |
/// | Advanced | the fields themselves |
/// | Blank | nothing |
///
/// Every answer maps to a fixed, readable choice. Nothing here is random and
/// nothing is inferred; the same answers always give the same rules.
library;

import 'phonology.dart';
import 'phonology_text.dart';

/// How the language feels in the mouth.
enum SoundTexture {
  soft,
  balanced,
  harsh;

  String get label => switch (this) {
        SoundTexture.soft => 'Soft and flowing',
        SoundTexture.balanced => 'Balanced',
        SoundTexture.harsh => 'Hard and clipped',
      };
}

/// How much a syllable may carry.
enum SyllableComplexity {
  simple,
  moderate,
  complex;

  String get label => switch (this) {
        SyllableComplexity.simple => 'Simple — ka, lo, mi',
        SyllableComplexity.moderate => 'Moderate — kan, lor, mis',
        SyllableComplexity.complex => 'Clustered — kran, stol, blin',
      };
}

/// How long words usually run.
enum WordLength {
  short,
  medium,
  long;

  String get label => switch (this) {
        WordLength.short => 'Short — one or two syllables',
        WordLength.medium => 'Medium — one to three',
        WordLength.long => 'Long — two to four',
      };
}

/// The author's answers.
class GuidedAnswers {
  const GuidedAnswers({
    this.texture = SoundTexture.balanced,
    this.complexity = SyllableComplexity.moderate,
    this.length = WordLength.medium,
    this.stress = StressRule.penultimate,
    this.avoid = '',
  });

  final SoundTexture texture;
  final SyllableComplexity complexity;
  final WordLength length;
  final StressRule stress;

  /// Sounds the language never uses, as spellings: `z q x`. Removed from the
  /// palette before anything else is decided.
  final String avoid;
}

/// The rules [answers] describe, as the Sound panel's fields.
PhonologyText guidedPhonology(GuidedAnswers answers) {
  final avoided = {
    for (final token in answers.avoid.toLowerCase().split(RegExp(r'[\s,]+')))
      if (token.isNotEmpty) token,
  };

  final consonants = [
    for (final entry in _consonants[answers.texture]!)
      if (!avoided.contains(entry.$1)) entry,
  ];
  final vowels = [
    for (final entry in _vowels[answers.texture]!)
      if (!avoided.contains(entry.$1)) entry,
  ];

  // The coda and cluster classes are chosen from what survived the avoid list,
  // so a class never names a sound the inventory no longer has.
  bool kept(String spelling) => consonants.any((entry) => entry.$1 == spelling);
  final codas = [
    for (final spelling in const ['n', 'm', 'r', 'l', 's'])
      if (kept(spelling)) spelling,
  ];
  final liquids = [
    for (final spelling in const ['r', 'l'])
      if (kept(spelling)) spelling,
  ];

  final classes = <String>[];
  var templates = '(C)V';
  switch (answers.complexity) {
    case SyllableComplexity.simple:
      break;
    case SyllableComplexity.moderate:
      if (codas.isNotEmpty) {
        classes.add('N = ${codas.join(' ')}');
        templates = '(C)V(N)';
      }
    case SyllableComplexity.complex:
      if (codas.isNotEmpty) classes.add('N = ${codas.join(' ')}');
      if (liquids.isNotEmpty) classes.add('L = ${liquids.join(' ')}');
      templates = [
        codas.isEmpty ? '(C)V' : '(C)V(N)',
        if (liquids.isNotEmpty) 'CLV${codas.isEmpty ? '' : '(N)'}',
      ].join(', ');
  }

  final (minimum, maximum) = switch (answers.length) {
    WordLength.short => (1, 2),
    WordLength.medium => (1, 3),
    WordLength.long => (2, 4),
  };

  String sounds(List<(String, int)> entries) => [
        for (final (spelling, weight) in entries)
          weight == 1 ? spelling : '$spelling:$weight',
      ].join(' ');

  return PhonologyText(
    consonants: sounds(consonants),
    vowels: sounds(vowels),
    classes: classes.join('\n'),
    templates: templates,
    // Doubled vowels read as typing errors in almost every romanisation, so
    // the guide forbids them; an author who wants them deletes the line.
    forbidden: [
      for (final (vowel, _) in vowels) '$vowel$vowel',
    ].join(' '),
    stress: answers.stress,
    minSyllables: minimum,
    maxSyllables: maximum,
  );
}

/// Sound palettes, most characteristic sounds weighted highest.
const _consonants = <SoundTexture, List<(String, int)>>{
  SoundTexture.soft: [
    ('l', 4),
    ('r', 3),
    ('n', 4),
    ('m', 3),
    ('v', 2),
    ('s', 2),
    ('th', 2),
    ('h', 1),
    ('w', 1),
    ('y', 1),
    ('f', 1),
  ],
  SoundTexture.balanced: [
    ('k', 3),
    ('t', 3),
    ('d', 2),
    ('l', 3),
    ('r', 3),
    ('n', 3),
    ('m', 2),
    ('s', 2),
    ('v', 1),
    ('th', 1),
    ('g', 1),
  ],
  SoundTexture.harsh: [
    ('k', 4),
    ('g', 3),
    ('t', 3),
    ('d', 3),
    ('r', 3),
    ('z', 2),
    ('kh', 2),
    ('sh', 1),
    ('b', 2),
    ('n', 2),
    ('m', 1),
    ('s', 1),
  ],
};

const _vowels = <SoundTexture, List<(String, int)>>{
  SoundTexture.soft: [('a', 4), ('e', 4), ('i', 3), ('o', 2), ('u', 1)],
  SoundTexture.balanced: [('a', 4), ('e', 3), ('i', 2), ('o', 2), ('u', 1)],
  SoundTexture.harsh: [('a', 3), ('o', 3), ('u', 3), ('e', 1), ('i', 1)],
};
