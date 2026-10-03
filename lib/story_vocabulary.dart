/// The words AuthorOS reads a story graph with.
///
/// Which connection types mean *appears in a scene*, which record types carry
/// a storyline, which links Characters Studio treats as a relationship. Six
/// declarations that decide what every detector and every provocation is
/// about.
///
/// They lived beside the detectors, which was right while the detectors were
/// the only reader. AOS Unblocked's engine is the second, and a second shell
/// over that engine — one that reads a `.authoros` file with no database and
/// no Flutter binding — is the third. Core cannot import
/// `continuity/detectors.dart`: it names `ManuscriptScene`, declared beside
/// `shared_preferences` and drift.
///
/// So the declarations moved down rather than being copied across. There is
/// still exactly one of each, and `project_survey.dart` re-exports them so
/// every existing reader imports what it always did.
library;

/// The record categories that count as worldbuilding.
///
/// Selecting by category rather than by a hardcoded list of type ids means an
/// author's own custom types are included automatically: a custom type
/// declares the category it belongs to, and derived types inherit their
/// parent's when they do not override it.
///
/// `maps` and `routes` are excluded on purpose. A map marker with no
/// manuscript connection is a normal map marker, not a finding.
const worldbuildingCategoryIds = <String>{
  'world',
  'locations',
  'factions',
  'culture',
  'religion',
  'magic',
  'history',
  'items',
  'lore',
  'creatures',
  'technology',
};

/// The category every character record type belongs to.
const characterCategoryId = 'characters';

/// The category of records that annotate a character and belong on its page
/// alone: a Character Chat interview, a conversation with the character.
///
/// They were filed under [characterCategoryId], and everything that selects
/// characters by category took them for characters. Continuity reported
/// "Fears & Secrets — Vincenzo never appears in the manuscript", and the same
/// rule fed them to every other cast reader. A session is a note *about* a
/// character, made on that character's page, and nothing past that page has a
/// use for it.
const characterNotesCategoryId = 'character-notes';

/// The record types in [characterNotesCategoryId].
///
/// For a surface that lists every record a project holds rather than selecting
/// by category — search, the Story Codex, the graph — so it can leave these
/// out the way it leaves out `CodexInfrastructureTypes.all`. Literal ids, as
/// this file imports nothing: they are `kCharacterChatSessionTypeId` and
/// `kInterrogationSessionTypeId`, and AOS-Write's tests hold the two in step.
const characterNotesTypeIds = <String>{
  'character-chat-session',
  'interrogation-session',
};

/// The connection types that mean "this record reaches the manuscript".
const manuscriptConnectionTypeIds = <String>{'appearsIn', 'mentionedIn'};

/// The character-to-character connection types Characters Studio treats as a
/// relationship, taken from `CharacterService.getCharacterRelationships` so
/// the two never drift apart.
const relationshipConnectionTypeIds = <String>{
  'relatedTo',
  'parentOf',
  'guardianOf',
  'friendOf',
  'enemyOf',
  'alliedWith',
  'rivalOf',
  'mentors',
  'partnerOf',
  'knows',
};

/// Plot types that carry a storyline a scene can belong to.
const plotlineTypeIds = <String>{
  'plotline',
  'subplot',
  'arc',
  'character-arc',
  'relationship-arc',
  'world-arc',
  'political-arc',
  'romance-arc',
  'mystery-arc',
};

/// The connection types that put a scene inside a plotline.
const plotSceneConnectionTypeIds = <String>{
  'appearsIn',
  'plannedFor',
  'fulfilledBy',
  'resolvesIn',
  'depicts',
};
