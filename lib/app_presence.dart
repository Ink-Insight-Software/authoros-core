/// Which application last opened a project, and when (AOS Worldsmith build
/// plan, Phase 10: the "last opened in" marker, October 10, 2026).
///
/// A world is one `.authoros` project that both AOS Worldsmith and AuthorOS
/// Write can open. When it moves between them, by a backup restored in the
/// other, the author should be told that the other application touched it
/// last, and when. This record says so.
///
/// It is organisational metadata, the shape `PinnedRecords` uses: one record
/// per project, scoped to it, holding when each application last opened the
/// project. It takes no links, is not in the record type registry, and no
/// room lists it.
library;

import 'connected_domain.dart';

/// What the marker says about a project.
class AppPresenceReading {
  const AppPresenceReading({required this.openedAt});

  /// Application id → when it last opened the project, in UTC.
  final Map<String, DateTime> openedAt;

  /// The application that opened the project most recently, or null.
  String? get lastApp {
    String? app;
    DateTime? at;
    for (final MapEntry(key: id, value: when) in openedAt.entries) {
      if (at == null || when.isAfter(at)) {
        app = id;
        at = when;
      }
    }
    return app;
  }

  /// Whether another application opened the project after [app] last did.
  /// The first time [app] opens it, any other application's opening counts.
  bool openedElsewhereSince(String app) {
    final mine = openedAt[app];
    for (final MapEntry(key: id, value: when) in openedAt.entries) {
      if (id == app) continue;
      if (mine == null || when.isAfter(mine)) return true;
    }
    return false;
  }
}

abstract final class AppPresence {
  /// Not in the registry, like `codexCollection`: organisational metadata.
  static const String typeId = 'app-presence';

  static const String field = 'openedAt';

  /// The two applications that open AuthorOS projects today.
  static const String authorosWrite = 'authoros-write';
  static const String worldsmith = 'aos-worldsmith';

  static String recordIdFor(String projectId) => 'app-presence-$projectId';

  /// [projectId]'s marker among [records], or null.
  static AuthorRecord? markerIn(
    Iterable<AuthorRecord> records,
    String projectId,
  ) {
    final id = recordIdFor(projectId);
    for (final record in records) {
      if (record.id == id && record.typeId == typeId) return record;
    }
    return null;
  }

  /// What [marker] says, or nothing when there is no marker.
  static AppPresenceReading read(AuthorRecord? marker) {
    final stored = marker?.fields[field];
    final openedAt = <String, DateTime>{};
    if (stored is Map) {
      for (final MapEntry(:key, :value) in stored.entries) {
        final when = value is String ? DateTime.tryParse(value) : null;
        if (when != null) openedAt['$key'] = when.toUtc();
      }
    }
    return AppPresenceReading(openedAt: openedAt);
  }

  /// [marker] (or a new one for [projectId]) saying [app] opened the project
  /// at [now]. The caller writes it.
  static AuthorRecord opened(
    AuthorRecord? marker, {
    required String projectId,
    required String app,
    required DateTime now,
  }) {
    final at = now.toUtc();
    final before = read(marker).openedAt;
    final fields = <String, Object?>{
      field: {
        for (final MapEntry(:key, :value) in before.entries)
          key: value.toIso8601String(),
        app: at.toIso8601String(),
      },
    };
    if (marker == null) {
      return AuthorRecord(
        id: recordIdFor(projectId),
        typeId: typeId,
        scopeType: RecordScopeType.project,
        scopeId: projectId,
        projectId: projectId,
        title: 'Opened by',
        fields: fields,
        createdAt: at,
        updatedAt: at,
      );
    }
    return marker.copyWith(
      fields: {...marker.fields, ...fields},
      revision: marker.revision + 1,
      updatedAt: at,
    );
  }
}
