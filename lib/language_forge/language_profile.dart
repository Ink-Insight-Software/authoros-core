/// Language Forge Phase 3 — the Language Profile.
///
/// The brief's *Language Profile Template*: identity, speakers and regions,
/// sound, script, grammar, vocabulary, naming, dialects, history, cultural
/// usage and relationships. It is **not** a second record. Every section is a
/// reading of what the author already keeps — the `language` record's own
/// fields, the lexicon, grammar rules and dialects that point at it, and the
/// Study's working layer — and each says what it found and what would finish
/// it. Filling a section means going where that thing lives; the report points.
///
/// ## Core and optional
///
/// A language may have no dialects and no recorded relatives and be complete;
/// those two sections are reported and never required. *Master Linguist —
/// complete every core section* is [LanguageProfileReport.isComplete].
///
/// ## Fields the brief names that the record lacks
///
/// Native name, literacy rate, writing direction beyond the script's, mutual
/// intelligibility at the language level, second-language speakers and
/// development status are not fields of `language` today. They belong in
/// `language_record_types.dart` as a proposal to AOS Write, not in a sidecar
/// here, which would make this room a second owner of a language's identity.
library;

import '../connected_domain.dart';
import '../language_record_types.dart';
import 'language_forge_workspace.dart';
import 'linguists_study_read_model.dart';

enum ProfileStatus { empty, started, complete }

enum ProfileSectionKind {
  identity,
  speakers,
  sound,
  script,
  grammar,
  vocabulary,
  naming,
  history,
  culture,
  dialects,
  relationships;

  String get title => switch (this) {
        ProfileSectionKind.identity => 'Identity',
        ProfileSectionKind.speakers => 'Speakers and regions',
        ProfileSectionKind.sound => 'Sound system',
        ProfileSectionKind.script => 'Script',
        ProfileSectionKind.grammar => 'Grammar',
        ProfileSectionKind.vocabulary => 'Vocabulary',
        ProfileSectionKind.naming => 'Naming conventions',
        ProfileSectionKind.history => 'History',
        ProfileSectionKind.culture => 'Cultural usage',
        ProfileSectionKind.dialects => 'Dialects',
        ProfileSectionKind.relationships => 'Language relationships',
      };

  /// Whether *every core section* includes this one.
  bool get isCore => switch (this) {
        ProfileSectionKind.dialects ||
        ProfileSectionKind.relationships =>
          false,
        _ => true,
      };

  /// The Study panel that finishes this section, by its slug — or null where
  /// the answer lives on the Codex record itself.
  String? get panelSlug => switch (this) {
        ProfileSectionKind.sound => 'sound',
        ProfileSectionKind.script => 'script',
        ProfileSectionKind.vocabulary => 'dictionary',
        ProfileSectionKind.naming => 'naming',
        ProfileSectionKind.grammar => 'grammar',
        ProfileSectionKind.dialects ||
        ProfileSectionKind.relationships =>
          'family',
        _ => null,
      };
}

class ProfileSection {
  const ProfileSection({
    required this.kind,
    required this.status,
    this.found = const [],
    this.missing = const [],
  });

  final ProfileSectionKind kind;
  final ProfileStatus status;

  /// What is already there, in a phrase each.
  final List<String> found;

  /// What would finish the section, in a phrase each.
  final List<String> missing;
}

class LanguageProfileReport {
  const LanguageProfileReport({
    required this.languageId,
    required this.sections,
  });

  final String languageId;
  final List<ProfileSection> sections;

  Iterable<ProfileSection> get core =>
      sections.where((section) => section.kind.isCore);

  int get coreComplete =>
      core.where((section) => section.status == ProfileStatus.complete).length;

  int get coreTotal => core.length;

  /// Every core section complete — the brief's *Master Linguist*.
  bool get isComplete => coreComplete == coreTotal;

  ProfileSection of(ProfileSectionKind kind) =>
      sections.firstWhere((section) => section.kind == kind);
}

/// How many words make a vocabulary rather than a start — the brief's
/// *First Words* milestone.
const profileVocabularyTarget = 10;

LanguageProfileReport languageProfile({
  required AuthorRecord language,
  required LinguistsStudySnapshot snapshot,
  required LanguageForgeWorkspace workspace,
}) {
  String text(String field) {
    final value = language.fields[field];
    if (value is String) return value.trim();
    if (value is Iterable) {
      return value
          .map((each) => '$each'.trim())
          .where((each) => each.isNotEmpty)
          .join(', ');
    }
    return '';
  }

  ProfileSection fromFields(
    ProfileSectionKind kind,
    Map<String, String> fields,
  ) {
    final found = <String>[];
    final missing = <String>[];
    fields.forEach((field, label) {
      (text(field).isEmpty ? missing : found).add(label);
    });
    return ProfileSection(
      kind: kind,
      status: missing.isEmpty
          ? ProfileStatus.complete
          : found.isEmpty
              ? ProfileStatus.empty
              : ProfileStatus.started,
      found: found,
      missing: missing,
    );
  }

  final id = language.id;
  final sections = <ProfileSection>[];

  sections.add(fromFields(ProfileSectionKind.identity, const {
    'family': 'Family',
    'vitality': 'Vitality',
  }));

  final speakers = fromFields(ProfileSectionKind.speakers, const {
    'speakers': 'Who speaks it',
    'region': 'Where it is spoken',
  });
  final speaking = snapshot.names.where((name) => name.languageId == id).length;
  sections.add(ProfileSection(
    kind: speakers.kind,
    status: speakers.status == ProfileStatus.empty && speaking > 0
        ? ProfileStatus.started
        : speakers.status,
    found: [
      ...speakers.found,
      if (speaking > 0)
        '$speaking ${speaking == 1 ? 'record speaks' : 'records speak'} it',
    ],
    missing: speakers.missing,
  ));

  final phonology = workspace.phonologies[id];
  final prose = text('phonology').isNotEmpty || text('prosody').isNotEmpty;
  sections.add(phonology != null && phonology.configurationIssues.isEmpty
      ? const ProfileSection(
          kind: ProfileSectionKind.sound,
          status: ProfileStatus.complete,
          found: ['Sound rules set in the Study'],
        )
      : ProfileSection(
          kind: ProfileSectionKind.sound,
          status: prose || phonology != null
              ? ProfileStatus.started
              : ProfileStatus.empty,
          found: [
            if (prose) 'Sound described on the record',
            if (phonology != null) 'Sound rules begun',
          ],
          missing: const ['Sound rules the Study can test words against'],
        ));

  final scriptId = text('writingSystem');
  final mapped = scriptId.isNotEmpty && workspace.scripts.containsKey(scriptId);
  sections.add(ProfileSection(
    kind: ProfileSectionKind.script,
    status: mapped
        ? ProfileStatus.complete
        : scriptId.isNotEmpty
            ? ProfileStatus.started
            : ProfileStatus.empty,
    found: [
      if (scriptId.isNotEmpty) 'Writing system chosen',
      if (mapped) 'Its letters mapped',
    ],
    missing: [
      if (scriptId.isEmpty) 'A Writing System on the record',
      if (!mapped) 'The script\'s letters mapped in the Study',
    ],
  ));

  final rules = snapshot.grammarFor(id).length;
  final summary = text('grammarSummary').isNotEmpty;
  sections.add(ProfileSection(
    kind: ProfileSectionKind.grammar,
    status: summary && rules > 0
        ? ProfileStatus.complete
        : summary || rules > 0
            ? ProfileStatus.started
            : ProfileStatus.empty,
    found: [
      if (summary) 'Grammar described',
      if (rules > 0) '$rules grammar ${rules == 1 ? 'rule' : 'rules'}',
    ],
    missing: [
      if (!summary) 'The grammar in prose on the record',
      if (rules == 0) 'At least one Grammar Rule',
    ],
  ));

  final words = snapshot.lexiconFor(id).length;
  sections.add(ProfileSection(
    kind: ProfileSectionKind.vocabulary,
    status: words >= profileVocabularyTarget
        ? ProfileStatus.complete
        : words > 0
            ? ProfileStatus.started
            : ProfileStatus.empty,
    found: [if (words > 0) '$words ${words == 1 ? 'word' : 'words'}'],
    missing: [
      if (words < profileVocabularyTarget)
        '${profileVocabularyTarget - words} more '
            '${profileVocabularyTarget - words == 1 ? 'word' : 'words'}',
    ],
  ));

  final conventions = workspace.conventionsFor(id).length;
  final namingProse = text('namingConventions').isNotEmpty;
  sections.add(ProfileSection(
    kind: ProfileSectionKind.naming,
    status: conventions > 0
        ? ProfileStatus.complete
        : namingProse
            ? ProfileStatus.started
            : ProfileStatus.empty,
    found: [
      if (namingProse) 'Naming described on the record',
      if (conventions > 0)
        '$conventions naming ${conventions == 1 ? 'convention' : 'conventions'}',
    ],
    missing: [if (conventions == 0) 'A naming convention in the Study'],
  ));

  sections.add(fromFields(ProfileSectionKind.history, const {
    'history': 'History',
  }));
  sections.add(fromFields(ProfileSectionKind.culture, const {
    'culturalRole': 'Cultural role',
    'register': 'Registers',
  }));

  final dialects = [
    for (final record in snapshot.languages)
      if (record.typeId == LanguageRecordTypes.dialectTypeId &&
          record.fields['parentLanguage'] == id)
        record,
  ];
  sections.add(ProfileSection(
    kind: ProfileSectionKind.dialects,
    status: dialects.isEmpty ? ProfileStatus.empty : ProfileStatus.complete,
    found: [
      if (dialects.isNotEmpty)
        '${dialects.length} ${dialects.length == 1 ? 'dialect' : 'dialects'}',
    ],
    missing: [if (dialects.isEmpty) 'Optional: a Dialect of this language'],
  ));

  final influences = text('influences').isNotEmpty || text('family').isNotEmpty;
  sections.add(ProfileSection(
    kind: ProfileSectionKind.relationships,
    status: influences ? ProfileStatus.complete : ProfileStatus.empty,
    found: [if (influences) 'Family or influences recorded'],
    missing: [
      if (!influences) 'Optional: the languages it came from or borrowed from',
    ],
  ));

  return LanguageProfileReport(
    languageId: id,
    sections: List.unmodifiable(sections),
  );
}
