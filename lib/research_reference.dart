/// Reference attachments: a picture or a PDF the author keeps as research.
///
/// **Not a second research model.** A reference is a Research Studio entry
/// (`research-entry`, [ResearchRecordTypes]) of kind *Reference*, carrying
/// the file under the per-record asset role [ResearchReferences.assetRole].
/// Its title is the record's title; its caption, notes, credit and source
/// link are the entry's own `summary`, `notes`, `citation` and `sourceUrl`.
/// The file's type and size are the asset's. So AuthorOS Write's Research
/// Studio lists a reference AOS Worldsmith made, and the other way round.
///
/// A reference reaches the records it is about through `documents`, the
/// connection research already uses (*Documented by* from the other end).
/// One file, attached to three records, is one entry with three connections:
/// it is stored once.
///
/// **Linking never makes research canon.** A reference is written
/// [CanonStatus.nonCanon], and attaching one writes a connection and nothing
/// else: no field of the record it documents changes. A reference is
/// evidence an author consulted, not a fact of the world.
library;

import 'dart:typed_data';

import 'connected_domain.dart';
import 'image_media_type.dart';
import 'research_record_types.dart';

class ResearchReferences {
  const ResearchReferences._();

  /// The per-record asset role a reference's file is kept under.
  static const assetRole = 'reference';

  /// The research kind a reference carries.
  static const kind = 'Reference';

  /// The connection from a reference to a record it is about.
  static const documentsTypeId = 'documents';

  static const pdfMediaType = 'application/pdf';

  /// Ten megabytes a file.
  ///
  /// A scanned page or a photograph of a map is a few megabytes; a book-length
  /// PDF is not research to attach but a library to link to. The ceiling sits
  /// under the archive's sixteen-megabyte limit on one entry
  /// (`AuthorOsArchiveLimits.maximumEntryBytes`) so that every file a world
  /// accepts is one its backup can read back. A world holding many references
  /// makes a large backup; nothing here bounds the total.
  static const maxBytes = 10 * 1024 * 1024;

  /// What a reference may be: the four images every platform draws, and PDF.
  static const mediaTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    pdfMediaType,
  ];

  /// The IANA type of [bytes] when it is a file a reference may hold, read
  /// from the file's own leading bytes, never its name.
  static String? sniff(Uint8List bytes) {
    final image = sniffImageMediaType(bytes);
    if (image != null) return image;
    // `%PDF-`. Every PDF version opens with it.
    const pdf = [0x25, 0x50, 0x44, 0x46, 0x2D];
    if (bytes.length < pdf.length) return null;
    for (var index = 0; index < pdf.length; index++) {
      if (bytes[index] != pdf[index]) return null;
    }
    return pdfMediaType;
  }

  static bool isImage(String mediaType) => mediaType.startsWith('image/');

  /// Why [bytes] cannot be a reference, or null when it can. Nothing throws:
  /// a file the app cannot keep is an answer for the author.
  static ResearchReferenceRejection? rejection(Uint8List bytes) {
    if (bytes.isEmpty) return ResearchReferenceRejection.empty;
    if (bytes.length > maxBytes) return ResearchReferenceRejection.tooLarge;
    if (sniff(bytes) == null) {
      return ResearchReferenceRejection.unsupportedType;
    }
    return null;
  }

  /// Whether [record] is a research entry of kind *Reference*.
  static bool isReference(AuthorRecord record) =>
      ResearchRecordTypes.recordTypeIds.contains(record.typeId) &&
      record.fields[ResearchRecordTypes.kindFieldId] == kind;

  static String captionOf(AuthorRecord record) => _text(record, 'summary');
  static String notesOf(AuthorRecord record) => _text(record, 'notes');
  static String creditOf(AuthorRecord record) =>
      _text(record, ResearchRecordTypes.citationFieldId);
  static String sourceUrlOf(AuthorRecord record) =>
      _text(record, ResearchRecordTypes.sourceUrlFieldId);

  /// The entry's fields for a reference called [title], over [existing] so
  /// a field another studio wrote survives an edit.
  static Map<String, Object?> fields({
    required String title,
    String caption = '',
    String notes = '',
    String credit = '',
    String sourceUrl = '',
    Map<String, Object?> existing = const {},
  }) {
    final link = sourceUrl.trim();
    final written = {
      ...existing,
      'name': title.trim(),
      'summary': caption.trim(),
      'notes': notes.trim(),
      ResearchRecordTypes.kindFieldId: kind,
      ResearchRecordTypes.categoryFieldId:
          existing[ResearchRecordTypes.categoryFieldId] ??
              ResearchRecordTypes.defaultCategory,
      ResearchRecordTypes.statusFieldId:
          existing[ResearchRecordTypes.statusFieldId] ??
              ResearchRecordTypes.defaultStatus,
      ResearchRecordTypes.citationFieldId: credit.trim(),
      ResearchRecordTypes.sourceUrlFieldId: link,
    };
    // A url field is checked as a url; an empty one is left out rather than
    // stored as a link to nowhere.
    if (link.isEmpty) written.remove(ResearchRecordTypes.sourceUrlFieldId);
    return written;
  }

  /// A new reference entry in project [projectId]. Written non-canon.
  static AuthorRecord newRecord({
    required String id,
    required String projectId,
    required String title,
    required DateTime now,
    String caption = '',
    String notes = '',
    String credit = '',
    String sourceUrl = '',
  }) =>
      AuthorRecord(
        id: id,
        typeId: ResearchRecordTypes.baseTypeId,
        scopeType: RecordScopeType.project,
        scopeId: projectId,
        projectId: projectId,
        canonStatus: CanonStatus.nonCanon,
        title: title.trim(),
        fields: fields(
          title: title,
          caption: caption,
          notes: notes,
          credit: credit,
          sourceUrl: sourceUrl,
        ),
        createdAt: now,
        updatedAt: now,
      );

  /// The connection saying reference [referenceId] documents [recordId].
  static RecordLink documentsLink({
    required String id,
    required String referenceId,
    required String recordId,
    required String scopeId,
    required DateTime now,
  }) =>
      RecordLink(
        id: id,
        sourceId: referenceId,
        targetId: recordId,
        typeId: documentsTypeId,
        scopeId: scopeId,
        createdAt: now,
        updatedAt: now,
      );

  static String _text(AuthorRecord record, String field) {
    final value = record.fields[field];
    return value is String ? value : '';
  }
}

/// Why a file cannot be a reference.
enum ResearchReferenceRejection {
  empty,
  tooLarge,
  unsupportedType;

  /// What to tell the author.
  String get message => switch (this) {
        empty => 'That file is empty.',
        tooLarge => 'That file is larger than 10 MB. Try a smaller one, '
            'or link to it instead.',
        unsupportedType => 'That is not a JPEG, PNG, GIF or WebP image, '
            'or a PDF.',
      };
}
