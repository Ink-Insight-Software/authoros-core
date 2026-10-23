import 'package:authoros_core/built_in_connection_types.dart';
import 'package:authoros_core/built_in_record_types.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/government_record_types.dart';
import 'package:authoros_core/record_validation.dart';
import 'package:test/test.dart';

final _at = DateTime.utc(2026, 10, 23);

void main() {
  final types = BuiltInRecordTypes.registry();
  final edges = BuiltInConnectionTypes.registry(recordTypes: types);
  final institution = types.resolve(BuiltInRecordTypes.institutionTypeId);
  Set<String> fieldsOf(String id) =>
      {for (final field in types.resolve(id).fields) field.id};

  group('an institution is a faction', () {
    test('it inherits `faction`, filed under factions', () {
      expect(BuiltInRecordTypes.institutionTypeId, 'institution');
      expect(types.selfAndAncestors('institution'), {
        'institution',
        'faction',
        'general-lore',
      });
      expect(institution.categoryId, 'factions');
      expect(institution.templateVersion, 2);
    });

    test('with every faction field, and three of its own', () {
      expect(fieldsOf('institution'), containsAll(fieldsOf('faction')));
      expect(
        fieldsOf('institution').difference(fieldsOf('faction')),
        {'charter', 'jurisdiction', 'answersTo'},
      );
      final section =
          institution.sections.singleWhere((s) => s.id == 'institution');
      expect(section.fieldIds, ['charter', 'jurisdiction', 'answersTo']);
      final jurisdiction =
          institution.fields.singleWhere((f) => f.id == 'jurisdiction');
      expect(jurisdiction.referenceTypeIds, contains('civilisation'));
      final answersTo =
          institution.fields.singleWhere((f) => f.id == 'answersTo');
      expect(
        answersTo.referenceTypeIds,
        containsAll(['government', 'political-office', 'institution']),
      );
    });

    test('so the faction edges reach it', () {
      expect(edges.resolve('memberOf').permits('character', 'institution'),
          isTrue);
      expect(edges.resolve('atWarWith').permits('institution', 'government'),
          isTrue);
      expect(edges.resolve('appearsIn').permits('institution', 'book'), isTrue);
    });

    test('and no system claims it', () {
      expect(institution.sourcePackId, 'authoros-core');
      expect(
        GovernmentRecordTypes.reservedForOtherSystems,
        contains('institution'),
      );
    });

    test('it is declared once', () {
      expect(
        BuiltInRecordTypes.definitions.where((d) => d.id == 'institution'),
        hasLength(1),
      );
    });
  });

  group('an institution written before 0.22.0', () {
    // As 0.21.0 stored it: type `institution`, template version 1, and only
    // `general-lore` fields, the only ones it had.
    final stored = AuthorRecord.fromJson({
      'id': 'senate',
      'typeId': 'institution',
      'scopeType': 'project',
      'scopeId': 'p',
      'projectId': 'p',
      'title': 'The Senate',
      'status': 'active',
      'canonStatus': 'canon',
      'revision': 3,
      'schemaVersion': 1,
      'templateId': 'institution',
      'templateVersion': 1,
      'fields': {
        'summary': 'Three hundred, for life.',
        'aliases': ['The Hall of Voices'],
        'sourceReferences': ['research-1'],
      },
      'createdAt': _at.toIso8601String(),
      'updatedAt': _at.toIso8601String(),
    });

    test('reads with every value it had', () {
      expect(stored.typeId, 'institution');
      expect(stored.fields['summary'], 'Three hundred, for life.');
      expect(stored.fields['aliases'], ['The Hall of Voices']);
      for (final key in stored.fields.keys) {
        expect(fieldsOf('institution'), contains(key), reason: key);
      }
    });

    test('is valid against the new template', () {
      final result = RecordValidator(types).validate(stored, projectId: 'p');
      expect(result.issues, isEmpty);
    });

    test('and survives a round trip unchanged', () {
      expect(
        AuthorRecord.fromJson(stored.toJson()).toJson(),
        stored.toJson(),
      );
    });

    test('a new one may fill the fields of both', () {
      final written = AuthorRecord(
        id: 'bank',
        typeId: 'institution',
        scopeType: RecordScopeType.project,
        scopeId: 'p',
        projectId: 'p',
        title: 'The Iron Bank',
        templateVersion: 2,
        fields: const {
          'charter': 'Granted by the Sealords in perpetuity.',
          'jurisdiction': 'braavos',
          'answersTo': 'sealord',
          'leadership': ['The Keyholders'],
        },
        createdAt: _at,
        updatedAt: _at,
      );
      expect(
        RecordValidator(types).validate(written, projectId: 'p').issues,
        isEmpty,
      );
    });
  });
}
