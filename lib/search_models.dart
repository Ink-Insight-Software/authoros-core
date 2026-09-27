import 'connected_domain.dart';
import 'dart:convert';

enum SearchEntityKind { record, manuscriptNode, branchRecord }

enum SearchDestination {
  characterStudio,
  worldStudio,
  storyCodex,
  timelineStudio,
  plotStudio,
  manuscriptStudio,

  /// The Chapters Studio: the chapter-level view of the manuscript.
  ///
  /// Distinct from [manuscriptStudio], which owns the whole node tree. A
  /// manuscript *node* always routes to the tree; a record typed `chapter`
  /// routes here, where chapter structure is what the page is about.
  chapterStudio,
  seriesStudio,
  knowledgeGraph,

  /// The Research Studio: the author's research library.
  ///
  /// Its records used to route to the Story Codex (`research-entry`) and the
  /// World Studio (`research`, through the untyped fallback) — two type ids
  /// for one library, neither of which opened it.
  researchStudio,

  /// The Ideas Studio.
  ///
  /// Phase 8D. Ideas had no destination because an idea was not a record: it
  /// lived in a `SharedPreferences` bucket with no project in its key, and
  /// nothing in the search index could point at it.
  ideasStudio,

  /// The Notes Studio.
  ///
  /// `author-note` had no destination of its own either, so a note found in
  /// search fell through to [record] and opened the World Studio.
  notesStudio,
  record,
}

class SearchNavigationTarget {
  const SearchNavigationTarget({
    required this.destination,
    required this.recordId,
    required this.projectId,
    this.branchId,
  });

  final SearchDestination destination;
  final String recordId;
  final String projectId;
  final String? branchId;
}

class UniversalSearchFilter {
  const UniversalSearchFilter({
    required this.projectId,
    this.recordType,
    this.seriesId,
    this.bookId,
    this.branchId,
    this.canonStatus,
    this.lifecycleStatus,
    this.limit = 100,
  });

  final String projectId;
  final String? recordType;
  final String? seriesId;
  final String? bookId;
  final String? branchId;
  final CanonStatus? canonStatus;
  final AuthorRecordStatus? lifecycleStatus;
  final int limit;

  UniversalSearchFilter copyWith({
    String? recordType,
    String? seriesId,
    String? bookId,
    String? branchId,
    CanonStatus? canonStatus,
    AuthorRecordStatus? lifecycleStatus,
  }) =>
      UniversalSearchFilter(
        projectId: projectId,
        recordType: recordType ?? this.recordType,
        seriesId: seriesId ?? this.seriesId,
        bookId: bookId ?? this.bookId,
        branchId: branchId ?? this.branchId,
        canonStatus: canonStatus ?? this.canonStatus,
        lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
        limit: limit,
      );
}

class SearchResult {
  const SearchResult({
    required this.recordId,
    required this.recordType,
    required this.title,
    required this.snippet,
    required this.projectId,
    required this.canonStatus,
    required this.navigationTarget,
    required this.relevance,
    this.seriesId,
    this.bookId,
    this.branchId,
    this.templateId,
    this.category,
    this.tags = const [],
    this.matchedField,
  });

  final String recordId;
  final String recordType;
  final String title;
  final String snippet;
  final String projectId;
  final String? seriesId;
  final String? bookId;
  final String? branchId;
  final CanonStatus canonStatus;
  final String? templateId;
  final String? category;
  final List<String> tags;
  final String? matchedField;
  final double relevance;
  final SearchNavigationTarget navigationTarget;
}

class SearchIndexHit {
  const SearchIndexHit({
    required this.entityId,
    required this.kind,
    required this.title,
    required this.snippet,
    required this.rank,
    this.matchedField,
  });

  final String entityId;
  final SearchEntityKind kind;
  final String title;
  final String snippet;
  final double rank;
  final String? matchedField;
}

String branchSearchEntityId(String branchId, String recordId) =>
    'branch-record:${_encodeSearchId(branchId)}:${_encodeSearchId(recordId)}';

({String branchId, String recordId})? parseBranchSearchEntityId(String value) {
  final parts = value.split(':');
  if (parts.length != 3 || parts.first != 'branch-record') return null;
  try {
    return (
      branchId: _decodeSearchId(parts[1]),
      recordId: _decodeSearchId(parts[2]),
    );
  } on FormatException {
    return null;
  }
}

String _encodeSearchId(String value) =>
    base64Url.encode(utf8.encode(value)).replaceAll('=', '');

String _decodeSearchId(String value) => utf8.decode(
      base64Url.decode(base64Url.normalize(value)),
    );
