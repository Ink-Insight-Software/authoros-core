# Changelog

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
