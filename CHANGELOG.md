# Changelog

## 0.20.0

Reference attachments, and the archive carries attached files (October 16,
2026). Additive: nothing is removed or renamed.

- **`ResearchReferences`** (`research_reference.dart`). A reference picture
  or PDF is a Research Studio entry (`research-entry`) of kind *Reference*,
  with its file under the per-record asset role `reference`. Its caption,
  notes, credit and source link are the entry's `summary`, `notes`,
  `citation` and `sourceUrl`; no new record type and no new field. It
  documents records through the existing `documents` connection, so one
  file attached to several records is stored once. A reference is written
  non-canon, and attaching one changes no field of the record it documents.
  `sniff` reads JPEG, PNG, GIF, WebP and PDF from the file's own bytes;
  `rejection` refuses an empty file, an unknown type, and anything over
  10 MB, which is under the archive's 16 MB limit on one entry.
- **`RecordAsset`** (`record_asset.dart`): one row of the per-record asset
  table in transit, every role (avatar, voice, reference, and roles a later
  build adds).
- **The archive carries record assets.** `exportSnapshot(recordAssets:)`
  writes `data/record-assets.jsonl` (one line per asset, keyed
  `projectId|recordId|role`) and each file once under
  `assets/sha256/<digest>`, with its own media type in the manifest.
  `AuthorOsArchiveContents.recordAssets` reads them back, and a line whose
  file is missing or altered fails the import. An archive without assets is
  byte-identical to one written before; an older build reads a newer archive
  and ignores the files. Export refuses two assets under one key and a file
  larger than one archive entry may be. Until now no avatar, voice note or
  attachment travelled in a backup.
- `ArchiveInspection.attachedFiles` counts them, and the summary says so.
- **Tests** for the round trip, content addressing, byte-identical output,
  determinism, refusals, tampering, and the reference model.

## 0.19.0

For Language Forge's speaker profiles (October 16, 2026). Additive: nothing
is removed or renamed.

- **`speaks` declares `fluency`, `literacy` and `accent`**, beside the Codex
  metadata it already carried. Fluency is a single choice of Native, Fluent,
  Conversational, Basic or Understands only; literacy of Reads and writes,
  Reads only or Spoken only. Both accept the author's own word, as
  `partnerOf`'s `union` does. Accent is short text. The Codex's `strength`
  stays the relationship's, not the speaker's.
- A `speaks` link without them validates as before, and no other Codex
  relationship gains them. The archive carries link metadata as written, so
  nothing there changes.
- **Tests** for the declaration, an author's own word, an old link, and a
  value of the wrong type.

## 0.18.0

Two changes (October 16, 2026). AOS Worldsmith can delete a scenario the author discards, rather than
archive it, and AuthorOS Write can mount Language Forge. **Breaking for implementers**: every
`ConnectedDomainRepository` must add one method. Nothing is removed or
renamed.

- **`ConnectedDomainRepository.deleteBranch(branchId)`** removes a story
  branch, its record and link overlays, and every version and audit event
  filed under it, in one transaction, and returns how many rows went. Canon
  and other branches are untouched.
- **`BranchService.deleteBranch(branchId)`** is the way to call it. It
  refuses a branch that is not the project's, and a branch another branch
  descends from.
- **Tests** for the service's refusals and its call through.
- **`languageForgeEnabled`** in `build_flags.dart`, read from
  `AOS_ENABLE_LANGUAGE_FORGE` (October 16, 2026). Const-shaped like the
  other two flags and off by default, so AuthorOS Write can mount the
  Linguist's Study as a page of the Story Codex and a build without the
  define drops the room's code, words and address from its bundle. It gates
  the room only; `lib/language_forge/` is unaffected. A test holds that each
  flag reads its own define and stays a `const bool.fromEnvironment`.

## 0.17.0

For AOS Worldsmith's scenario workshop and its Observatory (October 11,
2026). Additive: nothing is removed or renamed.

- **`BranchService` and `TemplateEngine` moved here** from AuthorOS Write
  (`lib/branch_service.dart`, `lib/template_engine.dart`), beside
  `branch_domain.dart` and `branch_engine.dart`, so an application other
  than AuthorOS Write can save a `whatIf` branch. Behaviour is unchanged;
  one unused private helper was dropped. AuthorOS Write's old paths are
  one-line exports of these.
- **Nine more edges carry a consequence** in
  `ConsequenceTraversal.defaultRules`: `ruledBy`, `occupies`, `signed`,
  `requires`, `usedBy`, `uses`, `routeFrom`, `routeTo` and `practices`,
  each the twin of an edge already ruled on. They were AOS Worldsmith's
  `ObservatoryRules`, and keep its directions and words. A walk given the
  default rules now reaches a treaty's signatories, a route's ends and a
  resource's users.
- **Tests** that every default rule names a built-in edge and that no edge
  is ruled on twice (a second rule would silently replace the first).

## 0.16.0

So the Linguist's Study can open in AOS Worldsmith without losing an
author's work (October 11, 2026). Additive: nothing is removed or renamed.

- **The archive carries every extension's per-project working layer.**
  `AuthorOsArchiveContents.extensionDocuments`, and the matching
  `exportSnapshot` parameter, hold `{extension, projectId, document}` entries
  at `data/extension-documents.jsonl`, keyed `"$extension:$projectId"`. One
  generic slot rather than one per extension, so Hearts & Tensions' sidecar
  can travel the way Language Forge's now does. Written only when non-empty,
  so an archive without it is byte-identical to a 0.15.0 one; optional on
  read; an entry without its extension or project fails the export.
  `extensionDocumentsFor(extension)` reads one extension's documents back.
- **Language Forge's pure-Dart model moved here** from AuthorOS Write's
  Language Forge expansion, under `lib/language_forge/`, one library per file
  and `lib/language_forge.dart` exporting them all: phonology, the
  phonology text form and guided build, the word and name forges, naming
  conventions, script mapping, grammar, the translation workbench, sound
  change, lexicon, lineage, Linguistic Continuity, the Study's read model,
  the language profile, and the working layer itself
  (`LanguageForgeWorkspace`, `ReservedWord`). Behaviour is unchanged; the
  expansion's files are now one-line exports of these. The
  `SharedPreferences` store stayed in the expansion.
- **`LanguageForgeWorkspace` gains** `extensionId` (`language-forge`),
  `schemaVersion`, `toDocument`/`fromDocument` for the archive slot, and
  `remapIds`/`remapDocumentIds`, so a world imported or duplicated with fresh
  record ids keeps its phonologies, scripts, grammar and conventions keyed to
  the new ids.
- **The package's first tests of its own**, under `test/`, with `test` as a
  dev dependency only. The older ones still live in AOS-Write.

## 0.15.0

For AOS Worldsmith's Phases 5 to 8 (October 10, 2026). Additive: no type,
field or edge is removed or renamed.

- **Six new record types**, each checked against the tree first:
  - `religious-order`, a faction child, and `denomination`, a religion child
    (`FaithInstitutionRecordTypes`);
  - `legal-code`, which a law joins by `partOf`, and `court`,
    `military-force` and `intelligence-service`, all faction children
    (`LawAndWarRecordTypes`).
- **New fields:**
  - `world.currentEra` says which era is now (`world` template version 2).
  - `house` and `clan` gain `inheritedTraits`, `bloodlineRequirements` and
    `hiddenAncestry` (in `sharedFieldIds`), under a *The blood* section
    (template version 3).
- **Four new edges:**
  - `variesIn`: a culture's regional or generational variant, with what
    differs;
  - `produces`: what a people, place, faction, government or person makes;
  - `tradesWith`: undirected, with the goods traded;
  - `atWarWith`: undirected and time-bounded, between powers.
- **`app_presence.dart`**: which application last opened a project, and
  when, so a world moved between AOS Worldsmith and AuthorOS Write can say
  so. It uses one organisational record per project, the shape
  `PinnedRecords` uses.
- **`consequence_traversal.dart`**: given a changed record, the records it
  may affect, by per-edge-type rules, each with the shortest path that
  reaches it. It is deterministic and writes nothing.

## 0.14.0

- **The archive carries a project's spatial document.**
  `AuthorOsArchiveContents.cartographerDocuments` holds one document per
  project, as Cartographer wrote it, at `data/cartographer-documents.jsonl`.
  Opaque here for the same reason `manuscripts` is: maps and plans belong to
  Cartographer (Casebook ADR-0001, rule 4), and importing its document model
  would put a second description of a place in the core.
- **So that a project stays one file.** The alternative was a `.cartographer`
  package beside the project that an author has to keep alongside it, which is
  how projects lose their maps.
- **Additive, and byte-identical without one.** The entry is written only when
  there is a document, so an archive from a project with no map is unchanged
  from one written before this version. On read it is optional: absence means
  *"this file says nothing about a map"*, never *"this project has no map"* —
  the same terms as the roster.
- **`ArchiveInspection` counts them** as `mappedProjects`, and counts them in
  `isEmpty`, so an archive holding a project's maps and nothing else is not
  reported as holding nothing.

## 0.13.0

- **`title` and `estate`, new Bloodlines types** (October 10, 2026, for AOS
  Worldsmith's Ancestry Room). A title is a dignity a family holds and
  passes (rank, holder, House, estate, the rule it passes by, heir, former
  holders, who granted it); an estate is land held by right (holder, seat,
  lands, title, yield, obligations, entail). Free types with free fields, as
  `house` and `clan` are. Neither is `political-office`, which is a post a
  government fills.
- **`partnerOf` gains `union`** (betrothed, married, separated, divorced,
  annulled, widowed) and **`parentOf` gains `legitimacy` and `parentage`**,
  as link metadata beside the existing dates. Links without them read as
  before.
- **`story_graph.dart` and `story_graph_modes.dart` move in** from AuthorOS
  Write's `lib/core/`, unchanged, so the Loom's canvas can move to
  `authoros_ui`.
- `BloodlineRecordTypes.kinTypeIds`: `house` and `clan`, the two kinship
  types the inherited and shared field lists describe. `recordTypeIds` is
  all four.

## 0.12.0

- **`pinned_records.dart`, moved in from AOS-Write.** `PinnedRecords` says
  where a project's pinned records live: a Story Codex collection of kind
  `pinned`, one record per project, `codex-collection-pinned-<projectId>`,
  listing the pinned ids in pin order. AOS Worldsmith pins with the same
  record, so neither application keeps its own pinning model.
- **One record per project, not one for all.** AOS-Write kept a single
  `codex-collection-pinned` for every project; records are written by
  upsert, so opening a second project's Codex took it over, empty, and the
  first project's pins were lost. A project whose `codex-collection-pinned`
  is still scoped to it keeps using it (`collectionIn`); nothing is
  rewritten. Additive: nothing existing changes.

## 0.11.0

- **`connection_engine.dart`, moved in from AOS-Write.** `ConnectionEngine`
  connects, updates and disconnects records with their history, and
  validates a connection's type, endpoints and cardinality before writing
  it. AOS Worldsmith links a civilisation to its government, culture and
  religion, and cannot import AOS-Write's `lib/`; writing a second engine
  there would give the shared record model two ways to make a link. Every
  file it imports was already here. Moved unchanged; AOS-Write replaces its
  copy with a one-line export when it moves its pin past this release.
  Additive: nothing existing changes.

## 0.10.0

- **`civilisation`: a people and its systems** (AOS Worldsmith build plan,
  Phase 2; the owner's choice of October 5, 2026 over *country plus a
  profile*). New `civilisation_record_types.dart`: one type, in the World
  category, with a people's own fields only — name for its people, other
  names, standing, population, when it rose and fell, level of technology,
  what defines it, and its history. Its culture, faith, language and
  government are linked, never redescribed, through the existing `*`-typed
  `hasCulture`, `worships`, `speaks` and `governedBy`.
- **`occupies`**, from a civilisation to a place, time-bounded: the land a
  people holds. Declared beside `locatedIn`, which places a thing, and
  distinct from `controls`, which is political rule.
- Additive: no existing type, field or relationship changes.

## 0.9.0

- **Five files AOS Companion's engine needs, moved in from AOS-Write.** All
  small, pure Dart, and each used elsewhere in AOS-Write, so the core is where
  they belong: `procedural/generation_seed.dart` (the one seeded generator),
  `record_completeness.dart`, `canon_facts.dart`,
  `revision_decision_subject.dart` and `checkout_link.dart`. Moved unchanged.
  AOS-Write replaces its copies with one-line exports when it moves its pin
  past this release. Additive: nothing existing changes.

## 0.8.0

- **Knowledge tracking** (AOS-Write `PLAN.md` §3.59). New
  `knowledge_ledger.dart`: `KnowledgeState`, `KnowledgeFact`,
  `KnowledgeLedger` (read from `knows` links and the *Character knowledge*
  table; `asOf` a reading position) and `sheetKnowledgeRows`. `knows` gains
  *Lies About*, *Conceals* and a `learnedIn` metadata field.
- Continuity: `detectKnowledgeConflicts` and `detectAgeConflicts`
  (`continuity/knowledge_detector.dart`), run by `detectAll`, with the new
  conditions `knowledgeConflict` and `ageConflict`.
  `scenesInReadingOrder` and `readingPosition` place a scene or a depicted
  event in reading order.
- `readingPosition` places an event no scene depicts by its date, among
  the depicted events of the same calendar and era; `compareStoryDates`.
- `ConnectionTypeDefinition.isArchived`: an archived custom type is not
  offered for new links and still resolves for existing ones.

- **The Calendar Bible: calendars that mean things as well as count them**
  (AOS-Write `PLAN.md` §3.57). New `calendar_bible.dart`, exported from
  `timeline_domain.dart`: `CalendarMonthLore` (symbol, meaning, season,
  associations, public belief, hidden truth, rituals, story meaning, plot
  uses), `TimelineWeekday` (a day with what it is for),
  `TimelineDateFormat`, `CalendarSpecialDate` (placed by month and day, or
  told by timing), `CalendarSign` and `CalendarDetails` — the author's own
  labelled details on any of them.
- `TimelineCalendar` gains `weekdayDetails`, `dateFormats`,
  `specialDates`, `signs` and `readingParts`; `weekdays`, `canCount`,
  `weekdayOf`, `specialDatesOn`, `dateAt` (the inverse of `ordinal`),
  `worldDayOf` / `dateAtWorldDay`, and `fromGregorian` / `toGregorian` by an
  anchor in `conversionMetadata`. `convertTimelineDate` converts between
  two calendars through a shared day count (`epoch.worldDay`).
  `format(date, {template})` gains `{weekday}`, `{monthSymbol}` and
  `{season}`, and collapses a missing weekday with its comma.
- A month of length 0 is one not yet counted: dates in it name and write,
  any day from 1 validates, and the calendar does not count days
  (`canCount` is false).
- `calendar-definition` declares the bible's fields in their own sections,
  after the counting section, so older views read as they did.
  `timelineCalendarFromRecord` reads them; a week stored as bare names
  still reads.
- Characters gain a **Birth reading** section (`birth.*`): a calendar, a
  public and a true record, marked dates and reveal notes.
- Continuity: `detectCalendarConflicts`, run by `detectAll`, reports the new
  `StructuralCondition.calendarConflict` — a day the calendar does not have,
  a festival on the wrong day, an event before a birth, a scene whose words
  name another month.
- **`PaidProduct.calendarBible`** (`curio-calendar-bible`), a paid Curio:
  the calendar's lore, astrology and festivals. Eleven `calendar-definition`
  fields and four `birth.*` fields carry `soldWith` (`calendars.lore`,
  `calendars.astrology`, `calendars.festivals`); the months, week, eras,
  epoch, formats, conversion and both birth dates stay unmarked and free.
- `detectCalendarConflicts` matches names with `mentionsName`, the one
  definition of a mention.
- **The Codex Bible System** (AOS-Write `PLAN.md` §3.58). `bible.dart`: a
  bible type is a project-scoped record type with entry sections in
  `extensionData['bible']` (`BibleTypes`, `BibleEntrySection`); entries join
  their bible by `partOf`, whose metadata declares `bibleSection`; rules an
  author writes (`BibleRule`, `BibleRuleKind`, `BibleRules` under
  `_bible.rules`). `bible_templates.dart`: nine starter bibles.
  `hidden_truth.dart`: a hidden truth beside any field (`_truth.values`).
- `PaidProduct.aosCasebook` (`aos-casebook`), `aosLorekeeper`
  (`aos-lorekeeper`) and `aosCodexBibles` (`aos-codex-bibles`).
  `BibleTemplate.soldWith` marks a paid starter bible.
- Continuity: `detectBibleRules`, run by `detectAll`, reports the new
  `StructuralCondition.bibleRule`. `characterBirthDate` is public for it.
- `StoryClockLinks` moves here from AOS Write (`story_clock_links.dart`).
- `AuthorRecord.copyWith` can change `extensionData`.

## 0.7.0

Continuity reports what is really in the manuscript. Each item below was a
finding it got wrong on an ordinary project.

- **A character answers to their first name.** `ManuscriptContinuity.charactersNamed`
  matches a full name or alias, then a first name. A POV of "Kali" is Kali
  Vale, not a missing character with a *Create "Kali"* that made a duplicate.
  A first name two characters share is not reported as missing. The orphan
  check counts a unique first name written capitalised, so "Will" in prose
  is Will Turner and "will" is not; `ProjectSurvey.allProseAsWritten` keeps
  the capitals for that one question.
- **A location ignores case, spacing and a leading "The"** (`bareName`). A
  scene set in "Docks" finds The Docks instead of offering to create a second
  one.
- **A world entity named in the prose but not connected is reported once**,
  as an unlinked mention with *Connect*, and no longer also as unused
  worldbuilding. Its *Open Studio* goes to the Studio that owns the record:
  `StructuralFinding` takes an optional `destination`.
- **A plotline connected to its chapter has scenes.** It was reported as
  empty, unlike every other check, which reads a chapter as covering its
  scenes.
- **Relationship notices are quieter.** Only arcs marked *active* are open;
  planned, unset and abandoned are not reported. Only links of a kind that
  changes (enemy, rival, partner, ally, mentor) want an arc, not `knows`,
  family or friendship. Each kind folds into one notice however many there
  are.

## 0.6.0

- **Character Chat sessions are character notes, not characters.**
  `character-chat-session` and `interrogation-session` move from the
  `characters` category to the new `characterNotesCategoryId`
  (`'character-notes'`) in `story_vocabulary.dart`. Everything that read the
  cast by category took them for characters: Continuity reported an interview
  ("Fears & Secrets — Vincenzo") as a character who never appears in the
  manuscript. `characterNotesTypeIds` names the two types for surfaces that
  list every record rather than selecting by category.
- Both session types declare `selectableForNewRecords: false`, so a
  template picker no longer offers them as something to create.
- `ProjectSurvey.from` leaves character notes out of the records it reads, so
  no detector or provocation counts an interview as part of the story.
- No stored data changes. A record's category comes from its type, and both
  applications find sessions by type id, not category.

## 0.5.0

- **The archive carries each scene's authorship record.** One optional entry,
  `content/scene-authorship.jsonl`, written only when the application passes
  records to `exportSnapshot(sceneAuthorship:)`, so an archive without any is
  byte-identical to before. Each line is an opaque map with an `id` (the
  scene): what an origin means, and the digest that ties a record to its
  text, belong to the application (AOS-Write `PLAN.md` §3.39).
  `AuthorOsArchiveContents` gains `sceneAuthorship`.
- An older build reading a 0.5.0 archive ignores the entry, as 0.4.0's
  roster entries are ignored.

## 0.4.0

- **The archive carries the project roster.** Two optional entries,
  `data/projects.jsonl` (`ProjectRosterEntry`) and `data/series.jsonl`
  (`WritingSeries`), written only when there is a roster, so an archive without
  one is byte-identical to before. `AuthorOsArchiveContents` gains `projects`,
  `series` and `carriesRoster`; `ArchiveInspection` counts `projects`, and an
  archive holding only a roster is no longer reported empty. Until now a
  restore into an empty installation brought back every record and no
  projects (AOS-Write `PLAN.md` §3.37).
- `ProjectRosterEntry` gains `toJson` and `fromJson`.
- An older build reading a 0.4.0 archive ignores the two entries: import
  checks entries against the manifest and decodes only the ones it knows.

## 0.3.0

- The continuity seam from AOS-Write (its #550): the world hierarchy,
  dismissals and timeline fields, then the manuscript model and the
  continuity detectors, join the core. Carried over with their history.

## 0.2.0

- `progression/progression_domain.dart` and `image_media_type.dart` join the
  core, as they did in AOS-Write for ADR-0028: the database needs them before
  it can leave the application for `authoros_persistence`. Pure Dart, and
  carried over with their history.

## 0.1.0

- The package as it stood in AOS-Write at the move: the record engine, the
  archive and the continuity model. Only `resolution: workspace` was removed
  from `pubspec.yaml`, so it resolves on its own.
