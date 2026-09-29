/// The project roster — the domain layer.
///
/// A [ProjectRosterEntry] is one project as the roster knows it: the project
/// itself, and — when it is a book rather than a standalone novel — which
/// series it belongs to and where it sits in that series.
///
/// It carries no title and no word target of its own. Both live on the
/// [StarterProject] it wraps, which is the only place either is defined.
///
/// Presentation-independent: nothing here imports Flutter, and this lives in
/// `core/` so the persistence layer can store a roster entry without importing
/// the onboarding widgets.
library;

import 'starter_project.dart';

/// One project on the author's roster.
class ProjectRosterEntry {
  const ProjectRosterEntry({
    required this.project,
    this.seriesId,
    this.seriesPosition,
    this.archivedAt,
    this.profileId,
    this.createdAt,
    this.updatedAt,
  });

  /// A standalone project — on the roster, in no series.
  factory ProjectRosterEntry.standalone(StarterProject project) =>
      ProjectRosterEntry(project: project);

  final StarterProject project;

  /// The series this project is a book of, or `null` when it stands alone.
  /// AuthorOS must keep supporting the novelist who will never write a series.
  final String? seriesId;

  /// Zero-based position within the series, so "Book 1" is position 0.
  /// `null` exactly when [seriesId] is null.
  final int? seriesPosition;

  /// When the author archived this project, or `null` while it is active.
  ///
  /// Archiving is deliberately *not* deletion and deliberately not a boolean:
  /// an archived project keeps its manuscript, its records and its place in a
  /// series, and the instant is what lets a restored project be told apart
  /// from one that was never put away. It exists so an author who has finished
  /// a book can stop seeing it everywhere without being asked to destroy it —
  /// the choice AuthorOS previously forced.
  final DateTime? archivedAt;
  /// The author profile this project belongs to, or `null` when it predates
  /// profile ownership.
  ///
  /// Null is a real state, not a gap to fill in. One account can hold several
  /// pen names, so a project written before ownership existed cannot be
  /// attributed by guessing — it belongs to whichever identity the author had
  /// in mind, and only they know which. An unowned project stays visible to
  /// every profile rather than being hidden from all of them or assigned to
  /// the wrong one.
  ///
  /// The one case that can be decided without asking is an account holding
  /// exactly one profile, where "which identity" has a single answer. See
  /// `ProjectRosterStore.adoptUnownedProjects`.
  final String? profileId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get projectId => project.id;

  /// The project's title, read from the project itself.
  String get title => project.title;

  /// The book's word target: the project's own goal, which is what
  /// `AnalyticsSummary.targetWordCount` already reads. A series never stores a
  /// second copy of this number.
  int get targetWords => project.wordGoal < 0 ? 0 : project.wordGoal;

  /// Whether this project is a book in a series rather than a standalone.
  bool get isBook => seriesId != null;

  /// Whether the author has put this project away.
  bool get isArchived => archivedAt != null;

  /// Human-facing book number: position 0 is "Book 1". `null` when standalone.
  int? get bookNumber => seriesPosition == null ? null : seriesPosition! + 1;

  ProjectRosterEntry copyWith({
    StarterProject? project,
    String? seriesId,
    int? seriesPosition,
    DateTime? archivedAt,
    String? profileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProjectRosterEntry(
        project: project ?? this.project,
        seriesId: seriesId ?? this.seriesId,
        seriesPosition: seriesPosition ?? this.seriesPosition,
        archivedAt: archivedAt ?? this.archivedAt,
        profileId: profileId ?? this.profileId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// The same entry, archived at [at].
  ProjectRosterEntry archived(DateTime at) => copyWith(archivedAt: at);

  /// The entry as the `.authoros` archive carries it, one line of
  /// `data/projects.jsonl`.
  ///
  /// `id` is the project's, so the archive can sort and key the line the way
  /// it keys every other entry. Timestamps are UTC ISO-8601, as everywhere
  /// else. Added with the archive entry, so a backup carries the roster
  /// (AOS-Write `PLAN.md` §3.35).
  Map<String, Object?> toJson() => {
        'id': project.id,
        'project': project.toJson(),
        'seriesId': seriesId,
        'seriesPosition': seriesPosition,
        'archivedAt': archivedAt?.toUtc().toIso8601String(),
        'profileId': profileId,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  /// The entry [toJson] wrote. A `seriesPosition` without a `seriesId` is
  /// dropped, because a position means nothing outside a series.
  factory ProjectRosterEntry.fromJson(Map<String, dynamic> json) {
    DateTime? at(Object? value) =>
        value is String ? DateTime.parse(value).toLocal() : null;
    final seriesId = json['seriesId'] as String?;
    return ProjectRosterEntry(
      project: StarterProject.fromJson(
        Map<String, dynamic>.from(json['project'] as Map),
      ),
      seriesId: seriesId,
      seriesPosition: seriesId == null ? null : json['seriesPosition'] as int?,
      archivedAt: at(json['archivedAt']),
      profileId: json['profileId'] as String?,
      createdAt: at(json['createdAt']),
      updatedAt: at(json['updatedAt']),
    );
  }

  /// The same entry, back out of the archive.
  ///
  /// A separate method rather than `copyWith(archivedAt: null)`, for the same
  /// reason [withoutSeries] is: `copyWith` cannot tell "leave it alone" from
  /// "clear it".
  ProjectRosterEntry restored() => ProjectRosterEntry(
        project: project,
        seriesId: seriesId,
        seriesPosition: seriesPosition,
        // Carried explicitly: restoring a project must not quietly cost it the
        // pen name it belongs to. Every field this constructor omits is
        // cleared, which is the point for `archivedAt` and a bug for anything
        // else.
        profileId: profileId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// The same entry with no series membership.
  ///
  /// A separate method rather than `copyWith(seriesId: null)`, because
  /// `copyWith` cannot tell "leave it alone" from "clear it".
  ProjectRosterEntry withoutSeries() => ProjectRosterEntry(
        project: project,
        archivedAt: archivedAt,
        profileId: profileId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// The same entry placed in a series at [position].
  ProjectRosterEntry inSeries(String seriesId, int position) =>
      ProjectRosterEntry(
        project: project,
        seriesId: seriesId,
        seriesPosition: position < 0 ? 0 : position,
        archivedAt: archivedAt,
        profileId: profileId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  String toString() => 'ProjectRosterEntry(${project.id}, '
      '${seriesId == null ? 'standalone' : 'book $bookNumber of $seriesId'}'
      '${isArchived ? ', archived' : ''})';
}
