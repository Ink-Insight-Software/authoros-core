/// Language Forge — the Linguist's Study's working layer, as a value.
///
/// The five canonical language record types stay where they are: in the
/// connected domain. This is only what the Study adds over them — a
/// structured [Phonology] per `language` or `dialect` record, a
/// [ScriptMapping] per `writing-system` record, naming conventions, grammar
/// formulas, sound change sets, the words an author has dismissed from
/// Linguistic Continuity, and the generated words they have reserved.
///
/// ## Why it is in the core
///
/// Each application keeps this layer in its own store, outside the world's
/// records: AuthorOS Write's Language Forge and AOS Worldsmith's Linguist's
/// Study both keep one envelope per project in `SharedPreferences`. A store is
/// the application's business; the *value* is not. A project carried between
/// the two, or through a `.authoros` archive, must arrive with its phonologies
/// readable on the other side, so the model and its JSON live here once and
/// travel as an archive extension document ([extensionId]).
///
/// It was moved here from the DLC's `language_forge_store.dart` unchanged in
/// behaviour; the store class stayed behind, because it reads
/// `shared_preferences` and the core is pure Dart.
library;

import 'grammar.dart';
import 'naming_conventions.dart';
import 'phonology.dart';
import 'script_mapping.dart';
import 'sound_change.dart';

/// A generated word the author has put aside, not yet saved to a record.
///
/// Reserving is how a name stays out of the next generation run without the
/// author having to decide today what it names. [seedPath] reproduces it.
class ReservedWord {
  const ReservedWord({
    required this.spelling,
    required this.languageId,
    this.note = '',
    this.seedPath = const [],
  });

  final String spelling;
  final String languageId;
  final String note;
  final List<String> seedPath;

  Map<String, Object?> toJson() => {
        'spelling': spelling,
        'languageId': languageId,
        if (note.isNotEmpty) 'note': note,
        if (seedPath.isNotEmpty) 'seedPath': seedPath,
      };

  factory ReservedWord.fromJson(Map<String, Object?> json) => ReservedWord(
        spelling: json['spelling'] as String,
        languageId: json['languageId'] as String,
        note: json['note'] as String? ?? '',
        seedPath: List<String>.from(json['seedPath'] as List? ?? const []),
      );
}

/// Everything the Study keeps for one project.
class LanguageForgeWorkspace {
  LanguageForgeWorkspace({
    Map<String, Phonology> phonologies = const {},
    Map<String, ScriptMapping> scripts = const {},
    Set<String> ignoredWords = const {},
    List<ReservedWord> reserved = const [],
    List<NamingConvention> conventions = const [],
    Map<String, GrammarFormula> grammar = const {},
    List<SoundChangeSet> soundChanges = const [],
    this.skippedOnRead = 0,
  })  : phonologies = Map.unmodifiable(phonologies),
        soundChanges = List.unmodifiable(soundChanges),
        grammar = Map.unmodifiable(grammar),
        conventions = List.unmodifiable(conventions),
        scripts = Map.unmodifiable(scripts),
        ignoredWords = Set.unmodifiable(
            ignoredWords.map((word) => word.trim().toLowerCase())),
        reserved = List.unmodifiable(reserved);

  static final empty = LanguageForgeWorkspace();

  /// The extension id this layer travels under in an archive's
  /// `extensionDocuments`. Stable: renaming it orphans every archive written
  /// with the old one.
  static const extensionId = 'language-forge';

  /// The envelope's schema. 2 added naming conventions, 3 grammar formulas,
  /// 4 sound change sets. A reader meeting a newer one reads nothing and must
  /// write nothing over it; see [fromDocument].
  static const int schemaVersion = 4;

  /// Keyed by the `language` or `dialect` record id.
  final Map<String, Phonology> phonologies;

  /// Keyed by the `writing-system` record id.
  final Map<String, ScriptMapping> scripts;

  /// Words dismissed from Linguistic Continuity, lowercase.
  final Set<String> ignoredWords;

  final List<ReservedWord> reserved;

  /// Naming conventions, in the order the author made them. Added in store
  /// schema 2.
  final List<NamingConvention> conventions;

  /// Grammar formulas, keyed by the `grammar-rule` record each belongs to.
  /// Added in store schema 3.
  final Map<String, GrammarFormula> grammar;

  /// Sound change sets, in the order the author made them. Added in store
  /// schema 4.
  final List<SoundChangeSet> soundChanges;

  /// The formulas of one language, applied.
  GrammarBook grammarBookFor(String languageId) => GrammarBook([
        for (final formula in grammar.values)
          if (formula.languageId == languageId) formula,
      ]);

  List<NamingConvention> conventionsFor(String languageId) => [
        for (final convention in conventions)
          if (convention.languageId == languageId) convention,
      ];

  bool get isEmpty =>
      phonologies.isEmpty &&
      scripts.isEmpty &&
      ignoredWords.isEmpty &&
      reserved.isEmpty &&
      conventions.isEmpty &&
      grammar.isEmpty &&
      soundChanges.isEmpty;

  /// Sets, or with null removes, the phonology for [languageId].
  LanguageForgeWorkspace withPhonology(String languageId, Phonology? value) {
    final next = {...phonologies}..remove(languageId);
    if (value != null) next[languageId] = value;
    return _copy(phonologies: next);
  }

  /// Sets, or with null removes, the script table for [writingSystemId].
  LanguageForgeWorkspace withScript(
      String writingSystemId, ScriptMapping? value) {
    final next = {...scripts}..remove(writingSystemId);
    if (value != null) next[writingSystemId] = value;
    return _copy(scripts: next);
  }

  LanguageForgeWorkspace ignoring(String word) =>
      _copy(ignoredWords: {...ignoredWords, word});

  LanguageForgeWorkspace unignoring(String word) =>
      _copy(ignoredWords: {...ignoredWords}..remove(word.trim().toLowerCase()));

  LanguageForgeWorkspace reserving(ReservedWord word) => _copy(reserved: [
        for (final existing in reserved)
          if (existing.spelling.toLowerCase() != word.spelling.toLowerCase())
            existing,
        word,
      ]);

  LanguageForgeWorkspace releasing(String spelling) => _copy(reserved: [
        for (final existing in reserved)
          if (existing.spelling.toLowerCase() != spelling.toLowerCase())
            existing,
      ]);

  /// Adds [convention], or replaces the one with its id in place.
  LanguageForgeWorkspace withConvention(NamingConvention convention) {
    final index = conventions.indexWhere((each) => each.id == convention.id);
    final next = [...conventions];
    if (index < 0) {
      next.add(convention);
    } else {
      next[index] = convention;
    }
    return _copy(conventions: next);
  }

  /// Sets, or with null removes, the formula for grammar rule [ruleId].
  LanguageForgeWorkspace withGrammar(String ruleId, GrammarFormula? formula) {
    final next = {...grammar}..remove(ruleId);
    if (formula != null) next[ruleId] = formula;
    return _copy(grammar: next);
  }

  /// Adds [set], or replaces the one with its id in place.
  LanguageForgeWorkspace withSoundChanges(SoundChangeSet set) {
    final index = soundChanges.indexWhere((each) => each.id == set.id);
    final next = [...soundChanges];
    if (index < 0) {
      next.add(set);
    } else {
      next[index] = set;
    }
    return _copy(soundChanges: next);
  }

  LanguageForgeWorkspace withoutSoundChanges(String id) => _copy(soundChanges: [
        for (final set in soundChanges)
          if (set.id != id) set,
      ]);

  LanguageForgeWorkspace withoutConvention(String id) => _copy(conventions: [
        for (final convention in conventions)
          if (convention.id != id) convention,
      ]);

  /// This workspace with every record id it holds rewritten through
  /// [oldToNew]: the keys of [phonologies], [scripts] and [grammar], and each
  /// language, writing-system and scope reference inside them.
  ///
  /// For a world imported or duplicated with fresh record ids — without it the
  /// phonologies would still be keyed to ids the new world does not have, and
  /// would read as missing. An id [oldToNew] does not name is kept as it is:
  /// a reference to a record outside the copy is not this method's to guess.
  /// Naming convention and sound change set ids are the layer's own, not
  /// record ids, and are kept.
  ///
  /// Goes through the JSON, so it is exactly [remapDocumentIds] read back.
  LanguageForgeWorkspace remapIds(Map<String, String> oldToNew) {
    if (oldToNew.isEmpty) return this;
    return LanguageForgeWorkspace.fromJson(_remapBody(toJson(), oldToNew));
  }

  /// [remapIds] on an archive document ([toDocument]'s shape), without
  /// reading it into this build's model.
  ///
  /// A document written by a newer build cannot be read here, but its ids can
  /// still be moved — which keeps it intact for the build that can read it,
  /// instead of dropping what this one does not understand.
  static Map<String, Object?> remapDocumentIds(
    Map<String, Object?> document,
    Map<String, String> oldToNew,
  ) {
    final body = document['workspace'];
    if (oldToNew.isEmpty || body is! Map) return document;
    return {
      ...document,
      'workspace': _remapBody(Map<String, Object?>.from(body), oldToNew),
    };
  }

  static Map<String, Object?> _remapBody(
    Map<String, Object?> body,
    Map<String, String> oldToNew,
  ) {
    String id(Object? value) => oldToNew[value] ?? value as String;
    Object? remapFields(Object? value, Set<String> fields) {
      if (value is! Map) return value;
      return {
        for (final entry in value.entries)
          entry.key as String:
              fields.contains(entry.key) && entry.value is String
                  ? id(entry.value)
                  : entry.value,
      };
    }

    Object? keyed(Object? value, Set<String> fields) {
      if (value is! Map) return value;
      return {
        for (final entry in value.entries)
          id(entry.key): remapFields(entry.value, fields),
      };
    }

    Object? listed(Object? value, Set<String> fields) {
      if (value is! List) return value;
      return [for (final each in value) remapFields(each, fields)];
    }

    return {
      ...body,
      if (body.containsKey('phonologies'))
        'phonologies': keyed(body['phonologies'], const {}),
      if (body.containsKey('scripts'))
        'scripts': keyed(body['scripts'], const {'writingSystemRecordId'}),
      if (body.containsKey('grammar'))
        'grammar': keyed(body['grammar'], const {'languageId'}),
      if (body.containsKey('reserved'))
        'reserved': listed(body['reserved'], const {'languageId'}),
      if (body.containsKey('conventions'))
        'conventions':
            listed(body['conventions'], const {'languageId', 'scopeRecordId'}),
      if (body.containsKey('soundChanges'))
        'soundChanges': listed(
            body['soundChanges'], const {'fromLanguageId', 'toLanguageId'}),
    };
  }

  LanguageForgeWorkspace _copy({
    Map<String, Phonology>? phonologies,
    Map<String, ScriptMapping>? scripts,
    Set<String>? ignoredWords,
    List<ReservedWord>? reserved,
    List<NamingConvention>? conventions,
    Map<String, GrammarFormula>? grammar,
    List<SoundChangeSet>? soundChanges,
  }) =>
      LanguageForgeWorkspace(
        phonologies: phonologies ?? this.phonologies,
        scripts: scripts ?? this.scripts,
        ignoredWords: ignoredWords ?? this.ignoredWords,
        reserved: reserved ?? this.reserved,
        conventions: conventions ?? this.conventions,
        grammar: grammar ?? this.grammar,
        soundChanges: soundChanges ?? this.soundChanges,
      );

  Map<String, Object?> toJson() => {
        'phonologies': {
          for (final entry in phonologies.entries)
            entry.key: entry.value.toJson(),
        },
        'scripts': {
          for (final entry in scripts.entries) entry.key: entry.value.toJson(),
        },
        'ignoredWords': ignoredWords.toList()..sort(),
        'reserved': [for (final word in reserved) word.toJson()],
        'conventions': [
          for (final convention in conventions) convention.toJson(),
        ],
        'grammar': {
          for (final entry in grammar.entries) entry.key: entry.value.toJson(),
        },
        'soundChanges': [for (final set in soundChanges) set.toJson()],
      };

  /// The workspace as one archive extension document: the schema beside the
  /// body, the envelope AuthorOS Write's store has always written, less the
  /// project id the archive entry already carries.
  Map<String, Object?> toDocument() => {
        'schemaVersion': schemaVersion,
        'workspace': toJson(),
      };

  /// Reads [toDocument]'s shape. Missing or malformed is an empty workspace —
  /// *no Language Forge work yet*, never a broken project. A newer schema
  /// than [schemaVersion] reads as nothing with [skippedOnRead] set, so a
  /// caller that checks it never saves over work it cannot see.
  static LanguageForgeWorkspace fromDocument(Object? document) {
    if (document is! Map) return empty;
    try {
      final envelope = Map<String, Object?>.from(document);
      final version = (envelope['schemaVersion'] as num?)?.toInt() ?? 1;
      if (version > schemaVersion) {
        return LanguageForgeWorkspace(skippedOnRead: 1);
      }
      final body = envelope['workspace'];
      if (body is! Map) return empty;
      return LanguageForgeWorkspace.fromJson(Map<String, Object?>.from(body));
    } catch (_) {
      return empty;
    }
  }

  /// Reads a workspace, skipping — never throwing on — any entry this build
  /// cannot read. A newer phonology schema is skipped rather than half-read,
  /// which is why a store must refuse to overwrite a sidecar that held entries
  /// this read could not represent ([skippedOnRead]).
  factory LanguageForgeWorkspace.fromJson(Map<String, Object?> json) {
    final phonologies = <String, Phonology>{};
    final scripts = <String, ScriptMapping>{};
    var skipped = 0;

    final rawPhonologies = json['phonologies'];
    if (rawPhonologies is Map) {
      for (final entry in rawPhonologies.entries) {
        try {
          phonologies[entry.key as String] =
              Phonology.fromJson(Map<String, Object?>.from(entry.value as Map));
        } catch (_) {
          skipped++;
        }
      }
    }
    final rawScripts = json['scripts'];
    if (rawScripts is Map) {
      for (final entry in rawScripts.entries) {
        try {
          scripts[entry.key as String] = ScriptMapping.fromJson(
              Map<String, Object?>.from(entry.value as Map));
        } catch (_) {
          skipped++;
        }
      }
    }
    final reserved = <ReservedWord>[];
    final rawReserved = json['reserved'];
    if (rawReserved is List) {
      for (final raw in rawReserved) {
        try {
          reserved.add(
              ReservedWord.fromJson(Map<String, Object?>.from(raw as Map)));
        } catch (_) {
          skipped++;
        }
      }
    }
    final conventions = <NamingConvention>[];
    final rawConventions = json['conventions'];
    if (rawConventions is List) {
      for (final raw in rawConventions) {
        try {
          conventions.add(
              NamingConvention.fromJson(Map<String, Object?>.from(raw as Map)));
        } catch (_) {
          skipped++;
        }
      }
    }
    final grammar = <String, GrammarFormula>{};
    final rawGrammar = json['grammar'];
    if (rawGrammar is Map) {
      for (final entry in rawGrammar.entries) {
        try {
          grammar[entry.key as String] = GrammarFormula.fromJson(
              Map<String, Object?>.from(entry.value as Map));
        } catch (_) {
          skipped++;
        }
      }
    }
    final soundChanges = <SoundChangeSet>[];
    final rawChanges = json['soundChanges'];
    if (rawChanges is List) {
      for (final raw in rawChanges) {
        try {
          soundChanges.add(
              SoundChangeSet.fromJson(Map<String, Object?>.from(raw as Map)));
        } catch (_) {
          skipped++;
        }
      }
    }
    final rawIgnored = json['ignoredWords'];
    return LanguageForgeWorkspace(
      phonologies: phonologies,
      scripts: scripts,
      ignoredWords: {
        if (rawIgnored is List)
          for (final word in rawIgnored)
            if (word is String) word,
      },
      reserved: reserved,
      conventions: conventions,
      grammar: grammar,
      soundChanges: soundChanges,
      skippedOnRead: skipped,
    );
  }

  /// Entries the read could not represent. Non-zero makes a save unsafe.
  /// Never carried into a copy: an edited workspace is this build's own.
  final int skippedOnRead;
}
