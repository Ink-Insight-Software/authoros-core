# authoros_core

**This repository will be its home.** The package was copied here from
`flutter-author-studio-v1/authoros_core/` in `Ink-Insight-Software/AOS-Write`,
with its history, so that AuthorOS Write and Casebook
(`Ink-Insight-Software/AuthorOS-Expansions`) can both depend on one copy and
neither has to reach into the other's repository. It is public, so both
fetch it with no credential.

> **Not yet the source of truth.** Until AOS-Write depends on this repository
> instead of its own copy, AOS-Write's `flutter-author-studio-v1/authoros_core/`
> is the copy that is built and changed. This repository is a snapshot of it,
> tagged `Release` (0.1.0). Make no changes here until AOS-Write switches; a
> change made here first would not reach AuthorOS Write.
>
> Casebook already depends on this repository, pinned by commit. AuthorOS
> Write switches in its own change.

## Using it

Depend on a tag, never a branch, so a change here reaches an application
only when that application moves its pin:

```yaml
dependencies:
  authoros_core:
    git:
      url: git@github.com:Ink-Insight-Software/authoros-core.git
      ref: v0.1.0
```

Because the repository is public, a consumer's CI and web build need no
credential to fetch it. Pinning a commit instead of a tag is fine too, and
Casebook does.

## Releasing

1. Change the code with a pull request here; CI analyzes it.
2. Bump `version` in `pubspec.yaml` and add a `CHANGELOG.md` entry.
3. Tag the merge commit `v<version>` and push the tag.
4. Move each consumer's `ref` in its own pull request, where its own tests
   run against the new version.

## Known carry-overs

- The moved files' doc comments link to `../../docs/...` in AOS-Write. Those
  links do not resolve here; the documents stay in AOS-Write.
- `dart analyze` reports two unused declarations in
  `built_in_record_types.dart` (`_world`, `_location`). They came with the
  move and are left as they were.
- The package's tests still live in AOS-Write, which reads its source. Moving
  the ones that test only this package is follow-up work.

## History before the move

AuthorOS's shared core, extracted September 27, 2026 so that a standalone
application can depend on the AuthorOS engine instead of copying it. The first
such application is Casebook, which is built in `AuthorOS-Expansions`: see
Casebook ADR-0001 there, and ADR-0023 here, which named this package split as
the better long-run answer and declined to wait for it.

## What is in it

Exactly the import closure of the record engine, moved unchanged:

- the record envelope, `AuthorRecord`, and `ConnectedDomainRepository`
  (`connected_domain.dart`, `connected_domain_repository.dart`)
- the record and connection type registries and every built-in type
  (`record_types.dart`, `connection_types.dart`, `built_in_record_types.dart`,
  `built_in_connection_types.dart`, and the `*_record_types.dart` files)
- `RecordService`, validation, scene prose and revision, branches, version
  audit, writing goals, series and sessions, and the craft library

66 files. It is pure Dart; its only dependency is `crypto`.

**The archive joined it on September 28, 2026**, as the first step of the
Worldsmith build plan's Phase 0 (`PLAN.md` §3.33). `archive/authoros_archive.dart`
and `archive/archive_inspection.dart` write, read and inspect the `.authoros`
format. They are pure Dart and every file they import was already here, so a
standalone application can back up and restore without copying them. They
keep their own `archive/` directory, so the guards still read them as the
archive and not as Core. That brought one more dependency, `archive`, the
same constraint AuthorOS Write already used.

**Two files the database needs joined it the same day** (ADR-0028):
`progression/progression_domain.dart`, the progression ledger's model, and
`image_media_type.dart`. Both are pure Dart. They had to be here before the
database could leave the application for its own package, `authoros_persistence`.

**The continuity model joined it the same day.** `continuity_domain.dart`
(`ContinuityAnalyzer`, the warning types, severities and actions) and
`continuity/continuity_models.dart` (the project-wide findings and structural
conditions) are pure Dart and import nothing outside the core. They are the
vocabulary a standalone application's continuity report speaks. The
detectors that produce the findings did **not** move: `continuity/detectors.dart`
and `services/world_continuity.dart` reach the Drift database and Flutter
through `timeline_service`, `manuscript_continuity`, `project_survey` and
`world_service`, 45 and 30 application files deep. Moving them needs a seam
for what they read first. This change only moves files.

Some files are here because the built-in record registry names their record
types, not because they are core in themselves: `curio_activation.dart`,
`entitlement.dart`, `character_chat.dart` and `interrogation_session.dart`.
Cutting those edges is a separate change. This one moves files and nothing
else.

## How AuthorOS Write uses it

`flutter-author-studio-v1` is a pub workspace, so there is one resolution and
one `pubspec.lock`. Its other members are this package and, since September
28, 2026, `authoros_persistence`, the project database (ADR-0028).

Every file that moved left a one-line export at its old path in `lib/core/`
(or `lib/archive/`, `lib/continuity/`):

```dart
export 'package:authoros_core/connected_domain.dart';
```

So no import anywhere in the application changed. A library reached through
the export and through `package:authoros_core/...` is the same library, so
types are identical either way. New code may import either path.
**Source-reading tests must use the package path**, since the export has no
source to read. `test/support/source_tree.dart` lists both source roots for the
tests that scan the whole tree.

## Why here and at this depth

The package sits directly inside `flutter-author-studio-v1/`, with its sources
at `authoros_core/lib/`. That is the same depth as `lib/core/`, so the
`../../docs/...` links in the moved files' doc comments still resolve. The
Netlify site's base directory also still contains it, so a change to the core
redeploys the application.
