import 'package:authoros_core/bloodline_record_types.dart';
import 'package:authoros_core/built_in_connection_types.dart';
import 'package:authoros_core/built_in_record_types.dart';
import 'package:authoros_core/record_types.dart';
import 'package:test/test.dart';

void main() {
  final connections = BuiltInConnectionTypes.registry();
  final title =
      BuiltInRecordTypes.registry().resolve(BloodlineRecordTypes.titleTypeId);

  RecordFieldDefinition field(String id) =>
      title.fields.singleWhere((field) => field.id == id);

  group('claims', () {
    final claims = connections.resolve('claims');

    test('joins a person to a title or an office, in time', () {
      expect(claims.sourceTypeIds, ['character']);
      expect(claims.targetTypeIds, ['title', 'political-office']);
      expect(claims.temporalSupport, isTrue);
      final ids = [for (final f in claims.resolvedMetadataFields) f.id];
      expect(ids, ['startDate', 'endDate', 'standing', 'basis']);
      final standing =
          claims.resolvedMetadataFields.singleWhere((f) => f.id == 'standing');
      expect(standing.options, ['Pressed', 'Renounced', 'Excluded']);
      expect(standing.allowCustomValues, isTrue);
    });

    test('a renounced claim with its date is accepted', () {
      connections.validateConnection(
        typeId: 'claims',
        sourceTypeId: 'character',
        targetTypeId: 'title',
        metadata: {
          'standing': 'Renounced',
          'basis': 'Eldest daughter of the late duke',
          'startDate': '1201',
          'endDate': '1210',
        },
      );
    });

    test('a claim with nothing recorded about it is a claim', () {
      connections.validateConnection(
        typeId: 'claims',
        sourceTypeId: 'character',
        targetTypeId: 'political-office',
      );
    });

    test("an author's own standing is kept", () {
      connections.validateConnection(
        typeId: 'claims',
        sourceTypeId: 'character',
        targetTypeId: 'title',
        metadata: {'standing': 'Held in abeyance'},
      );
    });

    test('only a person claims, and only a title or an office', () {
      expect(
        () => connections.validateConnection(
          typeId: 'claims',
          sourceTypeId: 'house',
          targetTypeId: 'title',
        ),
        throwsStateError,
      );
      expect(
        () => connections.validateConnection(
          typeId: 'claims',
          sourceTypeId: 'character',
          targetTypeId: 'estate',
        ),
        throwsStateError,
      );
    });

    test('a value of the wrong type is refused', () {
      expect(
        () => connections.validateConnection(
          typeId: 'claims',
          sourceTypeId: 'character',
          targetTypeId: 'title',
          metadata: {'standing': 3},
        ),
        throwsStateError,
      );
    });
  });

  group('how a title is held', () {
    test('the dignity carries held through, held since, regent and regency',
        () {
      final dignity =
          title.sections.singleWhere((s) => s.id == 'title-dignity');
      expect(dignity.fieldIds, [
        'rank',
        'holder',
        'heldThrough',
        'heldSince',
        'regent',
        'regency',
        'house',
        'estate',
      ]);
      expect(field('heldThrough').type, RecordFieldType.singleChoice);
      expect(field('heldThrough').optionSetId, 'title-holding');
      expect(field('heldThrough').allowCustomValues, isTrue);
      expect(field('regent').type, RecordFieldType.recordReference);
      expect(field('regent').referenceTypeIds, ['character']);
      expect(field('heldSince').type, RecordFieldType.shortText);
      expect(field('regency').type, RecordFieldType.shortText);
      final holding =
          title.optionSets.singleWhere((set) => set.id == 'title-holding');
      expect(holding.values, contains('Usurpation'));
      expect(title.templateVersion, 2);
    });

    test('every field a title had is still there, unchanged in kind', () {
      for (final (id, type) in [
        ('rank', RecordFieldType.shortText),
        ('holder', RecordFieldType.recordReference),
        ('house', RecordFieldType.recordReference),
        ('estate', RecordFieldType.recordReference),
        ('succession', RecordFieldType.singleChoice),
        ('successor', RecordFieldType.recordReference),
        ('predecessors', RecordFieldType.list),
        ('contested', RecordFieldType.longText),
        ('grantedBy', RecordFieldType.recordReference),
        ('created', RecordFieldType.shortText),
      ]) {
        expect(field(id).type, type, reason: id);
      }
    });
  });
}
