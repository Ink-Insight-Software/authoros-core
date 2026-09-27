/// Prose entries derived from `docs/research/01-prose.md`.
///
/// The research doc is an essay; these are not. An essay may spend a page
/// arguing that psychic distance is a dial, and an entry has three sentences
/// to make that useful to someone in the middle of a paragraph. What survived
/// the compression is the part that answers *what does this do to a reader*,
/// which is the only test `craft_entry.dart` sets.
///
/// What did not survive: the diagnostics. A doc proposing that AuthorOS could
/// count filter verbs is proposing a feature, and the library explains craft
/// rather than announcing what the app might one day measure. Where a finding
/// was genuinely about the writing rather than about the tooling — the one
/// below on countable qualities — it is here as craft, in the author's terms.
library;

import '../craft_entry.dart';

/// Entries about the sentence, the paragraph and the voice.
const List<CraftEntry> kProseResearchEntries = [
  CraftEntry(
    id: 'story-narrative-prose',
    family: CraftFamily.prose,
    term: 'Story, narrative and prose',
    oneLine: 'Three different things a reader is often told are one.',
    whatItDoes: 'The story is what happened. The narrative is the order you '
        'reveal it in. The prose is the words doing the revealing. A book can '
        'be sound at one level and fail at another, and knowing which level '
        'hurts is most of knowing what to fix.',
    seeAlso: ['summary-and-scene', 'in-medias-res', 'the-chronology-you-keep'],
    example: 'Story: he died in 1961. Narrative: the reader finds out in '
        'chapter thirty. Prose: “They had buried him by the time she landed.”',
  ),
  CraftEntry(
    id: 'distance-ladder',
    family: CraftFamily.prose,
    term: 'The distance ladder',
    oneLine: 'The rungs between a wide shot and a thought, in one paragraph.',
    whatItDoes: 'From "It was winter" through "Henry hated the cold" to '
        '"Christ, the cold" — each step stands closer to the mind. Naming the '
        'rungs makes the dial usable: you can hear which one a sentence is on '
        'and whether the next sentence moved one step or four.',
    seeAlso: ['narrative-distance', 'free-indirect-style', 'filtering'],
    exercise: 'Take a paragraph of your own and rewrite it four times, once '
        'per rung, from the widest view down to the character\'s own words '
        'with no attribution. Read the four aloud and notice which one you '
        'had actually been writing without choosing it.',
    example: '“The tide was out.” · “The beach smelled of it.” · “God, that '
        'smell.”',
  ),
  CraftEntry(
    id: 'subjects-and-verbs',
    family: CraftFamily.prose,
    term: 'Characters as subjects, actions as verbs',
    oneLine: 'The two habits that carry most of what people call clarity.',
    whatItDoes: 'When the person doing the thing is the subject of the '
        'sentence, and the thing they do is its verb, a reader parses it '
        'without noticing. When either drifts elsewhere, the sentence still '
        'means what it meant and costs more to read.',
    seeAlso: ['nominalisation', 'modifier-on-the-verb', 'sentence-rhythm'],
    example: '“The committee reached a decision” against “Ellis and Mara '
        'decided.”',
  ),
  CraftEntry(
    id: 'nominalisation',
    family: CraftFamily.prose,
    term: 'Nominalisation',
    oneLine: 'A verb wearing a noun\'s coat — *decide* becoming *decision*.',
    whatItDoes: 'The action stops being something a person does and becomes a '
        'thing that exists, which quietly removes whoever did it. It is how '
        'prose gets abstract without any single sentence being abstract, and '
        'it is the most reversible of all prose habits.',
    seeAlso: ['subjects-and-verbs', 'concrete-detail'],
    exercise: 'Search a chapter for words ending in -tion, -ment, -ance and '
        '-ity. For each one, try the sentence again with the buried verb doing '
        'the work. Keep the ones that read better as nouns — some do.',
    example: '“The decision was made” against “She decided.”',
  ),
  CraftEntry(
    id: 'cumulative-sentence',
    family: CraftFamily.prose,
    term: 'Cumulative sentence',
    oneLine: 'A complete clause, then modifiers trailing after it.',
    whatItDoes: 'The reader gets the whole thought immediately and then '
        'watches it gain detail, which reads as a mind noticing more as it '
        'looks. It is the workhorse of close narration, and it can run long '
        'without ever feeling long.',
    seeAlso: ['periodic-sentence', 'sentence-rhythm', 'concrete-detail'],
    exercise: 'Write one sentence of eight words. Then extend it three times '
        'without touching the original eight — each addition a phrase that '
        'looks closer at something already there.',
    example: '“He ran, coat open, breath tearing, the bag hammering his '
        'hip.”',
  ),
  CraftEntry(
    id: 'periodic-sentence',
    family: CraftFamily.prose,
    term: 'Periodic sentence',
    oneLine: 'The one that holds its main clause back until the end.',
    whatItDoes: 'Suspension. The reader carries an incomplete thought and '
        'cannot put it down until the last few words arrive, which is why one '
        'of these lands a revelation and why four in a row exhaust a reader.',
    seeAlso: ['cumulative-sentence', 'sentence-rhythm'],
    example: '“Coat open, breath tearing, bag hammering his hip, he ran.”',
  ),
  CraftEntry(
    id: 'voice-and-style',
    family: CraftFamily.prose,
    term: 'Voice against style',
    oneLine: 'Whose sensibility it is, against the choices that render it.',
    whatItDoes: 'Style is countable — clause length, diction, how much '
        'metaphor. Voice is the thing those choices add up to, and it is why '
        'two writers using identical sentence lengths sound nothing alike. '
        'Style is imitable; voice is what remains when the imitation fails.',
    seeAlso: ['register', 'sentence-rhythm', 'the-countable-and-the-good'],
    example: 'Two writers, the same clause length and the same plain diction. '
        'One sounds like a coroner and the other like a man apologising.',
  ),
  CraftEntry(
    id: 'the-countable-and-the-good',
    family: CraftFamily.prose,
    term: 'The countable and the good',
    oneLine: 'Every measurable prose quality has a high end worth writing.',
    whatItDoes: 'Long sentences, repeated words, adverbs, passive '
        'construction, dialogue with no attribution: each is named as a fault '
        'somewhere, and each is the whole technique of a book somebody loves. '
        'A count tells you a number. What it does not tell you is whether you '
        'are in the regime where the number is the point.',
    seeAlso: ['deliberate-repetition', 'voice-and-style', 'purple-prose'],
    example: 'Adverb count: forty-one. The book is a comic novel narrated by a '
        'man who over-explains absolutely everything.',
  ),
  CraftEntry(
    id: 'purple-prose',
    family: CraftFamily.prose,
    term: 'Purple prose',
    oneLine: 'Writing that asks to be admired while the scene waits.',
    whatItDoes: 'The tell is not ornament — ornate books work. It is ornament '
        'the moment does not pay for: three clauses on the light in a room '
        'where someone has just been told their brother is dead. The reader '
        'feels the author arrive, and the character goes quiet.',
    seeAlso: ['the-countable-and-the-good', 'concrete-detail', 'darlings'],
    example: '“The orb of night ascended” against “The moon came up.”',
  ),
  CraftEntry(
    id: 'white-space-of-attention',
    family: CraftFamily.prose,
    term: 'What the reader is given to do',
    oneLine: 'Prose leaves work for a reader, or does all of it for them.',
    whatItDoes: 'A reader who assembles the conclusion holds it as their own. '
        'One who is handed every inference stays a spectator. This is what '
        'people are reaching for when they say prose feels flat despite '
        'nothing in it being wrong.',
    seeAlso: ['showing-and-telling', 'subtext', 'filtering'],
    example: '“She was devastated.” Against: “She put the phone down and went '
        'on cutting the bread.”',
  ),
];
