/// Language Forge Phase 1 — transliteration for the Alphabet and Script
/// Designer.
///
/// An author types in romanisation and reads it back in the fictional script.
/// A [ScriptMapping] is the table between the two: romanised graphemes on one
/// side, glyphs on the other. A glyph is any string — a Unicode letter from an
/// existing script, or a Private Use Area code point the author's uploaded or
/// drawn glyph font renders. The mapping does not care which, and never draws.
///
/// ## What the mapping owns, and what it does not
///
/// The canonical `writing-system` record keeps the script's type, direction,
/// symbols and literacy in its own fields, and stays readable whatever an
/// account owns. This is the room's working table over that record, keyed by
/// its id — the same sidecar arrangement Hearts & Tensions uses for arcs. The
/// direction is carried for presentation only: text is stored in logical
/// order and a surface lays it out, so a right-to-left script is never
/// reversed here.
///
/// ## Honest about gaps
///
/// Characters the table does not cover pass through unchanged **and are
/// reported**, so a preview never silently shows a half-converted word as if
/// it were finished.
library;

/// Which way a surface lays out the script. Presentation only.
enum ScriptDirection { leftToRight, rightToLeft, topToBottom }

/// One grapheme correspondence.
class GlyphMapping {
  const GlyphMapping({
    required this.romanised,
    required this.glyph,
    this.name = '',
  })  : assert(romanised != ''),
        assert(glyph != '');

  /// As typed, lowercase.
  final String romanised;

  /// As displayed in the fictional script.
  final String glyph;

  /// The letter's name in its own language, for the alphabet chart.
  final String name;

  Map<String, Object?> toJson() => {
        'romanised': romanised,
        'glyph': glyph,
        if (name.isNotEmpty) 'name': name,
      };

  factory GlyphMapping.fromJson(Map<String, Object?> json) => GlyphMapping(
        romanised: (json['romanised'] as String).toLowerCase(),
        glyph: json['glyph'] as String,
        name: json['name'] as String? ?? '',
      );
}

/// A converted text, and what could not be converted.
class Transliteration {
  const Transliteration({required this.output, required this.unmapped});

  final String output;

  /// Characters the table had no entry for, in order of first appearance.
  final List<String> unmapped;

  bool get isComplete => unmapped.isEmpty;
}

class ScriptMapping {
  ScriptMapping({
    required this.writingSystemRecordId,
    required List<GlyphMapping> glyphs,
    this.direction = ScriptDirection.leftToRight,
    this.passThrough = ' \t\n.,;:!?\'"-()[]',
  }) : glyphs = List.unmodifiable(glyphs) {
    for (final glyph in glyphs) {
      _forward.putIfAbsent(glyph.romanised, () => glyph.glyph);
      _backward.putIfAbsent(glyph.glyph, () => glyph.romanised);
    }
    _romanisedLongestFirst = _forward.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    _glyphsLongestFirst = _backward.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
  }

  static const schemaVersion = 1;

  /// The canonical `writing-system` record this table belongs to.
  final String writingSystemRecordId;

  /// In chart order — the order the author arranged the alphabet in.
  final List<GlyphMapping> glyphs;

  final ScriptDirection direction;

  /// Characters that are neither mapped nor reported: spacing and the
  /// punctuation a script without its own punctuation borrows.
  final String passThrough;

  final Map<String, String> _forward = {};
  final Map<String, String> _backward = {};
  late final List<String> _romanisedLongestFirst;
  late final List<String> _glyphsLongestFirst;

  /// Romanisation to script. Case-insensitive on input.
  Transliteration toScript(String romanised) =>
      _convert(romanised.toLowerCase(), _romanisedLongestFirst, _forward);

  /// Script back to romanisation — the reverse of [toScript] wherever the
  /// table is one-to-one. Where two graphemes share a glyph, the first in chart
  /// order wins, and [ambiguousGlyphs] names the glyph so the author knows.
  Transliteration toRomanised(String script) =>
      _convert(script, _glyphsLongestFirst, _backward);

  /// Glyphs more than one romanised grapheme maps to. Reading such a glyph
  /// back cannot say which was meant.
  List<String> get ambiguousGlyphs {
    final counts = <String, int>{};
    for (final glyph in glyphs) {
      counts[glyph.glyph] = (counts[glyph.glyph] ?? 0) + 1;
    }
    return [
      for (final entry in counts.entries)
        if (entry.value > 1) entry.key,
    ];
  }

  Transliteration _convert(
    String source,
    List<String> keysLongestFirst,
    Map<String, String> table,
  ) {
    final output = StringBuffer();
    final unmapped = <String>[];
    var index = 0;
    while (index < source.length) {
      String? key;
      for (final candidate in keysLongestFirst) {
        if (source.startsWith(candidate, index)) {
          key = candidate;
          break;
        }
      }
      if (key != null) {
        output.write(table[key]);
        index += key.length;
        continue;
      }
      final char = _characterAt(source, index);
      output.write(char);
      if (!passThrough.contains(char) && !unmapped.contains(char)) {
        unmapped.add(char);
      }
      index += char.length;
    }
    return Transliteration(
      output: output.toString(),
      unmapped: List.unmodifiable(unmapped),
    );
  }

  /// One whole character at [index], keeping a surrogate pair together so a
  /// Private Use glyph above U+FFFF is reported as itself, not as halves.
  static String _characterAt(String source, int index) {
    final unit = source.codeUnitAt(index);
    final isHighSurrogate = unit >= 0xD800 && unit <= 0xDBFF;
    if (isHighSurrogate && index + 1 < source.length) {
      return source.substring(index, index + 2);
    }
    return source[index];
  }

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'writingSystemRecordId': writingSystemRecordId,
        'direction': direction.name,
        'glyphs': [for (final glyph in glyphs) glyph.toJson()],
      };

  factory ScriptMapping.fromJson(Map<String, Object?> json) {
    final version = (json['schemaVersion'] as num?)?.toInt() ?? 1;
    if (version > schemaVersion) {
      throw FormatException('Script schema $version is newer than '
          '$schemaVersion; this build cannot read it.');
    }
    return ScriptMapping(
      writingSystemRecordId: json['writingSystemRecordId'] as String,
      direction: ScriptDirection.values
          .byName(json['direction'] as String? ?? 'leftToRight'),
      glyphs: [
        for (final raw in json['glyphs'] as List)
          GlyphMapping.fromJson(Map<String, Object?>.from(raw as Map)),
      ],
    );
  }
}
