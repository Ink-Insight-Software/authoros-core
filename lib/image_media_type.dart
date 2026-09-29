/// What an image actually is, read from its own leading bytes.
///
/// An extension is a claim and a file picker's filter is a suggestion; neither
/// is evidence. A `.png` that is really a renamed JPEG would be stored with the
/// wrong media type, and a surface that later hands those bytes to a decoder —
/// or writes them into an EPUB manifest — would be passing on the lie.
///
/// Callers narrow this to the types they are prepared to accept. This function
/// only answers what the bytes are.
library;

import 'dart:typed_data';

/// The IANA type of [bytes], or null when it is not an image this app reads.
///
/// Recognises the four formats every target platform can decode. Anything else
/// — TIFF, BMP, SVG, HEIC — returns null rather than a guess, because a caller
/// that stored it would be promising a render it cannot deliver.
String? sniffImageMediaType(Uint8List bytes) {
  if (_startsWith(bytes, const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (_startsWith(
    bytes,
    const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
  )) {
    return 'image/png';
  }
  if (_startsWith(bytes, const [0x47, 0x49, 0x46, 0x38])) return 'image/gif';
  // WebP is a RIFF container: 'RIFF', four bytes of length, then 'WEBP'.
  if (_startsWith(bytes, const [0x52, 0x49, 0x46, 0x46]) &&
      bytes.length >= 12 &&
      _matchesAt(bytes, 8, const [0x57, 0x45, 0x42, 0x50])) {
    return 'image/webp';
  }
  return null;
}

bool _startsWith(Uint8List bytes, List<int> signature) =>
    _matchesAt(bytes, 0, signature);

bool _matchesAt(Uint8List bytes, int offset, List<int> signature) {
  if (bytes.length < offset + signature.length) return false;
  for (var index = 0; index < signature.length; index++) {
    if (bytes[offset + index] != signature[index]) return false;
  }
  return true;
}
