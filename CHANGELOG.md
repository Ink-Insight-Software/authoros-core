# Changelog

## 0.6.0

- **Knowledge tracking** (AOS-Write `PLAN.md` §3.47). New
  `knowledge_ledger.dart`: `KnowledgeState`, `KnowledgeFact`,
  `KnowledgeLedger` (read from `knows` links and the *Character knowledge*
  table; `asOf` a reading position) and `sheetKnowledgeRows`. `knows` gains
  *Lies About*, *Conceals* and a `learnedIn` metadata field.
- Continuity: `detectKnowledgeConflicts` and `detectAgeConflicts`
  (`continuity/knowledge_detector.dart`), run by `detectAll`, with the new
  conditions `knowledgeConflict` and `ageConflict`.
  `scenesInReadingOrder` and `readingPosition` place a scene or a depicted
  event in reading order.
- `ConnectionTypeDefinition.isArchived`: an archived custom type is not
  offered for new links and still resolves for existing ones.

- **The Calendar Bible: calendars that mean things as well as count them**
  (AOS-Write `PLAN.md` §3.45). New `calendar_bible.dart`, exported from
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
- **The Codex Bible System** (AOS-Write `PLAN.md` §3.46). `bible.dart`: a
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
