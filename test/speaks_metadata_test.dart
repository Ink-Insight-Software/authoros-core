import 'package:authoros_core/built_in_connection_types.dart';
import 'package:authoros_core/record_types.dart';
import 'package:test/test.dart';

void main() {
  final registry = BuiltInConnectionTypes.registry();
  final speaks = registry.resolve('speaks');

  RecordFieldDefinition field(String id) =>
      speaks.resolvedMetadataFields.singleWhere((field) => field.id == id);

  test('speaks declares fluency, literacy and accent beside the Codex keys',
      () {
    final ids = [for (final field in speaks.resolvedMetadataFields) field.id];
    expect(ids, containsAll(['strength', 'startDate', 'notes', 'source']));
    expect(ids, containsAll(['fluency', 'literacy', 'accent']));
    expect(field('fluency').type, RecordFieldType.singleChoice);
    expect(field('fluency').options, [
      'Native',
      'Fluent',
      'Conversational',
      'Basic',
      'Understands only',
    ]);
    expect(field('literacy').type, RecordFieldType.singleChoice);
    expect(field('literacy').options,
        ['Reads and writes', 'Reads only', 'Spoken only']);
    expect(field('accent').type, RecordFieldType.shortText);
  });

  test('no other Codex relationship gains them', () {
    for (final id in ['worships', 'practices', 'influences']) {
      final ids = {
        for (final field in registry.resolve(id).resolvedMetadataFields)
          field.id,
      };
      expect(ids.intersection({'fluency', 'literacy', 'accent'}), isEmpty,
          reason: id);
    }
  });

  test('a speaks link with the three is accepted', () {
    registry.validateConnection(
      typeId: 'speaks',
      sourceTypeId: 'character',
      targetTypeId: 'language',
      metadata: {
        'fluency': 'Fluent',
        'literacy': 'Reads only',
        'accent': 'Clipped, from the northern valleys',
      },
    );
  });

  test("an author's own word is kept, as union's is", () {
    registry.validateConnection(
      typeId: 'speaks',
      sourceTypeId: 'character',
      targetTypeId: 'language',
      metadata: {'fluency': 'Rusty', 'literacy': 'Reads the old hand only'},
    );
  });

  test('a speaks link without them still reads', () {
    registry.validateConnection(
      typeId: 'speaks',
      sourceTypeId: 'character',
      targetTypeId: 'language',
    );
    registry.validateConnection(
      typeId: 'speaks',
      sourceTypeId: 'culture',
      targetTypeId: 'language',
      metadata: {'strength': 3, 'notes': 'Trade tongue'},
    );
  });

  test('a value of the wrong type is still refused', () {
    expect(
      () => registry.validateConnection(
        typeId: 'speaks',
        sourceTypeId: 'character',
        targetTypeId: 'language',
        metadata: {'fluency': 4},
      ),
      throwsStateError,
    );
  });
}
