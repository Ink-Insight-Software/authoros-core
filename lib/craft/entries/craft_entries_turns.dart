/// Turn entries derived from `docs/research/10-plot-twists.md` and
/// `11-plot-twist-catalogue.md`.
///
/// The catalogue in doc 11 lists sixty-eight twists. None of them are here,
/// and that was the finding rather than a shortcut: a named twist is a thing
/// somebody else already did, and an entry saying *the narrator did it* helps
/// nobody write one. What transfers is the machinery — why a twist works at
/// all, what makes one land as fair, and how heavily a clue can be laid.
///
/// The [turns] family already holds the reveal fields the record model stores.
/// These sit above them: the reveal fields say what is revealed and to whom,
/// and these say what a reveal has to do to the pages behind it.
library;

import '../craft_entry.dart';

/// Entries about how a turn works on a reader.
const List<CraftEntry> kTurnResearchEntries = [
  CraftEntry(
    id: 'two-readings',
    family: CraftFamily.turns,
    term: 'The second reading',
    oneLine: 'A twist rewrites pages the reader has already read.',
    whatItDoes: 'The mechanism is not the shock. It is that everything behind '
        'the reveal now means something else, and the reader can feel both '
        'meanings at once. A turn that changes only what happens next is a '
        'development; a turn that changes what already happened is a twist.',
    seeAlso: ['surprise-and-inevitability', 'plant', 'actual-reveal-point'],
    exercise: 'Take the chapter before your twist and read it twice, once as a '
        'first-time reader and once knowing. List the lines that carry two '
        'meanings, and the lines that carry one.',
    example: 'First reading: he is being kind to her. Second reading: he is '
        'making sure she stays in the house.',
  ),
  CraftEntry(
    id: 'surprise-and-inevitability',
    family: CraftFamily.turns,
    term: 'Surprising, then inevitable',
    oneLine: 'Unforeseen at the time, and obvious a moment later.',
    whatItDoes: 'Both halves are required and they pull against each other. '
        'Surprise alone is a trick; inevitability alone is a reveal the '
        'reader got to first. The third condition is the one people forget — '
        'it has to change what the book is about, not only what happened.',
    seeAlso: ['two-readings', 'misdirection-and-concealment', 'earned-ending'],
    exercise: 'Write the sentence a reader would say a page later to explain '
        'why your twist had to be so. Then find the pages that sentence rests '
        'on.',
    example: '“She was never on the boat.” And then: the coat, the wrong tide '
        'time, and the sister who would not look at the water.',
  ),
  CraftEntry(
    id: 'misdirection-and-concealment',
    family: CraftFamily.turns,
    term: 'Misdirection against concealment',
    oneLine: 'Showing the reader and steering their attention, or hiding it.',
    whatItDoes: 'Misdirection puts the fact on the page where a reader can '
        'see it and gives them something more interesting to look at. '
        'Concealment keeps it off the page. The first can be reread with '
        'pleasure; the second can only be discovered to have been withheld.',
    seeAlso: ['red-herring', 'plant', 'the-withheld-thought'],
    exercise: 'Take your central hidden fact and write the version where it '
        'sits on the page in plain sight with something more interesting '
        'beside it. Keep both drafts.',
    example: 'The ticket is on the page in chapter two, third in a list of six '
        'things, the fourth of which is a dead wasp. Against: no ticket '
        'anywhere until chapter thirty.',
  ),
  CraftEntry(
    id: 'the-withheld-thought',
    family: CraftFamily.turns,
    term: 'The thought the narrator did not have',
    oneLine: 'A close point of view that skips what the character knows.',
    whatItDoes: 'When a book stands inside a mind and steps outside it at the '
        'one moment that mind would have thought about the secret, the reader '
        'feels the manoeuvre later even if they cannot name it. It is where '
        'most complaints of an unfair twist actually originate.',
    seeAlso: ['misdirection-and-concealment', 'narrative-distance',
        'unreliable-narrator'],
    exercise: 'Read every scene in close point of view where your character '
        'stands near the secret, and mark what they think about instead. Read '
        'the marks in a row.',
    example: 'Nine pages close inside his head. His mother\'s name comes up, '
        'and the narration moves to the weather.',
  ),
  CraftEntry(
    id: 'clue-dosage',
    family: CraftFamily.turns,
    term: 'How heavily to lay a clue',
    oneLine: 'The same fact, given three different amounts of emphasis.',
    whatItDoes: 'A clue at the end of a paragraph is louder than the same '
        'clue mid-sentence, and one a character reacts to is louder again. '
        'Fairness comes from the fact being present; difficulty comes from '
        'where in the sentence it sits.',
    seeAlso: ['plant', 'misdirection-and-concealment', 'reader-awareness'],
    exercise: 'Write the sentence carrying your clue three times: buried in a '
        'subordinate clause, ending a paragraph, and remarked on by someone. '
        'Choose after reading all three in place.',
    example: '“…his keys, a ferry ticket and a comb.” · “…and a ferry ticket.” '
        '· “Why have you got a ferry ticket?”',
  ),
  CraftEntry(
    id: 'twist-and-person',
    family: CraftFamily.turns,
    term: 'What the twist does to a person',
    oneLine: 'Whether the reveal rearranges the plot or a character.',
    whatItDoes: 'A reveal that changes only the sequence of events is solved '
        'and finished. One that changes who somebody has been the whole time '
        'is still working two chapters later, because the reader has to '
        'revise a person rather than a fact.',
    seeAlso: ['two-readings', 'characterisation-and-character'],
    exercise: 'Write two lines about your twist: what it changes about what '
        'happened, and what it changes about who someone has been. Read which '
        'line is longer.',
    example: 'Plot: the will was forged. Person: it was forged by the one who '
        'spent the book refusing to touch the money.',
  ),
];
