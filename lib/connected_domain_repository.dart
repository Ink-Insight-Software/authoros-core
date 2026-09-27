import 'branch_domain.dart';
import 'connected_domain.dart';
import 'connection_types.dart';
import 'project_roster_entry.dart';
import 'record_types.dart';
import 'relationship_validation.dart';
import 'scene_prose.dart';
import 'scene_revision.dart';
import 'search_models.dart';
import 'version_audit.dart';
import 'writing_goals.dart';
import 'writing_series.dart';
import 'revision_decision.dart';
import 'writing_session.dart';

/// The persistence contract AuthorOS Core depends on.
///
/// Core owns the canonical model but not the store that holds it. Every Core
/// service reads and writes through this interface, so the layer stays free of
/// any particular database: `DriftConnectedDomainRepository` in
/// `lib/persistence` is the shipping implementation, and a platform that cannot
/// run Drift can supply its own without Core changing.
///
/// Every type named here is declared inside `lib/core`, which is what keeps the
/// dependency pointing inward. Implementations must not widen the contract with
/// store-specific types.
abstract interface class ConnectedDomainRepository {
  Future<void> putManuscriptNodes(
    Iterable<ManuscriptNodeReference> nodes,
  );

  Future<void> removeManuscriptNodes(Iterable<String> nodeIds);

  Future<Map<String, SceneProseDigest>> sceneProseDigestsForProject(
    String projectId,
  );

  Future<Map<String, SceneProse>> sceneProseForProject(String projectId);

  Future<SceneProse?> sceneProseById(String sceneId);

  Future<void> putSceneProse(Iterable<SceneProse> prose);

  Future<void> removeSceneProse(Iterable<String> sceneIds);

  Future<void> removeSceneProseForProject(String projectId);

  Future<void> putRecordsAndLinks({
    required Iterable<AuthorRecord> records,
    required Iterable<RecordLink> links,
  });

  Future<void> putRecord(AuthorRecord record);

  Future<void> putLink(RecordLink link);

  Future<void> putRecordWithHistory({
    required AuthorRecord record,
    required Iterable<RecordLink> links,
    required RecordVersion version,
    required AuditEvent auditEvent,
  });

  Future<void> putLinkWithHistory({
    required RecordLink link,
    required RecordVersion version,
    required AuditEvent auditEvent,
  });

  Future<void> deleteLinkWithHistory({
    required String linkId,
    required RecordVersion version,
    required AuditEvent auditEvent,
  });

  Future<void> putBranchWithHistory({
    required StoryBranch branch,
    required RecordVersion version,
    required AuditEvent auditEvent,
  });

  Future<void> putBranchRecordOverlayWithHistory({
    required BranchRecordOverlay overlay,
    required RecordVersion version,
    required AuditEvent auditEvent,
  });

  Future<void> putBranchLinkOverlayWithHistory({
    required BranchLinkOverlay overlay,
    required RecordVersion version,
    required AuditEvent auditEvent,
  });

  Future<void> appendHistory(
    RecordVersion version,
    AuditEvent auditEvent,
  );

  Future<RecordVersion?> versionById(String id, String projectId);

  Future<List<RecordVersion>> versionHistory(HistoryFilter filter);

  Future<List<AuditEvent>> auditHistory(HistoryFilter filter);

  Future<RecordVersion?> latestVersion({
    required String projectId,
    required String entityId,
    String? branchId,
  });

  Future<void> putWritingSession(WritingSession session);

  Future<void> putWritingSessions(Iterable<WritingSession> sessions);

  Future<List<WritingSession>> writingSessionsForProject(
    String projectId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Future<int> deleteWritingSessionsForProject(String projectId);

  /// Writes one author decision about a finding, replacing any earlier answer
  /// to the same subject. ADR-0011.
  Future<void> putRevisionDecision(RevisionDecision decision);

  Future<void> putRevisionDecisions(Iterable<RevisionDecision> decisions);

  /// One project's decisions, optionally narrowed to a single kind.
  Future<List<RevisionDecision>> revisionDecisionsForProject(
    String projectId, {
    RevisionDecisionKind? kind,
  });

  /// Withdraws a decision — the author un-dismissing a finding they had
  /// silenced. Returns the number of rows removed, which is 0 or 1.
  Future<int> deleteRevisionDecision(String id);

  Future<int> deleteRevisionDecisionsForProject(String projectId);

  Future<WritingGoals?> writingGoalsForProject(String projectId);

  Future<void> putWritingGoals(WritingGoals goals);

  Future<int> deleteWritingGoalsForProject(String projectId);

  Future<List<WritingSeries>> allSeries();

  Future<WritingSeries?> seriesById(String seriesId);

  Future<void> putSeries(WritingSeries series);

  Future<int> deleteSeries(String seriesId);

  Future<List<ProjectRosterEntry>> projectRoster();

  Future<ProjectRosterEntry?> projectRosterEntry(String projectId);

  Future<void> putProjectRosterEntry(ProjectRosterEntry entry);

  Future<int> deleteProjectRosterEntry(String projectId);

  Future<List<ProjectRosterEntry>> booksInSeries(String seriesId);

  Future<void> putSceneRevision(
    SceneRevision revision, {
    SceneRevisionRetention retention = const SceneRevisionRetention(),
    DateTime? now,
  });

  Future<List<SceneRevisionSummary>> sceneRevisionSummaries(
    String projectId,
    String sceneId, {
    int? limit,
  });

  Future<SceneRevision?> sceneRevision(String revisionId);

  Future<Map<String, String>> newestSceneRevisionDigests(
    String projectId,
  );

  Future<int> deleteSceneRevisionsForProject(String projectId);

  /// Erases everything one project holds, leaving the project itself.
  ///
  /// The Danger Zone's first button. "Delete all project data" is precisely
  /// what it says and no more: every record, link, chapter, scene, word of
  /// prose, version, audit event, writing session, style decision, goal,
  /// branch, asset and snapshot belonging to [projectId] goes, and the project
  /// keeps its roster entry, its id and its title. An author who empties a book
  /// is starting it over, not leaving.
  ///
  /// **Three things are deliberately out of scope, and each would be a bug to
  /// include.**
  ///
  ///  * **Progression.** `ProgressionStateRows` is career-scoped and its own
  ///    documentation states the rule this honours — *"deleting a finished
  ///    project never demotes the author who finished it"*. An author's XP
  ///    floor and unlock dates are facts about them, not about a book.
  ///  * **Series membership and other projects.** A shared or series-scoped
  ///    record belongs to more than this book, so it is left alone. The
  ///    predicate throughout is `projectId`, never `scopeId` alone.
  ///  * **Anything on the server.** This is a local erase. Pressings are
  ///    revoked from their own pane, deliberately, because unpublishing is a
  ///    separate decision from emptying a draft.
  ///
  /// One transaction. A half-erased project is worse than either outcome: it
  /// would leave links pointing at records that no longer exist, which is the
  /// state `removeManuscriptNodes` already goes out of its way to avoid.
  ///
  /// Returns how many rows were removed, so a surface can report what happened
  /// rather than assert it.
  Future<int> eraseProject(String projectId);

  Future<void> putRecordTypeDefinition(
    RecordTypeDefinition definition,
  );

  Future<RecordTypeDefinition?> recordTypeDefinitionById(String id);

  Future<void> putConnectionTypeDefinition(
    ConnectionTypeDefinition definition,
  );

  Future<List<ConnectionTypeDefinition>> connectionTypeDefinitionsByScope(
    String scopeId,
  );

  Future<void> putBranch(StoryBranch branch);

  Future<void> putBranchRecordOverlay(BranchRecordOverlay overlay);

  Future<void> putBranchLinkOverlay(BranchLinkOverlay overlay);

  Future<List<StoryBranch>> branchesByProject(String projectId);

  Future<List<BranchRecordOverlay>> branchRecordOverlays(
    Iterable<String> branchIds,
  );

  Future<List<BranchLinkOverlay>> branchLinkOverlays(
    Iterable<String> branchIds,
  );

  Future<List<RecordTypeDefinition>> recordTypeDefinitionsByScope({
    required RecordScopeType scopeType,
    required String scopeId,
  });

  Future<List<AuthorRecord>> recordsByTypeAndScope({
    required String typeId,
    required String scopeId,
  });

  Future<List<AuthorRecord>> recordsByScope(String scopeId);

  Future<List<AuthorRecord>> recordsByProject(String projectId);

  Future<List<AuthorRecord>> recordsByType(String typeId);

  Future<List<AuthorRecord>> recordsInSeriesScope(String seriesId);

  Future<List<AuthorRecord>> recordsVisibleToProject(
    String projectId, {
    Iterable<String> inheritedScopeIds = const [],
  });

  Future<List<AuthorRecord>> recordsByTagAndScope({
    required String tagId,
    required String scopeId,
  });

  Future<void> replaceSnapshot(ConnectedDomainSnapshot snapshot);

  Future<void> putConnectedSlice({
    required AuthorRecord record,
    required ManuscriptNodeReference manuscriptNode,
    required RecordLink link,
  });

  Future<AuthorRecord?> recordById(String id);

  Future<List<AuthorRecord>> recordsByIds(Iterable<String> ids);

  Future<List<ManuscriptNodeReference>> manuscriptNodesByIds(
    Iterable<String> ids,
  );

  Future<List<RecordLink>> linksForEntities(
    Iterable<String> ids, {
    Set<String>? typeIds,
  });

  Future<List<ManuscriptNodeReference>> manuscriptNodesForProject(
    String projectId,
  );

  Future<ManuscriptNodeReference?> manuscriptNodeById(String id);

  Future<List<ManuscriptNodeReference>> manuscriptNodesByProject(
    String projectId,
  );

  Future<List<RecordLink>> backlinks(String entityId);

  Future<List<RecordLink>> outgoingLinks(String entityId);

  Future<List<RecordLink>> incomingLinks(String entityId);

  Future<RecordLink?> linkById(String id);

  Future<List<RecordLink>> linksByScope(String scopeId);

  Future<String?> entityScopeId(String entityId);

  Future<String?> entityTypeId(String entityId);

  Future<String?> entityProjectId(String entityId);

  Future<RelationshipEndpoint> relationshipEndpoint(String entityId);

  Future<void> deleteLink(String linkId);

  Future<List<SearchIndexHit>> searchIndex(
    String query, {
    required String exactQuery,
    required UniversalSearchFilter filter,
  });

  Future<List<String>> searchEntityIds(String query);

  Future<ConnectedDomainSnapshot> snapshot();
}
