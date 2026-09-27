/// The Craft Library — the value objects.
///
/// A [CraftEntry] is one thing about writing that an author might want
/// explained, and nothing more than that. It is shipped content, authored the
/// way `character_chat.dart`'s prompt sets and `character_interrogation.dart`'s
/// library are authored: plain Dart, versioned, identical on every device.
///
/// ## What it is not
///
/// **It is not an `AuthorRecord`.** A trope is not a thing in the author's
/// story; it is a thing about stories. Lock 1 governs the author's creative
/// entities, and nothing here is one — the library holds no project data, is
/// never persisted, and never travels over sync.
///
/// **It never reads the author's book.** The library knows about writing. It
/// knows nothing about your book. Lock 8's September 4, 2026 amendment now
/// permits prose to be read for observations — quoted, versioned, and offered
/// rather than asserted — but that is a different layer with a different
/// posture, and this one does not become it. An entry explaining a reveal is
/// shipped content that is identical on every device; recognising a reveal in
/// a manuscript is an observation about one book. Keeping them apart is what
/// lets an entry be cited by an observation without either becoming the other.
///
/// **The library is what an observation cites, never what produces one.** The
/// arrow runs one way, and `craft_library_test.dart` holds it: nothing here
/// imports a record, a store or a graph.
///
/// **It does not prescribe.** Lock 7 — presets configure, they never restrict.
/// An entry says what a thing does in a story. It never says a book should
/// have one.
///
/// See `docs/craft-library-design.md`.
library;

/// Recorded alongside anything that cites an entry, so a citation still means
/// what it meant after the library evolves — the same reproducibility posture
/// as [kInterrogationLibraryVersion] and `ChatPromptSet.version`.
const int kCraftLibraryVersion = 3;

/// The families of craft knowledge the library covers.
///
/// Deliberately few and deliberately broad. A family per term would be a
/// taxonomy nobody asked for; these are the shapes an author actually arrives
/// with — *how do I tell this*, *who is this person*, *what is under them*,
/// *what am I allowed to do with a convention*, *how does a turn work*, *how
/// is a sentence made*, and *what do I do with what a reader told me*.
///
/// The first five were the families `docs/craft-library-design.md` scoped.
/// [prose] and [editorial] arrived with AOS Craft, and they are the two the
/// original five could not hold: everything above is about the *story*, and an
/// author asking how to write a paragraph, or what to do with a note from a
/// beta reader, was asking a question the library had no shelf for. They are
/// the same kind of object under the same rule — a term, what it is, and what
/// it does to a reader — because the rule is what makes any of this worth
/// reading, not the subject matter.
enum CraftFamily {
  /// Point of view, tense, distance, register. How the telling is done.
  voiceAndStyle,

  /// What a character is for, structurally — roles and archetypes.
  characterTypes,

  /// What is under a character: want against need, wound, belief, arc.
  characterDepth,

  /// Conventions of genre, and what subverting one costs.
  tropes,

  /// Reveals, reversals and twists. Plant, misdirect, pay off.
  turns,

  /// The sentence, the paragraph, the scene. How the prose itself is made.
  prose,

  /// Revision, and what a reader's note is actually worth.
  editorial,

  /// What the story puts at risk, and what each scale costs a reader.
  ///
  /// The family the others kept pointing at: a want, a conflict and a turn are
  /// all asking what happens if this goes wrong, and that question has its own
  /// vocabulary.
  stakes,

  /// How a whole story is shaped: scenes, causality, structure, promises.
  ///
  /// The five original families and [prose] all sit below the level of the
  /// book. An author asking why the middle sags, or what a structure model is
  /// for, was asking about the shape of the whole thing, and the nearest shelf
  /// was [turns] — which is about one moment, not the arrangement of all of
  /// them.
  structure,

  /// What a character looks like, and what a reader does with that.
  ///
  /// Deliberately separate from [characterDepth] rather than folded into it.
  /// The two answer different questions and fail in different ways: depth is
  /// about what is under a person, surface is about what a reader is told and
  /// how often. A shelf that mixed them would suggest that listing someone's
  /// eye colour is the same kind of work as finding their wound.
  characterSurface,

  /// The world under the story: its rules, its powers, its peoples.
  ///
  /// One family for magic, government, culture and invented language, because
  /// the research that produced these entries found one shape under all of
  /// them — what a system can do, what it cannot, and what each use costs.
  /// Four families would have hidden that.
  world,

  /// Planning, drafting, and the order the work happens in.
  ///
  /// [editorial] already holds revision and what to do with a note. This is
  /// the two phases before it. They are separate because the same observation
  /// is useful in one and destructive in the other, and a shelf that treated
  /// planning and revising as one subject would say otherwise.
  process,
}

extension CraftFamilyData on CraftFamily {
  /// The family's name as an author reads it.
  String get label => switch (this) {
        CraftFamily.voiceAndStyle => 'Voice and style',
        CraftFamily.characterTypes => 'Character types',
        CraftFamily.characterDepth => 'Character depth',
        CraftFamily.tropes => 'Tropes',
        CraftFamily.turns => 'Turns',
        CraftFamily.prose => 'Prose',
        CraftFamily.editorial => 'Editorial',
        CraftFamily.stakes => 'Stakes',
        CraftFamily.structure => 'Structure',
        CraftFamily.characterSurface => 'Character surface',
        CraftFamily.world => 'World',
        CraftFamily.process => 'Process',
      };

  /// What the family covers, for a browsable surface that lists them.
  String get describe => switch (this) {
        CraftFamily.voiceAndStyle =>
          'Who is telling this, from how far away, and when.',
        CraftFamily.characterTypes =>
          'What a character is for in the shape of the story.',
        CraftFamily.characterDepth =>
          'What is under a character, and what a story does to it.',
        CraftFamily.tropes => 'Conventions a reader arrives already knowing.',
        CraftFamily.turns =>
          'How a story changes direction without losing the reader.',
        CraftFamily.prose =>
          'How a sentence, a paragraph and a scene are built.',
        CraftFamily.editorial =>
          'What the passes over a draft are, and how to read a note.',
        CraftFamily.stakes => 'What it costs if it goes wrong.',
        CraftFamily.structure =>
          'How a whole story is arranged, and what holds it together.',
        CraftFamily.characterSurface =>
          'What a reader is told about a body, and what it carries.',
        CraftFamily.world =>
          'What a world can do, what it cannot, and what it costs.',
        CraftFamily.process =>
          'Planning and drafting — the work before the revision.',
      };
}

/// The kinds of record an author may claim a craft term on.
///
/// Deliberately coarse — a studio, not a record type. A convention operates on
/// a unit of story or on a person in it, and the thirty plot types are all the
/// former; splitting *scene plan* from *chapter plan* here would be a taxonomy
/// with nothing to say, and one the library would have to keep in step with
/// every type Plot Studio adds.
///
/// It exists because the first surface was not enough to shape it. §9.12
/// shipped the applied lens on plot records with a plain `assertable` flag and
/// named the gap in writing: the flag said *whether* a term could be claimed,
/// never *where*. One call site could not answer that, and inventing the
/// answer from one example is how a taxonomy ends up describing the example.
/// The character surface is the second, and *in medias res* on a person is the
/// case that decides it.
enum CraftSubject {
  /// A unit of story — everything Plot Studio holds.
  plot,

  /// A person in it.
  character,
}

/// One thing an author might want explained.
class CraftEntry {
  const CraftEntry({
    required this.id,
    required this.family,
    required this.term,
    required this.oneLine,
    required this.whatItDoes,
    this.appliesTo = const [],
    this.seeAlso = const [],
    this.exercise = '',
    this.example = '',
    this.assertOn = const {},
  })  : assert(id.length > 0, 'an entry nothing can cite is unreachable'),
        assert(term.length > 0, 'an entry with no term cannot be looked up'),
        assert(
          oneLine.length > 0 && whatItDoes.length > 0,
          'an entry that does not say what the thing does is a glossary '
          'definition, and the glossary is not the feature',
        );

  /// Stable id. Cited, never displayed — a stored citation must survive the
  /// term being reworded.
  final String id;

  final CraftFamily family;

  /// The thing being explained, as an author would name it.
  final String term;

  /// What it is, in one sentence.
  final String oneLine;

  /// **The load-bearing field.** What it *does* in the story, or to the
  /// reader — the thing a dictionary does not tell you and the reason the
  /// entry exists at all.
  ///
  /// `narrative_voice.dart` established the rule this enforces: anyone can
  /// list five points of view, and what makes the choice easier is being told
  /// what each one does at the moment of choosing. An entry that has no
  /// non-obvious answer here is a gloss, and a gloss belongs inline on the
  /// field rather than in this library.
  final String whatItDoes;

  /// Qualified field keys this entry explains, as `<namespace>.<field id>` —
  /// `character.psychology.coreWound`, `plot.reveal.readerKnowledge`.
  ///
  /// Qualified because plot field ids are not unique across types: `resolution`
  /// belongs to both `arc` and `obstacle`, and `payoff` is a field on the
  /// `payoff` type.
  ///
  /// This is what makes one entry serve two lenses. The same object is the
  /// helper text under the input and the card on the shelf, so the two cannot
  /// drift into different explanations of one word.
  final List<String> appliesTo;

  /// Other entry ids worth reading beside this one. Never a link out of the
  /// app — the library is shipped content, and an author offline still has all
  /// of it.
  final List<String> seeAlso;

  /// A line or two showing the thing on a page, or empty.
  ///
  /// The answer to the question a reader most often has next, which is *show
  /// me*. Several entries were already smuggling one into [whatItDoes] —
  /// `filtering` explains itself with *"She saw the door swing open"* against
  /// *"The door swung open"* — and a field is the honest place for that.
  ///
  /// ## Invented, and disposable
  ///
  /// **Never from a published book.** Quoting one would give the library a
  /// copyright question it has no reason to acquire, and the sentence would
  /// have to be good rather than clear. These are written for the entry and
  /// thrown away with it.
  ///
  /// **Never from the author's project.** Lock 8: the library does not read
  /// the manuscript. An example drawn from their own book would be the one
  /// thing this shelf promises it will never do.
  ///
  /// ## Empty far more often than not
  ///
  /// An example earns its place by showing something a sentence cannot.
  /// *Deuteragonist* cannot be demonstrated in two lines — the whole point of
  /// the role is that it runs the length of a book — so it carries none, and
  /// the shelf draws no empty block. Where an entry has no honest example,
  /// nothing is better than a laboured one.
  final String example;

  /// Whether this entry has an example to show.
  bool get hasExample => example.isNotEmpty;

  /// A way to practise the thing, addressed to the writer, or empty.
  ///
  /// Optional, and empty on most entries. Some craft is understood by reading
  /// a paragraph about it; some is only understood by doing it once on your
  /// own page, and psychic distance is the standard example — nobody has ever
  /// learned where the dial sits from a definition.
  ///
  /// ## Why an imperative is allowed here and nowhere else
  ///
  /// [oneLine] and [whatItDoes] are held to Lock 7 by
  /// `craft_library_test.dart`: they never say a book *should* be anything,
  /// because they are drawn under a field the author is filling in, where a
  /// prescription would be the app telling them what to write.
  ///
  /// An exercise is the opposite arrangement. Nothing draws it automatically;
  /// an author has to go and ask for it. So it may say *take a paragraph and
  /// rewrite it* the way a workbook does, and it stays inside Lock 7 because
  /// it configures nothing and restricts nothing — it is an offer, and the
  /// author has already accepted it by opening it.
  ///
  /// It says what to try. It never says what the result ought to be, and
  /// `craft_library_test.dart` holds that separately.
  final String exercise;

  /// The kinds of record an author may claim this term for.
  ///
  /// The third lens. [appliesTo] is the library explaining a box the author is
  /// already filling in, and the shelf is the library read on its own. This is
  /// the author pointing at their own scene and saying *that one is a red
  /// herring* — an assertion, made by them, stored on their record as ordinary
  /// field data under Lock 4.
  ///
  /// Lock 8 is why this is a set on a vocabulary rather than a recogniser.
  /// The app never finds a convention in a manuscript. It offers the words and
  /// the author does the claiming, which is the whole difference between a
  /// tool that knows about writing and one that claims to have read your book.
  ///
  /// Empty by default, and empty for most of the library. A term earns a
  /// subject by being something *that kind of record* can be, rather than
  /// something an entry merely explains: *Chekhov's gun* is a thing a scene
  /// does, *the genre promise* is a property of a whole book that no one scene
  /// carries, and *Trope* is the name of the category. Two of those three
  /// would be nonsense on a checkbox.
  ///
  /// A term can earn one subject and not the other, and that is the point of
  /// the set rather than a flag. *In medias res* is a thing a story does and
  /// nothing a person can be; *the chosen one* is both. The rule is the
  /// entry's own words: a term belongs to a subject when [oneLine] and
  /// [whatItDoes] still read true with that kind of record in front of them.
  final Set<CraftSubject> assertOn;

  /// Whether this term can be claimed on any kind of record at all.
  bool get assertable => assertOn.isNotEmpty;

  /// Whether this entry has something to practise.
  bool get hasExercise => exercise.isNotEmpty;

  /// The entry rendered as field helper text.
  ///
  /// One string, because that is what `RecordFieldDefinition.description` is
  /// and what both form builders draw. A browsable surface reads the two parts
  /// separately.
  String get helper => '$oneLine $whatItDoes';
}
