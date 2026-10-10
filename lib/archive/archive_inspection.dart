/// Reading an archive without opening a database.
///
/// Split from `lib/services/project_archive_service.dart` so the part that
/// only needs bytes does not need drift. That is not tidiness: the service
/// imports the database, so every assertion about what an archive holds would
/// have needed a database to make, and "does a flipped byte get rejected" is a
/// question about a file.
///
/// Pure Dart, like the archive format itself.
library;

import 'authoros_archive.dart';

/// Counts what an archive holds.
ArchiveInspection inspectionOf(AuthorOsArchiveContents contents) {
  final snapshot = contents.snapshot;
  return ArchiveInspection(
    records: snapshot.records.length,
    links: snapshot.links.length,
    manuscripts: contents.manuscripts.length,
    scenesWithProse: snapshot.sceneProse.length,
    writingSessions: snapshot.writingSessions.length,
    revisionDecisions: snapshot.revisionDecisions.length,
    projects: contents.projects.length,
    mappedProjects: contents.cartographerDocuments.length,
  );
}

/// What one archive contains, read without committing any of it.
class ArchiveInspection {
  const ArchiveInspection({
    required this.records,
    required this.links,
    required this.manuscripts,
    required this.scenesWithProse,
    required this.writingSessions,
    this.revisionDecisions = 0,
    this.projects = 0,
    this.mappedProjects = 0,
  });

  final int records;
  final int links;
  final int manuscripts;
  final int scenesWithProse;
  final int writingSessions;

  /// Author decisions about findings — dismissals, triage, accepted style
  /// entries. Counted so a restore can say the author is getting their
  /// working state back and not only their words.
  final int revisionDecisions;

  /// Projects on the roster the archive carries: zero for an archive written
  /// before the roster was, which says nothing about how many there were.
  final int projects;

  /// Projects whose spatial document the archive carries — one per project,
  /// as Cartographer wrote it. Zero on the same terms as [projects]: an
  /// archive written before documents were carried says nothing about whether
  /// a project had a map.
  final int mappedProjects;

  /// True when the archive parsed, every checksum matched, and it holds
  /// something. An archive that verifies but is empty is a real answer and not
  /// a good one, so the two are reported apart.
  bool get isEmpty =>
      records == 0 &&
      links == 0 &&
      manuscripts == 0 &&
      scenesWithProse == 0 &&
      projects == 0 &&
      // Counted here too, so an archive holding a project's maps and nothing
      // else is not reported as holding nothing.
      mappedProjects == 0;

  /// One line for a screen: what an author would get back.
  String get summary {
    if (isEmpty) return 'This archive verified, but there is nothing in it.';
    final parts = <String>[
      if (projects > 0)
        '$projects ${_plural(projects, 'project', 'projects')}',
      if (records > 0) '$records ${_plural(records, 'record', 'records')}',
      if (links > 0) '$links ${_plural(links, 'connection', 'connections')}',
      if (scenesWithProse > 0)
        '$scenesWithProse written '
            '${_plural(scenesWithProse, 'scene', 'scenes')}',
      if (writingSessions > 0)
        '$writingSessions writing '
            '${_plural(writingSessions, 'session', 'sessions')}',
      if (revisionDecisions > 0)
        '$revisionDecisions revision '
            '${_plural(revisionDecisions, 'decision', 'decisions')}',
      if (mappedProjects > 0)
        '$mappedProjects '
            '${_plural(mappedProjects, 'mapped project', 'mapped projects')}',
    ];
    return parts.join(' · ');
  }

  static String _plural(int count, String one, String many) =>
      count == 1 ? one : many;
}

/// A filename an author will recognise a year from now.
///
/// Dated, because the question asked of a backup folder is always "which of
/// these is the recent one". Sorted lexicographically the dates sort
/// chronologically, which is the reason for the ISO order.
String archiveFileName(String projectTitle, DateTime at) {
  final utc = at.toUtc();
  final date = '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';
  final buffer = StringBuffer();
  for (final rune in projectTitle.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(RegExp(r'[a-z0-9]').hasMatch(char) ? char : '-');
  }
  final slug = buffer
      .toString()
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return '${slug.isEmpty ? 'authoros' : slug}-$date.authoros';
}
