/// Whether a link held at a moment the author asks about (AOS Worldsmith
/// build plan, Phase 2: current and historical states).
///
/// A time-bounded link says when it began and when it ended under one of the
/// key pairs [ConnectionTypeDefinition.spanKeyPairs] declares. This reads
/// those keys off a link and sets them against a moment.
///
/// ## The core does not read dates
///
/// A date on a link is whatever the author wrote: `410`, `Third Age 2931`,
/// `12 Frostmoot 410`, a structured calendar date, or `after the war`. Which
/// of those can be put in order depends on the world's own calendars and
/// eras, and an application already has a reader for them (AOS Worldsmith's
/// `WorldDates`, AuthorOS Write's `MapWorldClock`). So the moment is the
/// caller's: a [LinkMoment] places one written date against itself, or says
/// it cannot. The core decides only what the answers mean together.
///
/// ## Never a guess
///
/// A date the moment cannot place is *can't tell* ([LinkStanding.cannotTell]),
/// and can't tell counts as still holding, the same as a link with no dates
/// at all. A link is set aside only when a date the moment *can* place proves
/// it: an end before the moment, or a start after it (Lock 8).
library;

import 'connected_domain.dart';
import 'connection_types.dart';

/// A moment a link is asked about, as the caller reads its world's dates.
abstract interface class LinkMoment {
  /// Where [written], a date as a link's metadata holds it, falls against
  /// this moment: negative before it, zero at it, positive after it. Null
  /// when it cannot be placed without guessing.
  int? place(Object written);
}

/// Where a link stands at a [LinkMoment].
enum LinkStanding {
  /// It held: nothing it records says otherwise.
  holds,

  /// It had not begun: its start is after the moment.
  notYet,

  /// It had ended: its end is before the moment.
  ended,

  /// A date it records could not be placed, and none that could proves it
  /// had ended or not begun. Read as holding.
  cannotTell;

  /// Whether a reader that asks about the moment should treat the link as
  /// true then. Only a proven end or a proven later start says no.
  bool get counts => this == holds || this == cannotTell;
}

/// The dates a link records, under the first pair of
/// [ConnectionTypeDefinition.spanKeyPairs] it writes either half of.
class LinkSpanText {
  const LinkSpanText({this.start, this.end});

  /// The start as written, or null when none is.
  final Object? start;

  /// The end as written, or null when none is.
  final Object? end;

  /// Whether an end is recorded at all, placeable or not.
  bool get ended => end != null;

  static LinkSpanText of(RecordLink link) {
    for (final (start, end) in ConnectionTypeDefinition.spanKeyPairs) {
      final from = _written(link.metadata[start]);
      final until = _written(link.metadata[end]);
      if (from != null || until != null) {
        return LinkSpanText(start: from, end: until);
      }
    }
    return const LinkSpanText();
  }

  /// Where the link stands at [at].
  LinkStanding at(LinkMoment at) {
    final fromEnd = end == null ? null : at.place(end!);
    final fromStart = start == null ? null : at.place(start!);
    if (fromEnd != null && fromEnd < 0) return LinkStanding.ended;
    if (fromStart != null && fromStart > 0) return LinkStanding.notYet;
    if ((end != null && fromEnd == null) ||
        (start != null && fromStart == null)) {
      return LinkStanding.cannotTell;
    }
    return LinkStanding.holds;
  }

  /// Empty text and an empty map are not a date: the form left the field
  /// blank.
  static Object? _written(Object? value) => switch (value) {
        null => null,
        String text => text.trim().isEmpty ? null : text.trim(),
        Map<Object?, Object?> map => map.isEmpty ? null : map,
        _ => value,
      };
}
