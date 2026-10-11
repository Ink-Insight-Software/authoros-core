/// Language Forge Phase 2 — the Study's one read of a project.
///
/// Reads the canonical records once and hands every surface in the room the
/// same projection: the languages and dialects, the scripts, the lexicon as
/// [LexiconTerm]s, the grammar rules, and the names the cast and the atlas
/// carry with the language each belongs to. Nothing is copied into the room;
/// every projection carries the record id it came from, and editing goes back
/// to the owning Studio.
///
/// ## Reading fields the way they are written
///
/// `lexicon-entry.language` is a record reference, which the free editors store
/// as the referenced record's id. Older projects and hand-edited ones may hold a
/// title instead, so a reference that matches no id is tried against language
/// titles before it is given up on. `inflections` is a table field no free
/// editor writes yet; its reader accepts the shapes a table plausibly takes —
/// rows of cells, a list of strings, a map of labels to forms, or plain text —
/// and treats every cell as a recorded form.
///
/// ## Which language a name belongs to
///
/// A character or place that `speaks` exactly one language has names in that
/// language. One that speaks two or more is not guessed at: a bilingual
/// character's name could be either, and a sound-rule finding against the
/// wrong language is worse than none.
library;

import '../connected_domain.dart';
import '../connected_domain_repository.dart';
import '../language_record_types.dart';
import 'lexicon.dart';
import 'lineage.dart';
import 'linguistic_continuity.dart';

class LinguistsStudySnapshot {
  const LinguistsStudySnapshot({
    required this.languages,
    required this.writingSystems,
    required this.lexiconRecords,
    required this.lexicon,
    required this.grammarRules,
    required this.names,
    this.languageLinks = const [],
    this.wordLinks = const [],
  });

  static const empty = LinguistsStudySnapshot(
    languages: [],
    writingSystems: [],
    lexiconRecords: [],
    lexicon: [],
    grammarRules: [],
    names: [],
  );

  /// `language` and `dialect` records, by title.
  final List<AuthorRecord> languages;
  final List<AuthorRecord> writingSystems;
  final List<AuthorRecord> lexiconRecords;
  final List<LexiconTerm> lexicon;
  final List<AuthorRecord> grammarRules;
  final List<LinguisticName> names;

  /// Descent, dialect and borrowing links between languages.
  final List<LineageLink> languageLinks;

  /// Descent and borrowing links between Lexicon Entries.
  final List<LineageLink> wordLinks;

  Lineage get languageFamily =>
      Lineage([for (final language in languages) language.id], languageLinks);

  Lineage get wordHistory =>
      Lineage([for (final term in lexicon) term.recordId], wordLinks);

  bool get isEmpty =>
      languages.isEmpty && writingSystems.isEmpty && lexicon.isEmpty;

  AuthorRecord? languageById(String id) {
    for (final language in languages) {
      if (language.id == id) return language;
    }
    return null;
  }

  List<LexiconTerm> lexiconFor(String languageId) => [
        for (final term in lexicon)
          if (term.languageId == languageId) term
      ];

  List<AuthorRecord> grammarFor(String languageId) => [
        for (final rule in grammarRules)
          if (_text(rule.fields['language']) == languageId) rule,
      ];

  /// Words already spoken for in [languageId], so generation never repeats one.
  Set<String> spellingsIn(String languageId) => {
        for (final term in lexiconFor(languageId)) ...term.spellings,
        for (final name in names)
          if (name.languageId == languageId)
            for (final (:word, start: _) in wordsIn(name.name))
              word.toLowerCase(),
      };
}

class LinguistsStudyReadModel {
  LinguistsStudyReadModel({
    required this.projectId,
    required this.recordsByProject,
    required this.linksByScope,
    this.tagsByProject,
  });

  factory LinguistsStudyReadModel.fromRepository({
    required String projectId,
    required ConnectedDomainRepository repository,
  }) =>
      LinguistsStudyReadModel(
        projectId: projectId,
        recordsByProject: repository.recordsByProject,
        linksByScope: repository.linksByScope,
        tagsByProject: (projectId) => repository.recordsByTypeAndScope(
          typeId: codexTagTypeId,
          scopeId: projectId,
        ),
      );

  /// The Codex's tag record type. Its records hold a tag's name as the title
  /// and its id in `tagId`; an entry's `tags` hold the ids.
  static const codexTagTypeId = 'codexTag';

  final String projectId;
  final Future<List<AuthorRecord>> Function(String projectId) recordsByProject;
  final Future<List<RecordLink>> Function(String scopeId) linksByScope;

  /// The Codex's tag records, for themed collections. Null: themes are shown
  /// by their ids.
  final Future<List<AuthorRecord>> Function(String projectId)? tagsByProject;

  /// Records whose names are read against a language's sound rules.
  static const namedTypeIds = <String>{
    'character',
    'person',
    'historical-figure',
    'location',
    'place',
    'faction',
    'house',
    'clan',
  };

  static const _languageTypes = {
    LanguageRecordTypes.languageTypeId,
    LanguageRecordTypes.dialectTypeId,
  };

  Future<LinguistsStudySnapshot> load() async {
    final records = [
      for (final record in await recordsByProject(projectId))
        if (record.status == AuthorRecordStatus.active) record,
    ];
    if (records.isEmpty) return LinguistsStudySnapshot.empty;

    List<AuthorRecord> ofType(Set<String> typeIds) => [
          for (final record in records)
            if (typeIds.contains(record.typeId)) record,
        ]..sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final languages = ofType(_languageTypes);
    if (languages.isEmpty &&
        !records.any((record) =>
            LanguageRecordTypes.recordTypeIds.contains(record.typeId))) {
      return LinguistsStudySnapshot.empty;
    }

    final lexiconRecords = ofType({LanguageRecordTypes.lexiconEntryTypeId});
    final resolveLanguage = _languageResolver(languages);

    final tagNames = <String, String>{};
    final readTags = tagsByProject;
    if (readTags != null) {
      for (final tag in await readTags(projectId)) {
        final tagId = tag.fields['tagId'];
        tagNames[tagId is String && tagId.isNotEmpty ? tagId : tag.id] =
            tag.title;
      }
    }

    final lexicon = [
      for (final record in lexiconRecords)
        lexiconTermFromRecord(
          record,
          resolveLanguage: resolveLanguage,
          tagNames: tagNames,
        ),
    ];

    final languageIds = {for (final language in languages) language.id};
    final wordIds = {for (final record in lexiconRecords) record.id};
    final languageLinks = <LineageLink>[
      // A dialect's own field is its first parent.
      for (final dialect in languages)
        if (dialect.typeId == LanguageRecordTypes.dialectTypeId)
          if (resolveLanguage(_text(dialect.fields['parentLanguage']))
              case final parent when languageIds.contains(parent))
            LineageLink(
              childId: dialect.id,
              parentId: parent,
              kind: LineageKind.dialect,
            ),
    ];
    final wordLinks = <LineageLink>[];

    final spoken = <String, Set<String>>{};
    for (final link in await linksByScope(projectId)) {
      final kind = switch (link.typeId) {
        'originatedFrom' => LineageKind.descent,
        'influences' => LineageKind.borrowing,
        _ => null,
      };
      if (kind != null) {
        // originatedFrom: younger → older. influences: lender → borrower,
        // so the borrower is the child.
        final (child, parent) = kind == LineageKind.borrowing
            ? (link.targetId, link.sourceId)
            : (link.sourceId, link.targetId);
        final lineage =
            LineageLink(childId: child, parentId: parent, kind: kind);
        if (languageIds.contains(child) && languageIds.contains(parent)) {
          languageLinks.add(lineage);
        } else if (wordIds.contains(child) && wordIds.contains(parent)) {
          wordLinks.add(lineage);
        }
        continue;
      }
      if (link.typeId != 'speaks') continue;
      final String speaker;
      final String language;
      if (languageIds.contains(link.targetId)) {
        speaker = link.sourceId;
        language = link.targetId;
      } else if (languageIds.contains(link.sourceId)) {
        speaker = link.targetId;
        language = link.sourceId;
      } else {
        continue;
      }
      (spoken[speaker] ??= {}).add(language);
    }

    final names = <LinguisticName>[];
    for (final record in records) {
      if (!namedTypeIds.contains(record.typeId)) continue;
      final languagesSpoken = spoken[record.id];
      if (languagesSpoken == null || languagesSpoken.length != 1) continue;
      if (record.title.trim().isEmpty) continue;
      names.add(LinguisticName(
        recordId: record.id,
        name: record.title.trim(),
        languageId: languagesSpoken.single,
      ));
    }
    names.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return LinguistsStudySnapshot(
      languages: List.unmodifiable(languages),
      writingSystems:
          List.unmodifiable(ofType({LanguageRecordTypes.writingSystemTypeId})),
      lexiconRecords: List.unmodifiable(lexiconRecords),
      lexicon: List.unmodifiable(lexicon),
      grammarRules:
          List.unmodifiable(ofType({LanguageRecordTypes.grammarRuleTypeId})),
      names: List.unmodifiable(names),
      languageLinks: List.unmodifiable(languageLinks),
      wordLinks: List.unmodifiable(wordLinks),
    );
  }

  static String Function(String) _languageResolver(
      List<AuthorRecord> languages) {
    final ids = {for (final language in languages) language.id};
    final byTitle = <String, String>{};
    final duplicated = <String>{};
    for (final language in languages) {
      final key = language.title.trim().toLowerCase();
      if (byTitle.containsKey(key)) duplicated.add(key);
      byTitle[key] = language.id;
    }
    return (reference) {
      final value = reference.trim();
      if (value.isEmpty || ids.contains(value)) return value;
      final key = value.toLowerCase();
      // Two languages with one title cannot be told apart by it.
      if (duplicated.contains(key)) return value;
      return byTitle[key] ?? value;
    };
  }
}

/// A [LexiconTerm] read off one `lexicon-entry` record.
///
/// The record's own title stands in for an empty `term`, because an author who
/// quick-creates *aran* has typed the word into the title and nowhere else.
LexiconTerm lexiconTermFromRecord(
  AuthorRecord record, {
  String Function(String reference)? resolveLanguage,
  Map<String, String> tagNames = const {},
}) {
  final term = _text(record.fields['term']);
  final language = _text(record.fields['language']);
  return LexiconTerm(
    recordId: record.id,
    term: term.isEmpty ? record.title.trim() : term,
    gloss: _text(record.fields['gloss']),
    languageId: resolveLanguage == null ? language : resolveLanguage(language),
    wordClass: _text(record.fields['wordClass']),
    forms: inflectedForms(record.fields['inflections']),
    themes: [
      for (final tag in record.tags)
        if (tag.trim().isNotEmpty) tagNames[tag] ?? tag,
    ],
  );
}

/// Every cell of an `inflections` value, in order, blanks and duplicates gone.
List<String> inflectedForms(Object? value) {
  final forms = <String>[];
  void take(Object? cell) {
    if (cell == null) return;
    if (cell is String) {
      for (final part in cell.split(RegExp(r'[\n,;]'))) {
        final form = part.trim();
        if (form.isNotEmpty && !forms.contains(form)) forms.add(form);
      }
    } else if (cell is Map) {
      for (final nested in cell.values) {
        take(nested);
      }
    } else if (cell is Iterable) {
      for (final nested in cell) {
        take(nested);
      }
    }
  }

  take(value);
  return forms;
}

String _text(Object? value) => value is String ? value.trim() : '';
