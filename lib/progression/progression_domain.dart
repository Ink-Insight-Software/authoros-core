/// Author progression — the domain layer.
///
/// The Achievement Program is three systems that work together and are
/// deliberately not the same system:
///
/// * **XP** measures how much meaningful creative work has been done.
/// * **Achievements** recognise specific things the author accomplished.
/// * **The Reward Tree** is what the author chooses to unlock with what they
///   have earned.
///
/// Everything in this directory is plain Dart with no Flutter import, per
/// Lock 12, and everything is a **fold over canonical data** rather than a
/// store, per Lock 3. The progression engine reads [ProgressionEvidence] and
/// returns a summary; it never writes a record, never mutates a source, and
/// never invents a number. Given the same evidence it returns the same answer
/// on any device, in the same order — Lock 8's second constraint, which is what
/// makes an XP total something an author can be shown rather than something
/// they have to trust.
///
/// One consequence is worth stating early because it is the whole reason the
/// system is shaped this way: **because XP is derived rather than accumulated,
/// idempotency is structural.** There is no "award XP" call to accidentally
/// make twice. A milestone is either crossed by the evidence or it is not, and
/// re-running the fold a thousand times produces the same total.
library;

/// The creative categories XP is earned in.
///
/// A category is a *kind of creative work*, not a studio and not a screen. Two
/// studios can both produce Worldbuilding XP, and one studio can produce three
/// categories, because the category describes what the author did rather than
/// where they were standing when they did it.
enum XpCategory {
  writing,
  manuscript,
  worldbuilding,
  storycraft,
  timeline,
  mapping,
  continuity,
  revision,
  completion,
  consistency,
  progression,
}

/// How an XP award behaves when the evidence behind it keeps growing.
enum XpAwardKind {
  /// Awarded the first time its condition holds and never again.
  oneTime,

  /// One of an ordered ladder of thresholds. Only the highest threshold
  /// reached pays out — see [ProgressionRules.greedyMilestoneBucketing].
  milestone,

  /// Pays out once per occurrence, with no ceiling.
  repeatable,

  /// Pays out per occurrence up to a stated maximum.
  capped,
}

/// How rare an achievement is meant to feel.
///
/// Rarity is a property of the *definition*, declared by the catalogue. It is
/// never computed from how many authors hold it, because AuthorOS does not know
/// what other authors hold and is not going to start knowing.
enum AchievementRarity { common, uncommon, rare, legendary }

/// Where an achievement stands for one author.
enum AchievementState {
  /// Visible, not yet earned. The author can see it and see how far along
  /// they are.
  locked,

  /// Not visible at all, and not yet earned. Its name, description and
  /// criteria are withheld — see [ProgressionRules.hiddenAchievementsDoNotLeak].
  hidden,

  /// Earned. Hidden achievements move to this state and become visible.
  unlocked,
}

/// One named, countable fact about an author's recorded creative history.
///
/// Every achievement criterion is stated as a signal plus a threshold rather
/// than as a closure, so that a criterion can be *inspected* — rendered to the
/// author as "42 of 50 timeline events" — instead of only evaluated. That is
/// Lock 8's third constraint applied to progression: an achievement the author
/// cannot inspect is a decoration, not an accomplishment.
enum ProgressionSignal {
  /// Career words the author **typed**, each session credited at most
  /// [ProgressionRules.sessionCreditCeiling].
  ///
  /// Pasted words are excluded — see [ProgressionRules.pastedWordsAreNotWritten].
  careerWords,

  /// Qualifying writing sessions, career-wide.
  qualifyingSessions,

  /// Distinct local calendar days carrying at least one qualifying session.
  writingDays,

  /// Words that arrived without being typed, and were therefore not credited.
  ///
  /// Reported so the exclusion is inspectable rather than silent: an author
  /// who pasted a novel should be able to see the number that did not count,
  /// and why.
  pastedWordsExcluded,

  /// Longest run of consecutive writing days ever recorded.
  longestStreakDays,

  /// Most words credited on any single local calendar day.
  bestDayWords,

  /// Longest single qualifying session, in whole minutes.
  longestSessionMinutes,

  /// Qualifying sessions that began between 00:00 and 04:00 local time.
  nightSessions,

  /// Qualifying sessions that ended shorter than they started.
  netNegativeSessions,

  /// Longest gap, in days, between two consecutive writing days that the
  /// author then crossed by writing again.
  longestSilenceCrossedDays,

  /// Days between the first and most recent recorded session.
  historySpanDays,

  /// Chapters the manuscript reports as complete.
  chaptersCompleted,

  /// Manuscripts the manuscript layer reports as complete.
  manuscriptsCompleted,

  /// Canonical records in the world domain.
  worldRecords,

  /// Canonical location records.
  locations,

  /// Canonical character records.
  characters,

  /// Links whose two endpoints are both character records.
  characterRelationships,

  /// Canonical timeline event records.
  timelineEvents,

  /// Maps the Map Studio holds.
  maps,

  /// Records placed onto a map.
  mapPlacements,

  /// Deepest nesting reached in the map scale hierarchy.
  deepestMapScale,

  /// Continuity findings the author has resolved.
  continuityResolutions,

  /// Scenes carrying at least one recorded revision.
  scenesRevised,

  /// Book projects exported at least once to a distribution format.
  booksDistributed,

  /// Specialist systems activated in any one project.
  activeSpecialistSystems,

  /// Records passing the completeness check.
  completeRecords,

  /// Canonical records held, of any type.
  totalRecords,

  /// Distinct creative domains the author has records in.
  domainsTouched,
}

/// The constants the program is allowed to have, gathered in one place.
///
/// The codebase already insists that session cutoffs live in
/// `WritingSessionThresholds` and nowhere else. This is the same rule for
/// progression: a threshold that is worth having is worth being findable.
class ProgressionRules {
  const ProgressionRules._();

  /// Documentation anchor: **pasted words are not written words.**
  ///
  /// Progression credits what the author typed. Text that arrived whole —
  /// from the clipboard, from a drag, from an import — contributes nothing,
  /// however many words it is.
  ///
  /// The reason is the one-sentence shape of the whole program: XP measures
  /// meaningful creative work. Pasting a novel into a scene is a real and
  /// legitimate thing to do, and it is not an afternoon's writing. The credit
  /// ceiling below was the old, blunter answer to the same problem — it made
  /// an import worth one very good day. This makes it worth what it is.
  ///
  /// Two things this rule must never do, and the editor half has to honour
  /// both:
  ///
  /// * **Never penalise an input method.** A CJK author committing an IME
  ///   composition, or anyone accepting an autocorrect suggestion, is typing.
  ///   Several characters arriving at once is not evidence of a paste.
  /// * **Never punish reorganising.** Cutting a paragraph from one chapter and
  ///   pasting it into another moves words that already existed; the project's
  ///   canonical total does not change, so the session nets zero either way.
  ///
  /// Where a session predates the editor being able to tell, its attribution
  /// is **unknown** and its words are credited in full. Progression does not
  /// retroactively take work away from an author who did nothing wrong.
  static const String pastedWordsAreNotWritten = 'typed words only';

  /// The most words one session may contribute to career totals.
  ///
  /// `WritingSession.wordsWritten` is a net delta, so importing a finished
  /// 90,000-word manuscript into a scene produces one session crediting 90,000
  /// words. That is the honest number for analytics, where the author is
  /// describing what happened. It is the wrong number for progression, which is
  /// describing what was *practised*.
  ///
  /// The ceiling is deliberately crude. It does not detect intent, and it
  /// slightly under-credits a genuinely exceptional day. Both are accepted,
  /// because the alternative is a total no author can trust.
  static const int sessionCreditCeiling = 5000;

  /// Documentation anchor: within an achievement chain, XP is paid for the
  /// **highest step reached**, never for the sum of every step below it.
  ///
  /// Writing 1,000 words earns the 1,000-word step. It does not simultaneously
  /// earn every lower step's XP as well. Lower steps still *unlock* — the
  /// author did write their first word, and that stays in their history — but
  /// their XP is subsumed by the step above.
  ///
  /// Without this, a chain of nine steps would pay out 44,400 XP for a career
  /// whose top step is worth 25,000, and every future chain would inflate the
  /// curve again.
  static const String greedyMilestoneBucketing = 'chain XP pays the top step';

  /// Documentation anchor: a locked hidden achievement leaks nothing.
  ///
  /// Not its name, not its description, not its criteria, not its id, and not
  /// its existence in a count. `ProgressionSummary` carries hidden definitions
  /// so the engine can evaluate them; every projection that leaves the device —
  /// and every surface that renders a list — reads
  /// `PublicProgressionProjection`, which drops them.
  static const String hiddenAchievementsDoNotLeak =
      'locked hidden is invisible';
}

/// A single XP payment, with the reason it was made.
///
/// [id] is the idempotency key. It is derived from what earned the XP — an
/// achievement id, a chain id — and never from a clock or a counter, so the
/// same evidence produces the same key on every device and re-running the fold
/// cannot pay twice.
class XpAward {
  const XpAward({
    required this.id,
    required this.category,
    required this.kind,
    required this.points,
    required this.reason,
    required this.evidence,
  });

  /// Stable idempotency key.
  final String id;
  final XpCategory category;
  final XpAwardKind kind;
  final int points;

  /// Human-readable reason, shown to the author beside the number.
  final String reason;

  /// The signals and figures that produced it, so the award can be inspected.
  final Map<ProgressionSignal, int> evidence;

  @override
  String toString() => 'XpAward($id, +$points, ${category.name})';
}

/// The one instant the fold cannot reproduce, and therefore the one thing
/// stored.
///
/// Totals only move forward, but history can be edited: delete a project and
/// its sessions go with it. Replaying thresholds against present-day evidence
/// would then *demote* an author who finished and archived a book, which is
/// indefensible — they did the work.
///
/// So an unlock is pinned once, as a floor. It is not a cache: the engine
/// derives first and consults the floor only where derivation would go
/// backwards. Deriving forward always wins.
class ProgressionUnlock {
  const ProgressionUnlock(
      {required this.achievementId, required this.unlockedAt});

  final String achievementId;
  final DateTime unlockedAt;

  Map<String, Object?> toJson() => {
        'achievementId': achievementId,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  static ProgressionUnlock? fromJson(Map<String, Object?> json) {
    final id = json['achievementId'];
    final at = DateTime.tryParse('${json['unlockedAt']}');
    if (id is! String || id.isEmpty || at == null) return null;
    return ProgressionUnlock(achievementId: id, unlockedAt: at);
  }

  @override
  String toString() => 'ProgressionUnlock($achievementId @ $unlockedAt)';
}

/// How close one category is to minting its next seal.
///
/// The purse says what an author *has*. This says what to do about it, which
/// is the more useful half for the categories that read zero — and those are
/// exactly the ones an author will be looking at, because a branch they can
/// already afford raises no question.
///
/// [mintedBy] is the rate said as an amount of work rather than a number.
/// "1,400 of 5,000 XP" is checkable and tells nobody what to do; "1,400 of
/// 5,000 — a seal every 5,000 words" is both.
class SealProgress {
  const SealProgress({
    required this.towards,
    required this.needed,
    required this.mintedBy,
  });

  /// XP earned in this category since its last seal.
  ///
  /// The *stream's* remainder. A seal granted by a rare or legendary
  /// achievement is in the purse without moving this, which is the honest
  /// reading: the bar is how close the work is to paying again, and an
  /// achievement is not a rate.
  final int towards;

  /// XP one seal costs here. Zero for a category that mints nothing.
  final int needed;

  /// What one seal is, in the author's terms — "ten records placed on a map".
  final String mintedBy;

  /// [towards] over [needed], in `0.0..1.0`. Zero where nothing is minted.
  double get share {
    if (needed <= 0) return 0;
    final fraction = towards / needed;
    return fraction < 0 ? 0 : (fraction > 1 ? 1 : fraction);
  }

  @override
  String toString() => 'SealProgress($towards/$needed, $mintedBy)';
}

/// Reward currency, flavoured by the kind of work that earned it.
///
/// The Reward Tree's nine branches are each keyed to an [XpCategory], and
/// until seals that key was decoration: points came from Author Level, level
/// came from total XP, and two authors at level 50 could buy the same nodes
/// whatever they had spent the fifty levels doing. A worldbuilder and a
/// novelist had identical purses.
///
/// A seal is the same fact made real. **Work of a kind mints seals of that
/// kind, and a branch is bought with the seals of the work it recognises.**
/// The Atlas is paid for by drawing maps; The Company by working out who knows
/// whom. Nothing is withheld from anyone — every node is still presentation,
/// still reachable, still not a feature — but the path to it now runs through
/// the work it is a recognition of, which is what a reward for that work
/// should mean.
///
/// ## Levels pace the tree; seals pay for it
///
/// The two jobs were one number and are now two, and separating them is what
/// makes both honest. [RewardNode.requiredLevel] still gates when a node comes
/// into reach, because pacing is a career-wide question. What it costs is a
/// category-wide one.
///
/// ## Spending is its own floor
///
/// [earnedIn] never falls below [spentIn], and that is not generosity — it is
/// the only reading that is true. A seal that was spent was a seal that was
/// earned, and the selection is the receipt.
///
/// The rule matters because the XP floor cannot reach here. `xpByCategory`
/// reports the derived half only: XP held up by the floor alone has no
/// category left to attribute it to, so an author who deleted a finished
/// project would watch a category's minting fall. Under the old single pool
/// that could not happen — the floor held the level, and the level held the
/// points. Without this rule, flavouring the currency would have introduced a
/// way to be told you are in debt for work you actually did, which is the one
/// outcome the whole program is built to avoid.
class SealPurse {
  const SealPurse({
    this.minted = const {},
    this.spent = const {},
    this.progress = const {},
  });

  /// An author who has done nothing and bought nothing.
  static const SealPurse empty = SealPurse();

  /// Seals the present evidence mints, by category, before spending is
  /// considered. Categories minting nothing are absent rather than zero.
  final Map<XpCategory, int> minted;

  /// Seals committed to the current selection, by category.
  final Map<XpCategory, int> spent;

  /// How far each category is towards its next seal.
  ///
  /// Present for **every** category the mint knows, including those that have
  /// minted nothing — unlike [minted] and [spent], which are sparse. A
  /// category at zero is the one an author most needs answered, and answering
  /// it with an absent key would be the surface having to invent the reply.
  final Map<XpCategory, SealProgress> progress;

  /// What [category] has minted, or the amount already spent in it — whichever
  /// is larger. See *Spending is its own floor* above.
  int earnedIn(XpCategory category) {
    final made = minted[category] ?? 0;
    final gone = spent[category] ?? 0;
    return made > gone ? made : gone;
  }

  int spentIn(XpCategory category) => spent[category] ?? 0;

  /// What is left to spend in [category]. Never negative.
  int availableIn(XpCategory category) {
    final remaining = (minted[category] ?? 0) - spentIn(category);
    return remaining < 0 ? 0 : remaining;
  }

  /// How far [category] is towards its next seal, or null where nothing mints
  /// one — `consistency` and `progression`, which no branch spends.
  SealProgress? progressIn(XpCategory category) => progress[category];

  /// Every category this purse has anything to say about, in enum order so two
  /// devices render the same list.
  List<XpCategory> get categories => [
        for (final category in XpCategory.values)
          if ((minted[category] ?? 0) > 0 || spentIn(category) > 0) category,
      ];

  /// Headline totals.
  ///
  /// A sum across categories, and **nothing is bought out of them**: an author
  /// holding nine writing seals and no mapping seals cannot buy a one-seal
  /// Atlas node, however large this total reads. They exist because "you have
  /// earned N seals" is a fair thing to show someone, not because there is a
  /// pool behind it.
  int get totalEarned => _sum(XpCategory.values.map(earnedIn));
  int get totalSpent => _sum(XpCategory.values.map(spentIn));
  int get totalAvailable => _sum(XpCategory.values.map(availableIn));

  static int _sum(Iterable<int> values) =>
      values.fold(0, (total, value) => total + value);

  @override
  String toString() =>
      'SealPurse($totalAvailable of $totalEarned across ${categories.length} '
      'categories)';
}

/// What a node actually grants. Every value is presentation.
enum RewardKind {
  /// A colour theme for the application.
  theme,

  /// The motif on the author's badge frame — the nib, the compass rose, the
  /// seal.
  ///
  /// Named `badgeFrame` rather than `badgeMotif` because it was the whole
  /// frame before the frame was composed, and the name is a persistence key:
  /// [RewardSlot.key] is written from it, so renaming it would stop an author
  /// wearing what they had put on.
  badgeFrame,

  /// A title the author may display beside their name.
  title,

  /// A typeface pairing for the editor.
  typography,

  /// The field of colour painted behind the workspace.
  ///
  /// Painted in the selected theme's own colours rather than its own, which
  /// is what lets one backdrop sit over every theme — see
  /// `ThemeBackdropPattern`.
  backdrop,

  /// The shape language: how corners are cut, and how heavily focus is drawn.
  edge,

  /// A style for rendered maps.
  mapStyle,

  /// How a map is drawn — the treatment, and how much colour and relief it
  /// carries. See `MapHand`.
  mapHand,

  /// The five colours a map is drawn in: paper, ink, and one sea.
  mapInk,

  /// What is drawn around a map rather than on it — compass, frame, grid,
  /// scale bar, legend.
  mapFurniture,

  /// A surface treatment for boards and canvases.
  boardSkin,

  /// What every board is laid on. See `BoardGround`.
  boardGround,

  /// The ruling drawn across every board.
  boardRule,

  /// How one item on a board is presented.
  boardCard,

  /// The line the badge frame is drawn on.
  badgeRing,

  /// The two colours the badge frame is drawn in.
  badgeInk,

  /// A small permanent memento of something finished.
  keepsake,
}

/// A surface a board treatment can dress.
///
/// Board skins are the one reward kind that is not a single slot — dressing
/// the character boards has nothing to do with dressing the timeline, and an
/// author wears both at once. Every [RewardKind.boardSkin] node names the
/// surface it belongs to so that resolution can keep them apart; without it,
/// owning two board skins would silently mean wearing one.
enum RewardSurface {
  /// Character boards and cards.
  character,

  /// World boards.
  world,

  /// The timeline.
  timeline,

  /// Continuity views.
  continuity,

  /// The revision surface.
  revision,

  /// The manuscript's chapter list.
  manuscript,
}

/// An addressable place a reward can be applied.
///
/// For most kinds the kind *is* the slot: there is one application theme, one
/// editor typeface pairing, one badge frame, one title, one map style. Board
/// skins are addressed by kind and [surface] together.
class RewardSlot {
  const RewardSlot(this.kind, [this.surface])
      : assert(
          (kind == RewardKind.boardSkin) == (surface != null),
          'a board skin is addressed by surface, and nothing else is',
        );

  final RewardKind kind;

  /// Set for [RewardKind.boardSkin] and null for every other kind.
  final RewardSurface? surface;

  /// The stable string this slot persists as.
  ///
  /// Enum *names* rather than indices, because a stored loadout has to survive
  /// a later build inserting a value into the middle of either enum.
  String get key =>
      surface == null ? kind.name : '${kind.name}:${surface!.name}';

  /// The slot [key] names, or null when it names nothing this build knows.
  static RewardSlot? fromKey(String key) {
    final parts = key.split(':');
    if (parts.isEmpty || parts.length > 2) return null;
    final kind = RewardKind.values.where((k) => k.name == parts[0]).firstOrNull;
    if (kind == null) return null;
    if (parts.length == 1) {
      // A board skin without a surface addresses nothing.
      return kind == RewardKind.boardSkin ? null : RewardSlot(kind);
    }
    if (kind != RewardKind.boardSkin) return null;
    final surface =
        RewardSurface.values.where((s) => s.name == parts[1]).firstOrNull;
    return surface == null ? null : RewardSlot(kind, surface);
  }

  @override
  bool operator ==(Object other) =>
      other is RewardSlot && other.kind == kind && other.surface == surface;

  @override
  int get hashCode => Object.hash(kind, surface);

  @override
  String toString() => 'RewardSlot($key)';
}

/// What a slot is called where an author is asked about it.
///
/// Here rather than in the surface that draws it, for the reason
/// `MapDecorationLabel` and `AuthorRoomData.title` are: a slot is addressed
/// from more than one place, and two spellings of "Character boards" is two
/// answers to what one slot is.
extension RewardSlotLabel on RewardSlot {
  String get label => switch (kind) {
        RewardKind.theme => 'Application theme',
        RewardKind.badgeFrame => 'Badge motif',
        RewardKind.badgeRing => 'Badge ring',
        RewardKind.badgeInk => 'Badge ink',
        RewardKind.title => 'Title',
        RewardKind.typography => 'Editor typeface',
        RewardKind.backdrop => 'Page backdrop',
        RewardKind.edge => 'Corners and focus',
        RewardKind.mapStyle => 'Map style',
        RewardKind.mapHand => 'Map hand',
        RewardKind.mapInk => 'Map ink',
        RewardKind.mapFurniture => 'Map furniture',
        RewardKind.boardGround => 'Board ground',
        RewardKind.boardRule => 'Board ruling',
        RewardKind.boardCard => 'Board cards',
        RewardKind.keepsake => 'Keepsake',
        RewardKind.boardSkin => switch (surface) {
            RewardSurface.character => 'Character boards',
            RewardSurface.world => 'World boards',
            RewardSurface.timeline => 'Timeline',
            RewardSurface.continuity => 'Continuity views',
            RewardSurface.revision => 'Revision surface',
            RewardSurface.manuscript => 'Chapter list',
            // Unreachable for a slot the tree produced — a board skin always
            // names a surface, asserted in the constructor and again in
            // `RewardTree.validate`. Answered rather than thrown because a
            // label is not worth crashing a page over.
            null => 'Boards',
          },
      };
}

/// What the author has put on: one node id per slot.
///
/// Stored, because it cannot be derived — see the library doc. Held as its own
/// type rather than a bare map so that the "unknown slots are dropped" rule
/// has one place to live, on the way in from disk.
class RewardLoadout {
  const RewardLoadout(this.applied);

  /// Nothing worn. What every install starts from, and what an author who
  /// takes everything off returns to.
  static const RewardLoadout empty = RewardLoadout({});

  final Map<RewardSlot, String> applied;

  bool get isEmpty => applied.isEmpty;

  String? operator [](RewardSlot slot) => applied[slot];

  /// A copy wearing [nodeId] in [slot].
  RewardLoadout applying(RewardSlot slot, String nodeId) =>
      RewardLoadout({...applied, slot: nodeId});

  /// A copy with [slot] empty.
  RewardLoadout removing(RewardSlot slot) =>
      RewardLoadout({...applied}..remove(slot));

  /// Keys sorted, so two devices wearing the same things write the same bytes.
  /// The same reason `putProgressionState` sorts the selection before encoding
  /// it.
  Map<String, String> toJson() {
    final keys = applied.keys.map((slot) => slot.key).toList()..sort();
    final byKey = {for (final slot in applied.keys) slot.key: applied[slot]!};
    return {for (final key in keys) key: byKey[key]!};
  }

  /// Reads a stored loadout, dropping anything this build cannot address.
  ///
  /// Never throws. A malformed value, a slot from a later build, a key that is
  /// no longer a slot — each is simply not worn, which is a correct look. The
  /// alternative is refusing to load an author's progression because of a
  /// cosmetic.
  factory RewardLoadout.fromJson(Object? json) {
    if (json is! Map) return RewardLoadout.empty;
    final applied = <RewardSlot, String>{};
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! String || value.isEmpty) continue;
      final slot = RewardSlot.fromKey(key);
      if (slot == null) continue;
      applied[slot] = value;
    }
    return RewardLoadout(applied);
  }

  @override
  String toString() => 'RewardLoadout(${applied.length} worn)';
}

/// The four things about progression that are stored rather than derived.
///
/// Everything else is recomputed from recorded creative history on every read.
/// These survive between evaluations because a fold cannot recover them:
///
/// * [unlocks] — *when* each achievement was first earned. Derivation can say
///   the criteria hold today; only a ledger can say they first held in March.
/// * [xpFloor] — the highest total XP ever derived, so deleting a finished
///   project never demotes the author who finished it.
/// * [rewardSelection] — what the author chose to spend points on, which is a
///   decision and not a consequence.
/// * [rewardLoadout] — which of the rewards they own they are actually
///   wearing. Owning is derived from the selection; wearing is a second
///   decision, and no evidence implies it.
///
/// The first two are floors rather than caches. Derivation runs first and a
/// floor is consulted only where the answer would otherwise go backwards, so a
/// stale floor can never inflate a total — it can only stop one falling.
class ProgressionState {
  const ProgressionState({
    this.unlocks = const [],
    this.xpFloor = 0,
    this.rewardSelection = const {},
    this.rewardLoadout = RewardLoadout.empty,
  });

  /// What a fresh install starts from: no history, no floor, nothing chosen.
  static const ProgressionState empty = ProgressionState();

  final List<ProgressionUnlock> unlocks;
  final int xpFloor;
  final Set<String> rewardSelection;

  /// What the author is wearing of what they own.
  ///
  /// Kept alongside the selection rather than derived from it: owning a reward
  /// and having it on are different facts, and only the first can be
  /// recomputed. See `reward_resolution.dart`.
  final RewardLoadout rewardLoadout;

  ProgressionState copyWith({
    List<ProgressionUnlock>? unlocks,
    int? xpFloor,
    Set<String>? rewardSelection,
    RewardLoadout? rewardLoadout,
  }) =>
      ProgressionState(
        unlocks: unlocks ?? this.unlocks,
        xpFloor: xpFloor ?? this.xpFloor,
        rewardSelection: rewardSelection ?? this.rewardSelection,
        rewardLoadout: rewardLoadout ?? this.rewardLoadout,
      );

  @override
  String toString() => 'ProgressionState(${unlocks.length} unlocks, '
      'floor $xpFloor, ${rewardSelection.length} chosen, '
      '${rewardLoadout.applied.length} worn)';
}

/// Everything the progression engine is allowed to know.
///
/// This is an **inventory of signals AuthorOS already records**, not a
/// telemetry wish list. Nothing here is collected for progression's sake: every
/// field names the layer that already owns it, and progression reads that layer
/// rather than growing a recorder of its own.
///
/// A field left at zero means *not wired yet*, and the achievements that depend
/// on it stay locked. That is the correct degradation and it is the reason this
/// type has no clever defaults: an achievement that unlocks because a counter
/// was missing would be a lie, and Lock 8's first constraint says the answer
/// where the data does not say is "not defined", never a flattering guess.
class ProgressionEvidence {
  const ProgressionEvidence({
    this.careerWords = 0,
    this.pastedWordsExcluded = 0,
    this.wordsWithoutAttribution = 0,
    this.qualifyingSessions = 0,
    this.writingDays = 0,
    this.longestStreakDays = 0,
    this.currentStreakDays = 0,
    this.bestDayWords = 0,
    this.longestSession = Duration.zero,
    this.nightSessions = 0,
    this.netNegativeSessions = 0,
    this.longestSilenceCrossedDays = 0,
    this.historySpanDays = 0,
    this.chaptersCompleted = 0,
    this.manuscriptsCompleted = 0,
    this.worldRecords = 0,
    this.locations = 0,
    this.characters = 0,
    this.characterRelationships = 0,
    this.timelineEvents = 0,
    this.maps = 0,
    this.mapPlacements = 0,
    this.deepestMapScale = 0,
    this.continuityResolutions = 0,
    this.scenesRevised = 0,
    this.booksDistributed = 0,
    this.activeSpecialistSystems = 0,
    this.completeRecords = 0,
    this.totalRecords = 0,
    this.domainsTouched = 0,
    this.firstSessionAt,
    this.lastSessionAt,
    this.hasRecordedHistory = false,
  });

  /// No recorded history on this device.
  ///
  /// Distinct from "zero words written": an author restoring onto a new machine
  /// has a career and no local evidence of it, and the honest answer is to say
  /// so and point at restore rather than to quietly report Level 1.
  const ProgressionEvidence.none() : this();

  /// Words the author typed, credited. Pasted words are not in here.
  final int careerWords;

  /// Words excluded because they were pasted rather than typed.
  final int pastedWordsExcluded;

  /// Credited words from sessions recorded before the editor could tell how
  /// they arrived.
  ///
  /// These are counted in [careerWords] in full. The figure is carried so a
  /// surface can be honest that part of a career predates the rule, rather
  /// than implying every credited word was verified as typed.
  final int wordsWithoutAttribution;

  final int qualifyingSessions;
  final int writingDays;
  final int longestStreakDays;
  final int currentStreakDays;
  final int bestDayWords;
  final Duration longestSession;
  final int nightSessions;
  final int netNegativeSessions;
  final int longestSilenceCrossedDays;
  final int historySpanDays;
  final int chaptersCompleted;
  final int manuscriptsCompleted;
  final int worldRecords;
  final int locations;
  final int characters;
  final int characterRelationships;
  final int timelineEvents;
  final int maps;
  final int mapPlacements;
  final int deepestMapScale;
  final int continuityResolutions;
  final int scenesRevised;
  final int booksDistributed;
  final int activeSpecialistSystems;
  final int completeRecords;
  final int totalRecords;
  final int domainsTouched;
  final DateTime? firstSessionAt;
  final DateTime? lastSessionAt;

  /// Whether any qualifying session has ever been recorded on this device.
  final bool hasRecordedHistory;

  /// Reads one named signal.
  ///
  /// The switch is exhaustive on purpose: adding a [ProgressionSignal] without
  /// saying where it comes from is a compile error rather than a zero.
  int read(ProgressionSignal signal) => switch (signal) {
        ProgressionSignal.careerWords => careerWords,
        ProgressionSignal.qualifyingSessions => qualifyingSessions,
        ProgressionSignal.writingDays => writingDays,
        ProgressionSignal.pastedWordsExcluded => pastedWordsExcluded,
        ProgressionSignal.longestStreakDays => longestStreakDays,
        ProgressionSignal.bestDayWords => bestDayWords,
        ProgressionSignal.longestSessionMinutes => longestSession.inMinutes,
        ProgressionSignal.nightSessions => nightSessions,
        ProgressionSignal.netNegativeSessions => netNegativeSessions,
        ProgressionSignal.longestSilenceCrossedDays =>
          longestSilenceCrossedDays,
        ProgressionSignal.historySpanDays => historySpanDays,
        ProgressionSignal.chaptersCompleted => chaptersCompleted,
        ProgressionSignal.manuscriptsCompleted => manuscriptsCompleted,
        ProgressionSignal.worldRecords => worldRecords,
        ProgressionSignal.locations => locations,
        ProgressionSignal.characters => characters,
        ProgressionSignal.characterRelationships => characterRelationships,
        ProgressionSignal.timelineEvents => timelineEvents,
        ProgressionSignal.maps => maps,
        ProgressionSignal.mapPlacements => mapPlacements,
        ProgressionSignal.deepestMapScale => deepestMapScale,
        ProgressionSignal.continuityResolutions => continuityResolutions,
        ProgressionSignal.scenesRevised => scenesRevised,
        ProgressionSignal.booksDistributed => booksDistributed,
        ProgressionSignal.activeSpecialistSystems => activeSpecialistSystems,
        ProgressionSignal.completeRecords => completeRecords,
        ProgressionSignal.totalRecords => totalRecords,
        ProgressionSignal.domainsTouched => domainsTouched,
      };

  ProgressionEvidence copyWith({
    int? careerWords,
    int? pastedWordsExcluded,
    int? wordsWithoutAttribution,
    int? qualifyingSessions,
    int? writingDays,
    int? longestStreakDays,
    int? currentStreakDays,
    int? bestDayWords,
    Duration? longestSession,
    int? nightSessions,
    int? netNegativeSessions,
    int? longestSilenceCrossedDays,
    int? historySpanDays,
    int? chaptersCompleted,
    int? manuscriptsCompleted,
    int? worldRecords,
    int? locations,
    int? characters,
    int? characterRelationships,
    int? timelineEvents,
    int? maps,
    int? mapPlacements,
    int? deepestMapScale,
    int? continuityResolutions,
    int? scenesRevised,
    int? booksDistributed,
    int? activeSpecialistSystems,
    int? completeRecords,
    int? totalRecords,
    int? domainsTouched,
    DateTime? firstSessionAt,
    DateTime? lastSessionAt,
    bool? hasRecordedHistory,
  }) =>
      ProgressionEvidence(
        careerWords: careerWords ?? this.careerWords,
        pastedWordsExcluded: pastedWordsExcluded ?? this.pastedWordsExcluded,
        wordsWithoutAttribution:
            wordsWithoutAttribution ?? this.wordsWithoutAttribution,
        qualifyingSessions: qualifyingSessions ?? this.qualifyingSessions,
        writingDays: writingDays ?? this.writingDays,
        longestStreakDays: longestStreakDays ?? this.longestStreakDays,
        currentStreakDays: currentStreakDays ?? this.currentStreakDays,
        bestDayWords: bestDayWords ?? this.bestDayWords,
        longestSession: longestSession ?? this.longestSession,
        nightSessions: nightSessions ?? this.nightSessions,
        netNegativeSessions: netNegativeSessions ?? this.netNegativeSessions,
        longestSilenceCrossedDays:
            longestSilenceCrossedDays ?? this.longestSilenceCrossedDays,
        historySpanDays: historySpanDays ?? this.historySpanDays,
        chaptersCompleted: chaptersCompleted ?? this.chaptersCompleted,
        manuscriptsCompleted: manuscriptsCompleted ?? this.manuscriptsCompleted,
        worldRecords: worldRecords ?? this.worldRecords,
        locations: locations ?? this.locations,
        characters: characters ?? this.characters,
        characterRelationships:
            characterRelationships ?? this.characterRelationships,
        timelineEvents: timelineEvents ?? this.timelineEvents,
        maps: maps ?? this.maps,
        mapPlacements: mapPlacements ?? this.mapPlacements,
        deepestMapScale: deepestMapScale ?? this.deepestMapScale,
        continuityResolutions:
            continuityResolutions ?? this.continuityResolutions,
        scenesRevised: scenesRevised ?? this.scenesRevised,
        booksDistributed: booksDistributed ?? this.booksDistributed,
        activeSpecialistSystems:
            activeSpecialistSystems ?? this.activeSpecialistSystems,
        completeRecords: completeRecords ?? this.completeRecords,
        totalRecords: totalRecords ?? this.totalRecords,
        domainsTouched: domainsTouched ?? this.domainsTouched,
        firstSessionAt: firstSessionAt ?? this.firstSessionAt,
        lastSessionAt: lastSessionAt ?? this.lastSessionAt,
        hasRecordedHistory: hasRecordedHistory ?? this.hasRecordedHistory,
      );
}
