/// The applied lens — craft terms as fields an author fills in.
///
/// `docs/craft-library-design.md` named three lenses over one library. Two
/// were built first because they ask nothing of the author: **inline**, where
/// an entry is the helper text under a box, and **browsable**, where the same
/// entry is a card on a shelf. Both are the library talking.
///
/// This is the third, and it runs the other way. The author looks at a record
/// they wrote and says *that one is a red herring*. The claim is theirs, it is
/// about their story, and so — unlike everything else the library touches — it
/// is **canonical data and belongs on the record** (Lock 1), stored through
/// the universal field system rather than a mechanism of its own (Lock 4).
///
/// ## Why this file is not in `core/craft/`
///
/// `craft_library_test.dart` holds a one-way arrow: nothing under `core/craft/`
/// imports a record, a store or a graph, because a dictionary that knows about
/// records is one refactor away from reading them. This file is the bridge and
/// therefore sits outside, next to the field model it builds against. The
/// library still knows nothing about records; something else knows about both.
///
/// ## What it does not do
///
/// It does not recognise a convention in a manuscript, suggest one for a
/// record, or notice that a record looks like one. Lock 8 permits prose to be
/// read for its form and never for its facts, and *this scene is a red
/// herring* is a fact about a story. The app offers the vocabulary; the author
/// does the claiming. That is the entire mechanism, and the restraint is the
/// point rather than a limitation waiting to be lifted.
library;

import 'craft/craft_entry.dart';
import 'craft/craft_library.dart';
import 'record_types.dart';

/// Fields whose options are craft library terms.
class CraftFields {
  const CraftFields._();

  /// A field on which an author claims terms from [family] for their record.
  ///
  /// [subject] is what kind of record the field goes on, and it narrows the
  /// options: a character is not offered *in medias res*, because a person is
  /// not a thing a book opens in the middle of. Required rather than
  /// defaulted, so adding a third surface is a decision at the call site
  /// instead of whatever the default happened to be.
  ///
  /// The options are the family's claimable terms, alphabetical because a
  /// picker sorted by the order entries happen to be declared in is sorted by
  /// nothing the author can see. Each option carries its entry's helper, so
  /// the explanation arrives at the moment of choosing rather than in a
  /// glossary the author has to go and find — the same arrangement the inline
  /// lens already makes for `singleChoice` options.
  ///
  /// **[allowCustomValues] is true and not configurable.** Lock 7: presets
  /// configure, they never restrict. The library ships the conventions it can
  /// explain, which is a shelf and not an inventory of every convention that
  /// exists, and a field that accepted only what the library has heard of
  /// would be telling an author their book uses nothing else.
  ///
  /// [library] is injectable for the same reason `CraftLibrary`'s constructor
  /// takes additions: a project that one day ships its own entries gets them
  /// on this field without a change here.
  static RecordFieldDefinition assertion({
    required String id,
    required String label,
    required CraftFamily family,
    required CraftSubject subject,
    required int order,
    required String description,
    CraftLibrary? library,
  }) {
    final entries = assertableTerms(family, subject, library: library);
    return RecordFieldDefinition(
      id: id,
      label: label,
      type: RecordFieldType.multipleChoice,
      order: order,
      description: description,
      options: [for (final entry in entries) entry.term],
      optionDescriptions: {
        for (final entry in entries) entry.term: entry.helper,
      },
      allowCustomValues: true,
    );
  }

  /// The entries of [family] an author may claim on a [subject], in display
  /// order.
  ///
  /// Separate from [assertion] so a surface that is not a form — a shelf
  /// filtered to what can be applied, say — reads the same set rather than
  /// deriving its own and drifting.
  static List<CraftEntry> assertableTerms(
    CraftFamily family,
    CraftSubject subject, {
    CraftLibrary? library,
  }) =>
      (library ?? CraftLibrary.builtIn)
          .family(family)
          .where((entry) => entry.assertOn.contains(subject))
          .toList()
        ..sort((left, right) => left.term.compareTo(right.term));
}
