# Changelog

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
