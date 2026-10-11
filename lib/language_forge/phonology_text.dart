/// Language Forge Phase 2 — the Phonology Studio's plain-text form.
///
/// The Studio edits a [Phonology] as a handful of short text fields, because
/// that is how a conlanger already writes one down: `k:3 t th:2 r l`,
/// `(C)V(N)`, `N = n m`. This file turns those fields into rules and back, and
/// reports every line it could not read rather than dropping it — an editor
/// that silently discards half a sound inventory is worse than one that
/// refuses to save.
///
/// Plain Dart, so the round trip is tested without a widget.
library;

import 'phonology.dart';

/// The Studio's fields, as the author typed them.
class PhonologyText {
  const PhonologyText({
    this.consonants = '',
    this.vowels = '',
    this.classes = '',
    this.templates = '',
    this.forbidden = '',
    this.clusters = '',
    this.stress = StressRule.penultimate,
    this.minSyllables = 1,
    this.maxSyllables = 4,
  });

  /// `k:3 t th:2` — spelling, then an optional `:weight`.
  final String consonants;
  final String vowels;

  /// One class per line: `N = n m`. `C` and `V` default to every consonant
  /// and every vowel; a line naming either replaces the default.
  final String classes;

  /// `(C)V(N), CLV` — comma, space or line separated.
  final String templates;

  final String forbidden;
  final String clusters;
  final StressRule stress;
  final int minSyllables;
  final int maxSyllables;

  /// The fields for [phonology], ready to edit.
  factory PhonologyText.from(Phonology phonology) {
    String sounds(SegmentKind kind) => [
          for (final phoneme in phonology.inventory)
            if (phoneme.kind == kind)
              phoneme.weight == 1
                  ? phoneme.spelling
                  : '${phoneme.spelling}:${phoneme.weight}',
        ].join(' ');

    final consonants = {
      for (final phoneme in phonology.inventory)
        if (phoneme.kind == SegmentKind.consonant) phoneme.spelling,
    };
    final vowels = {
      for (final phoneme in phonology.inventory)
        if (phoneme.kind == SegmentKind.vowel) phoneme.spelling,
    };
    bool isDefault(String label, List<String> members) =>
        (label == 'C' && _sameSet(members, consonants)) ||
        (label == 'V' && _sameSet(members, vowels));

    return PhonologyText(
      consonants: sounds(SegmentKind.consonant),
      vowels: sounds(SegmentKind.vowel),
      classes: [
        for (final entry in phonology.classes.entries)
          if (!isDefault(entry.key, entry.value))
            '${entry.key} = ${entry.value.join(' ')}',
      ].join('\n'),
      templates:
          phonology.templates.map((template) => template.pattern).join(', '),
      forbidden: phonology.forbiddenSequences.join(' '),
      clusters: phonology.permittedClusters.join(' '),
      stress: phonology.stress,
      minSyllables: phonology.minSyllables,
      maxSyllables: phonology.maxSyllables,
    );
  }

  /// Reads the fields. [previous] carries IPA notes across an edit, since the
  /// text form has no column for them and an author's transcription must not
  /// vanish because a weight was changed.
  PhonologyReading read({Phonology? previous}) {
    final errors = <String>[];
    final ipa = {
      for (final phoneme in previous?.inventory ?? const <Phoneme>[])
        if (phoneme.ipa.isNotEmpty) phoneme.spelling: phoneme.ipa,
    };

    final inventory = <Phoneme>[];
    final seen = <String>{};
    void readSounds(String source, SegmentKind kind) {
      for (final token in _tokens(source)) {
        final parts = token.split(':');
        final spelling = parts.first.toLowerCase();
        if (spelling.isEmpty || parts.length > 2) {
          errors.add('"$token" is not a sound. Write it as "th" or "th:2".');
          continue;
        }
        var weight = 1;
        if (parts.length == 2) {
          final parsed = int.tryParse(parts[1]);
          if (parsed == null || parsed < 0) {
            errors.add('"$token" has a weight that is not a whole number.');
            continue;
          }
          weight = parsed;
        }
        if (!seen.add(spelling)) {
          errors.add('"$spelling" is listed more than once.');
          continue;
        }
        inventory.add(Phoneme(spelling,
            kind: kind, weight: weight, ipa: ipa[spelling] ?? ''));
      }
    }

    readSounds(consonants, SegmentKind.consonant);
    readSounds(vowels, SegmentKind.vowel);

    final classMap = <String, List<String>>{
      'C': [
        for (final phoneme in inventory)
          if (phoneme.kind == SegmentKind.consonant) phoneme.spelling,
      ],
      'V': [
        for (final phoneme in inventory)
          if (phoneme.kind == SegmentKind.vowel) phoneme.spelling,
      ],
    };
    for (final line in classes.split('\n')) {
      if (line.trim().isEmpty) continue;
      final equals = line.indexOf('=');
      final label = equals < 0 ? '' : line.substring(0, equals).trim();
      if (label.length != 1 || label == '(' || label == ')') {
        errors.add('"${line.trim()}" should read like "N = n m": one letter, '
            'then the sounds.');
        continue;
      }
      classMap[label] = [
        for (final token in _tokens(line.substring(equals + 1)))
          token.toLowerCase(),
      ];
    }

    final parsedTemplates = <SyllableTemplate>[];
    for (final pattern in _tokens(templates)) {
      try {
        parsedTemplates.add(SyllableTemplate.parse(pattern));
      } on FormatException catch (error) {
        errors.add('Syllable shape "$pattern": ${error.message}');
      }
    }

    // Clamped so the tester still has a phonology to run; the error below is
    // what stops the clamped value being saved as if the author chose it.
    final minimum = minSyllables < 1 ? 1 : minSyllables;
    final maximum = maxSyllables < minimum ? minimum : maxSyllables;
    if (minSyllables < 1 || maxSyllables < minSyllables) {
      errors.add('Word length must be at least one syllable, and the most '
          'cannot be fewer than the least.');
    }

    final phonology = Phonology(
      inventory: inventory,
      classes: classMap,
      templates: parsedTemplates,
      forbiddenSequences: _tokens(forbidden).toList(),
      permittedClusters: _tokens(clusters).toList(),
      stress: stress,
      minSyllables: minimum,
      maxSyllables: maximum,
    );
    return PhonologyReading(
      phonology: phonology,
      errors: List.unmodifiable([...errors, ...phonology.configurationIssues]),
    );
  }

  static Iterable<String> _tokens(String source) => source
      .split(RegExp(r'[\s,]+'))
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty);

  static bool _sameSet(List<String> members, Set<String> expected) =>
      members.length == expected.length && expected.containsAll(members);
}

/// What the fields say, and everything wrong with them.
class PhonologyReading {
  const PhonologyReading({required this.phonology, required this.errors});

  /// Always built, so the example-word tester keeps working while the author
  /// is mid-edit. Only a reading with no [errors] may be saved.
  final Phonology phonology;

  final List<String> errors;

  bool get canSave => errors.isEmpty;
}

/// Quick Build's starting point: a small, pleasant sound system an author can
/// generate names from at once and reshape at leisure. Deliberately ordinary —
/// the author's changes are what make it theirs.
Phonology starterPhonology() => const PhonologyText(
      consonants: 'k:3 t:3 th:2 r:3 l:3 n:3 m:2 s:2 v:1 d:2',
      vowels: 'a:4 e:3 i:2 o:2 u:1',
      classes: 'N = n m r l s',
      templates: '(C)V(N)',
      forbidden: '^r aa ee ii oo uu',
      stress: StressRule.penultimate,
      minSyllables: 1,
      maxSyllables: 4,
    ).read().phonology;
