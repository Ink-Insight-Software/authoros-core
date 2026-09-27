import 'connected_domain.dart';
import 'record_types.dart';

enum RecordValidationSeverity { warning, error }

class RecordValidationIssue {
  const RecordValidationIssue({
    required this.code,
    required this.message,
    this.fieldId,
    this.severity = RecordValidationSeverity.error,
  });

  final String code;
  final String message;
  final String? fieldId;
  final RecordValidationSeverity severity;
}

class RecordValidationResult {
  const RecordValidationResult(this.issues);

  final List<RecordValidationIssue> issues;

  bool get isValid =>
      !issues.any((issue) => issue.severity == RecordValidationSeverity.error);
  List<RecordValidationIssue> get errors => issues
      .where((issue) => issue.severity == RecordValidationSeverity.error)
      .toList();
  List<RecordValidationIssue> get warnings => issues
      .where((issue) => issue.severity == RecordValidationSeverity.warning)
      .toList();
}

class RecordValidationException implements Exception {
  const RecordValidationException(this.result);

  final RecordValidationResult result;

  @override
  String toString() =>
      'Record validation failed: ${result.errors.map((issue) => issue.message).join(' ')}';
}

class RecordValidator {
  const RecordValidator(this.registry);

  final RecordTypeRegistry registry;

  RecordValidationResult validate(
    AuthorRecord record, {
    required String projectId,
    Set<String> inheritedScopeIds = const {},
  }) {
    final issues = <RecordValidationIssue>[];
    if (record.id.trim().isEmpty) {
      issues.add(const RecordValidationIssue(
        code: 'missing-id',
        message: 'Record id is required.',
      ));
    }
    if (record.title.trim().isEmpty) {
      issues.add(const RecordValidationIssue(
        code: 'missing-title',
        message: 'Record title is required.',
        fieldId: 'title',
      ));
    }
    if (record.scopeId.trim().isEmpty) {
      issues.add(const RecordValidationIssue(
        code: 'missing-scope',
        message: 'Record scope id is required.',
      ));
    }
    final owningProjectId = record.projectId;
    // Shared canon belongs to a scope above the book, so a member book reading
    // it is not a mismatch.
    final inheritedShared = isInheritedSharedScope(
      scopeType: record.scopeType,
      scopeId: record.scopeId,
      inheritedScopeIds: inheritedScopeIds,
    );
    if (record.scopeId != projectId &&
        owningProjectId != projectId &&
        !inheritedShared) {
      issues.add(RecordValidationIssue(
        code: 'project-mismatch',
        message: 'Record ${record.id} does not belong to project $projectId.',
      ));
    }
    try {
      RecordScope(
        type: record.scopeType,
        id: record.scopeId,
        projectId: owningProjectId is String
            ? owningProjectId
            : (inheritedShared ? record.scopeId : projectId),
        seriesId: record.seriesId,
        bookId: record.bookId,
        branchId: record.branchId,
      ).validate();
    } on FormatException catch (error) {
      issues.add(RecordValidationIssue(
        code: 'invalid-scope-hierarchy',
        message: error.message,
      ));
    }

    RecordTypeDefinition? definition;
    try {
      registry.resolve(record.typeId);
    } on StateError {
      issues.add(RecordValidationIssue(
        code: 'unknown-record-type',
        message: 'Unknown record type: ${record.typeId}.',
      ));
    }
    final templateId = record.templateId ?? record.typeId;
    try {
      definition = registry.resolve(templateId);
    } on StateError {
      issues.add(RecordValidationIssue(
        code: 'unknown-template',
        message: 'Unknown record template: $templateId.',
      ));
    }
    if (definition == null) {
      return RecordValidationResult(issues);
    }
    if (!registry.isTemplateCompatible(templateId, record.typeId)) {
      issues.add(RecordValidationIssue(
        code: 'incompatible-template',
        message:
            'Template $templateId is not compatible with ${record.typeId}.',
      ));
    }
    if (!definition.allowedScopeTypes.contains(record.scopeType)) {
      issues.add(RecordValidationIssue(
        code: 'invalid-scope',
        message:
            '${definition.name} records cannot use ${record.scopeType.name} scope.',
      ));
    }
    final recordTemplateVersion =
        record.templateVersion ?? record.schemaVersion;
    if (recordTemplateVersion > definition.templateVersion) {
      issues.add(RecordValidationIssue(
        code: 'schema-mismatch',
        message: 'Record template version $recordTemplateVersion is newer than '
            '${definition.name} template version ${definition.templateVersion}.',
      ));
    }
    for (final field in definition.fields) {
      // A disabled field does not apply to this record, so it is neither
      // demanded nor type-checked. Its stored value is deliberately left
      // alone: disabling must never be a way to lose data, and re-enabling
      // has to find the value where it was.
      if (!field.enabled) continue;
      final value = field.extensionData['recordProperty'] == 'title'
          ? record.title
          : record.fields[field.id];
      if (field.required && _isEmpty(value)) {
        issues.add(RecordValidationIssue(
          code: 'missing-required-field',
          message: '${field.label} is required.',
          fieldId: field.id,
        ));
      } else if (!_isEmpty(value) &&
          !_matchesType(field, value, registry.optionsFor(field))) {
        issues.add(RecordValidationIssue(
          code: 'invalid-field-type',
          message: '${field.label} has an invalid value.',
          fieldId: field.id,
        ));
      }
    }
    return RecordValidationResult(issues);
  }
}

// Both questions moved to `record_types.dart`, beside the field system they
// are about, so connection metadata can ask them without importing this file —
// which would close a cycle, since `connected_domain.dart` imports
// `connection_types.dart` and this file imports that.
bool _isEmpty(Object? value) => recordFieldIsEmpty(value);

bool _matchesType(
  RecordFieldDefinition field,
  Object? value,
  List<String> choices,
) =>
    recordFieldAccepts(field, value, choices: choices);
