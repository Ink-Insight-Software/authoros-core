/// Map Studio Phase 7 — deterministic seeding.
///
/// Plain Dart on purpose, like every other file under `lib/core`: the
/// generation engine must be resolvable in a test without a Flutter binding.
///
/// [Lock 9][lock] requires generation to be deterministic, seed-driven and
/// reproducible. Those three words are one mechanism, and this file is it.
/// Nothing in a generator may call `Random()`, read the clock, or iterate an
/// unordered collection — every value comes from here.
///
/// ## Why every number here is 32 bits
///
/// AuthorOS runs on the Dart VM *and* in a browser. On the VM an `int` is a
/// 64-bit integer; on the web it is a JavaScript double, where `&`, `^` and
/// `>>>` are defined on the low 32 bits and integers above 2^53 are not exact.
/// A 64-bit generator would therefore produce one world on the desktop app and
/// a different one on the web build from the same seed.
///
/// So the arithmetic here stays inside 32 bits, and the one operation that
/// cannot — multiplication, which overflows a double's exact range — goes
/// through [_mul32], which splits it into halves that stay exact. The result is
/// a generator whose output is identical on both platforms, which is what
/// "reproducible" has to mean for an app that ships to both.
///
/// [lock]: ../../docs/architecture/authoros-architecture-lock.md
library;

/// A reproducible source of derived randomness.
///
/// A seed is an immutable 32-bit value plus the path that produced it. Two
/// things make it useful for a hierarchy of generators:
///
/// **Derivation is pure.** `seed.derive('city:3')` returns the same child seed
/// every time, for the same parent and the same label. A generator never has to
/// thread a mutable random source through its call tree; it derives the seed for
/// each thing it produces from the thing's own address.
///
/// **Siblings are independent.** Deriving `'city:3'` does not disturb
/// `'city:4'`. Regenerating one district cannot change the district beside it,
/// which is what makes selective regeneration possible at all.
class GenerationSeed {
  const GenerationSeed._(this.value, this.path, this.rootValue);

  /// The root seed for [value], at the root of the generation tree.
  factory GenerationSeed.root(int value) {
    final mixed = _fmix32(value & _mask32);
    return GenerationSeed._(mixed, const [], mixed);
  }

  /// The root seed for a human-typed seed phrase.
  ///
  /// Authors type words, not 32-bit integers. `'Endovier'` is a seed; so is
  /// `'the cold north'`. The mapping is a pure hash, so the same phrase is
  /// always the same world.
  factory GenerationSeed.phrase(String phrase) {
    final mixed = _fmix32(_hash32(_fnvOffset32, phrase));
    return GenerationSeed._(mixed, const [], mixed);
  }

  /// A seed read back from storage, exactly as it was written.
  ///
  /// Not [GenerationSeed.root], and the difference is the entire reason this
  /// exists: `root` *hashes* what it is given, so `root(seed.value)` is a
  /// different seed from `seed`. That is right for an author typing a number and
  /// wrong for reading one back — a stored seed has already been through the
  /// mixer, and putting it through again produces a different world from the one
  /// the record was written for.
  ///
  /// Provenance never needed this: it records a seed to *report* it, and never
  /// replays one. Phase 8A does, because a height field is stored as a base that
  /// gets replayed rather than as sixty thousand numbers.
  factory GenerationSeed.stored(
    int value, {
    List<String> path = const [],
    int? rootValue,
  }) =>
      GenerationSeed._(
        value & _mask32,
        List.unmodifiable(path),
        (rootValue ?? value) & _mask32,
      );

  /// The 32-bit seed value.
  final int value;

  /// The value at the root of this seed's tree.
  ///
  /// Carried down every [derive] so a seed anywhere in the tree can say which
  /// generation it belongs to. A path alone cannot: every world has a
  /// `world/continent:1`, so two worlds in one project share most of their
  /// shallow addresses, and matching on the path alone makes one world's
  /// records answer for another's — measured in Phase 8F as seven of the first
  /// world's records being replaced when a second was adopted beside it.
  final int rootValue;

  /// The address of this seed in the generation tree, root first.
  ///
  /// Carried so a generated record can record *where* it came from, not merely
  /// that it was generated. `['world', 'continent:1', 'city:4']` is a legible
  /// answer to "what produced this?" in a way a bare integer is not.
  final List<String> path;

  /// The seed for [label] beneath this one.
  ///
  /// The label is any stable address — `'continent:2'`, `'river'`,
  /// `'room:kitchen'`. Stability is the whole contract: a generator that labels
  /// its children by loop index produces the same world twice, and a generator
  /// that labels them by iteration order over a `Set` does not.
  GenerationSeed derive(String label) => GenerationSeed._(
        _fmix32(_hash32(value, label)),
        [...path, label],
        rootValue,
      );

  /// A stream of values drawn from this seed.
  ///
  /// The stream is the one piece of mutable state in the engine, and it is
  /// deliberately local: a generator takes a stream, draws from it in a fixed
  /// order, and discards it. Two generators never share one.
  GenerationRandom random() => GenerationRandom._(value);

  /// A value in `[0, 1)` derived from this seed and the point ([a], [b]).
  ///
  /// The same answer [derive] would reach for a coordinate label, without
  /// building the label or the child seed's path. A noise field samples this
  /// hundreds of thousands of times per world, and at that volume the string
  /// and the list it would otherwise allocate are the whole cost of generation.
  ///
  /// Pure in the coordinates, so the field can be sampled in any order and
  /// still give the same world.
  double unitAt(int a, int b) {
    var hash = _fmix32(value ^ _mul32(a & _mask32, 0x27D4EB2D));
    hash = _fmix32(hash ^ _mul32(b & _mask32, 0x165667B1));
    return hash / _twoPow32;
  }

  /// This seed's address as a single string, for provenance and diagnostics.
  String get pathLabel => path.isEmpty ? 'root' : path.join('/');

  @override
  String toString() => 'GenerationSeed($value, $pathLabel)';

  @override
  bool operator ==(Object other) =>
      other is GenerationSeed &&
      other.value == value &&
      other.pathLabel == pathLabel;

  @override
  int get hashCode => Object.hash(value, pathLabel);
}

/// A deterministic value stream.
///
/// SplitMix32: a counter advanced by a fixed odd increment, passed through a
/// strong finalising mix. Chosen over `dart:math`'s `Random` for one reason that
/// matters more than raw quality — its algorithm is fixed here, in this file,
/// so a world generated today still generates identically after an SDK upgrade.
class GenerationRandom {
  GenerationRandom._(int seed) : _state = seed & _mask32;

  int _state;

  /// The next raw 32-bit value.
  int nextInt32() {
    _state = (_state + _gamma32) & _mask32;
    return _fmix32(_state);
  }

  /// The next value in `[0, bound)`.
  ///
  /// Rejection-sampled rather than taken modulo, so the low values are not
  /// slightly more likely than the high ones. A generator asking for one of
  /// three biomes gets a third each, not 34/33/33.
  int nextInt(int bound) {
    if (bound <= 0) {
      throw ArgumentError.value(bound, 'bound', 'Must be positive');
    }
    // The largest multiple of `bound` that fits in 32 bits. Draws at or above
    // it would wrap and over-represent the low remainder, so they are redrawn.
    final limit = _twoPow32 - (_twoPow32 % bound);
    while (true) {
      final draw = nextInt32();
      if (draw < limit) return draw % bound;
    }
  }

  /// The next value in `[0.0, 1.0)`.
  double nextDouble() => nextInt32() / _twoPow32;

  /// The next value in `[min, max)`.
  double nextRange(double min, double max) => min + nextDouble() * (max - min);

  /// True with probability [chance], clamped to `[0, 1]`.
  bool nextChance(double chance) {
    if (chance <= 0) return false;
    if (chance >= 1) return true;
    return nextDouble() < chance;
  }

  /// One element of [items], uniformly.
  ///
  /// Takes a `List` and not an `Iterable` deliberately: choosing from a `Set`
  /// would make the result depend on hash iteration order, which is exactly the
  /// kind of accidental non-determinism Lock 9 exists to prevent.
  T pick<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Cannot pick from empty list');
    }
    return items[nextInt(items.length)];
  }

  /// A shuffled copy of [items], leaving the original untouched.
  List<T> shuffled<T>(List<T> items) {
    final copy = [...items];
    for (var i = copy.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final swap = copy[i];
      copy[i] = copy[j];
      copy[j] = swap;
    }
    return copy;
  }

  /// A value clustered toward the middle of `[min, max)`.
  ///
  /// The average of two uniform draws. Useful wherever a uniform spread would
  /// look obviously synthetic — settlement sizes, room proportions, the width of
  /// a river — because natural quantities cluster and uniform ones do not.
  double nextCentred(double min, double max) =>
      min + (nextDouble() + nextDouble()) / 2 * (max - min);
}

const int _mask32 = 0xFFFFFFFF;
const int _twoPow32 = 4294967296;
const int _gamma32 = 0x9E3779B9;
const int _fnvOffset32 = 0x811C9DC5;
const int _fnvPrime32 = 0x01000193;

/// FNV-1a over [text], starting from [start].
int _hash32(int start, String text) {
  var hash = start & _mask32;
  for (final unit in text.codeUnits) {
    hash = _mul32(hash ^ unit, _fnvPrime32);
  }
  return hash;
}

/// Murmur3's 32-bit finaliser.
///
/// Also used to condition raw seed values, so a root seed of `1` and a root seed
/// of `2` produce worlds with nothing visibly in common. Without it, adjacent
/// seeds produce adjacent-looking output, and "try seed 2" would feel like it
/// barely changed anything.
int _fmix32(int value) {
  var h = value & _mask32;
  h = (h ^ (h >>> 16)) & _mask32;
  h = _mul32(h, 0x85EBCA6B);
  h = (h ^ (h >>> 13)) & _mask32;
  h = _mul32(h, 0xC2B2AE35);
  return (h ^ (h >>> 16)) & _mask32;
}

/// 32-bit multiplication that is exact on the VM and in a browser.
///
/// The direct product of two 32-bit values needs up to 64 bits, which a
/// JavaScript double cannot hold exactly. Splitting the left operand into
/// 16-bit halves keeps each partial product under 2^48 — comfortably inside a
/// double's exact range — and the halves are recombined with shifts that are
/// already defined as 32-bit on both platforms.
int _mul32(int a, int b) {
  final left = a & _mask32;
  final right = b & _mask32;
  final low = (left & 0xFFFF) * right;
  final high = ((left >>> 16) * right) & _mask32;
  return (low + ((high << 16) & _mask32)) & _mask32;
}
