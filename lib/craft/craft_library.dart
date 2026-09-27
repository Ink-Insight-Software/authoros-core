/// The Craft Library — the entries, and the registry over them.
///
/// One source for every sentence of craft guidance AuthorOS ships. The point
/// of centralising them is stated once here and holds for everything added
/// later: **a term is explained in exactly one place**, so the helper text
/// under a field and the card on a browsable shelf cannot become two different
/// explanations of the same word.
///
/// ## What is in here, and what stays inline
///
/// An entry earns its place by having a non-obvious answer to *what does this
/// do in the story*. Where a description only restates the label — "Where you
/// intend it to land" — there is nothing to teach, and it stays as an inline
/// `description` on the field. This is the line that keeps the library from
/// becoming a dumping ground for every string in the record model.
///
/// `test/craft_library_test.dart` holds the other half of that rule: a field
/// may take its description from the library or declare one inline, never
/// both. One source per field, mechanically.
///
/// ## Flutter-free, per Lock 12
///
/// This directory imports nothing — not Flutter, not a store, not a clock,
/// not `record_types.dart`. The record types import the library, never the
/// other way round, so the dependency runs in one direction and a second shell
/// over this content needs no widget tree.
library;

import 'craft_entry.dart';
import 'entries/craft_entries_character.dart';
import 'entries/craft_entries_process.dart';
import 'entries/craft_entries_prose.dart';
import 'entries/craft_entries_structure.dart';
import 'entries/craft_entries_turns.dart';
import 'entries/craft_entries_world.dart';

/// Every entry AuthorOS ships, in the order a reader would meet them.
const List<CraftEntry> _entries = [
  // ---------------------------------------------------------------------
  // Voice and style.
  //
  // The point of view and tense entries are `narrative_voice.dart`'s own
  // words, moved rather than rewritten: that file got this right first, and
  // its comment — "the descriptions are the feature" — is the rule the whole
  // library follows. `PovMode.describe` now reads them back from here, so the
  // picker sheet and the shelf cannot drift.
  //
  // The four that follow are not attached to a field. Distance, free indirect
  // style, unreliability and register are things an author chooses in the
  // prose rather than in a form, and AuthorOS stores no field for any of them.
  // An entry with no `appliesTo` is reachable from the shelf and from nowhere
  // else, which is the honest shape for craft the model does not record.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'pov-third-limited',
    family: CraftFamily.voiceAndStyle,
    term: 'Third person limited',
    oneLine: 'Stays inside one character.',
    whatItDoes: 'The reader learns what they learn, when they learn it.',
    appliesTo: ['manuscript.pov.thirdLimited'],
    seeAlso: ['narrative-distance', 'free-indirect-style'],
    exercise: 'Take a scene with two people in it and write half a page from '
        'inside one of them, then the same half page from inside the other. '
        'Then list the facts you had to withhold each time.',
    example: '“She could not tell whether he believed her.” The doubt is '
        'hers, and the reader is given no more than she has.',
  ),
  CraftEntry(
    id: 'pov-third-objective',
    family: CraftFamily.voiceAndStyle,
    term: 'Third person objective',
    oneLine: 'Reports what a camera would see.',
    whatItDoes: 'Speech and action, and no thoughts at all.',
    appliesTo: ['manuscript.pov.thirdObjective'],
    seeAlso: ['narrative-distance'],
    exercise: 'Write a page using only what a camera and a microphone would catch '
        '— no thoughts, nothing named as a feeling. Then read it back and '
        'list what a reader still infers.',
    example: '“He set the glass down. He did not pick it up again.” No word '
        'for what he felt, and the reader supplies one.',
  ),
  CraftEntry(
    id: 'pov-third-omniscient',
    family: CraftFamily.voiceAndStyle,
    term: 'Third person omniscient',
    oneLine: 'Moves between minds freely.',
    whatItDoes: 'The narrator knows more than anyone in the room.',
    appliesTo: ['manuscript.pov.thirdOmniscient'],
    seeAlso: ['reader-knowledge', 'narrative-distance'],
    exercise: 'Take a finished scene and add one sentence no character in it '
        'could know. Read it before and after, and listen for what the '
        'narrator just became.',
    example: '“Neither of them knew the letter had already been burned.” A '
        'fact standing above the room, available to nobody in it.',
  ),
  CraftEntry(
    id: 'pov-first',
    family: CraftFamily.voiceAndStyle,
    term: 'First person',
    oneLine: 'The character tells it themselves.',
    whatItDoes: 'Closer, and unreliable in whatever way they are.',
    appliesTo: ['manuscript.pov.first'],
    seeAlso: ['unreliable-narrator'],
    exercise: 'Take a paragraph written in third person and move it to first. The '
        'facts stay the same; watch which of them start sounding like '
        'opinions.',
    example: '“I told her I did not mind.” It reports what was said, and '
        'quietly raises the question of whether it was true.',
  ),
  CraftEntry(
    id: 'pov-second',
    family: CraftFamily.voiceAndStyle,
    term: 'Second person',
    oneLine: 'Makes the reader "you".',
    whatItDoes: 'Insistent, and difficult to hold for a whole book.',
    appliesTo: ['manuscript.pov.second'],
    exercise: 'Write half a page in second person and read it aloud. Mark the '
        'exact line where the insistence starts working against you.',
    example: '“You check the lock twice. You knew it was locked the first '
        'time.” The reader is inside a habit before agreeing to have '
        'one.',
  ),
  CraftEntry(
    id: 'tense-past',
    family: CraftFamily.voiceAndStyle,
    term: 'Past tense',
    oneLine: 'The usual choice.',
    whatItDoes: 'What happened is settled, and the telling stands a little '
        'apart from it.',
    appliesTo: ['manuscript.tense.past'],
    exercise: 'Take a present-tense page and move it to past, changing nothing '
        'else. Read both aloud and listen for what happens to the sense of '
        'an outcome already settled.',
    example: '“The bridge held.” Settled, and told by somebody who reached '
        'the other side.',
  ),
  CraftEntry(
    id: 'tense-present',
    family: CraftFamily.voiceAndStyle,
    term: 'Present tense',
    oneLine: 'Happening now.',
    whatItDoes: 'Immediate, and it leaves the narrator nowhere to stand '
        'outside the scene.',
    appliesTo: ['manuscript.tense.present'],
    exercise: 'Take a past-tense page and move it to present, changing nothing '
        'else. Read both and notice which one makes you want to hurry.',
    example: '“The bridge holds.” Nothing yet promises it will still be '
        'holding a paragraph from now.',
  ),
  CraftEntry(
    id: 'tense-future',
    family: CraftFamily.voiceAndStyle,
    term: 'Future tense',
    oneLine: 'Unusual on purpose — a prophecy, a plan, a warning.',
    whatItDoes: 'Rarely held for long.',
    appliesTo: ['manuscript.tense.future'],
    example: '“You will not remember any of this by morning.” A narrator '
        'standing past the event and telling it forward.',
  ),
  CraftEntry(
    id: 'narrative-distance',
    family: CraftFamily.voiceAndStyle,
    term: 'Narrative distance',
    oneLine: "How far the telling stands from the character's mind.",
    whatItDoes: 'A dial rather than a switch: the same scene can open wide on '
        'a town and close to a single thought three sentences later. Moving '
        'it a long way in one step is what makes prose feel like it jumped.',
    seeAlso: ['pov-third-limited', 'free-indirect-style'],
    exercise: 'Read a page of your own and mark each sentence far, middle or '
        'close. Look for the places the mark jumps two rungs in a single '
        'step.',
    example: '“It was winter.” · “The cold got into the house.” · “Christ, '
        'the cold.” Three rungs, one paragraph.',
  ),
  CraftEntry(
    id: 'free-indirect-style',
    family: CraftFamily.voiceAndStyle,
    term: 'Free indirect style',
    oneLine:
        "Narration that takes on a character's voice without quoting their "
        'thoughts.',
    whatItDoes: 'Lets a third-person page think in a character\'s own words, '
        'which is how close third gets first person\'s intimacy while keeping '
        'the room to step back out again.',
    seeAlso: ['pov-third-limited', 'narrative-distance'],
    exercise: 'Take a line of interior monologue in italics or quotation marks '
        'and rewrite it as narration in the character\'s own idiom, marks '
        'dropped. Read the paragraph around it and hear whether the voice '
        'held.',
    example: '“He would ring tomorrow. Definitely tomorrow.” No quotation '
        'marks and no *he thought*, and the second sentence is entirely '
        'his.',
  ),
  CraftEntry(
    id: 'unreliable-narrator',
    family: CraftFamily.voiceAndStyle,
    term: 'Unreliable narrator',
    oneLine: 'A narrator the reader learns to read against.',
    whatItDoes: 'It works only once the reader has some way to check them — '
        'an unreliability that nothing in the book contradicts reads as the '
        'author having got it wrong.',
    seeAlso: ['pov-first', 'reader-knowledge'],
    exercise: 'Write half a page in which the narrator states something the scene '
        'around them quietly contradicts. Give the reader both and nothing '
        'else.',
    example: '“I barely touched him.” Said in a room where everyone else has '
        'gone quiet.',
  ),
  CraftEntry(
    id: 'register',
    family: CraftFamily.voiceAndStyle,
    term: 'Register',
    oneLine: 'The level the prose speaks at — plain, formal, ornate, '
        'vernacular.',
    whatItDoes: 'Readers notice a change in it faster than almost anything '
        'else on the page, which is what makes an unintended shift read as a '
        'slip and a deliberate one read as a signal.',
    seeAlso: ['narrative-distance'],
    exercise: 'Take a paragraph and write it twice more — once in the plainest '
        'words you have, once in the most formal. Read all three in a row.',
    example: '“We regret to inform you” against “I have to tell you '
        'something.” The same news, at two distances from the person '
        'hearing it.',
  ),

  // ---------------------------------------------------------------------
  // Turns — the seven kinds of turning point, and the shapes of conflict.
  //
  // These explain *options*, not fields, and their `appliesTo` keys carry a
  // `#value` suffix. The field model gained somewhere to put them in the same
  // change that added these entries: `RecordFieldDefinition.options` is a
  // `List<String>`, so until then a field could offer "reversal / crisis /
  // climax" and had nowhere to say what any of them was.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'turn-inciting-incident',
    family: CraftFamily.turns,
    term: 'Inciting incident',
    oneLine: 'The thing that makes the rest of the book necessary.',
    whatItDoes: 'Before it the character could have gone on as they were, and '
        'after it they cannot. That is the whole test of one.',
    appliesTo: ['plot.turning-point.turningPointType#inciting-incident'],
    seeAlso: ['turn-first-major-decision'],
    exercise: 'Name the last page on which your protagonist could still have '
        'walked away and had the same life afterwards. Count the pages before '
        'it.',
    example: 'The letter is on the mat when she gets in. Everything she was '
        'going to do that week is now not going to happen.',
  ),
  CraftEntry(
    id: 'turn-first-major-decision',
    family: CraftFamily.turns,
    term: 'First major decision',
    oneLine: 'The first time the character chooses rather than reacts.',
    whatItDoes: 'It converts a person things are happening to into a person '
        'driving, which is usually where a reader stops watching and starts '
        'following.',
    appliesTo: ['plot.turning-point.turningPointType#first-major-decision'],
    seeAlso: ['turn-inciting-incident', 'external-want'],
    exercise: 'Read your first four chapters and mark each place your '
        'protagonist chooses rather than responds. Find the first mark, and '
        'count the pages before it.',
    example: 'For eleven chapters things happen to him. In chapter twelve he '
        'gets on the wrong train on purpose.',
  ),
  CraftEntry(
    id: 'turn-midpoint',
    family: CraftFamily.turns,
    term: 'Midpoint',
    oneLine: 'A turn near the centre that changes what the story is about.',
    whatItDoes: 'Often where the want and the need stop pointing the same way, '
        'so the second half costs what the first half did not.',
    appliesTo: ['plot.turning-point.turningPointType#midpoint'],
    seeAlso: ['external-want', 'internal-need'],
    exercise: 'Write your protagonist\'s want and their need as two sentences, '
        'then find the page where following one begins to cost them the other.',
    example: 'Page 190 of 380: the man he has been chasing was sent by his own '
        'side.',
  ),
  CraftEntry(
    id: 'turn-reversal',
    family: CraftFamily.turns,
    term: 'Reversal',
    oneLine: 'A turn that inverts the situation rather than advancing it.',
    whatItDoes: 'What looked like a win is a loss, or the ally was the threat. '
        'It re-reads what came before, so it lands hardest where the earlier '
        'pages were honest and merely incomplete.',
    appliesTo: ['plot.turning-point.turningPointType#reversal'],
    seeAlso: ['reader-knowledge', 'plant'],
    exercise: 'Take your largest reversal and reread the twenty pages before '
        'it. List what those pages withheld, and separately what they had no '
        'reason to mention yet.',
    example: 'She wins the case. In the corridor afterwards her client thanks '
        'her, and she understands that he did it.',
  ),
  CraftEntry(
    id: 'turn-crisis',
    family: CraftFamily.turns,
    term: 'Crisis',
    oneLine: 'The choice with no option that costs nothing.',
    whatItDoes: 'It is the decision the book has been arranging, and its job '
        'is to force the character to say what they actually value by giving '
        'something else up.',
    appliesTo: ['plot.turning-point.turningPointType#crisis'],
    seeAlso: ['internal-conflict', 'turn-climax'],
    exercise: 'Write the two things your protagonist cannot both keep, one '
        'line each. Then look for a third way out that is still open to them '
        'on the page, and name it if there is one.',
    example: 'The boat holds four. There are five of them, and the tide is '
        'coming in.',
  ),
  CraftEntry(
    id: 'turn-climax',
    family: CraftFamily.turns,
    term: 'Climax',
    oneLine: 'Where the crisis is acted on and the outcome settles.',
    whatItDoes: 'The crisis is the choosing and this is the paying, which is '
        'why a climax that arrives without one reads as an event rather than '
        'as an ending.',
    appliesTo: ['plot.turning-point.turningPointType#climax'],
    seeAlso: ['turn-crisis', 'turn-resolution'],
    exercise: 'Read your climax and name the decision it pays for. Find the '
        'page where that decision was made, and count the distance between '
        'them.',
    example: 'He puts the child in the boat and steps back from it.',
  ),
  CraftEntry(
    id: 'turn-resolution',
    family: CraftFamily.turns,
    term: 'Resolution',
    oneLine: 'What the world looks like once the outcome has settled.',
    whatItDoes: 'It is where the reader finds out what the story cost, and it '
        'is the only place a book can answer the questions it raised but did '
        'not resolve in the climax.',
    appliesTo: ['plot.turning-point.turningPointType#resolution'],
    seeAlso: ['turn-climax'],
    exercise: 'List every question the book raised that the climax did not '
        'settle. Read your last chapter with the list beside you.',
    example: 'Two years on, the shop has her name over the door and her '
        'brother\'s furniture in it, and they do not speak.',
  ),
  CraftEntry(
    id: 'conflict-vs-self',
    family: CraftFamily.turns,
    term: 'Character versus self',
    oneLine: 'The opposition is inside the character.',
    whatItDoes: 'Nothing outside can settle it, so it needs an external '
        'situation that forces the internal question to be answered out loud.',
    appliesTo: ['plot.conflict.conflictType#character-vs-self'],
    seeAlso: ['internal-conflict', 'false-belief'],
    exercise: 'Write the scene where your character has to say the thing they '
        'have been avoiding, and put someone in the room who will not let them '
        'leave.',
    example: 'Nobody is stopping him. The letter has been written for a month '
        'and is in the drawer.',
  ),
  CraftEntry(
    id: 'conflict-vs-character',
    family: CraftFamily.turns,
    term: 'Character versus character',
    oneLine: 'A person wants something incompatible with what another wants.',
    whatItDoes: 'The sharpest version is two people who are both right, '
        'because then the reader cannot resolve it by picking a side.',
    appliesTo: ['plot.conflict.conflictType#character-vs-character'],
    seeAlso: ['external-conflict'],
    exercise: 'Write half a page from inside your antagonist on the day they '
        'decided, giving them the reason they would give.',
    example: 'She needs the north field for the herd. He needs it for the '
        'road. There is one field.',
  ),
  CraftEntry(
    id: 'conflict-vs-society',
    family: CraftFamily.turns,
    term: 'Character versus society',
    oneLine: 'The opposition is what everyone else agrees is normal.',
    whatItDoes: 'It has no single opponent to defeat, so it tends to resolve '
        'by the character changing their place in the world rather than the '
        'world changing.',
    appliesTo: ['plot.conflict.conflictType#character-vs-society'],
    seeAlso: ['conflict-vs-system'],
    exercise: 'Name the ordinary thing everyone in your book agrees on and '
        'your character cannot. Then write what it costs to say so at a table '
        'of six.',
    example: 'The village is not cruel to her. It simply stops including her, '
        'at roughly one invitation a month.',
  ),
  CraftEntry(
    id: 'conflict-vs-nature',
    family: CraftFamily.turns,
    term: 'Character versus nature',
    oneLine: 'The opposition has no intent.',
    whatItDoes: 'A storm cannot be persuaded, bargained with, or made to '
        'regret anything, which throws the whole weight of the story onto how '
        'the character responds.',
    appliesTo: ['plot.conflict.conflictType#character-vs-nature'],
    exercise: 'Take a scene where the weather or the country opposes your '
        'character and cut every word that hands it a motive. Read what '
        'carries the tension after the cut.',
    example: 'The river does not know the child is on the other side, and '
        'rises anyway.',
  ),
  CraftEntry(
    id: 'conflict-vs-system',
    family: CraftFamily.turns,
    term: 'Character versus system',
    oneLine: 'The opposition is a machine of rules rather than a person.',
    whatItDoes: 'Everyone inside it may be reasonable and the outcome still '
        'crushing, which is what distinguishes it from an antagonist who '
        'happens to hold an office.',
    appliesTo: ['plot.conflict.conflictType#character-vs-system'],
    seeAlso: ['conflict-vs-society'],
    exercise: 'Write the clerk who turns your character away, and give them a '
        'reason a decent person would accept. Then write what happens anyway.',
    example: 'Form 11B requires the registrar\'s signature. The registrar '
        'signs Form 11B on receipt of Form 11B.',
  ),
  CraftEntry(
    id: 'conflict-vs-supernatural',
    family: CraftFamily.turns,
    term: 'Character versus supernatural',
    oneLine: 'The opposition works by rules the ordinary world does not have.',
    whatItDoes: 'It stays tense only while its rules are consistent — a force '
        'that can do anything cannot be resisted interestingly, so what it '
        'cannot do is the part worth deciding first.',
    appliesTo: ['plot.conflict.conflictType#character-vs-supernatural'],
    seeAlso: ['deus-ex-machina'],
    exercise: 'List three things your supernatural force cannot do, and the '
        'price of each thing it can. Keep the list beside you while you draft.',
    example: 'It cannot cross running water and it cannot be lied to. The '
        'bridge is out.',
  ),
  CraftEntry(
    id: 'conflict-vs-faction',
    family: CraftFamily.turns,
    term: 'Character versus faction',
    oneLine: 'The opposition is an organised group with its own aims.',
    whatItDoes: 'Unlike a society it can be negotiated with and can change its '
        'mind, which makes it the shape that produces alliances rather than '
        'only obstacles.',
    appliesTo: ['plot.conflict.conflictType#character-vs-faction'],
    exercise: 'Name something your faction wants that has nothing to do with '
        'your protagonist. Then write the offer they would take.',
    example: 'The Guild will drop the charge for the harbour rights. They '
        'would genuinely rather have the harbour rights.',
  ),
  CraftEntry(
    id: 'conflict-vs-world',
    family: CraftFamily.turns,
    term: 'Character versus world',
    oneLine: 'The opposition is the way things fundamentally are.',
    whatItDoes: 'The largest scale and the hardest to keep personal: it needs '
        'one concrete thing the character can lose, or the reader has nothing '
        'to hold on to.',
    appliesTo: ['plot.conflict.conflictType#character-vs-world'],
    exercise: 'Name the one small thing your character stands to lose that a '
        'reader can picture. Write the scene where it is nearly lost, early '
        'on.',
    example: 'Nobody did this to them. The seam ran out, and there was never '
        'going to be another one.',
  ),

  // ---------------------------------------------------------------------
  // Stakes — the nine scales, and the thing they are usually got wrong about.
  //
  // Bigger is not better, and almost every entry below is some version of
  // saying so. A threat to everybody is a threat to nobody in particular; a
  // threat to one person the reader has been given a reason to care about is
  // the one that works. The field offered these nine and said nothing.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'stake-personal',
    family: CraftFamily.stakes,
    term: 'Personal',
    oneLine: 'What one person stands to lose.',
    whatItDoes: 'The smallest scale and the one readers feel most reliably, '
        'because it needs no explaining — they already know what losing '
        'something of your own is like.',
    appliesTo: ['plot.stake.stakeType#personal'],
    seeAlso: ['stake-world'],
    exercise: 'Write the sentence that says what this character loses if they '
        'fail, in words only they would use. If it runs past one sentence, '
        'the stake is still abstract.',
    example: '“She could lose the argument.” Against: “She could lose the shop '
        'her father left her.”',
  ),
  CraftEntry(
    id: 'stake-emotional',
    family: CraftFamily.stakes,
    term: 'Emotional',
    oneLine: 'What it would cost them to feel it.',
    whatItDoes: 'Runs underneath the others: a scene can be safe in every '
        'other way and still be the hardest one in the book.',
    appliesTo: ['plot.stake.stakeType#emotional'],
    seeAlso: ['core-wound', 'defences'],
    example: 'Nobody draws a weapon. He sits down opposite her and says the '
        'sentence he has been rehearsing for eleven years.',
  ),
  CraftEntry(
    id: 'stake-relationship',
    family: CraftFamily.stakes,
    term: 'Relationship',
    oneLine: 'What is between two people, and what breaking it would cost.',
    whatItDoes: 'It raises the price of every scene those two share, because '
        'the reader is watching two things at once — what is happening, and '
        'what it is doing to them.',
    appliesTo: ['plot.stake.stakeType#relationship'],
    seeAlso: ['emotional-needs'],
    exercise: 'Name the thing these two could say to each other that could not be '
        'taken back. Write the scene up to the moment before it.',
    example: 'They both come out of the fire alive. Afterwards she knows he '
        'went back for the dog first.',
  ),
  CraftEntry(
    id: 'stake-physical',
    family: CraftFamily.stakes,
    term: 'Physical',
    oneLine: 'Injury, survival, the body.',
    whatItDoes: 'The most immediate and the weakest on its own: a threat to a '
        'body means little where the reader has not yet been given a reason to '
        'want that body to keep going.',
    appliesTo: ['plot.stake.stakeType#physical'],
    seeAlso: ['stake-personal'],
    example: 'A stranger bleeds out on the platform in chapter one. In chapter '
        'nine, the same wound, on the man who taught her to drive.',
  ),
  CraftEntry(
    id: 'stake-moral',
    family: CraftFamily.stakes,
    term: 'Moral',
    oneLine: 'What they would have to become in order to win.',
    whatItDoes: 'The stake that makes a victory ambiguous, and the only one '
        'that can let a character lose by succeeding.',
    appliesTo: ['plot.stake.stakeType#moral'],
    seeAlso: ['internal-conflict', 'turn-crisis'],
    exercise: 'Describe the choice in two sentences, one from each side, so both '
        'sound reasonable. If one of them was easy to write, the moral '
        'stake is thinner than it looked.',
    example: 'He can get them all out tonight. He needs only to sign the list '
        'of who stays.',
  ),
  CraftEntry(
    id: 'stake-political',
    family: CraftFamily.stakes,
    term: 'Political',
    oneLine: 'Power, position, and who gets to decide.',
    whatItDoes: 'Abstract until it is attached to somebody: readers follow a '
        'throne through whoever wants it, not through the throne.',
    appliesTo: ['plot.stake.stakeType#political'],
    seeAlso: ['conflict-vs-system'],
    example: '“The succession is disputed.” Against: “Whoever sits there by '
        'spring decides whether her village pays the tithe twice.”',
  ),
  CraftEntry(
    id: 'stake-social',
    family: CraftFamily.stakes,
    term: 'Social',
    oneLine: 'Standing, reputation, belonging.',
    whatItDoes: 'Easy to dismiss and hard to live with — a character who '
        'cannot go home again has lost something a reader recognises without '
        'being told how large it is.',
    appliesTo: ['plot.stake.stakeType#social'],
    seeAlso: ['conflict-vs-society'],
    example: 'Nothing happens to her. She simply cannot sit at that table '
        'again, and everyone still at it knows why.',
  ),
  CraftEntry(
    id: 'stake-world',
    family: CraftFamily.stakes,
    term: 'World',
    oneLine: 'What happens to everybody.',
    whatItDoes: 'The largest scale and the one that most often flattens '
        'tension, because a threat to everyone is a threat to nobody in '
        'particular. It works where somebody the reader knows is standing '
        'inside it.',
    appliesTo: ['plot.stake.stakeType#world'],
    seeAlso: ['stake-personal', 'conflict-vs-world'],
    exercise: 'Take the threat to everyone and name a single house on a single '
        'street it reaches. Describe what is on the kitchen table.',
    example: '“Ten million people will die.” Against: “Ten million people will '
        'die, and one of them taught him to swim.”',
  ),
  CraftEntry(
    id: 'stake-existential',
    family: CraftFamily.stakes,
    term: 'Existential',
    oneLine: 'Whether any of it means anything.',
    whatItDoes: 'The stake underneath the others when a story is asking why '
        'the character goes on at all. It cannot be settled by '
        'winning, which is what makes it the hardest to resolve.',
    appliesTo: ['plot.stake.stakeType#existential'],
    seeAlso: ['internal-need', 'false-belief'],
    exercise: 'Write down the belief this character would have to give up in '
        'order to survive the book, in their own words.',
    example: 'He wins. He sits down on the step outside and cannot think of a '
        'reason to get up again.',
  ),

  // ---------------------------------------------------------------------
  // Knowledge status — the same machinery the reveal type is built on.
  //
  // A record's knowledge status is not filing. It is the difference between
  // what is true, what somebody believes, and what the reader has been told,
  // which is where suspense, dramatic irony and every fair reveal come from.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'knowledge-confirmed',
    family: CraftFamily.turns,
    term: 'Confirmed',
    oneLine: 'Established as true in the world of the book.',
    whatItDoes: 'What the story can build on without qualifying it, and what a '
        'later reveal has to work against rather than merely add to.',
    appliesTo: ['builtin.general-lore.knowledgeStatus#Confirmed'],
    seeAlso: ['knowledge-suspected'],
    example: 'The bridge went in the spring of 1943. The book is not going to '
        'take that back.',
  ),
  CraftEntry(
    id: 'knowledge-suspected',
    family: CraftFamily.turns,
    term: 'Suspected',
    oneLine: 'Believed by someone, and not established.',
    whatItDoes: 'Worth recording apart from what is true, because the gap '
        'between the two is where a character makes a mistake the reader can '
        'watch coming.',
    appliesTo: ['builtin.general-lore.knowledgeStatus#Suspected'],
    seeAlso: ['reader-knowledge', 'knowledge-false'],
    example: 'Mara is certain her brother signed it. The book has not said '
        'whether he did.',
  ),
  CraftEntry(
    id: 'knowledge-rumoured',
    family: CraftFamily.turns,
    term: 'Rumoured',
    oneLine: 'In circulation, with nobody standing behind it.',
    whatItDoes: 'Useful precisely because it may be wrong: a rumour puts an '
        'idea in the reader\'s head without the book committing to it.',
    appliesTo: ['builtin.general-lore.knowledgeStatus#Rumoured'],
    seeAlso: ['red-herring'],
    example: 'They say the doctor left over a girl in Cork. Everyone has heard '
        'it and nobody heard it from anybody.',
  ),
  CraftEntry(
    id: 'knowledge-false',
    family: CraftFamily.turns,
    term: 'False',
    oneLine: 'Recorded as believed, and untrue.',
    whatItDoes: 'The status doing work rather than filing: it marks the thing '
        'a character is wrong about, which is what a reveal later corrects and '
        'what an author needs to keep straight while writing them wrong.',
    appliesTo: ['builtin.general-lore.knowledgeStatus#False'],
    seeAlso: ['false-belief', 'revealed-information'],
    example: 'Recorded: the fire started in the kitchen. It did not, and she '
        'acts on it for two hundred pages.',
  ),
  CraftEntry(
    id: 'knowledge-secret',
    family: CraftFamily.turns,
    term: 'Secret',
    oneLine: 'True, and known to few.',
    whatItDoes: 'Naming who holds it is what turns a fact into a scene: '
        'somebody finds out, or the keeping of it costs something.',
    appliesTo: ['builtin.general-lore.knowledgeStatus#Secret'],
    seeAlso: ['secrets', 'reveal-secret'],
    example: 'He is her father. Three people know, and one of them is dead.',
  ),
  CraftEntry(
    id: 'knowledge-revealed',
    family: CraftFamily.turns,
    term: 'Revealed',
    oneLine: 'Was a secret, and is not one any more.',
    whatItDoes: 'Worth marking because the tension a secret carried does not '
        'survive it, and a book that forgets a thing is out keeps playing a '
        'card it has already spent.',
    appliesTo: ['builtin.general-lore.knowledgeStatus#Revealed'],
    seeAlso: ['knowledge-secret', 'actual-reveal-point'],
    example: 'Chapter twenty-two: it is out. The card the book has been '
        'holding since chapter three cannot be played twice.',
  ),

  // ---------------------------------------------------------------------
  // Tropes.
  //
  // The editorial stance is **descriptive**, decided in
  // `docs/craft-library-design.md` §7.1: what the convention is, what a reader
  // arrives expecting, and what departing from it costs. No entry says a
  // convention is tired, overused or beneath anyone.
  //
  // The reason is the same one that governs the rest of the library. A tool
  // that will not tell an author their midpoint is late has no business
  // telling them their trope is exhausted — that is a verdict on writing the
  // library has not read, dressed as reference. Lock 7 again: presets
  // configure, they never restrict.
  //
  // Two consequences worth naming, because they look like omissions:
  //
  // 1. **No named critiques.** The terms this field uses for patterns it
  //    objects to are arguments, not techniques, and an entry that repeated
  //    one descriptively would be taking a side while pretending not to. The
  //    conventions below are the ones an author is deciding whether to use.
  // 2. **No branded beat sheets** (§7.2). Describing a proprietary structure
  //    by name is ordinary commentary; reproducing its coined beats in order
  //    is reproducing the expressive part, and at least one is a live
  //    trademark. What is here is older and unowned.
  //
  // Nine of the twelve carry an `assertOn` subject — they are the applied
  // lens's vocabulary, offered on a record for the author to claim. The three
  // that do not are *trope* (the name of the category), *the genre promise* (a
  // property of a whole book, which no single record carries) and *deus ex
  // machina* (a reading of an ending rather than a technique anyone sets out
  // to use; offering it as a checkbox would be the library grading a draft it
  // has not read, which is Lock 7 again).
  //
  // Five of the nine are claimable on a character as well as on a unit of
  // story, and the test is the entry's own words rather than a feeling about
  // the term. *A character singled out by prophecy* and *one character
  // positioned between two possible attachments* are about people and read
  // true on a character sheet. *Opening in the middle of something already
  // happening* is about a book and does not. *Chekhov's gun* is the near miss
  // that decides the rule: a character introduced to matter later is real
  // enough, but the entry says **a detail**, and stretching an explanation to
  // fit a second surface is how one term quietly becomes two.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'trope',
    family: CraftFamily.tropes,
    term: 'Trope',
    oneLine: 'A pattern readers have met before and recognise on sight.',
    whatItDoes: 'Not a fault, and not a compliment — it is shorthand. A reader '
        'who recognises one arrives already carrying expectations, which is '
        'work the page no longer has to do and a debt the page now owes.',
    seeAlso: ['genre-promise', 'subversion'],
    exercise: 'List five conventions your genre uses that a reader would notice '
        'were absent. Mark which ones your book is currently keeping.',
    example: 'The mentor dies at the end of the first act. The reader knew at '
        'the third scene, and read the third scene differently for it.',
  ),
  CraftEntry(
    id: 'genre-promise',
    family: CraftFamily.tropes,
    term: 'The genre promise',
    oneLine: 'What a reader believes they picked the book up for.',
    whatItDoes: 'It is made by the cover, the first page and the shelf the '
        'book sits on, long before any of it is written down. Most of what '
        'reads as a broken book is a kept story and a broken promise.',
    // The blurb boxes are where the promise is actually written down, at two
    // scales: one book, and the shape of a series. It stays out of the applied
    // lens for the reason it explains a blurb so well — it is a property of a
    // whole book, which is a thing to state once and not a checkbox on a scene.
    appliesTo: ['builtin.book.blurb', 'builtin.series.blurb'],
    seeAlso: ['trope', 'subversion'],
    exercise: 'Write the sentence a reader would use to describe your book to a '
        'friend. Then read your first chapter and find where it makes that '
        'promise.',
    example: '“A body in a locked room, and a detective who drinks.” Four '
        'hundred pages later the killer is never named.',
  ),
  CraftEntry(
    id: 'subversion',
    family: CraftFamily.tropes,
    term: 'Subversion',
    oneLine: 'Setting a convention up and then not paying it as expected.',
    whatItDoes: 'It costs the convention to buy the surprise, so it lands only '
        'on a reader who knew the convention was there. Subverting something '
        'the reader never expected reads as nothing happening.',
    seeAlso: ['trope', 'genre-promise', 'reader-knowledge'],
    exercise: 'Take a convention your book sets up and write both endings — the '
        'one the reader expects, and yours. Read them in a row and count '
        'what the second one spends.',
    assertOn: {CraftSubject.plot, CraftSubject.character},
    example: 'The prophecy is read out in full. The chosen one thanks them for '
        'their trouble and goes home.',
  ),
  CraftEntry(
    id: 'chekhovs-gun',
    family: CraftFamily.tropes,
    term: "Chekhov's gun",
    oneLine: 'A detail placed deliberately enough that a reader files it away.',
    whatItDoes: 'Attention is the cost: anything given weight on the page has '
        'borrowed some, and the reader is waiting to be paid back. A detail '
        'that never pays reads as a loose end rather than as scenery.',
    seeAlso: ['plant', 'payoff', 'red-herring'],
    assertOn: {CraftSubject.plot},
    example: 'Chapter two: the drawer sticks, and there is a revolver under '
        'the napkins. Chapter nine: the drawer sticks.',
  ),
  CraftEntry(
    id: 'red-herring',
    family: CraftFamily.tropes,
    term: 'Red herring',
    oneLine: 'A plant meant to be believed and meant to be wrong.',
    whatItDoes: 'It works on fairness: the reader has to be able to look back '
        'and see they were misled rather than lied to. One that could not have '
        'been seen through reads as the book keeping a secret badly.',
    seeAlso: ['chekhovs-gun', 'plant', 'reader-knowledge'],
    exercise: 'Read a false lead in your draft and name the second job it does. A '
        'clue that is only a clue is a scene the reader paid for twice.',
    assertOn: {CraftSubject.plot, CraftSubject.character},
    example: 'The gardener has mud on his boots, no alibi, and a reason. He '
        'also has a daughter he was walking home, which nobody thinks to ask '
        'about until afterwards.',
  ),
  CraftEntry(
    id: 'deus-ex-machina',
    family: CraftFamily.tropes,
    term: 'Deus ex machina',
    oneLine: 'A resolution arriving from outside what the story established.',
    whatItDoes: 'Readers take it where the book has been about forces larger '
        'than anyone in it, and feel cheated where the book has been about '
        'what its characters chose — the same ending, read two ways, '
        'depending on what the story spent its pages on.',
    seeAlso: ['revealed-by', 'payoff'],
    exercise: 'Read your last chapter and name where each thing used to solve it '
        'first appeared. Whatever first appears there is what a reader will '
        'feel.',
    example: 'The siege breaks because a river the book has not mentioned '
        'floods overnight.',
  ),
  CraftEntry(
    id: 'in-medias-res',
    family: CraftFamily.tropes,
    term: 'In medias res',
    oneLine: 'Opening in the middle of something already happening.',
    whatItDoes: 'Buys momentum against comprehension: the reader is pulled in '
        'before they know who to care about, and the book then owes them that '
        'context soon enough that the pull does not turn into confusion.',
    seeAlso: ['genre-promise'],
    exercise: 'Take your opening scene and start it three paragraphs later. Read '
        'what went, and whether the reader needed it yet.',
    assertOn: {CraftSubject.plot},
    example: '“Get down,” she said, and he did, and only afterwards wondered '
        'who she was.',
  ),
  CraftEntry(
    id: 'cliffhanger',
    family: CraftFamily.tropes,
    term: 'Cliffhanger',
    oneLine: 'Ending a unit of the story mid-danger or mid-question.',
    whatItDoes: 'It borrows against the next chapter. Readers forgive it when '
        'the next chapter pays promptly, and start skimming ahead when the '
        'answer is repeatedly deferred.',
    seeAlso: ['ticking-clock'],
    exercise: 'Read your chapter endings one after another, ignoring everything '
        'between them, and name the ones that make you turn the page.',
    assertOn: {CraftSubject.plot},
    example: 'It had been locked every night for nine years. It was not locked '
        'now. — end of chapter',
  ),
  CraftEntry(
    id: 'ticking-clock',
    family: CraftFamily.tropes,
    term: 'Ticking clock',
    oneLine: 'A deadline the characters and the reader can both count down.',
    whatItDoes: 'Turns a scene about whether something will happen into a '
        'scene about whether it will happen in time, which is the cheapest '
        'reliable way to make waiting tense. It also fixes the pace, and a '
        'clock the book quietly stops winding is one the reader notices.',
    seeAlso: ['cliffhanger'],
    exercise: 'Write the deadline as a date and the cost of missing it in one '
        'line. Then find the last scene where the reader heard about '
        'either.',
    assertOn: {CraftSubject.plot},
    example: 'The tide turns at four. It is half past one, and the causeway is '
        'already wet.',
  ),
  CraftEntry(
    id: 'chosen-one',
    family: CraftFamily.tropes,
    term: 'The chosen one',
    oneLine: 'A character singled out by prophecy, birth or destiny.',
    whatItDoes: 'Buys scale and inevitability at the price of agency — a '
        'character who was always going to win is harder to worry about — so '
        'books built on it tend to spend their tension on whether the chosen '
        'one wants it, or on what winning costs.',
    seeAlso: ['trope', 'external-want'],
    exercise: 'Write the version where the prophecy turns out to be false, '
        'and read what your protagonist does next.',
    assertOn: {CraftSubject.plot, CraftSubject.character},
    example: 'The prophecy names him. It does not say he agreed, and he keeps '
        'not agreeing for two hundred pages.',
  ),
  CraftEntry(
    id: 'enemies-to-lovers',
    family: CraftFamily.tropes,
    term: 'Enemies to lovers',
    oneLine: 'Antagonism that becomes attraction over the length of a story.',
    whatItDoes: 'The engine is the reason they are enemies, not the enmity '
        'itself: a grievance a conversation would settle gives the arc nowhere '
        'to go, and one that genuinely cannot be settled makes the turn cost '
        'something.',
    seeAlso: ['emotional-needs', 'external-conflict'],
    exercise: 'Name the thing each of them is right about in the argument that '
        'opens the book.',
    assertOn: {CraftSubject.plot, CraftSubject.character},
    example: '“You were right about the bridge,” he said, and it cost him more '
        'than the bridge had.',
  ),
  CraftEntry(
    id: 'love-triangle',
    family: CraftFamily.tropes,
    term: 'Love triangle',
    oneLine: 'One character positioned between two possible attachments.',
    whatItDoes: 'It is a device for revealing a character by what they choose, '
        'which is why it goes slack when one option is obviously wrong — the '
        'choice stops being a choice and the reader waits for the book to '
        'catch up with them.',
    seeAlso: ['internal-conflict', 'external-want'],
    exercise: 'Write a page from inside the person who does not get chosen.',
    assertOn: {CraftSubject.plot, CraftSubject.character},
    example: 'She picks the one who lets her keep working. The other would '
        'have let her keep anything else.',
  ),

  // ---------------------------------------------------------------------
  // Character depth — the psychology block.
  //
  // These fields shipped in M26 and went unexplained until the craft library.
  // Want and need were two boxes with nothing to say why they are two boxes,
  // and the distance between them is the arc.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'core-wound',
    family: CraftFamily.characterDepth,
    term: 'Core wound',
    oneLine: 'What happened to them.',
    whatItDoes: 'The event itself, not the conclusion they drew from it — '
        'that is the false belief below.',
    appliesTo: ['character.psychology.coreWound'],
    seeAlso: ['false-belief'],
    example: 'She was eleven, the ward would not let her in, and he died some '
        'time between four and six in the morning.',
  ),
  CraftEntry(
    id: 'false-belief',
    family: CraftFamily.characterDepth,
    term: 'False belief',
    oneLine: 'The conclusion they drew from the wound, held as though it were '
        'true of the world.',
    whatItDoes: 'This is the thing a story gets to disprove.',
    appliesTo: ['character.psychology.falseBelief'],
    seeAlso: ['core-wound', 'core-belief', 'internal-need'],
    example: '“Needing people gets you left.” Not a sentence she would ever '
        'say aloud, and the reason she has moved four times in six years.',
  ),
  CraftEntry(
    id: 'core-belief',
    family: CraftFamily.characterDepth,
    term: 'Core belief',
    oneLine: 'What they hold to be true and would defend.',
    whatItDoes: 'Unlike the false belief, this one may be right — a character '
        'can be correct and still be ruined by it.',
    appliesTo: ['character.psychology.coreBelief'],
    seeAlso: ['false-belief'],
    example: 'A debt is a debt. He is right about that, and it takes the farm.',
  ),
  CraftEntry(
    id: 'internal-need',
    family: CraftFamily.characterDepth,
    term: 'Internal need',
    oneLine:
        'What would actually make them whole, which they usually cannot name.',
    whatItDoes:
        'A story satisfies this or refuses to, and either is an ending.',
    appliesTo: ['character.psychology.internalNeed'],
    seeAlso: ['external-want', 'false-belief'],
    example: 'To sit in a room where nobody is keeping score. She has no words '
        'for it and would deny wanting it.',
  ),
  CraftEntry(
    id: 'external-want',
    family: CraftFamily.characterDepth,
    term: 'External want',
    oneLine: 'What they say they want, and would list if asked.',
    whatItDoes: 'It drives the plot, and it is not the need — the distance '
        'between these two fields is the arc.',
    appliesTo: ['character.psychology.externalWant'],
    seeAlso: ['internal-need'],
    example: 'The tenancy on the north field. She could say it in one sentence '
        'at any point in the book.',
  ),
  CraftEntry(
    id: 'fear',
    family: CraftFamily.characterDepth,
    term: 'Fear',
    oneLine: 'What they will not walk towards.',
    whatItDoes: 'Mostly useful for knowing which scene costs them the most to '
        'be in.',
    appliesTo: ['character.psychology.fear'],
    seeAlso: ['avoidances'],
    example: 'Not heights, and not dying. Being the one who has to make the '
        'call.',
  ),
  CraftEntry(
    id: 'desire',
    family: CraftFamily.characterDepth,
    term: 'Desire',
    oneLine: 'The pull rather than the goal.',
    whatItDoes: 'A want has a finish line; a desire is what they would still '
        'be reaching for after crossing it.',
    appliesTo: ['character.psychology.desire'],
    seeAlso: ['external-want'],
    example: 'The promotion is the want. To be spoken of the way his father '
        'was spoken of is the desire, and the promotion does not touch it.',
  ),
  CraftEntry(
    id: 'primary-motivation',
    family: CraftFamily.characterDepth,
    term: 'Primary motivation',
    oneLine: 'Why they act at all.',
    whatItDoes: 'If a scene has them doing something this does not explain, '
        'one of the two is telling the truth.',
    appliesTo: ['character.psychology.primaryMotivation'],
    seeAlso: ['secondary-motivations'],
    example: 'Everything she does keeps the four of them in that house. Then, '
        'in chapter nine, she leaves the door unlocked.',
  ),
  CraftEntry(
    id: 'secondary-motivations',
    family: CraftFamily.characterDepth,
    term: 'Secondary motivations',
    oneLine: 'The reasons underneath the stated one.',
    whatItDoes: 'Where a character surprises a reader without breaking, it is '
        'usually one of these surfacing.',
    appliesTo: ['character.psychology.secondaryMotivations'],
    seeAlso: ['primary-motivation', 'contradictions'],
    example: 'He says he came back for the funeral. He came back for the '
        'funeral, and to see whether the shop was still standing, and to be '
        'seen coming back.',
  ),
  CraftEntry(
    id: 'emotional-needs',
    family: CraftFamily.characterDepth,
    term: 'Emotional needs',
    oneLine: 'What they need from other people.',
    whatItDoes: 'The relationships in a book tend to be about whether these '
        'get met.',
    appliesTo: ['character.psychology.emotionalNeeds'],
    example: 'To be asked. Not helped and not forgiven — asked, once, by '
        'anybody.',
  ),
  CraftEntry(
    id: 'secrets',
    family: CraftFamily.characterDepth,
    term: 'Secrets',
    oneLine: 'What they are keeping, and from whom.',
    whatItDoes: 'A secret is a scene waiting to happen: someone finds out, or '
        'the keeping of it costs something.',
    appliesTo: ['character.psychology.secrets'],
    seeAlso: ['reveal-secret'],
    example: 'He has known since March. His sister has known since March that '
        'he knows, and neither of them has said so.',
  ),
  CraftEntry(
    id: 'shame',
    family: CraftFamily.characterDepth,
    term: 'Shame',
    oneLine: 'What they believe they are.',
    whatItDoes: 'Shame is about the self where guilt is about an act, which '
        'is why it is harder to confess and worse to carry.',
    appliesTo: ['character.psychology.shame'],
    seeAlso: ['guilt'],
    example: 'Not that he ran. That he is the sort of man who runs.',
  ),
  CraftEntry(
    id: 'guilt',
    family: CraftFamily.characterDepth,
    term: 'Guilt',
    oneLine: 'What they believe they did.',
    whatItDoes: 'It names an act, so unlike shame it can be admitted, atoned '
        'for, or paid off in the plot.',
    appliesTo: ['character.psychology.guilt'],
    seeAlso: ['shame'],
    example: 'He ran. He can say the sentence out loud, and has, twice, to a '
        'priest.',
  ),
  CraftEntry(
    id: 'regrets',
    family: CraftFamily.characterDepth,
    term: 'Regrets',
    oneLine: 'The roads not taken that still cost them.',
    whatItDoes: 'Often what they push a younger character towards, or away '
        'from.',
    appliesTo: ['character.psychology.regrets'],
    example: 'She did not go to Lisbon in 1971. She tells her niece to go, '
        'every time, and never says why.',
  ),
  CraftEntry(
    id: 'obsessions',
    family: CraftFamily.characterDepth,
    term: 'Obsessions',
    oneLine: 'What they return to when nothing is forcing them.',
    whatItDoes: 'Shows a reader what matters without anyone having to '
        'announce it.',
    appliesTo: ['character.psychology.obsessions'],
    example: 'Nobody has asked him about the bridge in nine years. He still '
        'drives the long way round to look at it.',
  ),
  CraftEntry(
    id: 'avoidances',
    family: CraftFamily.characterDepth,
    term: 'Avoidances',
    oneLine: 'What they will not do, discuss, or go near.',
    whatItDoes: 'A refusal is characterisation, and it gives a scene '
        'somewhere to press.',
    appliesTo: ['character.psychology.avoidances'],
    seeAlso: ['fear', 'defences'],
    example: 'She will discuss the money, the will and the funeral. She will '
        'not go upstairs.',
  ),
  CraftEntry(
    id: 'triggers',
    family: CraftFamily.characterDepth,
    term: 'Triggers',
    oneLine: 'What stops them being reasonable.',
    whatItDoes: 'The reliable way to get a controlled character acting out of '
        'character, believably.',
    appliesTo: ['character.psychology.triggers'],
    seeAlso: ['defences'],
    example: 'He is the calmest man in the room until somebody says his '
        'brother\'s name.',
  ),
  CraftEntry(
    id: 'defences',
    family: CraftFamily.characterDepth,
    term: 'Defences',
    oneLine: 'How they behave when the wound is touched — deflect, charm, '
        'attack, go quiet.',
    whatItDoes: 'This is the part a reader actually sees; the wound stays '
        'underneath.',
    appliesTo: ['character.psychology.defences'],
    seeAlso: ['core-wound', 'triggers'],
    example: 'The wound gets touched and he becomes extremely funny for about '
        'ninety seconds.',
  ),
  CraftEntry(
    id: 'contradictions',
    family: CraftFamily.characterDepth,
    term: 'Contradictions',
    oneLine: 'Where they do not add up.',
    whatItDoes: 'A character consistent in every direction reads as a type, '
        'and the contradiction is usually what makes them a person instead.',
    appliesTo: ['character.psychology.contradictions'],
    seeAlso: ['secondary-motivations'],
    example: 'She is scrupulous about money and lies about everything else, '
        'and has never once noticed.',
  ),
  CraftEntry(
    id: 'internal-conflict',
    family: CraftFamily.characterDepth,
    term: 'Internal conflict',
    oneLine: 'The fight inside them, between two things they both want or both '
        'believe.',
    whatItDoes: 'It does not end because someone wins.',
    appliesTo: ['character.psychology.internalConflict'],
    seeAlso: ['external-conflict'],
    example: 'She wants him out of the house, and she wants him to be all '
        'right. Neither one is going anywhere.',
  ),
  CraftEntry(
    id: 'external-conflict',
    family: CraftFamily.characterDepth,
    term: 'External conflict',
    oneLine: 'What in the world is against them.',
    whatItDoes: 'Where this and the internal one mirror each other, a single '
        'scene can carry both.',
    appliesTo: ['character.psychology.externalConflict'],
    seeAlso: ['internal-conflict'],
    example: 'The bank wants the farm. Her brother, who wants the farm, works '
        'at the bank.',
  ),

  // ---------------------------------------------------------------------
  // Character types.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'character-roles',
    family: CraftFamily.characterTypes,
    term: 'Roles',
    oneLine: 'What the character is for, structurally — more than one can be '
        'true at once.',
    whatItDoes: 'A role is a job in the shape of the story, not a description '
        'of the person: it says what the book uses them for, which is why a '
        'single character can be the protagonist, a foil and the narrator '
        'without any contradiction.',
    appliesTo: ['character.identity.roles'],
    seeAlso: ['role-protagonist', 'role-antagonist', 'role-foil'],
    example: 'She is the protagonist, the narrator, and her sister\'s foil. '
        'The book never has to choose.',
  ),
  // The fifteen roles, one entry each.
  //
  // `identity.roles` carried one entry and a comment explaining why it could
  // only carry one: per-option help had nowhere to live in the field model,
  // and the answer to fifteen role names is fifteen explanations rather than
  // one sentence naming the two least familiar. The model gained
  // `optionDescriptions`, so this is that comment being cashed in.
  //
  // Keyed `<field key>#<option>`, so the field's own `optionDescriptions` are
  // collected from here by `CraftLibrary.describeOptions` and there is still
  // exactly one place each of these words is explained.
  //
  // What the set is careful about: several of these names are **judgements
  // the book makes**, not structural positions — villain and hero are an
  // antagonist and a protagonist the story has taken a view on. Saying so is
  // the useful part, and it is also the line that keeps this descriptive:
  // the entries explain what choosing a label does to a reader, and never
  // suggest a cast has to contain one.
  CraftEntry(
    id: 'role-protagonist',
    family: CraftFamily.characterTypes,
    term: 'Protagonist',
    oneLine: 'The character the story happens to, and through.',
    whatItDoes: 'A structural job rather than a moral one: the protagonist is '
        'whoever the plot costs the most, which is why a thoroughly unpleasant '
        'character can hold the role without weakening it.',
    appliesTo: ['character.identity.roles#Protagonist'],
    seeAlso: ['role-deuteragonist', 'role-hero', 'external-want'],
    example: 'By the last chapter she has lost the shop, the brother and the '
        'argument. Nobody else in the book has lost more than one thing.',
  ),
  CraftEntry(
    id: 'role-antagonist',
    family: CraftFamily.characterTypes,
    term: 'Antagonist',
    oneLine: 'Whoever stands between the protagonist and what they want.',
    whatItDoes: 'Opposition, not evil. The strongest version wants something '
        'reasonable that happens to be incompatible, which stops a reader '
        'settling the book by picking a side.',
    appliesTo: ['character.identity.roles#Antagonist'],
    seeAlso: ['role-villain', 'role-rival', 'conflict-vs-character'],
    exercise: 'Write half a page from inside the antagonist in which everything '
        'they want sounds reasonable.',
    example: '“I want the dam finished before the next flood.” “I want the '
        'village that is standing where it goes.”',
  ),
  CraftEntry(
    id: 'role-deuteragonist',
    family: CraftFamily.characterTypes,
    term: 'Deuteragonist',
    oneLine: 'The second lead, carrying a storyline of their own.',
    whatItDoes: 'Not a sidekick. A sidekick serves the lead arc; this one has '
        'an arc the book would be poorer without, and the two comment on each '
        'other — which is what a reader is doing when they compare them.',
    appliesTo: ['character.identity.roles#Deuteragonist'],
    seeAlso: ['role-protagonist', 'role-supporting-character', 'role-foil'],
    exercise: 'Summarise the second storyline in three sentences without '
        'mentioning the protagonist. If that cannot be done, it is a '
        'subplot rather than a second lead.',
    example: 'She spends the book getting out of the town. He spends it '
        'deciding to stay. Neither storyline explains the other, and each is '
        'read through the other.',
  ),
  CraftEntry(
    id: 'role-supporting-character',
    family: CraftFamily.characterTypes,
    term: 'Supporting Character',
    oneLine: 'A named presence who shapes scenes without owning one.',
    whatItDoes: 'The test is whether they want something when the protagonist '
        'is not in the room. One who exists only when needed reads as '
        'furniture with a name.',
    appliesTo: ['character.identity.roles#Supporting Character'],
    seeAlso: ['role-minor-character', 'role-deuteragonist'],
    exercise: 'Pick a supporting character and write what they are doing during a '
        'scene the protagonist is not in.',
    example: 'The barman is trying to sell the pub. It comes up in three '
        'scenes and has nothing to do with the murder.',
  ),
  CraftEntry(
    id: 'role-love-interest',
    family: CraftFamily.characterTypes,
    term: 'Love Interest',
    oneLine: 'The character the romance is with.',
    whatItDoes: 'A relationship rather than a job description, and it goes '
        'slack the moment they exist only to be wanted — the role works when '
        'they want something of their own that the romance costs them.',
    appliesTo: ['character.identity.roles#Love Interest'],
    seeAlso: ['enemies-to-lovers', 'love-triangle', 'external-want'],
    example: 'He would have to give up the posting in Lisbon. She has never '
        'once asked him to, which is worse.',
  ),
  CraftEntry(
    id: 'role-mentor',
    family: CraftFamily.characterTypes,
    term: 'Mentor',
    oneLine: 'Someone who has what the protagonist lacks, and hands some over.',
    whatItDoes: 'The story usually has to take them away again, because a '
        'protagonist with a working mentor can keep asking instead of '
        'deciding.',
    appliesTo: ['character.identity.roles#Mentor'],
    seeAlso: ['role-foil', 'chosen-one'],
    example: 'She teaches him the grip, the timing and the tell. Then she is '
        'on a train, and the fourth thing he has to decide himself.',
  ),
  CraftEntry(
    id: 'role-foil',
    family: CraftFamily.characterTypes,
    term: 'Foil',
    oneLine: 'A character whose contrast makes another one legible.',
    whatItDoes: 'Same situation, different choice — and the reader only sees '
        'the choice because the alternative is standing next to it, taken. The '
        'work is done by difference rather than opposition, so the sharpest '
        'foil is often a friend.',
    appliesTo: ['character.identity.roles#Foil'],
    seeAlso: ['role-rival', 'contradictions', 'role-deuteragonist'],
    exercise: 'Take two characters and write the same half page twice, each time '
        'putting one of them in the other\'s situation. What survives the '
        'swap is the contrast.',
    example: 'Two men are offered the same bribe. One takes it, and the '
        'other\'s refusal becomes a thing he did rather than a thing he is.',
  ),
  CraftEntry(
    id: 'role-rival',
    family: CraftFamily.characterTypes,
    term: 'Rival',
    oneLine: 'Wants the same thing, and only one of them gets it.',
    whatItDoes: 'Distinguished from an antagonist by being sympathetic: a '
        'reader can want a rival to win something, which is what makes the '
        'competition cost anything.',
    appliesTo: ['character.identity.roles#Rival'],
    seeAlso: ['role-antagonist', 'role-foil', 'conflict-vs-character'],
    example: 'He beats her to the promotion. He is also the only one who '
        'visits her father in the ward.',
  ),
  CraftEntry(
    id: 'role-villain',
    family: CraftFamily.characterTypes,
    term: 'Villain',
    oneLine: 'An antagonist the story treats as morally culpable.',
    whatItDoes: 'Narrower than antagonist rather than a synonym for it: every '
        'villain is an antagonist and most antagonists are not villains. It '
        'buys the reader clarity and spends their ambiguity.',
    appliesTo: ['character.identity.roles#Villain'],
    seeAlso: ['role-antagonist', 'role-hero', 'role-antihero'],
    example: 'He knows the wing is unsafe, he knows who sleeps in it, and he '
        'signs the certificate anyway.',
  ),
  CraftEntry(
    id: 'role-hero',
    family: CraftFamily.characterTypes,
    term: 'Hero',
    oneLine: 'A protagonist the story treats as admirable.',
    whatItDoes: 'The mirror of villain and the same trade: the reader knows '
        'whose side to be on, and stops asking. What that frees up is '
        'attention for everything the book is doing instead.',
    appliesTo: ['character.identity.roles#Hero'],
    seeAlso: ['role-protagonist', 'role-antihero', 'chosen-one'],
    example: 'She goes back into the building. The book does not spend a line '
        'on whether she was right to.',
  ),
  CraftEntry(
    id: 'role-antihero',
    family: CraftFamily.characterTypes,
    term: 'Antihero',
    oneLine: 'A lead the reader follows without approving of.',
    whatItDoes: 'The tension belongs to the reader: they want this '
        'person to get there and are not at ease about wanting it, which is a '
        'different engine from suspense and does not run on the same fuel.',
    appliesTo: ['character.identity.roles#Antihero'],
    seeAlso: ['role-hero', 'role-villain', 'internal-conflict'],
    example: 'He takes the notes out of the collection box, and the reader '
        'catches themselves hoping the priest stays away another minute.',
  ),
  CraftEntry(
    id: 'role-comic-relief',
    family: CraftFamily.characterTypes,
    term: 'Comic Relief',
    oneLine: 'A character whose function is to let the pressure out.',
    whatItDoes: 'A note held long enough stops being heard, and release is '
        'what makes the next tightening register. The risk is using the role '
        'to step around a hard scene rather than to survive one.',
    appliesTo: ['character.identity.roles#Comic Relief'],
    seeAlso: ['role-supporting-character', 'sentence-rhythm'],
    exercise: 'Read the three scenes around your funniest one and name what the '
        'laugh bought.',
    example: 'Two hundred pages of siege. Then the cook, at length, on the '
        'quality of the horses.',
  ),
  CraftEntry(
    id: 'role-narrator',
    family: CraftFamily.characterTypes,
    term: 'Narrator',
    oneLine: 'The voice telling it.',
    whatItDoes: 'Not automatically the viewpoint character, and worth marking '
        'apart: a narrator recounting their younger self already knows how it '
        'ends, and every page is coloured by that.',
    appliesTo: ['character.identity.roles#Narrator'],
    seeAlso: ['unreliable-narrator', 'role-pov-character', 'narrative-distance'],
    exercise: 'Write the same event twice: once as the character living through '
        'it, once as that person telling it years later.',
    example: '“I was nineteen, and I thought the letter was good news.”',
  ),
  CraftEntry(
    id: 'role-pov-character',
    family: CraftFamily.characterTypes,
    term: 'POV Character',
    oneLine: 'Whoever the reader is standing behind in a given scene.',
    whatItDoes: 'Not always the protagonist, and picking somebody else is how '
        'a scene withholds: a scene cannot report what this person did not '
        'notice, and the discipline of that is where close third gets its '
        'tension.',
    appliesTo: ['character.identity.roles#POV Character'],
    seeAlso: ['pov-third-limited', 'reader-knowledge', 'filtering'],
    example: 'The scene stands behind the boy, so the reader learns his mother '
        'has been crying only from the way she keeps her face to the window.',
  ),
  CraftEntry(
    id: 'role-minor-character',
    family: CraftFamily.characterTypes,
    term: 'Minor Character',
    oneLine: 'Someone who arrives, does one thing, and goes.',
    whatItDoes: 'Worth naming as a role so they can be written light: a minor '
        'character given a full history reads as a promise the book does not '
        'keep.',
    appliesTo: ['character.identity.roles#Minor Character'],
    seeAlso: ['role-supporting-character'],
    exercise: 'Take a minor character carrying more than a page of history and '
        'cut it to the one detail a reader will remember.',
    example: 'The ferryman takes the coin, says the crossing shuts after dark, '
        'and is never mentioned again.',
  ),


  // ---------------------------------------------------------------------
  // Turns — the reveal, the plant and the payoff.
  //
  // The reveal type was built with three separate accounts of who knows what,
  // and the distance between the reader's and the characters' is the whole
  // difference between suspense and surprise. That was in the fields and
  // nowhere an author could read it.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'reveal-secret',
    family: CraftFamily.turns,
    term: 'Secret',
    oneLine: 'The thing being revealed, where it is already a record.',
    whatItDoes: 'Linking rather than retyping keeps the reveal and the secret '
        'the same fact.',
    appliesTo: ['plot.reveal.secret'],
    seeAlso: ['secrets'],
    example: 'Reveal 07 → Secret #14. Not: Reveal 07, “he is her father”, '
        'beside Secret #14, “he is her father”.',
  ),
  CraftEntry(
    id: 'revealed-information',
    family: CraftFamily.turns,
    term: 'Revealed information',
    oneLine: 'What is actually learned, in plain terms.',
    whatItDoes: 'Worth writing even when it feels obvious: a reveal that '
        'cannot be stated plainly here is rarely clear on the page either.',
    appliesTo: ['plot.reveal.revealedInformation'],
    exercise: 'Write in one plain sentence what the reader actually learns in '
        'your largest reveal. Read the sentence beside the scene.',
    example: '“The man who signed the eviction order was her father.” Not: '
        '“the truth about her family comes out at last.”',
  ),
  CraftEntry(
    id: 'revealed-to',
    family: CraftFamily.turns,
    term: 'Revealed to',
    oneLine: 'Who learns it.',
    whatItDoes: 'Not necessarily the reader.',
    appliesTo: ['plot.reveal.revealedTo'],
    seeAlso: ['reader-knowledge'],
    example: 'The reader, page 40. Anna, page 290. Her brother, never.',
  ),
  CraftEntry(
    id: 'revealed-by',
    family: CraftFamily.turns,
    term: 'Revealed by',
    oneLine: 'Who or what does the revealing.',
    whatItDoes: "A reveal that arrives by nobody's agency is a coincidence, "
        'which readers forgive at the start of a story more readily than at '
        'the end.',
    appliesTo: ['plot.reveal.revealedBy'],
    exercise: 'Name who or what does the revealing in your three largest '
        'reveals, then read where each of the three falls in the book.',
    example: 'Not: she happens to open the right drawer. Instead: her brother '
        'tells her, because he wants her to stop looking.',
  ),
  CraftEntry(
    id: 'actual-reveal-point',
    family: CraftFamily.turns,
    term: 'Actual reveal point',
    oneLine: 'Where it lands as drafted.',
    whatItDoes: 'A gap between this and the intended point is a planning '
        'note, not a mistake.',
    appliesTo: ['plot.reveal.actualRevealPoint'],
    example: 'Intended: chapter 14. Actual: chapter 22, because chapters 15 to '
        '21 turned out to be about the sister.',
  ),
  CraftEntry(
    id: 'author-knowledge',
    family: CraftFamily.turns,
    term: 'Author knowledge',
    oneLine: 'What you know that nobody in the book does yet.',
    whatItDoes: 'Kept here so it stops living only in your head.',
    appliesTo: ['plot.reveal.authorKnowledge'],
    seeAlso: ['character-knowledge', 'reader-knowledge'],
    example: 'It was her mother who set the fire. Nobody in the book knows '
        'until chapter thirty-one, and two of them never do.',
  ),
  CraftEntry(
    id: 'character-knowledge',
    family: CraftFamily.turns,
    term: 'Character knowledge',
    oneLine: 'Who knows what, and from when.',
    whatItDoes: 'This is what makes a scene playable: two people who know '
        'different things want different things from the same conversation.',
    appliesTo: ['plot.reveal.characterKnowledge'],
    seeAlso: ['reader-knowledge'],
    exercise: 'Take a conversation from your draft and write, for each person '
        'in it, what they know that the other does not. Then write what each '
        'of them wants out of the room.',
    example: 'Anna: since chapter 3. Piotr: since chapter 3, and does not know '
        'Anna knows. Marek: chapter 29.',
  ),
  CraftEntry(
    id: 'reader-knowledge',
    family: CraftFamily.turns,
    term: 'Reader knowledge',
    oneLine: 'What the reader knows by this point.',
    whatItDoes: 'Read against the character column it is the difference '
        'between suspense and surprise — the reader knowing first is '
        'suspense, the reader learning alongside the character is surprise.',
    appliesTo: ['plot.reveal.readerKnowledge'],
    seeAlso: ['character-knowledge', 'author-knowledge'],
    exercise: 'Pick a scene and write two columns — what the reader knows by '
        'here, and what the character knows. Read the gap, and decide which of '
        'the two you want this scene to be.',
    example: 'The reader has known since page 40. On page 210 Anna asks him '
        'about it, kindly.',
  ),
  CraftEntry(
    id: 'plant',
    family: CraftFamily.turns,
    term: 'Plant',
    oneLine: 'What goes on the page early, in the form the reader meets it.',
    whatItDoes: 'A plant that reads as significant first time is a promise; '
        'one that only reads that way in hindsight is a trick. Both work, and '
        'they work differently.',
    appliesTo: ['plot.foreshadowing.plant'],
    seeAlso: ['payoff', 'payoff-setup'],
    exercise: 'Take a plant from your draft and read only the paragraph it '
        'sits in. Write down whether a first-time reader would pause on it, '
        'and whether you meant them to.',
    example: 'Chapter two, in a list of what was in the drawer: a ferry ticket '
        'to Holyhead, dated.',
  ),
  CraftEntry(
    id: 'reader-awareness',
    family: CraftFamily.turns,
    term: 'Reader awareness',
    oneLine: 'What the reader is meant to make of it here.',
    whatItDoes:
        'Nothing, unease, or a wrong conclusion you intend them to draw.',
    appliesTo: ['plot.foreshadowing.readerAwareness'],
    seeAlso: ['reader-knowledge'],
    example: 'Here: nothing at all. She is meant to read straight past it. The '
        'unease is scheduled for chapter nine.',
  ),
  CraftEntry(
    id: 'payoff-setup',
    family: CraftFamily.turns,
    term: 'Setup',
    oneLine: 'The plant this pays off.',
    whatItDoes: 'Linking it is what lets the two be checked against each '
        'other rather than remembered.',
    appliesTo: ['plot.payoff.setup'],
    seeAlso: ['plant', 'payoff'],
    example: '→ Plant #6: the ferry ticket in the drawer, chapter two.',
  ),
  CraftEntry(
    id: 'payoff',
    family: CraftFamily.turns,
    term: 'Payoff',
    oneLine: 'What the setup turns out to have meant.',
    whatItDoes: 'A payoff a reader cannot trace back to a plant reads as a '
        'cheat, even when it was planned all along.',
    appliesTo: ['plot.payoff.payoff'],
    seeAlso: ['plant', 'payoff-setup'],
    exercise: 'Write your payoff in one sentence, then find the earliest page '
        'carrying the fact it rests on. Write down the page, or that there is '
        'not one yet.',
    example: 'So that was why the drawer was locked, and why he never went to '
        'the funeral.',
  ),
  CraftEntry(
    id: 'turning-point-type',
    family: CraftFamily.turns,
    term: 'Turning point',
    oneLine: 'Which kind of turn this is.',
    whatItDoes: 'The names describe where a turn commonly falls, never where '
        'yours has to — and "custom" is there because the list is a '
        'vocabulary, not a shape to fill in.',
    appliesTo: ['plot.turning-point.turningPointType'],
    example: 'Midpoint. Or: custom — “the night the letters stop”, which is '
        'not on the list and is what this book turns on.',
  ),

  // ---------------------------------------------------------------------
  // Prose.
  //
  // The family the first five could not hold. Everything above this line is
  // about the story — who is in it, what is under them, how it turns. This is
  // about the paragraph, which is the thing an author is actually looking at
  // when they are stuck on a line rather than on a plot.
  //
  // Not one of these is attached to a field, and that is the honest shape for
  // them: AuthorOS records what a book *contains*, and none of this is a thing
  // a book contains. It is a set of choices made in the typing, so the entries
  // are reachable from the shelf and from nowhere else.
  //
  // The temptation this family carries is prescription, and it is stronger
  // here than anywhere else in the library, because prose advice is written
  // as commandments almost everywhere it is written at all — cut the adverbs,
  // never say anything but "said", show don't tell. Every one of those is a
  // trade stated as a rule. What each entry does instead is name both sides of
  // the trade and leave the choosing where it belongs.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'showing-and-telling',
    family: CraftFamily.prose,
    term: 'Showing and telling',
    oneLine: 'Staging a thing on the page, against reporting that it happened.',
    whatItDoes: 'Staged, the reader draws the conclusion and owns it. '
        'Reported, they are handed it and move on. A book with only the first '
        'never gets anywhere; a book with only the second is a synopsis.',
    seeAlso: ['summary-and-scene', 'concrete-detail', 'subtext'],
    example: '“She was furious” against “She folded the letter into smaller '
        'and smaller squares.”',
  ),
  CraftEntry(
    id: 'filtering',
    family: CraftFamily.prose,
    term: 'Filtering',
    oneLine: 'Naming the act of perceiving before naming the thing perceived.',
    whatItDoes: 'It holds the reader one step back, watching somebody notice, '
        'rather than putting them in the room where it happens. The step back '
        'is worth taking when the noticing is what the moment is about.',
    seeAlso: ['narrative-distance', 'pov-third-limited'],
    example: '“She saw the door swing open” against “The door swung open.”',
  ),
  CraftEntry(
    id: 'concrete-detail',
    family: CraftFamily.prose,
    term: 'Concrete detail',
    oneLine: 'The particular noun standing in for the general one.',
    whatItDoes: 'A reader builds the scene out of whatever you name. "Tree" '
        'builds nothing in particular; "sycamore" builds a tree and, at the '
        'same time, tells them something about whoever is looking at it.',
    seeAlso: ['white-room', 'showing-and-telling'],
    example: '“He brought flowers” against “He brought carnations, dyed '
        'blue.”',
  ),
  CraftEntry(
    id: 'sentence-rhythm',
    family: CraftFamily.prose,
    term: 'Sentence rhythm',
    oneLine: 'The lengths of consecutive sentences, varied on purpose.',
    whatItDoes: 'Short sentences quicken a page and land hard. Long ones carry '
        'a reader through without letting them stop. A page built entirely '
        'from one length reads flat whichever length it is.',
    seeAlso: ['paragraph-break', 'reading-it-aloud', 'register'],
    example: '“He waited. The house made its small night noises, settling '
        'and ticking and letting go of the heat of the day. Then the '
        'phone rang.”',
  ),
  CraftEntry(
    id: 'paragraph-break',
    family: CraftFamily.prose,
    term: 'The paragraph break',
    oneLine: 'Where the reader is given somewhere to breathe.',
    whatItDoes: 'A break is a beat. Short paragraphs speed a page up, and '
        'whatever is left standing alone between two of them carries weight '
        'it would not carry inside a block.',
    seeAlso: ['sentence-rhythm'],
    example: '“…and she said yes.” — new paragraph — “He had not expected '
        'that.” The break is the pause he takes.',
  ),
  CraftEntry(
    id: 'said',
    family: CraftFamily.prose,
    term: 'Said',
    oneLine: 'The plain tag naming who spoke.',
    whatItDoes: 'A reader stops hearing "said" after a page and reads straight '
        'through it. Anything else — barked, opined, ventured — is heard, and '
        'a tag the reader hears is one that had better be doing work.',
    seeAlso: ['action-beat', 'modifier-on-the-verb'],
    example: '“I know,” she said, against “I know,” she countered. The first '
        'disappears; the second is heard.',
  ),
  CraftEntry(
    id: 'action-beat',
    family: CraftFamily.prose,
    term: 'Action beat',
    oneLine: 'A small physical action standing in for a dialogue tag.',
    whatItDoes: 'It says who is speaking and what their hands are doing at '
        'once, and it sets the tempo of the exchange: a beat between two lines '
        'is a pause the reader takes without being told to.',
    seeAlso: ['said', 'subtext'],
    example: '“I know.” She put the cup down. Who spoke, and what it cost '
        'her, in one line.',
  ),
  CraftEntry(
    id: 'subtext',
    family: CraftFamily.prose,
    term: 'Subtext',
    oneLine: 'What a scene is about, which is not what is being said in it.',
    whatItDoes: 'Two people argue about the dishes and neither one is talking '
        'about dishes. The reader does the arithmetic, and doing the '
        'arithmetic is most of the pleasure of reading a scene.',
    seeAlso: ['showing-and-telling', 'action-beat', 'internal-conflict'],
    example: '“Did you move my chair?” A question about a chair, in a house '
        'where nothing has been said out loud for a week.',
  ),
  CraftEntry(
    id: 'summary-and-scene',
    family: CraftFamily.prose,
    term: 'Summary and scene',
    oneLine: 'Time compressed, against time played out at its own speed.',
    whatItDoes: 'Summary covers a month in a line; scene covers a minute in a '
        'page. Which of the two you are in is how a reader works out how much '
        'this part matters, before anything in it has happened.',
    seeAlso: ['showing-and-telling', 'in-late-out-early'],
    example: '“The winter passed” against four pages of one afternoon inside '
        'it.',
  ),
  CraftEntry(
    id: 'exposition',
    family: CraftFamily.prose,
    term: 'Exposition',
    oneLine: 'The background a reader needs in order to follow this.',
    whatItDoes: 'Delivered at the point the reader has started wanting it, it '
        'reads as an answer. Delivered before, the same words read as '
        'homework — the information is identical and the experience is not.',
    seeAlso: ['white-room', 'summary-and-scene'],
    example: '“The city had been closed for nine months.” Useful on the page '
        'where somebody tries to leave; homework on page one.',
  ),
  CraftEntry(
    id: 'white-room',
    family: CraftFamily.prose,
    term: 'The white room',
    oneLine: 'A scene playing out in a place the reader has not been given.',
    whatItDoes: 'With nothing to build from, a reader puts the conversation '
        'nowhere and forgets it fast. Two specifics usually fix it; a '
        'paragraph of scenery usually costs more than it returns.',
    seeAlso: ['concrete-detail', 'exposition'],
    example: '“They argued” against “They argued across a kitchen table '
        'still laid for three.”',
  ),
  CraftEntry(
    id: 'in-late-out-early',
    family: CraftFamily.prose,
    term: 'In late, out early',
    oneLine: 'Beginning a scene after it started and leaving before it ends.',
    whatItDoes: 'The reader fills in the greeting and the goodbye for free, '
        'and what is left on the page is the part where something changed.',
    seeAlso: ['summary-and-scene'],
    example: 'Open on “You told her *what*?” and leave before the apology.',
  ),
  CraftEntry(
    id: 'modifier-on-the-verb',
    family: CraftFamily.prose,
    term: 'The modifier on the verb',
    oneLine: 'An adverb attached to an act of speech or action.',
    whatItDoes: '"Said angrily" hands the reader the reading to take. A verb '
        'or a beat that carries the anger lets them arrive at it themselves. '
        'Neither is wrong, and one of them asks more of the reader.',
    seeAlso: ['said', 'action-beat', 'showing-and-telling'],
    example: '“Fine,” he said angrily, against “Fine.” He did not look up.',
  ),
  CraftEntry(
    id: 'deliberate-repetition',
    family: CraftFamily.prose,
    term: 'Deliberate repetition',
    oneLine: 'A word or an image returned to on purpose.',
    whatItDoes: 'A reader clocks the second appearance without being told to, '
        'and the third one arrives carrying everything the first two picked '
        'up. Accidental repetition does the same thing, for nothing.',
    seeAlso: ['plant', 'sentence-rhythm'],
    example: 'A coat on a hook in chapter one. The same coat, still on the '
        'hook, in chapter twenty.',
  ),

  // ---------------------------------------------------------------------
  // Editorial.
  //
  // What happens to a draft after it exists, and what a reader's note is
  // worth. This family is here because the question authors arrive with —
  // "someone gave me feedback and I do not know what to do with it" — had no
  // shelf anywhere in AuthorOS, and it is not a question about their book that
  // the app could answer even if it wanted to. It is a question about the
  // process, which is exactly the kind of thing a reference can answer.
  //
  // The line this family walks: it explains what a developmental edit is. It
  // never says a draft needs one, never says which pass this draft is ready
  // for, and never reads a word of the manuscript to decide. The library knows
  // about writing and nothing about your book, and that holds here or it holds
  // nowhere.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'developmental-edit',
    family: CraftFamily.editorial,
    term: 'Developmental edit',
    oneLine: 'The pass about what the book is.',
    whatItDoes: 'Structure, character, pacing, premise. It is the pass that '
        'can conclude a chapter has no reason to exist, which is why it comes '
        'before any work on the sentences inside that chapter.',
    seeAlso: ['line-edit', 'order-of-the-passes'],
    exercise: 'Summarise every chapter in one sentence, then read the list on its '
        'own. The chapters that resisted summary are the ones to look at '
        'first.',
    example: '“Chapter nine is a conversation the book has already had, in a '
        'different kitchen.”',
  ),
  CraftEntry(
    id: 'line-edit',
    family: CraftFamily.editorial,
    term: 'Line edit',
    oneLine: 'The pass about how the book reads.',
    whatItDoes: 'Voice, rhythm, clarity, paragraph by paragraph. It rewrites '
        'sentences and leaves the story where it found it — so it assumes the '
        'story is one you have finished arguing with.',
    seeAlso: ['developmental-edit', 'copyedit', 'sentence-rhythm'],
    exercise: 'Take one page and cut it by a fifth without losing anything you '
        'meant. Read both versions aloud.',
    example: '“Three sentences here open with ‘She’, and the paragraph loses '
        'its footing at the semicolon.”',
  ),
  CraftEntry(
    id: 'copyedit',
    family: CraftFamily.editorial,
    term: 'Copyedit',
    oneLine: 'The pass about consistency and correctness.',
    whatItDoes: 'Grammar, usage, house style, and continuity of names, dates '
        'and facts. It takes every sentence to be the sentence you meant, and '
        'checks that it says what it says.',
    seeAlso: ['proofread', 'line-edit'],
    exercise: 'List every proper noun in a chapter beside its spelling, then '
        'search the whole manuscript for each one.',
    example: '“Her eyes are grey in chapter two and hazel here; the funeral is '
        'Tuesday on page 40 and Thursday on page 210.”',
  ),
  CraftEntry(
    id: 'proofread',
    family: CraftFamily.editorial,
    term: 'Proofread',
    oneLine: 'The last read before anyone else sees it.',
    whatItDoes: 'Typos, spacing, broken punctuation, a bad line break. '
        'Anything found at this stage that is bigger than one of those is '
        'expensive, which is the whole argument for the order of the passes.',
    seeAlso: ['copyedit', 'order-of-the-passes'],
    exercise: 'Read a page backwards, sentence by sentence, so the story stops '
        'carrying you past what is actually on it.',
    example: '“A line break has split ‘farm-house’ across two pages, and there '
        'are two spaces after ‘Then’.”',
  ),
  CraftEntry(
    id: 'order-of-the-passes',
    family: CraftFamily.editorial,
    term: 'The order of the passes',
    oneLine: 'Why the four edits run from the largest thing to the smallest.',
    whatItDoes: 'A sentence polished inside a chapter that later goes was '
        'polished for nobody. Each pass takes the one above it to be settled, '
        'and that is the only reason the sequence is worth anything.',
    seeAlso: ['developmental-edit', 'proofread', 'one-pass-one-question'],
    exercise: 'Before touching a sentence, write down the one structural question '
        'you are still unsure about, and answer that first.',
    example: 'The semicolon in chapter nine took an hour on Tuesday. Chapter '
        'nine came out on Thursday.',
  ),
  CraftEntry(
    id: 'beta-reader',
    family: CraftFamily.editorial,
    term: 'Beta reader',
    oneLine: 'A reader of the kind the book is for, reading it whole.',
    whatItDoes: 'They report where they were bored, lost, or moved. What they '
        'felt while reading is evidence about the book; what they propose '
        'doing about it is a guess from one reader, and a different thing.',
    seeAlso: ['note-and-fix', 'triangulating-notes', 'critique-partner'],
    exercise: 'Write three questions for your reader that cannot be answered yes '
        'or no: where did you slow down, who did you lose track of, what '
        'did you expect that never came.',
    example: '“I put it down at chapter nine and did not pick it up again '
        'until Sunday.”',
  ),
  CraftEntry(
    id: 'critique-partner',
    family: CraftFamily.editorial,
    term: 'Critique partner',
    oneLine: 'Another writer, trading whole drafts.',
    whatItDoes: 'They read like a writer, which finds craft problems a reader '
        'would only feel — and, for the same reason, skates past the ones only '
        'someone reading purely for pleasure would ever hit.',
    seeAlso: ['beta-reader', 'note-and-fix'],
    exercise: 'Take a chapter you are happy with and mark the two places you '
        'suspect another writer would stop. Then ask them.',
    example: '“Your midpoint is doing two jobs, and the second one starts '
        'about forty pages late.”',
  ),
  CraftEntry(
    id: 'authenticity-read',
    family: CraftFamily.editorial,
    term: 'Authenticity read',
    oneLine: 'A reader with lived proximity to something the book depicts.',
    whatItDoes: 'They report where a depiction would land wrong on the people '
        'it is about, and why. It is a category of accuracy note, given by one '
        'person rather than by a constituency.',
    seeAlso: ['beta-reader', 'note-and-fix'],
    exercise: 'List the experiences your book depicts that you have not had, and '
        'name which of them the story leans on hardest.',
    example: '“A nurse would not be the one carrying that tray, and the family '
        'would not be standing in that room at that hour.”',
  ),
  CraftEntry(
    id: 'note-and-fix',
    family: CraftFamily.editorial,
    term: 'The note and the fix',
    oneLine: 'What a reader reports, against what they propose.',
    whatItDoes: 'A reader telling you where they put the book down is almost '
        'always right — they were there. The same reader telling you what to '
        'change is one guess among many, and the choice stays yours.',
    seeAlso: ['beta-reader', 'triangulating-notes'],
    exercise: 'Take a note you disagree with and write down what the reader was '
        'feeling when they wrote it, separately from what they proposed '
        'doing about it.',
    example: '“I got bored around chapter nine.” Against: “Cut chapter nine.”',
  ),
  CraftEntry(
    id: 'triangulating-notes',
    family: CraftFamily.editorial,
    term: 'Triangulating notes',
    oneLine: 'What to make of readers who disagree with each other.',
    whatItDoes: 'One reader disliking a chapter is a reaction. Three of them '
        'slowing down in the same place is a fact about the chapter, whatever '
        'each of the three said was wrong with it.',
    seeAlso: ['note-and-fix', 'beta-reader'],
    exercise: 'Tabulate your readers\' notes by page rather than by reader, and '
        'look for the pages more than one of them stopped on.',
    example: 'Three readers on chapter nine: “slow”, “I skimmed a bit”, and '
        '“is the sister still in this?”',
  ),
  CraftEntry(
    id: 'one-pass-one-question',
    family: CraftFamily.editorial,
    term: 'One pass, one question',
    oneLine: 'Reading the whole draft watching for a single thing.',
    whatItDoes: 'A pass watching for everything watches for nothing. Asking '
        'one question per read — where is she in this scene, does this thread '
        'ever land — is slower per pass and faster over the revision.',
    seeAlso: ['order-of-the-passes', 'the-drawer'],
    exercise: 'Pick one question and read the entire draft for it and nothing '
        'else — where is she standing in this scene, or does this thread '
        'ever land.',
    example: 'A read for nothing at all except: where is she standing, in '
        'every scene she is in.',
  ),
  CraftEntry(
    id: 'the-drawer',
    family: CraftFamily.editorial,
    term: 'The drawer',
    oneLine: 'Time deliberately left between finishing and rereading.',
    whatItDoes: 'Distance is what lets you read what is on the page instead '
        'of what you meant to put there. Nothing else does the same job, and '
        'no amount of care while drafting substitutes for it.',
    seeAlso: ['one-pass-one-question', 'reading-it-aloud'],
    exercise: 'Take the draft, put it somewhere you cannot see it, and write the '
        'date you will next open it on the outside.',
    example: 'Six weeks in a drawer. First page after: “Who is Marta, and how '
        'does she already know?”',
  ),
  CraftEntry(
    id: 'darlings',
    family: CraftFamily.editorial,
    term: 'Darlings',
    oneLine: 'A line or a scene you love more than the book needs it.',
    whatItDoes: 'The test is not whether it is good. It is whether the book '
        'reads worse without it — and the answer being no is exactly why '
        'cutting one hurts.',
    seeAlso: ['the-drawer', 'note-and-fix'],
    exercise: 'List the five lines you would save if the book had to lose '
        'everything else, then read the book without them.',
    example: 'The heron paragraph. It is the best writing in the chapter, and '
        'the chapter is about a phone call.',
  ),
  CraftEntry(
    id: 'reading-it-aloud',
    family: CraftFamily.editorial,
    term: 'Reading it aloud',
    oneLine: 'Speaking the draft, in a voice, at reading speed.',
    whatItDoes: 'The ear catches what the eye forgives: a word repeated three '
        'times in a paragraph, a rhythm that stalls halfway, a line of '
        'dialogue nobody would ever actually say out loud.',
    seeAlso: ['sentence-rhythm', 'the-drawer'],
    exercise: 'Read a scene out at reading speed and mark only the places where '
        'you stumbled.',
    example: 'Aloud, the sentence runs out of breath somewhere before “and '
        'then she remembered the letter” — which the eye had been sliding past '
        'for months.',
  ),

  // ---------------------------------------------------------------------
  // The research entries.
  //
  // `docs/research/` holds twenty-one essays on craft. These are what came
  // back from them once each idea was held to the rule this library sets:
  // an entry earns its place by having a non-obvious answer to *what does
  // this do in the story*.
  //
  // They live in `entries/` rather than inline because a single file holding
  // every entry stopped being reviewable somewhere around the hundredth, and
  // because the grouping is real — each file names the docs it came from, so
  // an entry can be traced back to the argument that produced it.
  //
  // Order is preserved: the seven original families first, in the order a
  // reader met them, then the research, cluster by cluster.
  // ---------------------------------------------------------------------
  ...kProseResearchEntries,
  ...kStructureEntries,
  ...kTurnResearchEntries,
  ...kCharacterDepthEntries,
  ...kCharacterSurfaceEntries,
  ...kWorldEntries,
  ...kProcessEntries,
];

/// The entries available to a project.
///
/// Mirrors the registry shape of `ChatPromptSetRegistry`: built-ins now, with
/// the hook for author-defined additions already in the constructor so the
/// model does not have to change when they arrive. Shipping built-ins only is
/// the same call that registry made, for the same reason — the extension point
/// is cheap to design in and expensive to retrofit.
class CraftLibrary {
  CraftLibrary({Iterable<CraftEntry> additionalEntries = const []})
      : _entriesById = {
          for (final entry in [..._entries, ...additionalEntries])
            entry.id: entry,
        } {
    _byField = {
      for (final entry in _entriesById.values)
        for (final key in entry.appliesTo) key: entry,
    };
  }

  /// The library as it ships, with no project additions.
  static final CraftLibrary builtIn = CraftLibrary();

  final Map<String, CraftEntry> _entriesById;
  late final Map<String, CraftEntry> _byField;

  /// Every entry, in declaration order.
  List<CraftEntry> get all => _entriesById.values.toList();

  /// The entries in one family, for a browsable surface.
  List<CraftEntry> family(CraftFamily family) =>
      all.where((entry) => entry.family == family).toList();

  /// The entry with this id, or null. Null rather than throwing: a citation
  /// from an older library version naming an entry that has since been
  /// retired is a thing to render as absent, not a crash.
  CraftEntry? byId(String id) => _entriesById[id];

  /// The entry explaining a qualified field key, or null when none does.
  CraftEntry? forField(String fieldKey) => _byField[fieldKey];

  /// Every option [fieldKey] explains, as `{option: helper}`.
  ///
  /// Option entries key on `<field key>#<option>`, so this is the whole set
  /// of them for one field — the shape `RecordFieldDefinition.optionDescriptions`
  /// takes. Empty when nothing explains any of the field's options, which is
  /// the normal case: most choice lists explain themselves.
  static Map<String, String> describeOptions(String fieldKey) {
    final prefix = '$fieldKey#';
    return {
      for (final entry in builtIn.all)
        for (final key in entry.appliesTo)
          if (key.startsWith(prefix))
            key.substring(prefix.length): entry.helper,
    };
  }

  /// Helper text for a qualified field key, or the empty string.
  ///
  /// The empty string rather than null because that is what
  /// `RecordFieldDefinition.description` defaults to, and what both form
  /// builders already read as "draw no helper".
  static String describe(String fieldKey) =>
      builtIn.forField(fieldKey)?.helper ?? '';
}
