/// Character entries derived from `docs/research/03-character-creation.md`,
/// `04-sociology-and-background.md`, `05-personality-traits.md`,
/// `06-physical-traits.md`, `07-body-build.md`, `08-hair-colours.md` and
/// `09-eye-colours.md`.
///
/// Seven docs, two families, and the split between them is the argument.
///
/// [CraftFamily.characterDepth] already held what is under a person — the
/// wound, the want, the belief. What the research added was the machinery
/// between those fields: the chain that runs from one to the next, and the
/// distinction between what a character appears to be and what pressure
/// discovers they are.
///
/// [CraftFamily.characterSurface] is new, and it exists because four of these
/// docs were about description and none of them were about depth. Their
/// finding was consistent and slightly uncomfortable: a trait list is an
/// instrument of continuity, not of characterisation. Knowing a woman's eye
/// colour tells you nothing about her and everything about whether chapter
/// nineteen contradicts chapter two. Filing that under depth would have said
/// the opposite.
library;

import '../craft_entry.dart';

/// Entries about what is under a character, and what a story does to it.
const List<CraftEntry> kCharacterDepthEntries = [
  CraftEntry(
    id: 'characterisation-and-character',
    family: CraftFamily.characterDepth,
    term: 'Characterisation against true character',
    oneLine: 'The observable person, against the one revealed under pressure.',
    whatItDoes: 'Everything a reader could note from watching — job, manner, '
        'wit, dress — is characterisation. True character is what the person '
        'chooses when the choice costs them, and the gap between the two is '
        'where readers decide a character is real.',
    seeAlso: ['pressure-reveals', 'contradictions', 'wound-to-need'],
    example: 'He is charming, drives well and tips generously. Then the car in '
        'front stalls on the hill, and he is out and pushing before anyone '
        'asks.',
  ),
  CraftEntry(
    id: 'pressure-reveals',
    family: CraftFamily.characterDepth,
    term: 'Pressure as the only instrument',
    oneLine: 'Character is discovered by choice under cost, and nowhere else.',
    whatItDoes: 'A dilemma between good and bad reveals nothing. A choice '
        'between two things a person genuinely values, where one has to go, '
        'reveals their actual hierarchy — including to them. It is the reason '
        'a quiet scene with a real cost outperforms a loud one without.',
    seeAlso: ['characterisation-and-character', 'internal-conflict', 'stakes-and-proximity'],
    exercise: 'Take a character and name two things they would each call '
        'non-negotiable. Write the scene where they can keep one.',
    example: 'The money or the name. He has said the name his whole life. He '
        'takes the money, and learns something about himself in the car park.',
  ),
  CraftEntry(
    id: 'wound-to-need',
    family: CraftFamily.characterDepth,
    term: 'From wound to need',
    oneLine: 'A wound teaches a lie, the lie sets the want, the need undoes it.',
    whatItDoes: 'The four fields are already familiar separately; the chain '
        'is what makes them one person. Something happened, it taught them '
        'something untrue but survivable, they now pursue what that lie '
        'recommends — and the story hands them the thing they actually need, '
        'usually at the price of the thing they were chasing.',
    seeAlso: ['core-wound', 'false-belief', 'external-want', 'internal-need'],
    example: 'Left at nine. So: asking ends badly. So: she will own the '
        'building outright and need nobody. What she needs is to ask her '
        'brother for help, once.',
  ),
  CraftEntry(
    id: 'three-dimensions',
    family: CraftFamily.characterDepth,
    term: "Egri's three dimensions",
    oneLine: 'Physiology, sociology, psychology — a person on three axes.',
    whatItDoes: 'The middle one is the one authors skip. Body and inner life '
        'get pages; where someone stands in a world, what they owe and to '
        'whom, is left as a job title. It is the axis that generates most of '
        'the constraints a plot can push against.',
    seeAlso: ['sociology-not-backstory', 'three-capitals', 'core-wound'],
    example: 'Fifty-four, with arthritic hands. Second generation, and still '
        'owes the co-operative. Cannot stay in a room where somebody is angry.',
  ),
  CraftEntry(
    id: 'trait-triad',
    family: CraftFamily.characterDepth,
    term: 'The virtue, the shadow and the cost',
    oneLine: 'One trait, read three ways.',
    whatItDoes: 'Loyalty is steadfastness, and it is also the thing that '
        'keeps someone beside a person who is destroying them, and it costs '
        'them everyone who tells the truth about it. A trait held only as its '
        'virtue is a label; held as all three it generates scenes.',
    seeAlso: ['contradictions', 'values-under-traits', 'defences'],
    exercise: 'Pick the trait you most admire in your protagonist. Write the '
        'scene where that exact trait is the reason something goes wrong.',
    example: 'Loyal: he stays. Loyal: he stays while she drinks. Loyal: '
        'everyone who told him the truth about her has stopped ringing.',
  ),
  CraftEntry(
    id: 'values-under-traits',
    family: CraftFamily.characterDepth,
    term: 'The value under the trait',
    oneLine: 'What a person is prepared to lose things for.',
    whatItDoes: 'Traits describe how someone behaves; values explain which '
        'way they break when behaving is no longer free. Two characters can '
        'both read as generous and part company completely the moment '
        'generosity costs one of them their standing.',
    seeAlso: ['trait-triad', 'pressure-reveals', 'primary-motivation'],
    example: 'Both are generous until it costs them standing. One writes the '
        'cheque anyway. The other finds out he was generous about money.',
  ),
  CraftEntry(
    id: 'traits-for-continuity',
    family: CraftFamily.characterDepth,
    term: 'What a trait list is for',
    oneLine: 'Recording a person, rather than inventing one.',
    whatItDoes: 'Nobody has ever produced a character by choosing five '
        'adjectives, and the lists are still worth keeping — for the same '
        'reason a continuity supervisor keeps notes. They answer *what did I '
        'already say about her*, which is a real question with an expensive '
        'wrong answer.',
    seeAlso: ['trait-triad', 'description-payload'],
    example: 'Left-handed, allergic to shellfish, calls her mother Peg. '
        'Chapter thirty-one is where you find out you forgot.',
  ),
  CraftEntry(
    id: 'uniform-cast',
    family: CraftFamily.characterDepth,
    term: 'The cast that agrees with itself',
    oneLine: 'Every character holding a variation of the author\'s position.',
    whatItDoes: 'It reads as thinness without any single character being '
        'thin. The repair is not more personalities but more disagreement: '
        'somebody in the book who is right in a way the book finds '
        'inconvenient.',
    seeAlso: ['internal-argument', 'contradictions', 'faction-monolith'],
    example: 'Nine characters. All nine think the strike was justified, and '
        'they differ only in how well they put it.',
  ),
  CraftEntry(
    id: 'sociology-not-backstory',
    family: CraftFamily.characterDepth,
    term: 'Sociology against backstory',
    oneLine: 'Where a person stands, against what happened to them.',
    whatItDoes: 'Backstory is events. Sociology is position — who they can '
        'call, which rooms they enter without explaining themselves, what '
        'they owe. Backstory explains a character to a reader; position '
        'decides what they can attempt on the next page.',
    seeAlso: ['three-dimensions', 'three-capitals', 'obligations'],
    example: 'Backstory: his father drank. Position: he can telephone the '
        'parish priest at midnight and cannot get an appointment at the bank.',
  ),
  CraftEntry(
    id: 'three-capitals',
    family: CraftFamily.characterDepth,
    term: 'Three kinds of capital',
    oneLine: 'What you own, who you know, and what you know how to do.',
    whatItDoes: "Bourdieu's split explains characters money alone cannot: the "
        'penniless scholar admitted anywhere, the rich man nobody will vouch '
        'for. They convert into each other slowly and imperfectly, and the '
        'friction of converting one into another is a plot.',
    seeAlso: ['sociology-not-backstory', 'the-closed-door'],
    example: 'No money, a first-class degree, and a godfather in the ministry. '
        'He is at every table and pays for nothing.',
  ),
  CraftEntry(
    id: 'the-closed-door',
    family: CraftFamily.characterDepth,
    term: 'Closed, priced, or borrowed',
    oneLine: 'Three ways a door can be shut to a character.',
    whatItDoes: 'Closed means no amount of anything opens it. Priced means it '
        'opens for something they could conceivably pay. Borrowed means '
        'someone else opens it and now they are owed. Deciding which kind a '
        'door is turns a vague obstacle into a scene with a shape.',
    seeAlso: ['three-capitals', 'obligations', 'stakes-and-proximity'],
    example: 'Sealed by statute: closed. Opens for a bribe he could raise: '
        'priced. The archivist unlocks it for her: borrowed, and he will ask.',
  ),
  CraftEntry(
    id: 'obligations',
    family: CraftFamily.characterDepth,
    term: 'The obligation inventory',
    oneLine: 'Who a character owes, who owes them, and what for.',
    whatItDoes: 'Obligations are the cheapest source of pressure there is, '
        'because they are already there before the plot starts. A character '
        'with nobody to disappoint is a character who can leave town in '
        'chapter two, and most books need them not to.',
    seeAlso: ['the-closed-door', 'sociology-not-backstory', 'stakes-and-proximity'],
    exercise: 'List six people your protagonist owes something to. Then find '
        'the one whose claim arrives at the worst possible moment.',
    example: 'He owes his brother-in-law four hundred pounds and his sister '
        'does not know, and that is why he is still in the town in chapter '
        'twenty.',
  ),
];

/// Entries about description, and what a reader does with a body.
const List<CraftEntry> kCharacterSurfaceEntries = [
  CraftEntry(
    id: 'description-payload',
    family: CraftFamily.characterSurface,
    term: 'What a detail is carrying',
    oneLine: 'A described body can pay in six different currencies.',
    whatItDoes: 'Identification, so a reader can tell two people apart. '
        'History, where a body records what happened to it. Class. '
        'Self-image. The observer, since who is looking shapes what is seen. '
        'And plot, when the detail is load-bearing later. A detail carrying '
        'none of the six is furniture.',
    seeAlso: ['hands', 'first-description', 'appearance-in-context'],
    example: '“He had brown hair.” Against: “His hair was cut the way the army '
        'cuts it, and had been growing out for about four months.”',
  ),
  CraftEntry(
    id: 'hands',
    family: CraftFamily.characterSurface,
    term: 'Hands',
    oneLine: 'The most information-dense thing a body has.',
    whatItDoes: 'Hands carry work, class, age, health, nerves and habit at '
        'once, and they are in almost every scene without being stared at. '
        'One line about them typically does what a paragraph of face does '
        'not.',
    seeAlso: ['description-payload', 'concrete-detail', 'action-beat'],
    exercise: 'Describe three characters using only their hands, and see how '
        'much a reader can already tell about each life.',
    example: 'Her hands were fifteen years older than her face, and one '
        'thumbnail had never grown back straight.',
  ),
  CraftEntry(
    id: 'first-description',
    family: CraftFamily.characterSurface,
    term: 'The first description',
    oneLine: 'The one a reader keeps, whatever comes later.',
    whatItDoes: 'Readers fix an image early and revise it reluctantly, so a '
        'first pass that lists features from the top down spends its one '
        'chance on inventory. What sticks is the detail chosen because this '
        'observer, in this moment, would have noticed it.',
    seeAlso: ['description-payload', 'appearance-in-context', 'filtering'],
    example: 'Not: tall, dark-haired, green-eyed, mid-thirties. Instead: he '
        'was still wearing the paper band from the hospital.',
  ),
  CraftEntry(
    id: 'appearance-in-context',
    family: CraftFamily.characterSurface,
    term: 'How it looked, where it was',
    oneLine: 'The same hair is a different colour in a different room.',
    whatItDoes: 'Light, distance, weather and who is doing the looking all '
        'change a described appearance, and a book that renders one person '
        'identically in candlelight and daylight has described a record card '
        'rather than a person.',
    seeAlso: ['first-description', 'natural-and-current', 'filtering'],
    example: 'In the kitchen her hair is the colour of wet sand. On the '
        'platform at six in the morning it is nearly black.',
  ),
  CraftEntry(
    id: 'physiognomy',
    family: CraftFamily.characterSurface,
    term: 'The face as a verdict',
    oneLine: 'The old idea that a body announces a character.',
    whatItDoes: 'Weak chins for weak men, scars for villains, beauty for '
        'virtue. It has a documented history as a pseudoscience and it '
        'survives in fiction as a reflex, which is why the pattern is worth '
        'being able to see in your own draft rather than only in other '
        "people's.",
    seeAlso: ['body-and-verdict', 'description-equity'],
    example: '“You could tell he was not to be trusted. It was the chin.”',
  ),
  CraftEntry(
    id: 'body-and-verdict',
    family: CraftFamily.characterSurface,
    term: 'When bodies sort into sides',
    oneLine: 'A cast where the sympathetic and the described diverge.',
    whatItDoes: 'Lay the cast out with build and role side by side and the '
        'pattern is visible in a glance: heavy for indulgent, thin for cold, '
        'unblemished for good. Any single instance is a choice. The pattern '
        'across a whole book is one the author usually did not make on '
        'purpose.',
    seeAlso: ['physiognomy', 'description-equity'],
    exercise: 'Tabulate your cast: build in one column, how the book treats '
        'them in the other. Read the table rather than the chapters.',
    example: 'The cast laid out with a build column: the two kind ones are '
        '“slight” and “fine-boned”, the two cruel ones “heavy” and '
        '“thick-necked”, and the column is where it becomes visible.',
  ),
  CraftEntry(
    id: 'description-equity',
    family: CraftFamily.characterSurface,
    term: 'Who gets described',
    oneLine: 'How the description is distributed across a cast.',
    whatItDoes: 'Books commonly spend far more of it on women than men, on '
        'the young than the old, and on the beautiful than anyone else. An '
        'uneven distribution can be exactly right for a narrator with a '
        'particular eye — the value is in knowing which of those you have.',
    seeAlso: ['body-and-verdict', 'description-payload'],
    example: 'Four hundred pages. Every woman\'s face is described on arrival. '
        'Three of the eleven men have one at all.',
  ),
  CraftEntry(
    id: 'frame-and-mass',
    family: CraftFamily.characterSurface,
    term: 'Frame against mass',
    oneLine: 'Two things a build word runs together.',
    whatItDoes: 'Skeleton and proportion do not change after growth; weight '
        'and muscle change with food, work, illness and time. "Stocky" says '
        'both at once, which is why a character can be described consistently '
        'across a famine and still read wrong.',
    seeAlso: ['bodies-accumulate', 'period-body-signals'],
    example: '“Stocky” in chapter one. He is stocky again in chapter thirty, '
        'and the famine was chapter nine.',
  ),
  CraftEntry(
    id: 'bodies-accumulate',
    family: CraftFamily.characterSurface,
    term: 'What a body only gains',
    oneLine: 'Scars, marks and losses arrive and stay arrived.',
    whatItDoes: 'A body can gain a scar between chapters and cannot quietly '
        'shed one. Treating that class of detail as one-way makes a whole '
        'category of continuity slip visible without anyone tracking it by '
        'hand.',
    seeAlso: ['frame-and-mass', 'hair-grows', 'description-payload'],
    example: 'The burn arrives on her forearm in chapter four. In chapter '
        'twenty she pushes her sleeves back and there is no burn.',
  ),
  CraftEntry(
    id: 'period-body-signals',
    family: CraftFamily.characterSurface,
    term: 'What a body meant then',
    oneLine: 'The same build reads differently in a different century.',
    whatItDoes: 'Weight has signalled prosperity far more often than it has '
        'signalled indulgence; a tan has meant labour rather than leisure; '
        'soft hands have been status. A body described with a modern reading '
        'attached is one of the quieter anachronisms.',
    seeAlso: ['frame-and-mass', 'description-payload'],
    example: '1840: “She had grown stout, and it suited the family\'s '
        'circumstances.”',
  ),
  CraftEntry(
    id: 'hair-level-and-tone',
    family: CraftFamily.characterSurface,
    term: 'Level and tone',
    oneLine: 'Hair colour is two measurements, not one word.',
    whatItDoes: 'How dark it is, and which way it leans — warm, ash, red. '
        'Auburn and chestnut differ by tone at nearly the same level, which '
        'is why two people described with different words can be picturing '
        'the same head and one described consistently can drift.',
    seeAlso: ['natural-and-current', 'appearance-in-context'],
    example: 'Auburn in chapter two, chestnut in chapter nine. Nearly the same '
        'level, leaning opposite ways, and two readers are now picturing two '
        'heads.',
  ),
  CraftEntry(
    id: 'natural-and-current',
    family: CraftFamily.characterSurface,
    term: 'Natural and current',
    oneLine: 'What grows out of the head, and what is on it now.',
    whatItDoes: 'Two separate values, and a character can knowingly carry '
        'both. Keeping them apart is what lets dye, grey and a growing-out '
        'colour be tracked at all — and the gap between them is often the '
        'more interesting fact.',
    seeAlso: ['hair-level-and-tone', 'hair-grows'],
    example: 'Natural: black. Current: the red she has kept up for nine years, '
        'with two centimetres at the roots that say when she stopped.',
  ),
  CraftEntry(
    id: 'hair-grows',
    family: CraftFamily.characterSurface,
    term: 'Hair grows at a known rate',
    oneLine: 'Roughly a centimetre a month, in every century.',
    whatItDoes: 'It makes a shorn head into a clock. A character cropped in '
        'spring and described in a braid by midsummer has told the reader '
        'something about how much time the book thinks has passed.',
    seeAlso: ['natural-and-current', 'bodies-accumulate'],
    example: 'Cropped to the scalp in March, in a braid at her shoulder by '
        'August. At a centimetre a month that is a summer about two and a half '
        'years long.',
  ),
  CraftEntry(
    id: 'eye-colour-recall',
    family: CraftFamily.characterSurface,
    term: 'What readers keep',
    oneLine: 'Eye colour is stated often and remembered rarely.',
    whatItDoes: 'It is among the least-recalled details in fiction and among '
        'the most frequently supplied, which makes it a good measure of '
        'whether a description is doing work or filling a slot. A gesture in '
        'the same sentence outlasts it by a wide margin.',
    seeAlso: ['piercing-blue', 'description-payload'],
    example: 'Ask a reader what colour her eyes were: nothing. Ask what her '
        'hands did when she lied: the left one went to her collar.',
  ),
  CraftEntry(
    id: 'melanin-not-palette',
    family: CraftFamily.characterSurface,
    term: 'How eyes actually vary',
    oneLine: 'One pigment, in differing amounts, plus how light scatters.',
    whatItDoes: 'Brown at one end, and at the other end blue and grey which '
        'are not pigments at all but the way light behaves with very little '
        'of it. Violet and true black belong to fiction, which is a fine '
        'place for them as long as the book knows it put them there.',
    seeAlso: ['eye-colour-recall', 'appearance-in-context'],
    example: 'Violet eyes, in the book with the magic system. Violet eyes, in '
        'the book set in a hospital in Leeds.',
  ),
  CraftEntry(
    id: 'piercing-blue',
    family: CraftFamily.characterSurface,
    term: 'Piercing blue',
    oneLine: 'The most-used phrase in the most-used description.',
    whatItDoes: 'It arrives pre-attached to an intensity the character has '
        'not earned yet, doing the work the scene was supposed to do. The '
        'same is true of emerald green, and of any eye described as stormy.',
    seeAlso: ['eye-colour-recall', 'purple-prose', 'concrete-detail'],
    example: '“His piercing blue eyes.” Against: “He looked at her a moment '
        'too long, and she answered a question he had not asked.”',
  ),
];
