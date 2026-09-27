/// What happens to a record after it has been written.
///
/// The domain declares this and cannot implement it. Dependency direction is
/// `core -> persistence -> services -> studios`, which the architecture lock
/// states and `architecture_lock_test.dart` holds; sync sits above core, so
/// [RecordService] importing the sync layer would be an import upward. It
/// would also drag `package:flutter/foundation.dart` and SharedPreferences
/// into a file that must resolve without a Flutter binding.
///
/// So core names the port and ships the null implementation, `lib/sync/`
/// supplies the real one, and `main()` installs it — the same shape as the
/// `AppSupabase.onSessionEstablished` wiring that sits beside it, and for the
/// same reason: the layer that knows both sides is the one at the top.
library;

import 'connected_domain.dart';

/// Told about every record the domain writes, after the write has committed.
abstract class RecordWriteSink {
  const RecordWriteSink();

  /// Called once per written record, after it is safely stored.
  ///
  /// Implementations must not throw: the local write has already succeeded,
  /// and an author must never lose a save because something downstream of it
  /// failed.
  Future<void> wrote(AuthorRecord record);

  /// Called once per written link, after it is safely stored.
  Future<void> wroteLink(RecordLink link);

  /// Called when a link is removed.
  ///
  /// Links are the one thing here that really is deleted. A record is never
  /// removed — `deleteRecord` sets a status and Lock 6 keeps the row — but
  /// disconnecting two records is not hiding anything, and the row goes. So
  /// this is the one announcement that becomes a tombstone on the wire.
  Future<void> removedLink(String linkId);
}

/// The default: records go nowhere.
///
/// This is the correct behaviour for a test, a script, and the generator
/// engine running under a plain Dart VM — none of which has a sync layer, and
/// none of which should acquire one by importing the domain.
class NoRecordWriteSink implements RecordWriteSink {
  const NoRecordWriteSink();

  @override
  Future<void> wrote(AuthorRecord record) async {}

  @override
  Future<void> wroteLink(RecordLink link) async {}

  @override
  Future<void> removedLink(String linkId) async {}
}

/// The sink the running application installs, or the no-op until it does.
///
/// Mutable and library-level for the same reason `authorOsRepository` is: the
/// alternative is threading a parameter through all thirty-six places a
/// [RecordService] is constructed, most of which have no opinion about sync
/// and should not acquire one.
///
/// `record_sync_wiring_test.dart` holds the other end — that `main()` really
/// does install the sync sink, so this staying a no-op cannot be how record
/// sync quietly fails to exist.
RecordWriteSink recordWriteSink = const NoRecordWriteSink();
