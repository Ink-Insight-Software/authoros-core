/// A file the author attached to one record, as it travels.
///
/// The project database keeps these in its per-record asset table
/// (`RecordAssetRows` in `authoros_persistence`), keyed by project, record and
/// *role*: a character's `avatar`, an idea's `voice` note, a research entry's
/// `reference` file. This is that row's shape outside the database, so the
/// archive can carry it without importing drift, and an application can copy
/// one from a world to its duplicate without reaching into the table.
///
/// It is not a second description of anything. The row is the asset; this is
/// the row in transit, and nothing keeps it.
///
/// An asset is never graph truth. It is not the endpoint of a link, it
/// changes no field, and a record's canon does not depend on it.
library;

import 'dart:typed_data';

class RecordAsset {
  RecordAsset({
    required this.projectId,
    required this.recordId,
    required this.role,
    required this.mediaType,
    required this.bytes,
    required this.updatedAt,
    this.width,
    this.height,
    Map<String, Object?> extension = const {},
  }) : extension = Map.unmodifiable(extension);

  final String projectId;

  /// The record this belongs to. A plain id, as the table's column is.
  final String recordId;

  /// Which asset of the record this is: `avatar`, `voice`, `reference`, or a
  /// role a later build adds. The archive carries every role, known or not.
  final String role;

  /// The IANA type, as the importer sniffed it from the file's own bytes.
  final String mediaType;

  final Uint8List bytes;
  final int? width;
  final int? height;
  final DateTime updatedAt;

  /// The row's `extensionJson`, as written.
  final Map<String, Object?> extension;

  /// The key the table enforces: one asset per project, record and role.
  String get key => '$projectId|$recordId|$role';

  int get byteLength => bytes.length;

  /// The same asset under another record or project: a duplicate's copy.
  RecordAsset movedTo({String? projectId, String? recordId}) => RecordAsset(
        projectId: projectId ?? this.projectId,
        recordId: recordId ?? this.recordId,
        role: role,
        mediaType: mediaType,
        bytes: bytes,
        width: width,
        height: height,
        updatedAt: updatedAt,
        extension: extension,
      );
}
