/// World entries derived from `docs/research/12-worldbuilding-method.md`,
/// `13-constructed-languages.md`, `14-magic-systems.md`,
/// `15-politics-and-government.md` and `16-culture-and-tradition.md`.
///
/// Five docs and one family, which was a decision rather than an economy.
///
/// The research went looking for a magic system and found a shape; went
/// looking for a government and found the same shape; went looking for a
/// culture and found it a third time. **What a system can do, what it cannot,
/// and what each use costs** describes spellcasting, taxation and table
/// manners equally well, and it was arrived at independently in three domains
/// before it was noticed.
///
/// Four families would have hidden that. One family, with [capability-limit-cost]
/// near the front of it, says the thing the research actually found.
library;

import '../craft_entry.dart';

/// Entries about the world under the story.
const List<CraftEntry> kWorldEntries = [
  CraftEntry(
    id: 'capability-limit-cost',
    family: CraftFamily.world,
    term: 'Capability, limit, cost',
    oneLine: 'The three questions every invented system answers.',
    whatItDoes: 'What can it do, where does it stop, and what does each use '
        'take. Magic answers it with power, law and price; a government with '
        'what it compels, where its writ runs, and what enforcement spends; a '
        'culture with its norms, its taboos and its sanctions. A system with '
        'no answer to the second and third is a wish.',
    appliesTo: ['magic.magic-system.limitations'],
    seeAlso: ['unpaid-cost', 'where-the-writ-runs', 'taboo-and-sanction'],
    exercise: 'Take any system in your world and write three sentences, one '
        'per question. The one you find hardest to write is the one the book '
        'has been avoiding.',
    example: 'It can mend a bone. It cannot mend a mind. Each mending takes a '
        'week of the mender\'s own life.',
  ),
  CraftEntry(
    id: 'swap-test',
    family: CraftFamily.world,
    term: 'The swap test',
    oneLine: 'Replace an invented detail with an ordinary one and reread.',
    whatItDoes: 'If the scene survives the swap unchanged, the detail was '
        'decoration. It is the fastest available way to tell worldbuilding '
        'that is doing work from worldbuilding that is being enjoyed, and it '
        'can be run on a paragraph in a few seconds.',
    seeAlso: ['iceberg-rule', 'productive-avoidance', 'consequence-cascade'],
    example: '“She reached for the sunstone and the room lit.” Swap: “She '
        'reached for the lamp and the room lit.” Nothing else in the scene '
        'moves.',
  ),
  CraftEntry(
    id: 'iceberg-rule',
    family: CraftFamily.world,
    term: 'The iceberg, corrected',
    oneLine: 'The unseen part helps only where it touches the page.',
    whatItDoes: 'The usual version — know ten times what you show — is true '
        'of the parts a scene presses against and false of everything else. '
        'Depth behind a moment reads as confidence; depth behind nothing at '
        'all reads as nothing at all, because a reader cannot detect it.',
    seeAlso: ['swap-test', 'productive-avoidance', 'exposition'],
    example: 'Forty pages of guild history in a notebook. On the page: he '
        'counts the coins twice before handing them over.',
  ),
  CraftEntry(
    id: 'consequence-cascade',
    family: CraftFamily.world,
    term: 'The consequence cascade',
    oneLine: 'One change to a world, followed three steps outward.',
    whatItDoes: 'If healing is cheap, who dies, and of what? If nobody dies '
        'of infection, who inherits, and when? Worlds feel invented when a '
        'premise sits alone, and lived-in when its second and third '
        'consequences are visible in ordinary scenes.',
    appliesTo: ['magic.magic-system.culturalImpact'],
    seeAlso: ['swap-test', 'capability-limit-cost', 'material-culture'],
    exercise: 'Name one rule your world has that ours does not. Write the '
        'three things that follow from it, then the three that follow from '
        'those. Use the third row in a scene.',
    example: 'Healing is cheap, so nobody dies of infection, so the old do not '
        'make room, so inheritance is about waiting and everyone under forty '
        'is furious.',
  ),
  CraftEntry(
    id: 'text-established-invariant',
    family: CraftFamily.world,
    term: 'The first time the book said it',
    oneLine: 'In an invented world, the text is the only authority.',
    whatItDoes: 'There is nothing external to check a made-up rule against, '
        'so the earliest clear statement of it becomes the fact and every '
        'later one is measured against that. It is why invented-world '
        'continuity is stricter than historical continuity rather than looser.',
    appliesTo: ['magic.magic-system.exceptions'],
    seeAlso: ['capability-limit-cost', 'unpaid-cost'],
    example: 'Chapter three: the gates hold against anything without a '
        'heartbeat. Chapter twenty-nine: something without a heartbeat comes '
        'through.',
  ),
  CraftEntry(
    id: 'hard-and-soft-magic',
    family: CraftFamily.world,
    term: 'Hard and soft magic',
    oneLine: 'Not two kinds of magic — two states of reader knowledge.',
    whatItDoes: 'The axis is how much the reader has been told the rules. '
        'Where they know them, magic can solve problems and feel earned. '
        'Where they do not, it can create wonder and dread, and solving '
        'anything with it reads as the author intervening.',
    appliesTo: ['magic.magic-system.rules'],
    seeAlso: ['unpaid-cost', 'deus-ex-machina', 'reader-knowledge'],
    example: 'The reader was told the price in chapter two, so he pays it and '
        'wins. Against: the reader was told nothing, and he wins.',
  ),
  CraftEntry(
    id: 'unpaid-cost',
    family: CraftFamily.world,
    term: 'The cost nobody paid',
    oneLine: 'A power used at a stated price, without the price being charged.',
    whatItDoes: 'A magic that exhausts its user, in a chapter where the user '
        'is not tired, quietly tells the reader the rules are negotiable — '
        'and once they are negotiable, no later peril is frightening. It is '
        'the commonest way a well-designed system stops working.',
    appliesTo: ['magic.magic-system.costs'],
    seeAlso: ['capability-limit-cost', 'hard-and-soft-magic', 'stakes-and-proximity'],
    example: 'It takes a day of strength. He does it three times before noon '
        'and rides out at two.',
  ),
  CraftEntry(
    id: 'access-is-politics',
    family: CraftFamily.world,
    term: 'Who is allowed to have it',
    oneLine: 'Any scarce power is a question about who holds it.',
    whatItDoes: 'Whether ability is inherited, trained, bought or granted '
        'decides the shape of the society around it — a class, a guild, a '
        'market or a court. Deciding the mechanism and leaving the access '
        'undecided is what makes an invented power feel weightless.',
    appliesTo: ['magic.magic-system.practitioners'],
    seeAlso: ['capability-limit-cost', 'three-capitals', 'where-the-writ-runs'],
    example: 'It runs in families. So there are four families, a marriage '
        'register, and a man who married in and has not been forgiven.',
  ),
  CraftEntry(
    id: 'where-the-writ-runs',
    family: CraftFamily.world,
    term: 'Reach',
    oneLine: 'How far an authority can actually act, and how fast.',
    whatItDoes: 'Power on a map is not power on the ground. A decree travels '
        'at the speed of a rider, arrives where somebody local is willing to '
        'enforce it, and stops. Most invented empires act instantly '
        'everywhere, which is the tell that nobody costed the roads.',
    seeAlso: ['legibility', 'capability-limit-cost', 'kinds-of-authority'],
    example: 'The decree is sealed on the first of March. It reaches the '
        'northern valleys in June, where the reeve reads it aloud and does '
        'nothing.',
  ),
  CraftEntry(
    id: 'legibility',
    family: CraftFamily.world,
    term: 'Legibility',
    oneLine: 'A state can only govern what it can see and count.',
    whatItDoes: 'Names, addresses, censuses, standard weights and surveyed '
        'land are the instruments that make a population governable at all, '
        'and each one is a plot: who is uncounted, who wants to stay that '
        'way, and what happens when the surveyors arrive.',
    seeAlso: ['where-the-writ-runs', 'kinds-of-authority'],
    example: 'The surveyors arrive in the spring. Half the village has no '
        'surname before them and two surnames after.',
  ),
  CraftEntry(
    id: 'kinds-of-authority',
    family: CraftFamily.world,
    term: 'Three reasons people obey',
    oneLine: 'Because it is ancient, because he is extraordinary, or because '
        'it is the rule.',
    whatItDoes: "Weber's three: tradition, charisma and law. Each fails in "
        'its own way — tradition to a broken succession, charisma to a death, '
        'law to a procedure nobody believes in. Naming which one a regime '
        'rests on names the crisis it is vulnerable to.',
    seeAlso: ['where-the-writ-runs', 'legibility', 'faction-monolith'],
    example: 'He holds it because his grandfather did. She holds it because '
        'people would follow her into the sea. The third holds it because the '
        'paper says so, and the paper is in a drawer.',
  ),
  CraftEntry(
    id: 'faction-monolith',
    family: CraftFamily.world,
    term: 'The faction that agrees with itself',
    oneLine: 'An institution with one opinion and no internal fight.',
    whatItDoes: 'Real institutions contain their own opposition — the wing '
        'that thinks the leadership has gone soft, the department quietly '
        'ignoring the policy. A faction with none has no way to change, and '
        'so no way to be surprising.',
    seeAlso: ['internal-argument', 'uniform-cast', 'kinds-of-authority'],
    example: 'The Order votes to send the fleet. Eleven to nine — and the nine '
        'do not stop being nine.',
  ),
  CraftEntry(
    id: 'culture-is-unexplained',
    family: CraftFamily.world,
    term: 'What nobody explains',
    oneLine: 'Culture is what a group does without deciding to.',
    whatItDoes: 'It produces the delivery rule directly: a character never '
        'explains their own culture, because noticing it means it has stopped '
        'being invisible to them. It becomes visible at a breach or to an '
        'outsider, and almost nowhere else.',
    seeAlso: ['internal-argument', 'planet-of-hats', 'exposition'],
    example: 'Nobody at the table explains why the youngest pours. The visitor '
        'reaches for the jug and the room goes quiet.',
  ),
  CraftEntry(
    id: 'internal-argument',
    family: CraftFamily.world,
    term: 'The argument is the culture',
    oneLine: 'What a group fights about among itself.',
    whatItDoes: 'What a people agree on tells you less than what divides '
        'them. Every honour culture has cheats and a vocabulary for despising '
        'them, which exists precisely because they do. The disagreement is '
        'the most efficient way to render a culture as inhabited.',
    seeAlso: ['planet-of-hats', 'faction-monolith', 'uniform-cast'],
    example: 'They agree a debt of honour is absolute. They cannot agree '
        'whether one owed to a dead man still stands, and two families have '
        'not spoken since.',
  ),
  CraftEntry(
    id: 'planet-of-hats',
    family: CraftFamily.world,
    term: 'One people, one trait',
    oneLine: 'The warrior people. The merchant people. The people of honour.',
    whatItDoes: 'A whole culture summarised in a sentence and behaving '
        'uniformly, which reads as costume however carefully the costume is '
        'researched. Class, region, generation and trade all cut across any '
        'culture, and the cuts are where the scenes are.',
    seeAlso: ['internal-argument', 'culture-is-unexplained'],
    example: '“The Vashti are a warrior people.” Against: the Vashti farmer '
        'who has never held a blade and resents the levy that takes his sons.',
  ),
  CraftEntry(
    id: 'material-culture',
    family: CraftFamily.world,
    term: 'Practices come from conditions',
    oneLine: 'What a place is like decides what its people do.',
    whatItDoes: 'A fishing settlement works to the tide, so its authority '
        'sits with whoever reads weather, its generosity is measured in a '
        'share of a catch, and its funerals answer to a sea that keeps '
        'bodies. Derived that way a culture holds together; chosen from a '
        'list it does not.',
    seeAlso: ['consequence-cascade', 'culture-is-unexplained', 'holidays'],
    example: 'No wood within forty miles. So the houses are turf, the dead are '
        'not burned, and a carved box is what a family has instead of a ring.',
  ),
  CraftEntry(
    id: 'liminality',
    family: CraftFamily.world,
    term: 'The threshold',
    oneLine: 'Separation, the in-between, and return with a new standing.',
    whatItDoes: 'The three-part shape of every rite of passage, and the '
        'middle part is the useful one: the person is no longer what they '
        'were and not yet what they will be, which is the most narratively '
        'volatile position a character can occupy.',
    seeAlso: ['invented-tradition', 'heros-journey', 'material-culture'],
    example: 'For the nine days he is neither boy nor man he sleeps outside '
        'the wall, and nobody may say his name.',
  ),
  CraftEntry(
    id: 'invented-tradition',
    family: CraftFamily.world,
    term: 'The tradition that is younger than it looks',
    oneLine: 'Ancient custom, established within living memory.',
    whatItDoes: 'Many real traditions are recent constructions that claim '
        'deep antiquity, and the claim is doing political work. A world where '
        'someone alive can remember the first year of an immemorial custom '
        'has an argument in it.',
    seeAlso: ['liminality', 'kinds-of-authority', 'holidays'],
    example: 'The Founding Procession, held every spring since time out of '
        'mind. The blacksmith\'s mother remembers the first one.',
  ),
  CraftEntry(
    id: 'taboo-and-sanction',
    family: CraftFamily.world,
    term: 'The taboo nobody pays for',
    oneLine: 'A forbidden thing with no consequence attached.',
    whatItDoes: 'If the text says a thing is unthinkable and the person who '
        'does it loses nothing, the prohibition exists only as a label. What '
        'a society actually forbids is visible in what it does to the people '
        'who transgress.',
    seeAlso: ['capability-limit-cost', 'culture-is-unexplained'],
    example: 'It is unthinkable to enter the grove. A man enters it in chapter '
        'six, and in chapter seven he is at market as usual.',
  ),
  CraftEntry(
    id: 'holidays',
    family: CraftFamily.world,
    term: 'Who dreads the holiday',
    oneLine: 'Every celebration is an ordeal for somebody.',
    whatItDoes: 'Festivals are usually written as warmth and belonging, and '
        'every real one also has the person counting the cost, the one '
        'obliged to attend, the one it reminds of a death. That asymmetry is '
        'where the scene is, and it is the question authors skip.',
    seeAlso: ['material-culture', 'invented-tradition', 'obligations'],
    example: 'The long table, the lamps, the singing. And the sister-in-law '
        'totting up what the meat cost, and the boy who is not allowed to sit '
        'down.',
  ),
  CraftEntry(
    id: 'language-depth-tiers',
    family: CraftFamily.world,
    term: 'How much language a book needs',
    oneLine: 'Sounds, words, phrases, grammar, or a working tongue.',
    whatItDoes: 'Almost every book is served by the first two, where a '
        'consistent sound system and thirty words carry the whole impression. '
        'Each tier above costs an order of magnitude more work and shows on '
        'the page in fewer places than the tier below.',
    seeAlso: ['naming-conformance', 'untranslatable-word'],
    example: 'Thirty words and one consistent sound. Against a case system '
        'that surfaces in four lines of the whole book.',
  ),
  CraftEntry(
    id: 'naming-conformance',
    family: CraftFamily.world,
    term: 'Names that came from the same place',
    oneLine: 'A language shows mostly through whether the names agree.',
    whatItDoes: 'Readers do not parse an invented grammar, and they '
        'immediately feel a name assembled from different sounds than its '
        'neighbours. Conformance across a set of names is nearly the whole '
        'perceived depth of an invented language.',
    // A map's marker labels are that column, already in one place and
    // already read in order. The exercise below is the field's own contents.
    appliesTo: ['world.map-marker.label'],
    seeAlso: ['language-depth-tiers', 'untranslatable-word'],
    exercise: 'List every name from one culture in your book in a column. '
        'Read them aloud in order. The ones that jump are the ones you '
        'invented on a different day.',
    example: 'Kethra, Vashten, Morren, Sil — and Brian.',
  ),
  CraftEntry(
    id: 'untranslatable-word',
    family: CraftFamily.world,
    term: 'The word with no English for it',
    oneLine: 'A term a character keeps because nothing else says it.',
    whatItDoes: 'It is the highest-value use of an invented language, and the '
        'only one that earns its place in dialogue: a concept the culture has '
        'and the reader does not, which teaches the culture and the word in '
        'the same line.',
    seeAlso: ['naming-conformance', 'culture-is-unexplained', 'subtext'],
    example: '“There is no word for it in your language. We say kesh — what '
        'you owe someone for a kindness you did not want.”',
  ),
  // ---------------------------------------------------------------------
  // Magic, at the three boxes an author actually fills in.
  //
  // Most of what this family already held answers a magic system directly —
  // capability/limit/cost, the unpaid price, who is allowed to have it — and
  // it was answering it on a shelf nobody had reason to open while filling in
  // a form. Those are now attached to the fields where the decision is made.
  //
  // These three are what the shelf did not have. Each one is a distinction
  // the Magic sheet asks for by giving it a separate box, and then does not
  // explain: price against boundary against hazard, what a system's ceiling
  // does to every earlier scene, and why a limit's workaround is the more
  // interesting half of the limit.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'price-boundary-hazard',
    family: CraftFamily.world,
    term: 'Price, boundary, hazard',
    oneLine: 'Three different instruments, often written as one sentence.',
    whatItDoes: 'A price is charged every time and makes each use weigh '
        'something. A boundary is absolute and decides which stories are '
        'impossible. A hazard is a chance of going wrong, and it is the only '
        'one of the three that makes a use tense while it is happening. A '
        'system that answers all three with the same sentence has one '
        'instrument and three boxes.',
    appliesTo: ['magic.magic-system.risks'],
    seeAlso: ['capability-limit-cost', 'unpaid-cost', 'the-workaround'],
    example: 'Price: a day of strength, every time. Boundary: it will not '
        'raise the dead, ever. Hazard: one working in nine goes wrong, and you '
        'find out afterwards.',
  ),
  CraftEntry(
    id: 'power-ceiling',
    family: CraftFamily.world,
    term: 'The ceiling',
    oneLine: 'The most a system has been seen to do.',
    whatItDoes: 'Readers calibrate danger against it, so every raise quietly '
        'reprices everything below: the peril of chapter three stops being '
        'frightening once chapter twenty exists. Systems that stay tense over '
        'a long book tend to raise the cost of using magic rather than the '
        'amount of it.',
    appliesTo: ['magic.magic-system.abilities'],
    seeAlso: ['unpaid-cost', 'stakes-and-proximity', 'hard-and-soft-magic'],
    exercise: 'List what your magic does, in the order the reader learns it. '
        'If the list climbs, name what got more expensive as it climbed.',
    example: 'In chapter three a mender closes a cut and it is remarkable. In '
        'chapter twenty somebody stops a river, and the cut is furniture.',
  ),
  CraftEntry(
    id: 'the-workaround',
    family: CraftFamily.world,
    term: 'The way around it',
    oneLine: 'What a limit costs to get past, if it can be got past at all.',
    whatItDoes: 'A limit nothing gets past decides what the story cannot be, '
        'and is scenery. One that can be got past, at a price somebody has to '
        'be willing to pay, decides what the story is about. The workaround '
        'is where a limitation stops being a rule and becomes a scene.',
    appliesTo: ['magic.magic-limitation.workarounds'],
    seeAlso: ['capability-limit-cost', 'price-boundary-hazard', 'unpaid-cost'],
    example: 'The gate does not open from outside. It opens for anyone willing '
        'to give it a name it will answer to, and the names all belong to '
        'somebody.',
  ),
  // ---------------------------------------------------------------------
  // Maps.
  //
  // The Map domain declares eighteen fields and fifteen of them are drawing
  // mechanics — width, height, a coordinate system, a projection, an x and a
  // y. They do nothing in a story, which is the library's entry test, and
  // explaining a projection would be an encyclopedia. The same call the
  // calendar got.
  //
  // The craft of maps is real and it is almost none of it per-field, so most
  // of what follows is reachable from the shelf rather than from a box. Two
  // fields earn a sentence — what a map costs to cross, and what resolution
  // it is drawn at — and both are about the same thing: a map is a set of
  // decisions the book will have to honour afterwards.
  // ---------------------------------------------------------------------
  CraftEntry(
    id: 'distance-is-pacing',
    family: CraftFamily.world,
    term: 'What the map costs to cross',
    oneLine: 'Every distance on it is a number of days in the book.',
    whatItDoes: 'Scale fixes travel time, and travel time fixes what the plot '
        'can do: who arrives before the thing happens, which threat is '
        'imminent and which is theoretical, how long two people are alone on '
        'a road. Drawing the continent first and costing the journeys '
        'afterwards is how armies come to cross it in a week.',
    appliesTo: ['world.map.scale'],
    seeAlso: ['where-the-writ-runs', 'readers-clock', 'map-resolution'],
  ),
  CraftEntry(
    id: 'map-resolution',
    family: CraftFamily.world,
    term: 'The map the book asks for',
    oneLine: 'A world map and a room plan do different work.',
    whatItDoes: 'One sets scope and travel and answers questions measured in '
        'weeks. The other sets sightlines and doors and answers questions '
        'measured in minutes. Maps that go unused are usually drawn at a '
        'resolution the book never asks a question at.',
    appliesTo: ['world.map.mapType'],
    seeAlso: ['distance-is-pacing', 'iceberg-rule', 'readers-map'],
  ),
  CraftEntry(
    id: 'map-is-a-claim',
    family: CraftFamily.world,
    term: 'Who drew it',
    oneLine: 'A map inside the world is a document somebody made.',
    whatItDoes: 'It shows what its maker could reach, cared to record and '
        'wanted believed, so its blank spaces, its borders and its names are '
        'arguments rather than facts. A map with no maker is the narrator\'s: '
        'accurate, neutral, and unable to be wrong about anything.',
    seeAlso: ['legibility', 'where-the-writ-runs', 'text-established-invariant'],
    exercise: 'Name who drew the map at the front of your book, and one thing '
        'they left off on purpose.',
  ),
  CraftEntry(
    id: 'readers-map',
    family: CraftFamily.world,
    term: 'The map a reader carries',
    oneLine: 'A rough topology, not your coastline.',
    whatItDoes: 'Most readers look at the map once and then navigate by what '
        'the prose keeps repeating — this is north of that, the mountains are '
        'between them, the river runs down to the city. Past the handful of '
        'relations the text restates, the detail is for the author.',
    seeAlso: ['iceberg-rule', 'distance-is-pacing', 'map-resolution'],
  ),
];
