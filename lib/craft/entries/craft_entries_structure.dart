/// Structure entries derived from `docs/research/02-storytelling.md` and
/// `docs/research/17-plan-and-outline.md`.
///
/// The structure models are the reason this family exists and the reason it
/// was the hardest to write. A model is a lens: it describes a skeleton most
/// stories share, in one vocabulary, at one resolution. Listed without that
/// framing, ten of them read as ten checklists, and an author who takes them
/// that way writes the book the model already described.
///
/// So [structure-as-lens] is first, and every model entry says what it is
/// *good at* rather than what it requires. That is not softening. It is the
/// accurate statement: Freytag is genuinely the right tool for a five-act
/// tragedy and genuinely the wrong one for a novel, and an entry that said
/// only "exposition, rising action, climax" would have hidden the useful half.
library;

import '../craft_entry.dart';

/// Entries about the shape of a whole story.
const List<CraftEntry> kStructureEntries = [
  CraftEntry(
    id: 'structure-as-lens',
    family: CraftFamily.structure,
    term: 'A structure model is a lens',
    oneLine: 'Most models describe one skeleton in different vocabularies.',
    whatItDoes: 'Read as descriptions, several at once, they show you where '
        'your book already turns and where it goes quiet. Read as a template, '
        'one at a time, they produce a book that satisfies the model and '
        'surprises nobody. The difference is entirely in how they are held.',
    seeAlso: ['three-act', 'story-circle', 'seven-point', 'kishotenketsu'],
    example: 'Held as a description: the midpoint is at chapter nineteen, and '
        'that is late. Held as a template: the midpoint goes at chapter '
        'nineteen.',
  ),
  CraftEntry(
    id: 'value-charge',
    family: CraftFamily.structure,
    term: 'The charge on a scene',
    oneLine: 'The value a scene moves, and which way it moves it.',
    whatItDoes: 'Trust, safety, hope, control — name the one at stake and its '
        'state at the door and at the exit. A scene where the state is the '
        'same at both ends is a scene the book can lose. It is the fastest '
        'test there is, and it works on an outline as well as on prose.',
    seeAlso: ['scene-and-sequel', 'therefore-but', 'summary-and-scene'],
    exercise: 'Take five consecutive scenes and write one line each: the '
        'value, where it stood at the start, where it stood at the end. Any '
        'line where the two ends match is the one to look at first.',
    example: 'Trust: high at the door, gone by the exit. Against: high at the '
        'door, high at the exit, four thousand words in between.',
  ),
  CraftEntry(
    id: 'scene-and-sequel',
    family: CraftFamily.structure,
    term: 'Scene and sequel',
    oneLine: 'The unit where something happens, and the one where it lands.',
    whatItDoes: 'A scene is pursuit against resistance. A sequel is the '
        'reaction, the reckoning and the next decision — usually shorter, '
        'often a paragraph. Books made only of scenes exhaust a reader; books '
        'with long sequels stall. The ratio is most of what pace means.',
    seeAlso: ['value-charge', 'in-late-out-early', 'summary-and-scene'],
    example: 'Six pages of the raid. Then: he sat in the car without starting '
        'it, and decided not to tell her.',
  ),
  CraftEntry(
    id: 'therefore-but',
    family: CraftFamily.structure,
    term: 'Therefore, but, and then',
    oneLine: 'A causality test you can run on a summary of your own book.',
    whatItDoes: 'Say the plot aloud with only *therefore* or *but* between '
        'events. Where the only honest connective is *and then*, two things '
        'are adjacent rather than connected — which is what a reader is '
        'feeling when they say a book meanders without being able to say why.',
    seeAlso: ['value-charge', 'reverse-outline', 'sagging-middle'],
    exercise: 'Summarise your act two in eight sentences, each beginning with '
        'therefore or but. Where you have to reach for and then, you have '
        'found the join to work on.',
    example: 'She misses the train, and then the inspector calls. Against: she '
        'misses the train, therefore the inspector finds her at home.',
  ),
  CraftEntry(
    id: 'promise-ledger',
    family: CraftFamily.structure,
    term: 'The promise ledger',
    oneLine: 'Everything an opening promises, and where each one is paid.',
    whatItDoes: 'An opening makes commitments the author often never made '
        'consciously: a genre, a tone, a question, a character worth '
        'following. A reader remembers all of them. Keeping the list turns a '
        'vague sense that an ending disappointed into an addressable line.',
    seeAlso: ['genre-promise', 'plant', 'payoff', 'chekhovs-gun'],
    exercise: 'Read only your first chapter and list every promise it makes '
        'to a stranger. Then find the page where each one is paid. The ones '
        'you cannot find a page for are the list worth having.',
    example: 'Page one: a locked room, a dead man, and a narrator who says she '
        'lies. Paid: the room at chapter twelve, the man at chapter thirty. '
        'The lying, never.',
  ),
  CraftEntry(
    id: 'three-act',
    family: CraftFamily.structure,
    term: 'Three-act structure',
    oneLine: 'Setup, confrontation, resolution, with turns near the quarters.',
    whatItDoes: 'The default sanity check, and the one most readers have '
        'internalised without ever naming. Its value is proportion: it shows '
        'you quickly when a setup has taken half the book, which is the '
        'commonest shape problem in a first novel.',
    seeAlso: ['structure-as-lens', 'seven-point', 'sagging-middle'],
    example: 'Setup runs to page 180 of 360. Confrontation gets ninety pages '
        'and so does the resolution.',
  ),
  CraftEntry(
    id: 'freytags-pyramid',
    family: CraftFamily.structure,
    term: "Freytag's pyramid",
    oneLine: 'Exposition, rising action, climax, falling action, catastrophe.',
    whatItDoes: 'Written in 1863 to describe five-act tragedy, where a long '
        'fall after the climax is the point. Applied to a novel it asks for '
        'a third of the book after the climax, which is why books built on it '
        'so often feel as though they end twice.',
    seeAlso: ['structure-as-lens', 'three-act'],
    example: 'The climax lands on page 240 of 360. The hundred and twenty '
        'after it are the fall, and readers describe the book as ending twice.',
  ),
  CraftEntry(
    id: 'heros-journey',
    family: CraftFamily.structure,
    term: "The hero's journey",
    oneLine: 'Departure, initiation, return, in twelve named stages.',
    whatItDoes: 'Campbell described myth and Vogler turned it into a working '
        'model. It is precise about the shape of leaving home and coming back '
        'changed, which makes it strong for quest and coming-of-age and '
        'strained anywhere the protagonist never leaves.',
    seeAlso: ['structure-as-lens', 'story-circle'],
    example: 'She leaves the valley at chapter four and comes back at chapter '
        'thirty. The valley is the same one.',
  ),
  CraftEntry(
    id: 'story-circle',
    family: CraftFamily.structure,
    term: 'The story circle',
    oneLine: 'You, need, go, search, find, take, return, change.',
    whatItDoes: "Harmon's eight steps compress the journey into something "
        'small enough to run on a single chapter or a subplot. That is its '
        'real use: it is the only one of these models light enough to apply '
        'at two scales at once.',
    seeAlso: ['heros-journey', 'structure-as-lens'],
    example: 'Over the book: she needs the money, goes to the city, takes it, '
        'comes back changed. Over chapter nine: she needs the key, goes '
        'upstairs, takes it, comes down changed.',
  ),
  CraftEntry(
    id: 'seven-point',
    family: CraftFamily.structure,
    term: 'The seven-point structure',
    oneLine: 'Hook, two plot turns, two pinches, midpoint, resolution.',
    whatItDoes: 'Built backwards, which is the whole point of it: the '
        'resolution is decided first, the hook is derived as its inverse, and '
        'everything between is the road from one to the other. It is the '
        'clearest working demonstration that an ending constrains a beginning.',
    seeAlso: ['planning-backwards', 'structure-as-lens', 'three-act'],
    example: 'Resolution first: he hands the letter over. Hook derived from '
        'it: a man who has never given anything away.',
  ),
  CraftEntry(
    id: 'save-the-cat-beats',
    family: CraftFamily.structure,
    term: 'The beat sheet',
    oneLine: 'Fifteen named beats with page targets across the book.',
    whatItDoes: 'The finest-grained model in circulation, and the most '
        'commercially tuned — it is a pacing audit with the pages written on '
        'it. Its known cost is rigidity: beats hit because the sheet says so, '
        'at the page the sheet says, read as beats hit on schedule.',
    seeAlso: ['structure-as-lens', 'three-act'],
    example: 'The sheet puts the catalyst at twelve per cent. It is on page 31 '
        'of 260, and it arrives sounding like a page-31 catalyst.',
  ),
  CraftEntry(
    id: 'kishotenketsu',
    family: CraftFamily.structure,
    term: 'Kishōtenketsu',
    oneLine: 'Introduction, development, turn, reconciliation.',
    whatItDoes: 'A four-movement structure whose third movement is a turn '
        'rather than a confrontation — an unexpected element that reframes '
        'what the first two meant. It is the honest account of a great deal '
        'of literary and slice-of-life fiction that three-act analysis mangles.',
    seeAlso: ['structure-as-lens', 'turn-reversal', 'three-act'],
    example: 'Two sisters keep a shop. The shop keeps them. A letter arrives '
        'that was posted forty years ago. Neither sister mentions it again, '
        'and the shop is not the same shop.',
  ),
  CraftEntry(
    id: 'fichtean-curve',
    family: CraftFamily.structure,
    term: 'The Fichtean curve',
    oneLine: 'A rising series of crises with the exposition thrown out.',
    whatItDoes: 'Opens inside trouble and escalates without pausing to '
        'explain, letting the reader assemble the background from what people '
        'do under pressure. It is the natural shape of a thriller and the '
        'reason thrillers can start on page one of the worst day.',
    seeAlso: ['in-medias-res', 'structure-as-lens', 'exposition'],
    example: 'Page one: the car is already in the water.',
  ),
  CraftEntry(
    id: 'obligatory-scene',
    family: CraftFamily.structure,
    term: 'The obligatory scene',
    oneLine: 'The scene a genre has already promised the reader.',
    whatItDoes: 'A detective names the killer; lovers are alone and honest at '
        'least once; the horror survivors face the thing directly. Skipping '
        'one is a decision with a cost, and paying the cost knowingly is a '
        'different act from not knowing the debt existed.',
    seeAlso: ['genre-promise', 'promise-ledger', 'subversion'],
    example: 'Four hundred pages of detection. He works it out alone in the '
        'car, and the last chapter is the arrest.',
  ),
  CraftEntry(
    id: 'vonnegut-shapes',
    family: CraftFamily.structure,
    term: 'The shapes of stories',
    oneLine: "Vonnegut's contours: fortune plotted against time.",
    whatItDoes: 'Man in a Hole, Boy Meets Girl, Cinderella and the rest give '
        'you the arc of a book as a line you can look at whole. It is a '
        'summary of outcome, not of construction — useful for seeing the '
        'silhouette, silent about whether the scenes earn it.',
    seeAlso: ['fortune-is-not-feeling', 'structure-as-lens'],
    example: 'The line falls for two hundred pages and rises for eighty. It '
        'says nothing at all about whether the eighty were paid for.',
  ),
  CraftEntry(
    id: 'fortune-is-not-feeling',
    family: CraftFamily.structure,
    term: 'Fortune is not feeling',
    oneLine: "An arc's vertical axis is circumstance, not emotion.",
    whatItDoes: 'They travel together often enough to be confused, and they '
        'come apart exactly where the interesting fiction lives: a character '
        'can win everything and be hollowed out by it. Reading a rising line '
        'as a happy one loses that book entirely.',
    seeAlso: ['vonnegut-shapes', 'internal-need', 'external-want'],
    example: 'He gets the house, the firm and the name, and the line rises. He '
        'is in the kitchen at four in the morning with the lights off.',
  ),
  CraftEntry(
    id: 'dramatic-irony',
    family: CraftFamily.structure,
    term: 'Dramatic irony',
    oneLine: 'The reader knows something the character does not.',
    whatItDoes: 'It converts an ordinary scene into a held breath: every '
        'harmless line the character says is now weighted by what the reader '
        'can see coming. It is the cheapest tension available and it costs '
        'you the surprise you traded for it.',
    seeAlso: ['reader-knowledge', 'ticking-clock', 'suspense-and-surprise'],
    example: 'The reader watched him put the key in his coat. Now she asks '
        'him, twice, whether he has seen it.',
  ),
  CraftEntry(
    id: 'suspense-and-surprise',
    family: CraftFamily.structure,
    term: 'Suspense against surprise',
    oneLine: 'Tension from what a reader anticipates, or from what lands.',
    whatItDoes: 'Suspense is long and re-readable; surprise is a moment and '
        'spends itself once. Most books need both, and knowing which one a '
        'scene is buying tells you whether to plant the bomb early or keep it '
        'off the page.',
    seeAlso: ['dramatic-irony', 'plant', 'cliffhanger'],
    example: 'The reader watched the letter go into the fire on page ten, and '
        'waits ninety pages for somebody to ask for it. Against: the fire and '
        'the asking in the same paragraph.',
  ),
  // `stakes` is its own family now, and the nine `stake-*` entries in it name
  // the kinds. This one is the principle above them — it belongs beside them
  // rather than here, and it lives in this file only because the structure
  // research is what produced it.
  CraftEntry(
    id: 'stakes-and-proximity',
    family: CraftFamily.stakes,
    term: 'Proximity, not scale',
    oneLine: 'What is lost if this goes badly, and to whom it matters.',
    whatItDoes: 'Scale is not the variable — a world ending means less than a '
        'kitchen argument when the reader knows the kitchen. What makes '
        'stakes land is proximity: whether the reader can feel the specific '
        'person who pays.',
    seeAlso: ['stake-personal', 'stake-world', 'value-charge', 'external-want'],
    exercise: 'Take the largest stake in your book and name the one person who '
        'feels it first. Write the scene from beside them.',
    example: 'A continent burns on page four hundred. On page nine, a woman '
        'finds her sister\'s coat hanging in the hall.',
  ),
  CraftEntry(
    id: 'sagging-middle',
    family: CraftFamily.structure,
    term: 'The middle that sags',
    oneLine: 'The long stretch where events continue and pressure does not.',
    whatItDoes: 'Almost always a causality problem wearing a pacing costume: '
        'scenes joined by *and then* rather than by consequence. Adding '
        'incident makes it longer. Making each scene cause the next one makes '
        'it shorter without cutting anything.',
    seeAlso: ['therefore-but', 'value-charge', 'three-act'],
    example: 'Chapters eleven to nineteen: a robbery, a storm, a funeral, a '
        'betrayal. Nothing in chapter twenty happens because of any of them.',
  ),
  CraftEntry(
    id: 'theme-as-argument',
    family: CraftFamily.structure,
    term: 'Theme as an argument',
    oneLine: 'What the book contends, tested by what happens in it.',
    whatItDoes: 'A theme stated is a message; a theme argued is a structure. '
        'The argument is made by which choices cost what — and a book whose '
        'events contradict its stated theme is usually telling the truer of '
        'the two.',
    seeAlso: ['internal-need', 'fortune-is-not-feeling'],
    example: 'The book says loyalty is everything. Everyone who stays loyal '
        'loses, and the one who informs ends up with the house.',
  ),
  CraftEntry(
    id: 'earned-ending',
    family: CraftFamily.structure,
    term: 'An earned ending',
    oneLine: 'One the book has already paid for, page by page.',
    whatItDoes: 'The test is not whether it is happy or sad but whether a '
        'reader can trace it back: the capacity was planted, the cost was '
        'charged, the change was worked for. Endings that disappoint usually '
        'arrive correct and unpaid.',
    seeAlso: ['promise-ledger', 'deus-ex-machina', 'payoff'],
    example: 'She forgives him on the last page, having said in chapter two '
        'that she never would, and nothing between the two has been about it.',
  ),
  // ---------------------------------------------------------------------
  // Chronology — the arrangement of time, and the two clocks under it.
  //
  // The family already held the shape of a whole story and said nothing about
  // its *order*. `story-narrative-prose` names the levels — what happened,
  // the order you reveal it in, the words doing the revealing — and stops
  // there, which was right for a prose entry and left the middle level
  // unexplained. These are that middle level.
  //
  // They arrived with Timeline Studio, which had twenty fields and not one
  // sentence of guidance. The useful thing to say under a date box turned out
  // not to be about dates at all: an author keeping a chronology is holding
  // two clocks — the one the world runs on, and the one the reader is
  // actually feeling — and almost everything that goes wrong with time in a
  // book is the two being confused for each other.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'the-chronology-you-keep',
    family: CraftFamily.structure,
    term: 'The chronology you keep',
    oneLine: 'A record no reader will ever see, kept for what it catches.',
    whatItDoes: 'Readers experience the order of the telling; the dated list '
        'is the author\'s instrument for making sure that order is possible. '
        'Its return is almost entirely in contradictions found early — the '
        'character in two places, the wound that heals in a week and aches '
        'for a year — because a broken chronology is the one kind of mistake '
        'a reader always catches and never forgives quietly.',
    seeAlso: ['story-narrative-prose', 'hair-grows', 'readers-clock'],
    example: 'Row 41, 14 March: the wound. Row 58, 21 March: the ride to the '
        'coast. Row 60, 22 March: the wound reopens, after a week in the '
        'saddle nobody mentioned.',
  ),
  CraftEntry(
    id: 'readers-clock',
    family: CraftFamily.structure,
    term: "The reader's clock",
    oneLine: 'How much time a reader believes has passed.',
    whatItDoes: 'It is set by how many pages they turned, not by the dates on '
        'them. Three days given forty pages feel longer than five years given '
        'one line, so a chronology can be exactly right and still leave a '
        'book feeling rushed at the part that mattered and becalmed at the '
        'part that did not.',
    appliesTo: ['timeline.duration'],
    seeAlso: ['summary-and-scene', 'sagging-middle', 'time-skip'],
    example: 'Three days across forty pages. Five years in a line: “By the '
        'time the war ended she was thirty.”',
  ),
  CraftEntry(
    id: 'time-skip',
    family: CraftFamily.structure,
    term: 'The skip',
    oneLine: 'Cutting to a later moment and letting the gap stand.',
    whatItDoes: 'The reader fills it, and unless told otherwise they fill it '
        'with nothing much happening. That is why a skip over the stretch '
        'where someone changed reads as the change being announced rather '
        'than earned: the book asked for the gap to be uneventful and then '
        'needed it to have done the work.',
    seeAlso: ['readers-clock', 'summary-and-scene', 'earned-ending'],
    example: 'Chapter eleven ends with him unable to say it to her. Chapter '
        'twelve opens two years later, married.',
  ),
  CraftEntry(
    id: 'flashback',
    family: CraftFamily.structure,
    term: 'Flashback',
    oneLine: 'Leaving the present to show something that already happened.',
    whatItDoes: 'It sets down the forward question the reader was holding, so '
        'it costs whatever that question was worth. A reader follows one '
        'gladly when the present scene has just made them need the answer, '
        'and reads the identical material as delay when it arrives before '
        'they wanted it.',
    seeAlso: ['story-narrative-prose', 'in-medias-res', 'readers-clock'],
    example: 'She opens the box. Chapter break. Fourteen pages of 1962, and '
        'the box is still open.',
  ),
  CraftEntry(
    id: 'braided-chronology',
    family: CraftFamily.structure,
    term: 'The braid',
    oneLine: 'Threads in different times, cut against each other.',
    whatItDoes: 'The reader holds two positions at once and pays a little at '
        'every switch. The cut earns that back when it says something — when '
        'the later thread answers, undercuts or ironises what the earlier one '
        'has just done — and spends it for nothing when the two merely take '
        'turns.',
    seeAlso: ['dramatic-irony', 'readers-clock', 'the-chronology-you-keep'],
    example: '1994: he refuses to sign. 1962: his father signs the identical '
        'page. Against two threads that take a chapter each and never touch.',
  ),
  CraftEntry(
    id: 'frame-narrative',
    family: CraftFamily.structure,
    term: 'The frame',
    oneLine: 'A story told inside another story.',
    whatItDoes: 'It settles two things before the inner story starts: someone '
        'survived to tell it, and they are choosing what to say. Both are '
        'usually the reason to build one — the telling becomes a character '
        'act — and occasionally the reason not to, because the first of them '
        'spends most of the suspense about whether they live.',
    seeAlso: ['suspense-and-surprise', 'reader-knowledge', 'two-readings'],
    example: '“I am going to tell you how I lost the farm, and you will have '
        'noticed I am here to tell it.”',
  ),
  CraftEntry(
    id: 'narrative-time',
    family: CraftFamily.structure,
    term: "The book's clock",
    oneLine: 'Where a thing sits in the telling, not in the world.',
    whatItDoes: 'Three clocks run under any story and they are rarely the '
        'same one: the world\'s, which a chronology records; the book\'s, '
        'where the reader arrives at the thing; and the reader\'s, which '
        'counts pages. Holding the first two apart is what lets a book move '
        'an event without losing when it happened.',
    appliesTo: ['timeline.narrativeTime'],
    seeAlso: ['story-narrative-prose', 'readers-clock', 'flashback'],
    example: 'The murder happens in 1961, is read on page 300, and the reader '
        'gets there on their fourth evening with the book.',
  ),
  CraftEntry(
    id: 'important-to-whom',
    family: CraftFamily.structure,
    term: 'Important to whom',
    oneLine: 'Weight in the world, and weight in the book.',
    whatItDoes: 'The two come apart constantly: a war that redrew the map can '
        'be scenery, and one broken promise can be the hinge everything '
        'turns on. Ranking events by what they did to the world and then '
        'building the book from the top of that list is the standard way to '
        'end up writing about the least interesting thing in it.',
    appliesTo: ['timeline.importance'],
    seeAlso: ['stakes-and-proximity', 'value-charge'],
    example: 'The partition of the county: two paragraphs. The letter he did '
        'not open: nine chapters.',
  ),
  // ---------------------------------------------------------------------
  // The book, and the series it sits in.
  //
  // Two entries for the manuscript domain's only two boxes that are decisions
  // rather than metadata. An order, a subtitle and a publication date are
  // facts about a file; a word goal and *why an entity differs in this book*
  // are choices with consequences on the page.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'length-is-a-promise',
    family: CraftFamily.structure,
    term: 'What the length promises',
    oneLine: 'A reader forms expectations from thickness before page one.',
    whatItDoes: 'A shelf and a category set a range, and a book well outside '
        'its range is read as a different kind of book: fifty thousand words '
        'of epic fantasy reads as a fragment, two hundred thousand of thriller '
        'as a slog, whatever is inside either. Setting the number early makes '
        'it a structural decision instead of something discovered at the end.',
    appliesTo: ['builtin.book.wordGoal'],
    seeAlso: ['genre-promise', 'tentpoles', 'sagging-middle'],
  ),
  CraftEntry(
    id: 'change-across-books',
    family: CraftFamily.structure,
    term: 'Different in book three',
    oneLine: 'An entity that has changed between books, and what changed it.',
    whatItDoes: 'A difference the previous book paid for reads as growth; the '
        'same difference with nothing behind it reads as the author having '
        'forgotten. Series continuity is very largely that one distinction, '
        'and the cause is the half a reader can actually check.',
    appliesTo: ['builtin.entity-state.changeReason'],
    seeAlso: [
      'text-established-invariant',
      'earned-ending',
      'the-chronology-you-keep',
    ],
  ),
];
