/// Writing goals — the domain layer.
///
/// A [WritingGoals] is the author's own pace for one project: how many words
/// they mean to write in a day, a week, and a month. It is deliberately the
/// opposite kind of value from a [WritingSession]:
///
/// * A session is a *fact*. It records what happened and is never rewritten.
/// * A goal is an *intention*. It is current, editable, and overwritten every
///   time the author changes their mind.
///
/// That difference is why goals live in their own file rather than beside the
/// session model, and why the storage layer upserts them instead of appending.
///
/// Two rules govern this file:
///
/// * It is presentation-independent. Nothing here imports Flutter, and nothing
///   here formats a value for a screen.
/// * It owns no progress arithmetic. How far through a goal the author is
///   depends on words written, which is the analytics layer's question to
///   answer; this file only carries the targets.
library;

/// The author's daily, weekly, and monthly word targets for one project.
///
/// A target of `0` means "no goal for this period" — a distinct state from a
/// small goal, and one consumers must render as absent rather than as 0%.
/// This mirrors the rule `AnalyticsSummary.hasWritingTarget` already follows
/// for the manuscript target.
class WritingGoals {
  const WritingGoals({
    required this.projectId,
    required this.dailyWords,
    required this.weeklyWords,
    required this.monthlyWords,
    this.sessionWords = 0,
    this.chapterWords = 0,
    this.deadline,
    this.updatedAt,
  });

  /// The targets a project starts with, and the only place they are written
  /// down. Everything that needs a default — the storage layer, the restore
  /// button, the tests — reads them from here, so there is exactly one answer
  /// to "what is a default goal?".
  static const seedDefaults = WritingGoals(
    projectId: '',
    dailyWords: 2000,
    weeklyWords: 10000,
    monthlyWords: 40000,
  );

  /// An upper bound that keeps a slip — a pasted word count, a stray zero —
  /// from becoming a goal no author could write against.
  static const maximumWords = 1000000;

  /// The seeded targets, bound to one project.
  factory WritingGoals.defaultsFor(String projectId) =>
      seedDefaults.copyWith(projectId: projectId);

  final String projectId;

  /// Words the author means to write in a local calendar day. `0` means no
  /// daily goal.
  final int dailyWords;

  /// Words per local week (Monday-based, matching `WritingCalendar`).
  final int weeklyWords;

  /// Words per local calendar month.
  final int monthlyWords;

  /// Words the author means to write in one sitting. `0` means no session
  /// goal.
  ///
  /// Distinct from [dailyWords] rather than derived from it: a day can hold
  /// three sittings, and an author who writes 500 words at lunch has met a
  /// session goal without meeting a daily one. Both are intentions, so both
  /// live here.
  final int sessionWords;

  /// Words the author means each chapter to run to. `0` means no chapter goal.
  ///
  /// A target, never a limit. Nothing anywhere refuses a word because a chapter
  /// has reached this, and nothing may be built that does.
  final int chapterWords;

  /// The date the author means to finish by, or `null` when they have set none.
  ///
  /// Stored as a local calendar date at midnight, not an instant: a deadline is
  /// a day on a calendar, and treating it as a timestamp makes "due today" mean
  /// something different at 9am and 9pm. `GoalSchedule` is where it turns into
  /// arithmetic — see the note at the top of this file about what goals do not
  /// own.
  ///
  /// A deadline in the past is kept rather than cleared. An author who has
  /// missed one needs to be told, not to have the evidence quietly removed.
  final DateTime? deadline;

  /// When the author last changed these targets, or `null` when they have
  /// never been edited and these are still the seeded defaults.
  final DateTime? updatedAt;

  bool get hasDailyGoal => dailyWords > 0;
  bool get hasWeeklyGoal => weeklyWords > 0;
  bool get hasMonthlyGoal => monthlyWords > 0;
  bool get hasSessionGoal => sessionWords > 0;
  bool get hasChapterGoal => chapterWords > 0;
  bool get hasDeadline => deadline != null;

  /// Whether the author has moved off the seeded targets.
  ///
  /// Setting a deadline or a session or chapter target counts: each is the
  /// author saying something the seed did not, and "restore defaults" has to
  /// have something to undo.
  bool get isCustomized =>
      dailyWords != seedDefaults.dailyWords ||
      weeklyWords != seedDefaults.weeklyWords ||
      monthlyWords != seedDefaults.monthlyWords ||
      hasSessionGoal ||
      hasChapterGoal ||
      hasDeadline;

  /// The same goals with every target inside the range storage accepts:
  /// negatives floored at zero, everything capped at [maximumWords].
  ///
  /// Applied on the way in to storage, so a value the author can never reach
  /// — or a negative one, which would invert every progress bar — is never
  /// written in the first place.
  WritingGoals normalized() => WritingGoals(
        projectId: projectId,
        dailyWords: _clamp(dailyWords),
        weeklyWords: _clamp(weeklyWords),
        monthlyWords: _clamp(monthlyWords),
        sessionWords: _clamp(sessionWords),
        chapterWords: _clamp(chapterWords),
        deadline: _startOfDay(deadline),
        updatedAt: updatedAt,
      );

  /// Midnight local on the day [instant] falls in, or null.
  ///
  /// Applied on the way in to storage so a deadline is a date from the moment
  /// it is written, and every later comparison is against the same shape.
  static DateTime? _startOfDay(DateTime? instant) => instant == null
      ? null
      : DateTime(instant.year, instant.month, instant.day);

  static int _clamp(int words) {
    if (words < 0) return 0;
    if (words > maximumWords) return maximumWords;
    return words;
  }

  /// A copy with the given fields replaced.
  ///
  /// [clearDeadline] exists because `null` cannot mean "remove it" in a
  /// copyWith that also uses `null` to mean "leave it alone", and an author
  /// must be able to take a deadline off. The same shape
  /// `ManuscriptChapter.copyWith` already uses for `bookId`.
  WritingGoals copyWith({
    String? projectId,
    int? dailyWords,
    int? weeklyWords,
    int? monthlyWords,
    int? sessionWords,
    int? chapterWords,
    DateTime? deadline,
    bool clearDeadline = false,
    DateTime? updatedAt,
  }) =>
      WritingGoals(
        projectId: projectId ?? this.projectId,
        dailyWords: dailyWords ?? this.dailyWords,
        weeklyWords: weeklyWords ?? this.weeklyWords,
        monthlyWords: monthlyWords ?? this.monthlyWords,
        sessionWords: sessionWords ?? this.sessionWords,
        chapterWords: chapterWords ?? this.chapterWords,
        deadline: clearDeadline ? null : (deadline ?? this.deadline),
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Timestamps serialize as UTC ISO-8601, matching every other AuthorOS
  /// record, and are converted back to local time on the way in.
  /// Timestamps serialize as UTC ISO-8601, matching every other AuthorOS
  /// record, and are converted back to local time on the way in.
  ///
  /// The three fields added after this model shipped are written **only when
  /// set**, so a project whose author has never opened the goals screen
  /// serialises byte-for-byte as it did before they existed. An older build
  /// reading a newer file ignores keys it does not know; a newer build reading
  /// an older one falls back to "no goal", which is the honest answer.
  Map<String, Object?> toJson() => {
        'projectId': projectId,
        'dailyWords': dailyWords,
        'weeklyWords': weeklyWords,
        'monthlyWords': monthlyWords,
        if (hasSessionGoal) 'sessionWords': sessionWords,
        if (hasChapterGoal) 'chapterWords': chapterWords,
        if (deadline != null) 'deadline': deadline!.toUtc().toIso8601String(),
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  factory WritingGoals.fromJson(Map<String, dynamic> json) {
    final updatedAt = json['updatedAt'] as String?;
    final deadline = json['deadline'] as String?;
    return WritingGoals(
      projectId: (json['projectId'] as String?) ?? '',
      dailyWords: (json['dailyWords'] as int?) ?? seedDefaults.dailyWords,
      weeklyWords: (json['weeklyWords'] as int?) ?? seedDefaults.weeklyWords,
      monthlyWords: (json['monthlyWords'] as int?) ?? seedDefaults.monthlyWords,
      sessionWords: (json['sessionWords'] as int?) ?? 0,
      chapterWords: (json['chapterWords'] as int?) ?? 0,
      // Unparseable is treated as absent rather than as an error: a corrupt
      // date is not a reason to refuse to open a project.
      deadline:
          deadline == null ? null : _startOfDay(DateTime.tryParse(deadline)?.toLocal()),
      updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt).toLocal(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingGoals &&
          other.projectId == projectId &&
          other.dailyWords == dailyWords &&
          other.weeklyWords == weeklyWords &&
          other.monthlyWords == monthlyWords &&
          other.sessionWords == sessionWords &&
          other.chapterWords == chapterWords &&
          other.deadline == deadline &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(projectId, dailyWords, weeklyWords,
      monthlyWords, sessionWords, chapterWords, deadline, updatedAt);

  @override
  String toString() => 'WritingGoals($projectId, daily $dailyWords, '
      'weekly $weeklyWords, monthly $monthlyWords)';
}
