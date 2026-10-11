import 'package:authoros_core/built_in_connection_types.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/consequence_traversal.dart';
import 'package:test/test.dart';

final _at = DateTime.utc(2026, 10, 11);

AuthorRecord _r(String id, String typeId, String title) => AuthorRecord(
      id: id,
      typeId: typeId,
      scopeType: RecordScopeType.project,
      scopeId: 'world',
      projectId: 'world',
      title: title,
      createdAt: _at,
      updatedAt: _at,
    );

RecordLink _l(String id, String source, String type, String target) =>
    RecordLink(
      id: id,
      sourceId: source,
      targetId: target,
      typeId: type,
      scopeId: 'world',
      createdAt: _at,
      updatedAt: _at,
    );

List<String> _reached(
  String from,
  List<AuthorRecord> records,
  List<RecordLink> links,
) =>
    [
      for (final reach in ConsequenceTraversal.traverse(
        changedId: from,
        records: records,
        links: links,
      ).reached)
        reach.explanation,
    ];

void main() {
  test('one rule per edge, so no rule silently overrides another', () {
    final ids = [
      for (final rule in ConsequenceTraversal.defaultRules) rule.edgeTypeId,
    ];
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every rule names a built-in edge', () {
    final builtIn = {
      for (final type in BuiltInConnectionTypes.definitions) type.id,
    };
    for (final rule in ConsequenceTraversal.defaultRules) {
      expect(builtIn, contains(rule.edgeTypeId), reason: rule.edgeTypeId);
    }
  });

  test(
      'the nine edges moved from Worldsmith carry a change, each the way '
      'it did there', () {
    final rules = {
      for (final rule in ConsequenceTraversal.defaultRules)
        rule.edgeTypeId: (rule.fromSource, rule.fromTarget),
    };
    expect(rules['ruledBy'], ('', 'is ruled by'));
    expect(rules['occupies'], ('', 'occupies'));
    expect(rules['signed'], ('', 'signed'));
    expect(rules['requires'], ('', 'requires'));
    expect(rules['usedBy'], ('uses', ''));
    expect(rules['uses'], ('', 'uses'));
    expect(rules['routeFrom'], ('is where it begins', ''));
    expect(rules['routeTo'], ('is where it ends', ''));
    expect(rules['practices'], ('', 'practises'));
  });

  test(
      'a treaty reaches its signatories, a route its ends, a resource its '
      'users', () {
    final records = [
      _r('treaty', 'treaty', 'Concord of Varrow'),
      _r('aster', 'civilisation', 'Asterfolk'),
      _r('road', 'travel-route', 'Salt Road'),
      _r('brine', 'town', 'Brine'),
      _r('dun', 'town', 'Dunmor'),
      _r('salt', 'resource', 'Salt'),
      _r('guild', 'faction', 'Saltwrights'),
      _r('mill', 'faction', 'Millers'),
    ];
    final links = [
      _l('l1', 'aster', 'signed', 'treaty'),
      _l('l2', 'road', 'routeFrom', 'brine'),
      _l('l3', 'road', 'routeTo', 'dun'),
      _l('l4', 'salt', 'usedBy', 'guild'),
      _l('l5', 'mill', 'uses', 'salt'),
    ];
    expect(
      _reached('treaty', records, links),
      ['Concord of Varrow → Asterfolk (signed)'],
    );
    expect(_reached('road', records, links), [
      'Salt Road → Brine (is where it begins)',
      'Salt Road → Dunmor (is where it ends)',
    ]);
    expect(_reached('salt', records, links), [
      'Salt → Millers (uses)',
      'Salt → Saltwrights (uses)',
    ]);
    // Each runs one way: the signatory's change does not reach the treaty.
    expect(_reached('aster', records, links), isEmpty);
  });

  test(
      'a ruler reaches what it rules, a land its people, a need and a '
      'practice those who hold them', () {
    final records = [
      _r('queen', 'character', 'Queen Ysolde'),
      _r('city', 'city', 'Highmere'),
      _r('folk', 'civilisation', 'Asterfolk'),
      _r('mill', 'building', 'Saltmill'),
      _r('salt', 'resource', 'Salt'),
      _r('rite', 'custom-tradition', 'The Ember Rite'),
      _r('order', 'faction', 'Keepers'),
    ];
    final links = [
      _l('l1', 'city', 'ruledBy', 'queen'),
      _l('l2', 'folk', 'occupies', 'city'),
      _l('l3', 'mill', 'requires', 'salt'),
      _l('l4', 'order', 'practices', 'rite'),
    ];
    expect(_reached('queen', records, links), [
      'Queen Ysolde → Highmere (is ruled by)',
      'Queen Ysolde → Highmere (is ruled by) → Asterfolk (occupies)',
    ]);
    expect(_reached('salt', records, links), ['Salt → Saltmill (requires)']);
    expect(_reached('rite', records, links), [
      'The Ember Rite → Keepers (practises)',
    ]);
  });
}
