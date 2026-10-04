/// How a decision is keyed to the thing it is about — the subject grammar.
///
/// Split from `revision_decision.dart` for a reason worth stating, because it
/// looks like tidiness and is not. `RevisionDecision` is carried in
/// `ConnectedDomainSnapshot`, and the snapshot is inside the AOS Unblocked
/// provocation engine's import closure — which Lock 8 holds to
/// `dart:collection`, `dart:math` and `package:meta`, so that *"no model wrote
/// these questions"* stays a claim about what the code can reach rather than a
/// promise. Hashing needs `dart:convert` and `package:crypto`. Keeping the
/// grammar here keeps them out of the engine's reach: the decision the engine
/// might see through the snapshot imports nothing at all, and the keying that
/// only the Revision Layer needs stays where only the Revision Layer looks.
///
/// See
/// [ADR-0011](../../docs/architecture/ADR-0011-author-decisions-about-findings.md).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// How a decision is keyed to the thing it is about.
///
/// This is the one real design risk ADR-0011 recorded rather than solved, and
/// it is answered here because it is the implementation's to answer:
///
/// > A decision is keyed to a finding, and prose moves. A key too loose
/// > re-suppresses a genuinely new finding at the same location; a key too
/// > tight loses the author's decision the moment they edit the paragraph.
///
/// The rule, stated once: **a subject is the rule, the place at its coarsest
/// durable grain, and the finding's own words — never its offsets.**
///
/// Offsets are precisely the part that moves. Adding a paragraph at the top of
/// a scene shifts every character index below it and changes nothing the author
/// decided, so a key built on `start` and `end` throws the decision away for a
/// reason that has nothing to do with the finding. The finding's own words —
/// the text it quoted, or the numbers it rests on — move *with* the prose and
/// change when the prose it describes changes. That is the behaviour wanted in
/// both directions: rewrite the sentence and a genuinely new finding surfaces;
/// rearrange the chapter around it and the dismissal holds.
///
/// The grain is chosen by the caller, and both grains are needed. V-3 asks for
/// findings "dismissible per rule and per instance": [forRule] is the rule
/// grain — *never show me this again* — and [forInstance] is the instance.
class RevisionDecisionSubject {
  const RevisionDecisionSubject._();

  /// Every subject a rule-shaped decision produces is bounded to this many
  /// characters of readable text.
  ///
  /// Subjects stay legible on purpose: they are read in tests, in an archive,
  /// and by whoever is working out why a dismissal did or did not hold. Text
  /// longer than this is replaced by a digest of the whole rather than
  /// truncated to fit, because a truncated key is a key that silently collides
  /// — two different quotes sharing a prefix would share a decision, and the
  /// author would watch a dismissal they never made suppress a finding.
  static const int maximumTextLength = 160;

  /// The rule grain: *never show me this rule here again.*
  ///
  /// [scopeId] is the scene or chapter the suppression covers, or empty for the
  /// whole book. A rule dismissed book-wide and the same rule dismissed in one
  /// scene are different decisions and get different subjects, which is what
  /// lets an author silence a house-style quibble everywhere without silencing
  /// anything they have not looked at.
  static String forRule({
    required String lens,
    required String ruleId,
    String scopeId = '',
  }) =>
      _join([lens, ruleId, scopeId]);

  /// The instance grain: *this one, here.*
  ///
  /// [text] is what the finding itself asserted — the phrase it quoted where it
  /// quoted one, and otherwise the evidence it rests on ("9 sentences, 14–17
  /// words each"). Callers pass the finding's own words, never a rendered
  /// message: a message is prose that may be reworded in a release, and
  /// rewording it would silently orphan every decision made against it.
  static String forInstance({
    required String lens,
    required String ruleId,
    required String text,
    String scopeId = '',
  }) =>
      _join([lens, ruleId, scopeId, _fingerprint(text)]);

  /// A style-sheet term — *this book spells it* Aeryn.
  ///
  /// The term is normalized, and deliberately: an author who decided about
  /// `Aeryn` has decided about `aeryn` too, since the decision is which
  /// spelling the book uses and the question is the same either way. The
  /// answer keeps its own characters — it is stored as the decision's value,
  /// which nothing here touches.
  static String forTerm(String term) => _join(['style', _fingerprint(term)]);

  /// A completed pass, named by its lens.
  static String forPass(String lens) => _join(['pass', lens]);

  /// A pair of records whose voices converge on purpose.
  ///
  /// Sorted, because the pair is unordered: the author's statement about A and
  /// B is the same statement as the one about B and A, and an unsorted key
  /// would let the same decision be made twice and dismissed once.
  static String forPair(String recordIdA, String recordIdB) {
    final pair = [recordIdA, recordIdB]..sort();
    return _join(['pair', pair.first, pair.last]);
  }

  /// Readable where it can be, hashed where it cannot.
  ///
  /// Case-folded and whitespace-collapsed so that trailing spaces and a
  /// capitalised sentence start are not two decisions. The separator is
  /// stripped rather than escaped — a subject is compared, never parsed back
  /// apart, so there is nothing for an escape to protect.
  static String _fingerprint(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(_separator, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.length <= maximumTextLength) return normalized;
    return sha256.convert(utf8.encode(normalized)).toString().substring(0, 32);
  }

  static String _join(List<String> parts) =>
      parts.where((part) => part.isNotEmpty).join(_separator);

  static const _separator = '/';
}
