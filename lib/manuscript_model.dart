/// The manuscript's data model: chapters, scenes, their statuses and the
/// relationships between scenes.
///
/// Split out of `lib/services/manuscript_store.dart` on September 29, 2026.
/// The model and the store that reads and writes it shared one file, so
/// anything that needed a `ManuscriptScene` also reached Drift, shared
/// preferences and sync. The Continuity Engine's detectors were the first
/// thing that needed the model without the store (`PLAN.md` §3.33). The store
/// exports this file, so no import changed.
library;

import 'narrative_voice.dart';
import 'prose_document.dart';

class ManuscriptId {
  ManuscriptId._();

  static int _sequence = 0;

  static String create(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_sequence++}';
}

enum ManuscriptNodeStatus {
  planned,
  draft,
  revising,
  complete,
}

extension ManuscriptNodeStatusX on ManuscriptNodeStatus {
  String get id => name;

  String get label => switch (this) {
        ManuscriptNodeStatus.planned => 'Planned',
        ManuscriptNodeStatus.draft => 'Draft',
        ManuscriptNodeStatus.revising => 'Revising',
        ManuscriptNodeStatus.complete => 'Complete',
      };

  static ManuscriptNodeStatus fromId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ManuscriptNodeStatus.draft;
    }
    for (final status in ManuscriptNodeStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return ManuscriptNodeStatus.draft;
  }
}

enum SceneRelationshipType {
  previousScene,
  nextScene,
  relatedScene,
  character,
  location,
  plotPoint,
  timelineEvent,
  researchItem,
  note,
}

extension SceneRelationshipTypeX on SceneRelationshipType {
  String get label => switch (this) {
        SceneRelationshipType.previousScene => 'Previous Scene',
        SceneRelationshipType.nextScene => 'Next Scene',
        SceneRelationshipType.relatedScene => 'Related Scene',
        SceneRelationshipType.character => 'Character',
        SceneRelationshipType.location => 'Location',
        SceneRelationshipType.plotPoint => 'Plot Point',
        SceneRelationshipType.timelineEvent => 'Timeline Event',
        SceneRelationshipType.researchItem => 'Research Item',
        SceneRelationshipType.note => 'Note',
      };

  static SceneRelationshipType fromId(String? value) {
    if (value == null) {
      return SceneRelationshipType.relatedScene;
    }
    for (final type in SceneRelationshipType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return SceneRelationshipType.relatedScene;
  }
}

class SceneRelationship {
  const SceneRelationship({
    required this.id,
    required this.type,
    required this.targetId,
    this.label = '',
    this.metadata = const {},
  });

  final String id;
  final SceneRelationshipType type;
  final String targetId;
  final String label;
  final Map<String, String> metadata;

  SceneRelationship copyWith({
    String? id,
    SceneRelationshipType? type,
    String? targetId,
    String? label,
    Map<String, String>? metadata,
  }) =>
      SceneRelationship(
        id: id ?? this.id,
        type: type ?? this.type,
        targetId: targetId ?? this.targetId,
        label: label ?? this.label,
        metadata: metadata ?? this.metadata,
      );

  Map<String, Object> toJson() => {
        'id': id,
        'type': type.name,
        'targetId': targetId,
        'label': label,
        'metadata': metadata,
      };

  factory SceneRelationship.fromJson(Map<String, dynamic> json) =>
      SceneRelationship(
        id: (json['id'] as String?) ?? '',
        type: SceneRelationshipTypeX.fromId(json['type'] as String?),
        targetId: (json['targetId'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        metadata: (json['metadata'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            const {},
      );
}

class ManuscriptScene {
  const ManuscriptScene({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.order,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.pov = '',
    this.location = '',
    this.timeLabel = '',
    this.goal = '',
    this.conflict = '',
    this.outcome = '',
    this.notes = '',
    this.relationships = const [],
    this.document,
    this.placed = true,
  });

  final String id;
  final String chapterId;
  final String title;
  final int order;

  /// The scene's prose as plain text.
  ///
  /// Stays the scene's public shape and the one every other system reads:
  /// sync payloads, revisions, export, continuity and word counts all take
  /// this. Formatting rides alongside in [document] rather than through here,
  /// so none of them had to learn about marks.
  final String content;

  /// The formatted form of [content], when the scene has any formatting.
  ///
  /// Null means "plain", which is what almost every scene is and what every
  /// scene was before the editor could format. Never persisted in the
  /// manuscript blob: prose lives in `scene_prose_rows`, and this is hydrated
  /// from there on load.
  ///
  /// Its [ProseDocument.plainText] is [content] by construction. [copyWith]
  /// enforces that — see the note there.
  final ProseDocument? document;

  /// Whether this scene has a place in its chapter's prose.
  ///
  /// False for a scene whose marker the author deleted. It still exists, still
  /// holds its words, and is still a record that characters, timeline events
  /// and plot threads point at — it simply is not anywhere in the chapter, and
  /// waits in the scene list to be put back or properly deleted.
  ///
  /// The flag is what stops the marker growing back. Assembly skips an
  /// unplaced scene, so the next read does not quietly undo the deletion the
  /// author just made.
  final bool placed;

  final ManuscriptNodeStatus status;
  final String pov;
  final String location;
  final String timeLabel;

  /// What the point-of-view character wants in this scene, what stands in
  /// the way, and how it ends — the scene card's three questions. Plain
  /// text, like [pov] and [location]; empty until the author answers them.
  /// Added September 25, 2026 for Write It's Scene Guide.
  final String goal;
  final String conflict;
  final String outcome;
  final String notes;
  final List<SceneRelationship> relationships;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// A copy with the given fields replaced.
  ///
  /// Passing [content] without [document] drops the formatting, deliberately.
  /// Every caller that sets prose from somewhere plain — a restored revision,
  /// an arriving sync payload, a legacy migration — is handing over text that
  /// genuinely has no marks, and silently keeping the old scene's marks
  /// anchored over new words would be worse than losing them. Only the editor
  /// passes both, because only the editor knows both.
  ManuscriptScene copyWith({
    String? id,
    String? chapterId,
    bool? placed,
    String? title,
    int? order,
    String? content,
    ProseDocument? document,
    ManuscriptNodeStatus? status,
    String? pov,
    String? location,
    String? timeLabel,
    String? goal,
    String? conflict,
    String? outcome,
    String? notes,
    List<SceneRelationship>? relationships,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ManuscriptScene(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        title: title ?? this.title,
        order: order ?? this.order,
        content: content ?? this.content,
        document: document ?? (content == null ? this.document : null),
        status: status ?? this.status,
        pov: pov ?? this.pov,
        location: location ?? this.location,
        timeLabel: timeLabel ?? this.timeLabel,
        goal: goal ?? this.goal,
        conflict: conflict ?? this.conflict,
        outcome: outcome ?? this.outcome,
        notes: notes ?? this.notes,
        relationships: relationships ?? this.relationships,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        placed: placed ?? this.placed,
      );

  /// The scene's word count.
  ///
  /// Delegates to [ProseDocument.countWords] so a scene, its stored prose and
  /// its revisions can never disagree about how long it is -- and so writing
  /// sessions, streaks, goals and velocity keep counting the same thing they
  /// always did.
  int get wordCount => ProseDocument.countWords(content);

  /// The persisted shape.
  ///
  /// [includeProse] is false when the manuscript is written to its structure
  /// blob: prose lives one row per scene in the embedded database, and copying
  /// it back into the blob would restore exactly the whole-manuscript rewrite
  /// that separation removed.
  Map<String, Object> toJson({bool includeProse = true}) => {
        'id': id,
        'chapterId': chapterId,
        'title': title,
        'order': order,
        'content': includeProse ? content : '',
        'status': status.name,
        'pov': pov,
        'location': location,
        'timeLabel': timeLabel,
        // Written only when set, so a scene that never had them serialises
        // exactly as it always did.
        if (goal.isNotEmpty) 'goal': goal,
        if (conflict.isNotEmpty) 'conflict': conflict,
        if (outcome.isNotEmpty) 'outcome': outcome,
        'notes': notes,
        'relationships': relationships.map((item) => item.toJson()).toList(),
        // Written only when false. Every scene written before unplacing
        // existed was placed, so an untouched manuscript serialises exactly
        // as it always did.
        if (!placed) 'placed': false,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ManuscriptScene.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return ManuscriptScene(
      id: (json['id'] as String?) ?? '',
      chapterId: (json['chapterId'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled Scene',
      order: (json['order'] as int?) ?? 1,
      content: (json['content'] as String?) ?? '',
      status: ManuscriptNodeStatusX.fromId(json['status'] as String?),
      pov: (json['pov'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      timeLabel: (json['timeLabel'] as String?) ?? '',
      goal: (json['goal'] as String?) ?? '',
      conflict: (json['conflict'] as String?) ?? '',
      outcome: (json['outcome'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      relationships: (json['relationships'] as List? ?? const [])
          .map((item) => SceneRelationship.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      // Absent means placed: a manuscript written before unplacing existed
      // can only have meant every scene was in its chapter.
      placed: (json['placed'] as bool?) ?? true,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? now,
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ?? now,
    );
  }
}

class ManuscriptChapter {
  const ManuscriptChapter({
    required this.id,
    required this.title,
    required this.order,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.summary = '',
    this.prompt = '',
    this.pov = '',
    this.voice = NarrativeVoice.unset,
    this.bookId,
    this.linkedChapterIds = const [],
    this.scenes = const [],
  });

  final String id;
  final String title;
  final int order;
  final ManuscriptNodeStatus status;
  final String summary;
  final String prompt;
  final String pov;

  /// Who is telling this chapter, about whom, and when.
  ///
  /// Beside [pov] rather than replacing it. [pov] is a free-text name that
  /// `visual_planning`, the manuscript filter rail and the continuity lanes
  /// already read, so it keeps being written; this adds the point of view, the
  /// tense, and a record id that makes the POV character a real connection
  /// rather than a string a rename would break.
  final NarrativeVoice voice;

  /// The `book` record this chapter belongs to, or null when the project has
  /// no books yet.
  ///
  /// Book membership is manuscript structure, so it lives here beside chapter
  /// order rather than becoming an edge — the same choice already made for a
  /// scene's `chapterId`. Nullable so every manuscript written before books
  /// existed keeps loading unchanged.
  final String? bookId;

  final List<String> linkedChapterIds;
  final List<ManuscriptScene> scenes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManuscriptChapter copyWith({
    String? id,
    String? title,
    int? order,
    ManuscriptNodeStatus? status,
    String? summary,
    String? prompt,
    String? pov,
    NarrativeVoice? voice,
    String? bookId,
    bool clearBookId = false,
    List<String>? linkedChapterIds,
    List<ManuscriptScene>? scenes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ManuscriptChapter(
        id: id ?? this.id,
        title: title ?? this.title,
        order: order ?? this.order,
        status: status ?? this.status,
        summary: summary ?? this.summary,
        prompt: prompt ?? this.prompt,
        pov: pov ?? this.pov,
        voice: voice ?? this.voice,
        bookId: clearBookId ? null : (bookId ?? this.bookId),
        linkedChapterIds: linkedChapterIds ?? this.linkedChapterIds,
        scenes: scenes ?? this.scenes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  int get wordCount =>
      scenes.fold<int>(0, (sum, scene) => sum + scene.wordCount);

  Map<String, Object> toJson({bool includeProse = true}) => {
        'id': id,
        'title': title,
        'order': order,
        'status': status.name,
        'summary': summary,
        'prompt': prompt,
        'pov': pov,
        // Written only when set, so a manuscript nobody has given a voice to
        // serialises exactly as it did before this field existed.
        if (!voice.isUnset) 'voice': voice.toJson(),
        if (bookId != null) 'bookId': bookId!,
        'linkedChapterIds': linkedChapterIds,
        'scenes': scenes
            .map((scene) => scene.toJson(includeProse: includeProse))
            .toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ManuscriptChapter.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final chapterId = (json['id'] as String?) ?? '';
    final scenes = (json['scenes'] as List? ?? const [])
        .map((item) =>
            ManuscriptScene.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return ManuscriptChapter(
      id: chapterId,
      title: (json['title'] as String?) ?? 'Untitled Chapter',
      order: (json['order'] as int?) ?? 1,
      status: ManuscriptNodeStatusX.fromId(json['status'] as String?),
      summary: (json['summary'] as String?) ?? '',
      prompt: (json['prompt'] as String?) ?? '',
      pov: (json['pov'] as String?) ?? '',
      voice: json['voice'] is Map
          ? NarrativeVoice.fromJson(
              Map<String, Object?>.from(json['voice'] as Map))
          : NarrativeVoice.unset,
      bookId: _optionalId(json['bookId']),
      linkedChapterIds: (json['linkedChapterIds'] as List? ?? const [])
          .map((value) => value.toString())
          .toList(),
      scenes: [
        for (final scene in scenes)
          scene.chapterId == chapterId
              ? scene
              : scene.copyWith(chapterId: chapterId),
      ],
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? now,
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ?? now,
    );
  }
}

class ManuscriptProjectSummary {
  const ManuscriptProjectSummary({
    required this.projectId,
    required this.manuscriptTitle,
    required this.chapters,
    required this.currentChapterId,
    required this.currentSceneId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.migration = const {},
    this.povRoster = const [],
  });

  final String projectId;
  final String manuscriptTitle;
  final List<ManuscriptChapter> chapters;
  final String currentChapterId;
  final String currentSceneId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final Map<String, String> migration;

  /// The characters this book's chapters are told by.
  ///
  /// Record ids, in the order the author arranged them. A narrowing of the
  /// per-chapter picker and nothing more: a book with forty characters has
  /// perhaps four who ever hold a point of view, and offering all forty every
  /// time makes the common choice the hard one.
  ///
  /// Empty means every character is offered, which is the right default —
  /// nobody should have to configure a roster before writing chapter one. It
  /// is never a restriction: a chapter can still be given a character who is
  /// not on it, and one already chosen is never hidden.
  final List<String> povRoster;

  ManuscriptProjectSummary copyWith({
    String? manuscriptTitle,
    List<ManuscriptChapter>? chapters,
    String? currentChapterId,
    String? currentSceneId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    Map<String, String>? migration,
    List<String>? povRoster,
  }) =>
      ManuscriptProjectSummary(
        projectId: projectId,
        manuscriptTitle: manuscriptTitle ?? this.manuscriptTitle,
        chapters: chapters ?? this.chapters,
        currentChapterId: currentChapterId ?? this.currentChapterId,
        currentSceneId: currentSceneId ?? this.currentSceneId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        migration: migration ?? this.migration,
        povRoster: povRoster ?? this.povRoster,
      );

  int get chapterCount => chapters.length;

  int get sceneCount =>
      chapters.fold<int>(0, (sum, chapter) => sum + chapter.scenes.length);

  int get wordCount =>
      chapters.fold<int>(0, (sum, chapter) => sum + chapter.wordCount);

  double progressAgainst(int goalWords) {
    if (goalWords <= 0) {
      return 0;
    }
    return (wordCount / goalWords).clamp(0.0, 1.0);
  }

  ManuscriptChapter? chapterById(String id) {
    for (final chapter in chapters) {
      if (chapter.id == id) {
        return chapter;
      }
    }
    return null;
  }

  ManuscriptScene? sceneById(String id) {
    for (final chapter in chapters) {
      for (final scene in chapter.scenes) {
        if (scene.id == id) {
          return scene;
        }
      }
    }
    return null;
  }

  /// The chapter that owns [sceneId], or `null` when the scene is unknown.
  ManuscriptChapter? chapterOfScene(String sceneId) {
    for (final chapter in chapters) {
      for (final scene in chapter.scenes) {
        if (scene.id == sceneId) {
          return chapter;
        }
      }
    }
    return null;
  }

  /// A copy with chapter and scene orders renumbered from one, and every
  /// scene re-parented to the chapter that holds it.
  ManuscriptProjectSummary normalized() =>
      copyWith(chapters: _normalizedChapters(chapters));

  String exportAsSingleText() {
    final buffer = StringBuffer();
    final sortedChapters = [...chapters]
      ..sort((a, b) => a.order.compareTo(b.order));
    for (var chapterIndex = 0;
        chapterIndex < sortedChapters.length;
        chapterIndex++) {
      final chapter = sortedChapters[chapterIndex];
      buffer.writeln(chapter.title);
      if (chapter.prompt.trim().isNotEmpty) {
        buffer.writeln(chapter.prompt.trim());
      }
      final sortedScenes = [...chapter.scenes]
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final scene in sortedScenes) {
        buffer.writeln();
        buffer.writeln(scene.title);
        if (scene.content.trim().isNotEmpty) {
          buffer.writeln(scene.content.trim());
        }
      }
      if (chapterIndex < sortedChapters.length - 1) {
        buffer.writeln();
        buffer.writeln();
      }
    }
    return buffer.toString().trim();
  }

  List<SceneCursor> orderedSceneCursors() {
    final result = <SceneCursor>[];
    final sortedChapters = [...chapters]
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final chapter in sortedChapters) {
      final sortedScenes = [...chapter.scenes]
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final scene in sortedScenes) {
        result.add(SceneCursor(chapterId: chapter.id, sceneId: scene.id));
      }
    }
    return result;
  }

  Map<String, Object> toJson({bool includeProse = true}) => {
        'projectId': projectId,
        'manuscriptTitle': manuscriptTitle,
        'chapters': chapters
            .map((chapter) => chapter.toJson(includeProse: includeProse))
            .toList(),
        'currentChapterId': currentChapterId,
        'currentSceneId': currentSceneId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'migration': migration,
        // Written only when the author arranged one, so a manuscript that
        // never had a roster serialises exactly as it always did.
        if (povRoster.isNotEmpty) 'povRoster': povRoster,
      };

  factory ManuscriptProjectSummary.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final chapters = (json['chapters'] as List? ?? const [])
        .map((item) =>
            ManuscriptChapter.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    return ManuscriptProjectSummary(
      projectId: (json['projectId'] as String?) ?? '',
      manuscriptTitle: (json['manuscriptTitle'] as String?) ?? 'Manuscript',
      chapters: _normalizedChapters(chapters),
      currentChapterId: (json['currentChapterId'] as String?) ?? '',
      currentSceneId: (json['currentSceneId'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? now,
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ?? now,
      version: (json['version'] as int?) ?? 1,
      migration: (json['migration'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      // Absent means no roster, which means every character is offered.
      povRoster: [
        for (final id in (json['povRoster'] as List? ?? const []))
          '$id',
      ],
    );
  }

  static List<ManuscriptChapter> _normalizedChapters(
      List<ManuscriptChapter> chapters) {
    final sorted = [...chapters]..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (var chapterIndex = 0; chapterIndex < sorted.length; chapterIndex++)
        sorted[chapterIndex].copyWith(
          order: chapterIndex + 1,
          scenes: [
            for (final entry in ([...sorted[chapterIndex].scenes]
                  ..sort((a, b) => a.order.compareTo(b.order)))
                .asMap()
                .entries)
              entry.value.copyWith(
                chapterId: sorted[chapterIndex].id,
                order: entry.key + 1,
              )
          ],
        )
    ];
  }
}

class SceneCursor {
  const SceneCursor({
    required this.chapterId,
    required this.sceneId,
  });

  final String chapterId;
  final String sceneId;
}

class ManuscriptChapterSeed {
  const ManuscriptChapterSeed({
    required this.title,
    this.prompt = '',
    this.status = 'Active',
    this.scenes = const [],
    this.linkedChapterIds = const [],
  });

  final String title;
  final String prompt;
  final String status;
  final List<String> scenes;
  final List<String> linkedChapterIds;
}

/// Reads an optional id, treating an absent key and a blank string alike.
///
/// A manuscript saved before books existed simply has no `bookId` key, and a
/// chapter released back to "no book" writes none, so both must read as null.
String? _optionalId(Object? value) {
  final normalized = value is String ? value.trim() : '';
  return normalized.isEmpty ? null : normalized;
}
