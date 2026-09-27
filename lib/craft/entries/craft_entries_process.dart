/// Process entries derived from `docs/research/17-plan-and-outline.md`.
///
/// Every other family here describes something a manuscript contains. This one
/// describes what a writer does, which changes what an entry can honestly say.
///
/// A prose entry is true whenever it is true — filtering puts distance between
/// a reader and a scene on a Tuesday and on a Thursday. A process entry is
/// phase-sensitive: the same observation that is useful while planning is
/// destructive mid-draft, and an entry that stated it flatly would be wrong
/// half the time it was read.
///
/// So these say when they apply, in the entry, in the author's terms. That is
/// not hedging — it is the finding. The research doc's central claim is that
/// planning and drafting are an economic trade rather than a personality, and
/// an entry that left the timing out would have dropped the argument.
library;

import '../craft_entry.dart';

/// Entries about planning, outlining and the order the work happens in.
const List<CraftEntry> kProcessEntries = [
  CraftEntry(
    id: 'where-discovery-happens',
    family: CraftFamily.process,
    term: 'Where the discovery happens',
    oneLine: 'Every writer discovers. The question is which phase pays.',
    whatItDoes: 'The same realisation — this subplot goes nowhere — costs a '
        'line in an outline, a chapter in a draft, and a structural pass in '
        'revision. Planning is not a temperament. It is a decision about '
        'where you would rather absorb that cost.',
    seeAlso: ['what-prose-teaches', 'plan-as-hypothesis', 'tentpoles'],
    example: '“The brother does not need to be in this book.” In the '
        'outline: one line deleted. In revision: nine chapters and every '
        'scene that mentions him.',
  ),
  CraftEntry(
    id: 'what-prose-teaches',
    family: CraftFamily.process,
    term: 'What only the draft can tell you',
    oneLine: 'Some things are unavailable until the scene is actually written.',
    whatItDoes: 'A voice cannot be found in an outline, because an outline '
        'has no voice in it. Two characters cannot surprise you until they '
        'have talked at length. A scene cannot be discovered to be boring '
        'until enough of it exists to bore you. This is the counterweight to '
        'planning, and it is why the exhaustively planned book can come out '
        'correct and inert.',
    seeAlso: ['where-discovery-happens', 'outline-that-is-a-draft'],
    example: 'Outline: they argue and she leaves. Draft: he apologises before '
        'she can get to the door, and the four chapters after it are now about '
        'a different pair of people.',
  ),
  CraftEntry(
    id: 'outline-as-commitment',
    family: CraftFamily.process,
    term: 'A commitment, not a summary',
    oneLine: 'An outline line you cannot fail is not doing any work.',
    whatItDoes: '"Mara confronts her father" describes a location and a cast. '
        '"Mara chooses his approval over the evidence, and now cannot go to '
        'the inspector" can be written and got wrong — which means it '
        'constrains the chapters after it. One is a note; the other is a '
        'decision.',
    seeAlso: ['value-charge', 'three-outline-questions', 'outline-in-scenes'],
    exercise: 'Read your outline one line at a time and ask of each: could I '
        'write this scene and get it wrong? Rewrite the lines where the '
        'answer is no.',
    example: '“Tomas goes to the coast.” Against: “Tomas takes the coast road '
        'because he cannot face the inquest, and misses it.”',
  ),
  CraftEntry(
    id: 'three-outline-questions',
    family: CraftFamily.process,
    term: 'The three questions a line answers',
    oneLine: 'Who wants what, what stops them, what is different after.',
    whatItDoes: 'Three clauses turn a placeholder into something you can '
        'write from. Everything else in an outline line — weather, mood, a '
        'phrase you are pleased with — is optional, and past a certain volume '
        'of it you have begun drafting somewhere prose cannot live.',
    seeAlso: ['outline-as-commitment', 'value-charge', 'scene-and-sequel'],
    example: 'She wants the ledger. Her brother has locked the office. She '
        'leaves with the key and without the brother.',
  ),
  CraftEntry(
    id: 'outline-in-scenes',
    family: CraftFamily.process,
    term: 'Scenes, not chapters',
    oneLine: 'A chapter is packaging. A scene is a story decision.',
    whatItDoes: 'Chapter breaks control where a reader is invited to stop, '
        'and that depends on lengths and tension curves that do not exist '
        'yet. Outlining into chapter slots produces two visible things: '
        'chapters padded to fill a heading, and turns crushed because the '
        'slot had room for one.',
    seeAlso: ['outline-as-commitment', 'scene-and-sequel'],
    example: 'Chapter 14: the funeral, the reading of the will, the fight in '
        'the car park, and a walk along the canal to bring it up to length.',
  ),
  CraftEntry(
    id: 'planning-backwards',
    family: CraftFamily.process,
    term: 'Planning from the ending',
    oneLine: 'From an ending a beginning follows. It does not work the other way.',
    whatItDoes: 'Know that she ends alone and unforgiven and the opening is '
        'nearly written: give her company and the expectation of forgiveness. '
        'Start from the company and she can end anywhere. Consequence '
        'constrains cause far more tightly than cause constrains consequence.',
    seeAlso: ['seven-point', 'ending-in-two-lines', 'promise-ledger'],
    example: 'Ending: he is forgiven, and cannot believe it. Opening, '
        'therefore: a man entirely certain he is owed something.',
  ),
  CraftEntry(
    id: 'ending-in-two-lines',
    family: CraftFamily.process,
    term: 'The ending, in two lines',
    oneLine: 'The last thing that happens, and what it costs.',
    whatItDoes: 'The second line is the load-bearing one, and it can be '
        'answered without deciding a single event: *she wins, and it costs '
        'her the person who taught her*. That is a complete specification of '
        'an ending with no plot in it, and for a writer who will not outline '
        'it does most of the same work.',
    seeAlso: ['planning-backwards', 'earned-ending'],
    exercise: 'Before your next chapter, write those two lines for the whole '
        'book. Do not write the events between them.',
    example: 'The dam holds. The village that fought him over it will not have '
        'him back.',
  ),
  CraftEntry(
    id: 'decided-before-drafting',
    family: CraftFamily.process,
    term: 'The expensive decisions',
    oneLine: 'The few choices that cost a whole pass to change later.',
    whatItDoes: 'Point of view, person and tense; whose story it is; the want '
        'and the need; what the opening promises; and scope. Each is cheap to '
        'settle now and expensive to move at chapter thirty, which is the '
        'entire basis for deciding anything before the draft.',
    seeAlso: ['where-discovery-happens', 'promise-ledger', 'left-open'],
    example: 'Close third, past tense, hers. Chapter thirty is where you find '
        'out you wanted his.',
  ),
  CraftEntry(
    id: 'left-open',
    family: CraftFamily.process,
    term: 'What to leave open',
    oneLine: 'Dialogue, chapter breaks, minor names, the middle\'s texture.',
    whatItDoes: 'All cheap to change and better found in the writing. '
        'Over-specifying the middle in particular forecloses exactly the '
        'discoveries that only become available once you are inside it.',
    seeAlso: ['decided-before-drafting', 'what-prose-teaches'],
    example: 'The middle, in the plan: “they are on the road a while, and '
        'something goes wrong at the border.”',
  ),
  CraftEntry(
    id: 'productive-avoidance',
    family: CraftFamily.process,
    term: 'The work that feels like planning',
    oneLine: 'Maps, glossaries and family trees, built instead of scenes.',
    whatItDoes: 'All of it is real craft, and all of it is also the most '
        'comfortable available way of not writing the book. The test is one '
        'question — which scene does this change? — and the tell is recursion '
        'without an end: research that generates more research. Planning runs '
        'out of expensive decisions. This does not.',
    seeAlso: ['iceberg-rule', 'decided-before-drafting'],
    example: 'Nine hundred words on the succession law of a country the book '
        'visits for one chapter.',
  ),
  CraftEntry(
    id: 'tentpoles',
    family: CraftFamily.process,
    term: 'Tentpoles',
    oneLine: 'Four to eight fixed scenes, and open ground between them.',
    whatItDoes: 'A deliberate half-measure, and the most-used one: the '
        'load-bearing moments are settled so the book has a shape, and the '
        'stretches between stay available for whatever the drafting finds. '
        'Choosing it on purpose is different from stopping at chapter three.',
    seeAlso: ['where-discovery-happens', 'plan-as-hypothesis'],
    example: 'Six scenes on a card: the letter, the flood, the refusal, the '
        'funeral, the confession, the last morning. Nothing between them '
        'written down.',
  ),
  CraftEntry(
    id: 'synopsis-as-outline',
    family: CraftFamily.process,
    term: 'The synopsis as a plan',
    oneLine: 'Continuous prose, one to five pages, of the whole book.',
    whatItDoes: 'Because it is prose it cannot contain a list-shaped gap: you '
        'have to write the joins, which means writing *therefore* or *but*, '
        'which runs the causality test as a side effect of the form. It is '
        'also the form most able to hide a hole behind a graceful transition.',
    seeAlso: ['therefore-but', 'outline-as-commitment'],
    example: '“…and so she takes the job, but the office is his.” Both joins '
        'had to be written down, and one of them turned out to be a lie.',
  ),
  CraftEntry(
    id: 'reverse-outline',
    family: CraftFamily.process,
    term: 'The reverse outline',
    oneLine: 'One line per scene, written from the draft you already have.',
    whatItDoes: 'Who wanted what, what stopped them, what changed — and '
        'nothing else. On one page it shows what two hundred cannot: the '
        'scenes where nothing moved, the point made three times, the thread '
        'last touched ninety pages ago. It works by changing the scale at '
        'which the book can be seen at all.',
    seeAlso: ['therefore-but', 'value-charge', 'one-pass-one-question'],
    exercise: 'Reverse-outline one act. Do not fix anything while you do it — '
        'no notes on prose, no reordering. Read the finished page whole '
        'before you touch the draft again.',
    example: 'Scene 31: she wants the address, the clerk stalls, she leaves '
        'without it. Scene 32: she wants the address, the clerk stalls, she '
        'leaves without it.',
  ),
  CraftEntry(
    id: 'plan-as-hypothesis',
    family: CraftFamily.process,
    term: 'The plan is a hypothesis',
    oneLine: 'A prediction about a book made before meeting it.',
    whatItDoes: 'It will be wrong somewhere, and that is what planning is '
        'rather than a fault in it. When the draft contradicts the plan, one '
        'of them has become right and the other has not — and deciding which '
        'is the whole job.',
    seeAlso: ['undecided-divergence', 'tentpoles'],
    example: 'The plan has the sister forgiving her at the funeral. On the '
        'page the sister does not speak, and one of the two is now describing '
        'this book.',
  ),
  CraftEntry(
    id: 'undecided-divergence',
    family: CraftFamily.process,
    term: 'Divergence left undecided',
    oneLine: 'Noticing the draft has left the plan, and writing on anyway.',
    whatItDoes: 'The plan now describes one book and the pages describe '
        'another, so everything planned afterwards is planned against a book '
        'that no longer exists. It surfaces in revision, which is where the '
        'same discovery costs the most it will ever cost.',
    seeAlso: ['plan-as-hypothesis', 'where-discovery-happens'],
    example: 'The plan still has the wedding at chapter nineteen. The draft '
        'buried the groom at chapter eleven, and chapters twenty to twenty-six '
        'were planned afterwards.',
  ),
  CraftEntry(
    id: 'act-one-four-times',
    family: CraftFamily.process,
    term: 'Act one, four times',
    oneLine: 'An opening replanned repeatedly while the ending stays one line.',
    whatItDoes: 'Openings are the most pleasant part to plan and the part '
        'planning helps least, because they are also the cheapest to rewrite '
        'later. Time spent there is usually time spent away from the ending, '
        'which is the decision the rest of the plan depends on.',
    seeAlso: ['planning-backwards', 'productive-avoidance'],
    example: 'Four openings, drafted and redrafted across six months. The '
        'ending is still the one line it was in March.',
  ),
  CraftEntry(
    id: 'outline-that-is-a-draft',
    family: CraftFamily.process,
    term: 'When the outline became a draft',
    oneLine: 'Outline lines with dialogue in them, or a rhythm you like.',
    whatItDoes: 'A signal rather than a fault: the writing has started, and '
        'it is happening in a document that cannot hold prose. The work is '
        'not wasted — it wants moving somewhere it can be continued.',
    seeAlso: ['what-prose-teaches', 'outline-as-commitment'],
    example: 'Outline, scene 9: “‘You could have told me,’ he says, and she '
        'says nothing, and the kettle is the loudest thing in the room.”',
  ),
];
