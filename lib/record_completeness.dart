/// Records that were started in a hurry and never finished.
///
/// Quick-add exists so an author who invents a character mid-sentence does not
/// have to leave the sentence. That is the right trade — but it leaves behind
/// a record holding a name and nothing else, and the author who made it was
/// thinking about the sentence, not about the record.
///
/// So something has to remember. This decides which records are still only
/// what quick-add asked for.
///
/// ## Derived, never stamped
///
/// Nothing marks a record as unfinished. The question is answered by looking:
/// a record whose only filled fields are the ones quick-create shows is a
/// record nobody has been back to. Filling in anything else answers it
/// differently, so the flag clears itself and there is no state to go stale,
/// no migration, and nothing to reconcile if a record is edited somewhere
/// else entirely.
///
/// ## Not a criticism
///
/// A half-filled character is not a mistake. The author invented Halloran
/// mid-sentence on purpose, and that was the right call. This is for a gentle
/// "three characters are waiting", never a chore list and never a warning.
library;

import 'connected_domain.dart';
import 'record_types.dart';

class RecordCompleteness {
  const RecordCompleteness._();

  /// Whether [value] counts as something the author filled in.
  ///
  /// Empty strings, empty lists and empty maps are all absence. A `false`
  /// checkbox and a `0` are not — the author may well have meant them, and
  /// treating a deliberate zero as unfilled would nag about a finished record.
  static bool isFilled(Object? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  /// The fields quick-add is responsible for on this type.
  ///
  /// Two sets, and both belong here. The ones marked for quick create are what
  /// the shortcut asks the author for. The required ones are what it must seed
  /// to produce a record the store will accept — a character's Full name is
  /// required, so quick-add fills it from the title, and the author filled in
  /// nothing by doing so.
  ///
  /// Counting a seeded field as the author's work is what made a record look
  /// finished the moment it was created.
  static Set<String> shortcutFieldIds(RecordTypeDefinition definition) => {
        for (final field in definition.fields)
          if (field.quickCreateVisible || field.required) field.id,
      };

  /// Whether [record] still holds only what quick-add put there.
  ///
  /// False for a type quick-add has no shortcut for at all: it cannot have
  /// been created through one, and calling every empty record of that type
  /// unfinished would nag about records the author never touched.
  static bool isBarelyStarted(
    AuthorRecord record,
    RecordTypeDefinition definition,
  ) {
    final shortcut = shortcutFieldIds(definition);
    if (shortcut.isEmpty) return false;

    for (final entry in record.fields.entries) {
      if (!isFilled(entry.value)) continue;
      if (shortcut.contains(entry.key)) continue;
      return false;
    }
    return true;
  }

  /// The records among [records] that are still only their quick fields.
  ///
  /// Deleted records are skipped, and so is any record whose type this build
  /// cannot resolve — an unknown type is not evidence of an unfinished record,
  /// and guessing would put a nudge on something nobody can act on.
  static List<AuthorRecord> barelyStarted(
    Iterable<AuthorRecord> records,
    RecordTypeRegistry types,
  ) {
    final found = <AuthorRecord>[];
    for (final record in records) {
      if (record.status == AuthorRecordStatus.deleted) continue;
      final RecordTypeDefinition definition;
      try {
        definition = types.resolve(record.typeId);
      } catch (_) {
        continue;
      }
      if (isBarelyStarted(record, definition)) found.add(record);
    }
    return List.unmodifiable(found);
  }
}
