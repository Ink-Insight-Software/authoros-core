import 'package:authoros_core/built_in_connection_types.dart';
import 'package:authoros_core/built_in_record_types.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/connection_types.dart';
import 'package:authoros_core/link_span.dart';
import 'package:test/test.dart';

final _at = DateTime.utc(2026, 10, 23);

RecordLink _link(String type, Map<String, Object?> metadata) => RecordLink(
      id: 'l',
      sourceId: 'a',
      targetId: 'b',
      typeId: type,
      scopeId: 'w',
      createdAt: _at,
      updatedAt: _at,
      metadata: metadata,
    );

/// Reads a bare year and nothing else, as a test's stand-in for an
/// application's date reader.
class _Year implements LinkMoment {
  const _Year(this.year);

  final int year;

  @override
  int? place(Object written) {
    final value = written is num ? written.toInt() : int.tryParse('$written');
    return value?.compareTo(year);
  }
}

void main() {
  final edges = BuiltInConnectionTypes.registry(
    recordTypes: BuiltInRecordTypes.registry(),
  );

  group('which keys start and end an edge', () {
    test('three pairs, declared once', () {
      expect(ConnectionTypeDefinition.spanKeyPairs, [
        ('startDate', 'endDate'),
        ('beginning', 'ending'),
        ('joinedDate', 'leftDate'),
      ]);
    });

    test('each built-in edge with dates names one pair, both halves', () {
      final halves = {
        for (final (start, end) in ConnectionTypeDefinition.spanKeyPairs) ...{
          start: (start, end),
          end: (start, end),
        },
      };
      for (final definition in edges.definitions) {
        final dates = {
          for (final key in definition.temporalMetadataKeys)
            if (key != 'status') key,
        };
        if (dates.isEmpty) {
          expect(definition.spanKeys, isNull, reason: definition.id);
          continue;
        }
        final pair = definition.spanKeys;
        expect(pair, isNotNull, reason: definition.id);
        expect(dates, {pair!.$1, pair.$2}, reason: definition.id);
        for (final key in dates) {
          expect(halves[key], pair, reason: '${definition.id}.$key');
        }
      }
    });

    test('the three families, by example', () {
      expect(edges.resolve('atWarWith').spanKeys, ('startDate', 'endDate'));
      expect(edges.resolve('alliedWith').spanKeys, ('beginning', 'ending'));
      expect(edges.resolve('memberOf').spanKeys, ('joinedDate', 'leftDate'));
      expect(edges.resolve('controls').spanKeys, isNull);
    });
  });

  group('a link at a moment', () {
    LinkStanding at(int year, String type, Map<String, Object?> metadata) =>
        LinkSpanText.of(_link(type, metadata)).at(_Year(year));

    test('reads whichever pair it carries', () {
      final membership =
          LinkSpanText.of(_link('memberOf', {'joinedDate': '1180'}));
      expect(membership.start, '1180');
      expect(membership.ended, isFalse);
      final romance = LinkSpanText.of(
        _link('partnerOf', {'beginning': ' 1190 ', 'ending': ''}),
      );
      expect(romance.start, '1190');
      expect(romance.end, isNull);
    });

    test('an end before the moment has ended it', () {
      expect(at(1201, 'atWarWith', {'startDate': '1180', 'endDate': '1190'}),
          LinkStanding.ended);
      expect(at(1201, 'memberOf', {'leftDate': '1200'}), LinkStanding.ended);
    });

    test('a start after the moment has not begun', () {
      expect(
          at(1170, 'alliedWith', {'beginning': '1180'}), LinkStanding.notYet);
    });

    test('within its span, or at either end, it holds', () {
      expect(at(1185, 'atWarWith', {'startDate': '1180', 'endDate': '1190'}),
          LinkStanding.holds);
      expect(at(1190, 'atWarWith', {'startDate': '1180', 'endDate': '1190'}),
          LinkStanding.holds);
      expect(at(1180, 'atWarWith', {'startDate': '1180'}), LinkStanding.holds);
    });

    test('a link with no dates holds', () {
      expect(at(1201, 'atWarWith', const {}), LinkStanding.holds);
    });

    test('a date the moment cannot place is "can\'t tell", which counts', () {
      final unread = at(
          1201, 'atWarWith', {'startDate': '1180', 'endDate': 'after Varrow'});
      expect(unread, LinkStanding.cannotTell);
      expect(unread.counts, isTrue);
      expect(at(1201, 'memberOf', {'joinedDate': 'in her youth'}),
          LinkStanding.cannotTell);
    });

    test('but a placed date that proves it over still sets it aside', () {
      expect(
        at(1170, 'atWarWith',
            {'startDate': '1180', 'endDate': 'after the Varrow concord'}),
        LinkStanding.notYet,
      );
      expect(LinkStanding.ended.counts, isFalse);
      expect(LinkStanding.notYet.counts, isFalse);
    });
  });
}
