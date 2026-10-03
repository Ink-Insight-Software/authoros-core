/// Public record and hidden truth, for any field of any record
/// (AOS-Write `PLAN.md` §3.46).
///
/// A world whose official records lie needs two values where a form has one:
/// what the registry says, and what happened. The field holds the public
/// value, as it always has, so every surface that reads the field reads what
/// the world believes. The truth sits beside it under `_truth.values` —
/// namespaced the way `_canon.`, `_codex.` and `_world.` are — keyed by field
/// id, so a field gains a truth without its type changing and loses it
/// without leaving anything behind.
///
/// The birth reading's *on record* and *true* records came first and stay
/// as they are: two records of a structured value, each with its own reading.
/// This is the general case for the single values every other field holds.
library;

abstract final class HiddenTruths {
  static const key = '_truth.values';

  /// Every truth on [fields], keyed by field id.
  static Map<String, Object?> of(Map<String, Object?> fields) {
    final raw = fields[key];
    return raw is Map ? Map<String, Object?>.from(raw) : const {};
  }

  /// The truth behind [fieldId], or null.
  static Object? truthOf(Map<String, Object?> fields, String fieldId) {
    final value = of(fields)[fieldId];
    return _written(value) ? value : null;
  }

  /// Whether [fieldId] carries a truth at all.
  static bool has(Map<String, Object?> fields, String fieldId) =>
      truthOf(fields, fieldId) != null;

  /// [fields] with the truth behind [fieldId] set, or removed when [truth] is
  /// empty. The key itself goes when no field has a truth left.
  static Map<String, Object?> withTruth(
    Map<String, Object?> fields,
    String fieldId,
    Object? truth,
  ) {
    final truths = {...of(fields)};
    if (_written(truth)) {
      truths[fieldId] = truth;
    } else {
      truths.remove(fieldId);
    }
    return {
      for (final entry in fields.entries)
        if (entry.key != key) entry.key: entry.value,
      if (truths.isNotEmpty) key: truths,
    };
  }

  /// Whether the record says one thing and the truth another: both written,
  /// and not the same, ignoring case and the space around them.
  static bool differs(Map<String, Object?> fields, String fieldId) {
    final truth = truthOf(fields, fieldId);
    final public = fields[fieldId];
    return truth != null &&
        _written(public) &&
        _text(truth).trim().toLowerCase() !=
            _text(public).trim().toLowerCase();
  }

  /// The field ids whose record and truth disagree.
  static List<String> differing(Map<String, Object?> fields) => [
        for (final id in of(fields).keys)
          if (differs(fields, id)) id,
      ];

  static bool _written(Object? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  static String _text(Object? value) =>
      value is Iterable ? value.join(', ') : '$value';
}
