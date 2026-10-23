import 'package:authoros_core/built_in_record_types.dart';
import 'package:authoros_core/record_types.dart';
import 'package:test/test.dart';

void main() {
  final world = BuiltInRecordTypes.registry().resolve('world');

  test('the registered `world` says which era is now', () {
    final field = world.fields.singleWhere((f) => f.id == 'currentEra');
    expect(field.type, RecordFieldType.recordReference);
    expect(
      field.referenceTypeIds,
      ['timeline-era', 'timeline-historical-period'],
    );
    final society = world.sections.singleWhere((s) => s.id == 'worldSociety');
    expect(society.fieldIds, contains('currentEra'));
    expect(world.templateVersion, 2);
    expect(world.sourcePackId, 'authoros-world-core');
  });

  test('`world` is declared once, and only it has the field', () {
    expect(
      BuiltInRecordTypes.definitions.where((d) => d.id == 'world'),
      hasLength(1),
    );
    final location = BuiltInRecordTypes.registry().resolve('location');
    expect(location.fields.map((f) => f.id), isNot(contains('currentEra')));
  });
}
