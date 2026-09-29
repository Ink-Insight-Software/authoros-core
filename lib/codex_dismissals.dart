/// Where the Story Codex keeps the suggestions an author dismissed.
///
/// One record per project, `codex-suggestions-<projectId>`, holding the
/// dismissed keys in one field. Moved out of `EntitySuggestionService` on
/// September 29, 2026, so the Continuity Engine's survey can read the
/// dismissals from records it already holds without importing the service
/// that writes them (`PLAN.md` §3.33). The service forwards here.
library;

import 'connected_domain.dart';

abstract final class CodexDismissals {
  /// The id of the record [projectId]'s dismissals live on.
  static String recordIdFor(String projectId) => 'codex-suggestions-$projectId';

  /// The field the dismissed keys are stored in.
  static const String field = 'dismissedKeys';

  /// The dismissals held on [records], which must be a project's records.
  static Set<String> keysIn(Iterable<AuthorRecord> records, String projectId) {
    final id = recordIdFor(projectId);
    for (final record in records) {
      if (record.id != id) continue;
      return keysFrom(record.fields[field]);
    }
    return const {};
  }

  /// The keys in a stored [field] value, ignoring blanks and anything that
  /// is not a list.
  static Set<String> keysFrom(Object? stored) {
    if (stored is! List) return const {};
    return {
      for (final key in stored)
        if (key.toString().trim().isNotEmpty) key.toString(),
    };
  }
}
