/// Continuity domain logic.
///
/// Extracted verbatim from `lib/ui/continuity.dart` so Core can reach the
/// analyzer and its value types without reaching Flutter. The timeline widgets
/// that used to sit alongside these declarations stay in
/// `lib/ui/continuity.dart`,
/// which re-exports this library so existing importers are unaffected.
///
/// Pure Dart: this library must not gain a Flutter, persistence, or platform
/// dependency.
library;

enum ContinuityWarningType {
  unknownCharacter,
  unknownLocation,
  missingPovPresence,
  characterOverlap,
  impossibleTravel,
  invalidRange,
  impossibleSequence,
  missingRelationship,

  /// Two typed facts about the same thing disagree.
  ///
  /// Raised only from structured data — record fields, per-book states, and
  /// typed relationships. Prose is never parsed for facts, so AuthorOS can
  /// point at both sides of a contradiction and never has to guess.
  canonContradiction,
}

enum ContinuitySeverity { notice, warning, critical }

enum ContinuityActionKind { create, link, review }

class ContinuityEventSnapshot {
  const ContinuityEventSnapshot({
    required this.id,
    required this.title,
    required this.startDay,
    required this.endDay,
    required this.order,
    required this.pov,
    required this.plotline,
    required this.presentCharacters,
    this.dateLabel = '',
    this.type = 'Plot',
    this.location = '',
    this.travelDaysFromPrevious = 0,
  });

  final String id;
  final String title;
  final int startDay;
  final int endDay;
  final int order;
  final String pov;
  final String plotline;
  final List<String> presentCharacters;
  final String dateLabel;
  final String type;
  final String location;
  final int travelDaysFromPrevious;
}

class ContinuityWarning {
  const ContinuityWarning({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.eventIds,
  });

  final ContinuityWarningType type;
  final ContinuitySeverity severity;
  final String title;
  final String message;
  final List<String> eventIds;
}

class ContinuityIntegrityIssue {
  const ContinuityIntegrityIssue({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.eventIds,
  });

  final ContinuityWarningType type;
  final ContinuitySeverity severity;
  final String title;
  final String message;
  final String recommendation;
  final List<String> eventIds;

  ContinuityActionKind get actionKind => switch (type) {
        ContinuityWarningType.unknownCharacter ||
        ContinuityWarningType.unknownLocation =>
          ContinuityActionKind.create,
        ContinuityWarningType.missingRelationship => ContinuityActionKind.link,
        _ => ContinuityActionKind.review,
      };
}

class ContinuityIntegritySummary {
  const ContinuityIntegritySummary({
    required this.score,
    required this.criticalCount,
    required this.warningCount,
    required this.noticeCount,
    required this.issues,
  });

  final int score;
  final int criticalCount;
  final int warningCount;
  final int noticeCount;
  final List<ContinuityIntegrityIssue> issues;
}

class ContinuityAnalyzer {
  const ContinuityAnalyzer();

  static String _recommendationFor(ContinuityWarning warning) {
    switch (warning.type) {
      case ContinuityWarningType.unknownCharacter:
        return 'Add the character to your project roster or remove them from the scene to keep the cast accurate.';
      case ContinuityWarningType.unknownLocation:
        return 'Add this location to the Story Codex or update the scene reference so the world map stays consistent.';
      case ContinuityWarningType.missingPovPresence:
        return 'Assign the POV to a present character or change the scene POV so the narrative perspective remains consistent.';
      case ContinuityWarningType.characterOverlap:
        return 'Adjust one scene timeline or remove the duplicate character from the conflicting event to preserve story logic.';
      case ContinuityWarningType.impossibleTravel:
        return 'Increase travel time between locations or correct the route so the character can plausibly reach the next event.';
      case ContinuityWarningType.invalidRange:
        return 'Fix the start and end day values so the scene timeline never ends before it begins.';
      case ContinuityWarningType.impossibleSequence:
        return 'Reorder the event chronology so the sequence follows the actual story timeline.';
      case ContinuityWarningType.missingRelationship:
        return 'Link the existing records so their relationship is represented with stable IDs.';
      case ContinuityWarningType.canonContradiction:
        return 'Two records state different things about the same fact. Decide which is canon; AuthorOS will not choose for you.';
    }
  }

  static ContinuityIntegritySummary summaryFor(
      List<ContinuityWarning> warnings) {
    final issues = warnings
        .map((warning) => ContinuityIntegrityIssue(
              type: warning.type,
              severity: warning.severity,
              title: warning.title,
              message: warning.message,
              recommendation: _recommendationFor(warning),
              eventIds: warning.eventIds,
            ))
        .toList();

    final criticalCount = warnings
        .where((warning) => warning.severity == ContinuitySeverity.critical)
        .length;
    final warningCount = warnings
        .where((warning) => warning.severity == ContinuitySeverity.warning)
        .length;
    final noticeCount = warnings
        .where((warning) => warning.severity == ContinuitySeverity.notice)
        .length;

    final score =
        (100 - (criticalCount * 25) - (warningCount * 10) - (noticeCount * 4))
            .clamp(0, 100);

    return ContinuityIntegritySummary(
      score: score,
      criticalCount: criticalCount,
      warningCount: warningCount,
      noticeCount: noticeCount,
      issues: issues,
    );
  }

  List<ContinuityWarning> analyze(
    List<ContinuityEventSnapshot> events, {
    Iterable<String>? knownCharacters,
    Iterable<String>? knownLocations,
  }) {
    final warnings = <ContinuityWarning>[];
    final knownCharacterSet = knownCharacters?.toSet();
    final knownLocationSet = knownLocations?.toSet();
    final byOrder = [...events]
      ..sort((left, right) => left.order.compareTo(right.order));

    for (final event in byOrder) {
      final unknownCharacters = knownCharacterSet == null
          ? <String>[]
          : event.presentCharacters
              .where((character) => !knownCharacterSet.contains(character))
              .toSet()
              .toList()
        ..sort();
      if (unknownCharacters.isNotEmpty) {
        warnings.add(ContinuityWarning(
          type: ContinuityWarningType.unknownCharacter,
          severity: ContinuitySeverity.warning,
          title: 'Unknown character presence',
          message:
              '${unknownCharacters.join(', ')} is marked present in ${event.title} but is not in the project roster.',
          eventIds: [event.id],
        ));
      }

      if (event.location.isNotEmpty && knownLocationSet != null) {
        final normalizedLocation = event.location.trim();
        final normalizedMatches = {
          normalizedLocation,
          normalizedLocation.toLowerCase(),
          normalizedLocation.toUpperCase(),
          normalizedLocation.split(RegExp(r'\s+')).map((part) {
            if (part.isEmpty) {
              return part;
            }
            return part[0].toUpperCase() + part.substring(1).toLowerCase();
          }).join(' '),
        };
        if (!normalizedMatches.any(knownLocationSet.contains)) {
          warnings.add(ContinuityWarning(
            type: ContinuityWarningType.unknownLocation,
            severity: ContinuitySeverity.warning,
            title: 'Unknown world location',
            message:
                '${event.location} is referenced by ${event.title} but is not in the Story Codex or project world database.',
            eventIds: [event.id],
          ));
        }
      }

      if (event.endDay < event.startDay) {
        warnings.add(ContinuityWarning(
          type: ContinuityWarningType.invalidRange,
          severity: ContinuitySeverity.critical,
          title: 'Impossible date range',
          message:
              '${event.title} ends on Day ${event.endDay} before it starts on Day ${event.startDay}.',
          eventIds: [event.id],
        ));
      }

      if (event.pov.isNotEmpty &&
          !event.presentCharacters.contains(event.pov)) {
        warnings.add(ContinuityWarning(
          type: ContinuityWarningType.missingPovPresence,
          severity: ContinuitySeverity.warning,
          title: 'POV character is absent',
          message:
              '${event.pov} is the POV for ${event.title} but is not marked present.',
          eventIds: [event.id],
        ));
      }
    }

    for (var index = 1; index < byOrder.length; index++) {
      final previous = byOrder[index - 1];
      final current = byOrder[index];
      if (current.startDay < previous.startDay) {
        warnings.add(ContinuityWarning(
          type: ContinuityWarningType.impossibleSequence,
          severity: ContinuitySeverity.warning,
          title: 'Timeline order moves backward',
          message:
              '${current.title} is ordered after ${previous.title}, but starts earlier.',
          eventIds: [previous.id, current.id],
        ));
      }
    }

    for (var leftIndex = 0; leftIndex < events.length; leftIndex++) {
      final left = events[leftIndex];
      if (left.endDay < left.startDay) {
        continue;
      }

      for (var rightIndex = leftIndex + 1;
          rightIndex < events.length;
          rightIndex++) {
        final right = events[rightIndex];
        if (right.endDay < right.startDay || left.plotline == right.plotline) {
          continue;
        }

        final overlaps =
            left.startDay <= right.endDay && right.startDay <= left.endDay;
        if (!overlaps) {
          continue;
        }

        final sharedCharacters = left.presentCharacters
            .where(right.presentCharacters.contains)
            .toSet()
            .toList()
          ..sort();
        if (sharedCharacters.isEmpty) {
          continue;
        }

        warnings.add(ContinuityWarning(
          type: ContinuityWarningType.characterOverlap,
          severity: ContinuitySeverity.critical,
          title: 'Character appears in overlapping events',
          message:
              '${sharedCharacters.join(', ')} cannot be in ${left.title} and ${right.title} during the same time range.',
          eventIds: [left.id, right.id],
        ));
      }
    }

    final characters =
        events.expand((event) => event.presentCharacters).toSet();
    for (final character in characters) {
      final appearances = events
          .where((event) =>
              event.presentCharacters.contains(character) &&
              event.endDay >= event.startDay)
          .toList()
        ..sort((left, right) {
          final byDay = left.startDay.compareTo(right.startDay);
          return byDay != 0 ? byDay : left.order.compareTo(right.order);
        });

      for (var index = 1; index < appearances.length; index++) {
        final previous = appearances[index - 1];
        final current = appearances[index];
        if (previous.location.isEmpty ||
            current.location.isEmpty ||
            previous.location == current.location ||
            current.travelDaysFromPrevious <= 0) {
          continue;
        }

        final availableDays = current.startDay - previous.endDay;
        if (availableDays >= current.travelDaysFromPrevious) {
          continue;
        }

        warnings.add(ContinuityWarning(
          type: ContinuityWarningType.impossibleTravel,
          severity: ContinuitySeverity.critical,
          title: 'Impossible character travel',
          message:
              '$character has $availableDays day${availableDays == 1 ? '' : 's'} to travel from ${previous.location} to ${current.location}, but ${current.travelDaysFromPrevious} are required.',
          eventIds: [previous.id, current.id],
        ));
      }
    }

    return warnings;
  }
}
