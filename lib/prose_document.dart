/// Manuscript prose — the document model.
///
/// Until now a scene's prose was a bare `String`, and the whole manuscript —
/// every chapter, every scene, every word of it — was re-serialised into a
/// single `SharedPreferences` entry on every autosave tick. That made three
/// things impossible at once: formatting (a `String` has nowhere to put a
/// mark), scale (a 120,000-word manuscript rewrote 120,000 words to record a
/// three-letter edit), and recovery (nothing kept what the prose used to say).
///
/// This library is the first of those three: a document that can carry
/// structure and inline marks, and that still projects back to exactly the
/// plain text it came from. Two rules govern it:
///
/// * It is presentation-independent. Nothing here imports Flutter, and nothing
///   here decides how a mark is drawn.
/// * It is losslessly plain-text-compatible. [ProseDocument.fromPlainText]
///   followed by [ProseDocument.plainText] returns the original string for
///   every input, so migrating today's prose cannot lose a character, and any
///   code that still wants a `String` keeps working.
///
/// The word-count algorithm lives here and nowhere else. It is the same
/// whitespace split `ManuscriptScene.wordCount` has always used, so counts
/// stay identical across the migration and every statistic built on them —
/// writing sessions, streaks, goals, progress bars — keeps its meaning.
library;

/// An inline mark applied to a run of text.
///
/// Deliberately small. These four are what a manuscript needs; a mark that
/// carries data (a comment, a link, a citation) is a different shape and does
/// not belong in this enum.
enum ProseMark {
  bold,
  italic,
  underline,
  strikethrough,

  /// The author marking their own prose for their own attention.
  ///
  /// A mark rather than a block kind because it applies to a run of
  /// characters, and it belongs in this enum because it carries no data --
  /// which is the line drawn above for what may enter it.
  highlight,
}

/// Resolves persisted mark ids without throwing on values a newer build wrote.
extension ProseMarkX on ProseMark {
  String get id => name;

  /// The mark named [id], or `null` when nothing matches.
  ///
  /// Returning `null` rather than throwing is what lets an older build open a
  /// document a newer one saved: it drops the mark it cannot draw and keeps
  /// the words, which is always the better of the two failures.
  static ProseMark? fromId(String? id) {
    for (final mark in ProseMark.values) {
      if (mark.name == id) return mark;
    }
    return null;
  }
}

/// The kind of a block-level unit of prose.
enum ProseBlockKind {
  paragraph,
  heading1,
  heading2,
  heading3,
  blockQuote,

  /// A line of a bulleted list.
  ///
  /// The marker is not in the text and must never be, for the same reason a
  /// scene marker's number is not: a text field turns a tap into a caret
  /// position by walking the span it was given, so a character the author
  /// cannot see puts the caret where they did not click. It is painted beside
  /// the line instead.
  bulletList,

  /// A line of a numbered list.
  ///
  /// Like [bulletList], and like a scene marker, the number is its position
  /// among the run of list lines it belongs to rather than anything stored --
  /// so inserting an item renumbers the ones below it without touching a
  /// single document.
  numberedList,

  /// The typographic break between two scenes inside one chapter.
  sceneBreak,

  /// A scene's place in the chapter that contains it.
  ///
  /// The block an author creates with "add a scene". It stands for a real
  /// scene record — [ProseBlock.recordId] holds which one — and shows the
  /// author its number and description while they write. The number is not
  /// stored: it is the marker's position among its siblings, so inserting a
  /// scene renumbers the ones below it without touching a single document.
  ///
  /// A scene is planned here and written around here; it is never written
  /// *inside* here. The prose belongs to the chapter, in the blocks either
  /// side of this one.
  ///
  /// Distinct from [sceneBreak], which is the same idea with the identity
  /// taken out: a typographic break that no record answers for. An export
  /// renders both as the break the book's format asks for — the description
  /// is something the author sees, not something a reader does.
  sceneMarker,
}

/// Resolves persisted block ids, defaulting to a paragraph.
extension ProseBlockKindX on ProseBlockKind {
  String get id => name;

  /// Whether this is the manuscript's structure rather than its prose.
  ///
  /// A scene marker's description is the author planning the scene; a scene
  /// break is punctuation between them. Neither is anything a reader receives,
  /// and neither is anything the author wrote *of* the book — so both are
  /// excluded from the text a book is built from and from the words the
  /// manuscript is counted by.
  ///
  /// The one definition of that question. Export, word count and anything
  /// later that has to tell prose from planning all resolve here, so they
  /// cannot answer it differently.
  bool get isStructural =>
      this == ProseBlockKind.sceneMarker || this == ProseBlockKind.sceneBreak;

  /// Whether pressing Enter on this line should give another line like it.
  ///
  /// True only of the lists. Enter after a heading gives prose -- nobody
  /// writes two headings in a row -- but Enter in a list means the next item,
  /// and a list that quietly stopped being one at every line break would have
  /// to be re-applied per item.
  bool get continuesOnNewLine =>
      this == ProseBlockKind.bulletList || this == ProseBlockKind.numberedList;

  /// Whether this kind is one of the lists.
  bool get isList => continuesOnNewLine;

  static ProseBlockKind fromId(String? id) {
    for (final kind in ProseBlockKind.values) {
      if (kind.name == id) return kind;
    }
    return ProseBlockKind.paragraph;
  }
}

/// A run of text sharing one set of marks.
class ProseSpan {
  const ProseSpan(this.text, {this.marks = const <ProseMark>{}, this.href});

  final String text;
  final Set<ProseMark> marks;

  /// Where this run of text points, or null when it points nowhere.
  ///
  /// A link is deliberately *not* a [ProseMark]: it carries a target, and the
  /// enum is for marks that carry nothing. Keeping it here means a link can be
  /// stored, round-tripped and re-anchored by everything that already handles
  /// a run of text, without the enum growing a member that needs a second
  /// value to mean anything.
  final String? href;

  bool get isLink => href != null && href!.isNotEmpty;

  bool get isPlain => marks.isEmpty && !isLink;

  ProseSpan copyWith({
    String? text,
    Set<ProseMark>? marks,
    String? href,
    bool clearHref = false,
  }) =>
      ProseSpan(
        text ?? this.text,
        marks: marks ?? this.marks,
        href: clearHref ? null : (href ?? this.href),
      );

  Map<String, Object?> toJson() => {
        'text': text,
        if (marks.isNotEmpty)
          'marks': [
            for (final mark in ProseMark.values)
              if (marks.contains(mark)) mark.id,
          ],
        if (isLink) 'href': href,
      };

  factory ProseSpan.fromJson(Map<String, dynamic> json) => ProseSpan(
        (json['text'] as String?) ?? '',
        marks: _decodeMarks(json['marks'] as List?),
        href: (json['href'] as String?)?.trim().isEmpty ?? true
            ? null
            : (json['href'] as String).trim(),
      );

  static Set<ProseMark> _decodeMarks(List<Object?>? raw) {
    if (raw == null || raw.isEmpty) return const <ProseMark>{};
    final marks = <ProseMark>{};
    for (final value in raw) {
      final mark = ProseMarkX.fromId(value?.toString());
      if (mark != null) marks.add(mark);
    }
    return marks;
  }

  @override
  bool operator ==(Object other) =>
      other is ProseSpan &&
      other.text == text &&
      other.href == href &&
      other.marks.length == marks.length &&
      other.marks.containsAll(marks);

  @override
  int get hashCode => Object.hash(
        text,
        href,
        Object.hashAllUnordered(marks),
      );
}

/// One block-level unit of prose: a paragraph, a heading, a scene break.
class ProseBlock {
  const ProseBlock({
    this.kind = ProseBlockKind.paragraph,
    this.spans = const <ProseSpan>[],
    this.recordId,
  });

  /// A plain, unmarked paragraph holding [text].
  factory ProseBlock.paragraph(String text) => ProseBlock(
        spans: text.isEmpty ? const [] : [ProseSpan(text)],
      );

  /// A scene's marker in the chapter that contains it.
  ///
  /// [description] is what the author sees beside the number; it is prose
  /// about the scene rather than prose of it, which is why it lives in the
  /// block's spans and counts toward nothing.
  factory ProseBlock.sceneMarker({
    required String sceneId,
    String description = '',
  }) =>
      ProseBlock(
        kind: ProseBlockKind.sceneMarker,
        spans: description.isEmpty ? const [] : [ProseSpan(description)],
        recordId: sceneId,
      );

  final ProseBlockKind kind;
  final List<ProseSpan> spans;

  /// The record this block stands for, if it stands for one.
  ///
  /// Only a marker carries this. It is a reference and never a copy: the
  /// scene's title, its links and its place in the story graph stay on the
  /// record, so renaming a scene changes nothing here and deleting this block
  /// destroys no record. That is the whole reason the id is stored rather than
  /// the scene itself — a document holds a view of a record, never a second
  /// one. See Lock 1 and Lock 3.
  final String? recordId;

  /// The block's text with every mark removed.
  String get text => spans.map((span) => span.text).join();

  bool get isEmpty => text.isEmpty;

  /// Whether this block is an unmarked paragraph — the shape every scene
  /// written before the document model has, and the shape the compact
  /// encoding in [ProseDocument.toJson] is allowed to collapse.
  bool get isPlainParagraph =>
      kind == ProseBlockKind.paragraph && spans.every((span) => span.isPlain);

  /// [recordId] is passed through unless [dropRecordId] is set, because an
  /// optional argument cannot otherwise say "clear it" — omitting it and
  /// passing null are the same call. Turning a marker back into a paragraph is
  /// exactly the edit that needs to say it.
  ProseBlock copyWith({
    ProseBlockKind? kind,
    List<ProseSpan>? spans,
    String? recordId,
    bool dropRecordId = false,
  }) =>
      ProseBlock(
        kind: kind ?? this.kind,
        spans: spans ?? this.spans,
        recordId: dropRecordId ? null : (recordId ?? this.recordId),
      );

  Map<String, Object?> toJson() => {
        'kind': kind.id,
        'spans': [for (final span in spans) span.toJson()],
        if (recordId != null) 'recordId': recordId,
      };

  factory ProseBlock.fromJson(Map<String, dynamic> json) => ProseBlock(
        kind: ProseBlockKindX.fromId(json['kind'] as String?),
        spans: [
          for (final raw in (json['spans'] as List? ?? const []))
            ProseSpan.fromJson(Map<String, dynamic>.from(raw as Map)),
        ],
        recordId: json['recordId'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is ProseBlock &&
      other.kind == kind &&
      other.recordId == recordId &&
      _listEquals(other.spans, spans);

  @override
  int get hashCode => Object.hash(kind, recordId, Object.hashAll(spans));
}

/// The prose of one scene.
///
/// A document is an ordered list of blocks. Its [plainText] is the blocks'
/// text joined by newlines, which is the inverse of [ProseDocument.fromPlainText]
/// for every possible input — see the library comment for why that matters.
class ProseDocument {
  const ProseDocument(this.blocks);

  /// The empty document: one empty paragraph, so an empty scene and a scene
  /// holding `''` are the same document rather than two different ones.
  static const ProseDocument empty = ProseDocument([ProseBlock()]);

  /// The current on-disk shape of [toJson].
  ///
  /// Persisted with every document so a later shape can be recognised and
  /// converted rather than guessed at.
  static const int schemaVersion = 1;

  final List<ProseBlock> blocks;

  /// Builds a document from [text], one paragraph per line.
  ///
  /// Line-per-paragraph — rather than the more usual blank-line-separated
  /// paragraphs — is what makes the round-trip exact: blank lines survive as
  /// empty paragraphs instead of being collapsed away.
  factory ProseDocument.fromPlainText(String text) => ProseDocument([
        for (final line in text.split('\n')) ProseBlock.paragraph(line),
      ]);

  /// The document's text with every mark and block distinction removed.
  String get plainText => blocks.map((block) => block.text).join('\n');

  bool get isEmpty => plainText.isEmpty;

  /// Whether every block is an unmarked paragraph.
  bool get isPlainText => blocks.every((block) => block.isPlainParagraph);

  /// Which scene each marker is, keyed by the block it sits on.
  ///
  /// The one implementation of scene numbering. Nothing stores a number: a
  /// marker is the nth scene because n-1 markers come before it, so inserting
  /// a scene renumbers everything below it without rewriting a document, and
  /// two chapters can never disagree about what they contain.
  ///
  /// Numbering is per chapter and starts at 1, which is what an author means
  /// by "scene two" while they are inside chapter fifty-seven.
  Map<int, int> get sceneNumbers => sceneNumbersFor(
        [for (final block in blocks) block.kind],
      );

  /// [sceneNumbers] over a bare list of kinds, for callers holding the
  /// flattened form rather than the document.
  /// Which number each numbered-list line shows, keyed by line index.
  ///
  /// Counted per run: a list interrupted by a paragraph starts again at one
  /// below it, because that is a second list rather than a continuation of the
  /// first. Nothing is stored, so inserting an item renumbers what follows it
  /// without a single document being touched.
  static Map<int, int> listNumbersFor(List<ProseBlockKind> kinds) {
    final numbers = <int, int>{};
    var running = 0;
    for (var index = 0; index < kinds.length; index++) {
      if (kinds[index] == ProseBlockKind.numberedList) {
        running += 1;
        numbers[index] = running;
      } else {
        running = 0;
      }
    }
    return numbers;
  }

  static Map<int, int> sceneNumbersFor(List<ProseBlockKind> kinds) {
    final numbers = <int, int>{};
    var next = 1;
    for (var index = 0; index < kinds.length; index++) {
      if (kinds[index] == ProseBlockKind.sceneMarker) {
        numbers[index] = next++;
      }
    }
    return numbers;
  }

  /// The document's prose, with its structure left out.
  ///
  /// Distinct from [plainText], which is every block joined and must stay that
  /// way: it is the exact inverse of [ProseDocument.fromPlainText], and the
  /// store compares it against the scene's stored string to decide whether a
  /// document has gone stale. Narrowing it would make every chapter holding a
  /// marker look stale and stop its marks being read.
  ///
  /// This is the other question — what did the author actually write — and it
  /// is the one a word count and a book are interested in.
  String get proseText => blocks
      .where((block) => !block.kind.isStructural)
      .map((block) => block.text)
      .join('\n');

  /// The manuscript's canonical word count.
  ///
  /// The one implementation of this algorithm. `ManuscriptScene.wordCount`
  /// delegates here so a scene's count cannot drift from its document's.
  ///
  /// Counted over [proseText], so planning a scene never inflates the number
  /// the author is measured by. A description is a note to themselves; it is
  /// not words of the book, and a streak built on it would be a lie.
  int get wordCount => countWords(proseText);

  /// Counts the words in [text].
  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// The persisted shape.
  ///
  /// A document that carries no formatting is written as its plain text
  /// instead of a block list. Every scene written before this model is exactly
  /// that shape, so the migration does not inflate a manuscript on disk, and a
  /// scene only starts paying for the block encoding once it holds something
  /// the block encoding is needed for.
  Map<String, Object?> toJson() => isPlainText
      ? {'schema': schemaVersion, 'text': plainText}
      : {
          'schema': schemaVersion,
          'blocks': [for (final block in blocks) block.toJson()],
        };

  factory ProseDocument.fromJson(Map<String, dynamic> json) {
    final blocks = json['blocks'] as List?;
    if (blocks == null) {
      return ProseDocument.fromPlainText((json['text'] as String?) ?? '');
    }
    if (blocks.isEmpty) return ProseDocument.empty;
    return ProseDocument([
      for (final raw in blocks)
        ProseBlock.fromJson(Map<String, dynamic>.from(raw as Map)),
    ]);
  }

  @override
  bool operator ==(Object other) =>
      other is ProseDocument && _listEquals(other.blocks, blocks);

  @override
  int get hashCode => Object.hashAll(blocks);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) return false;
  }
  return true;
}
