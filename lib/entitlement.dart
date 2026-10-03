/// What an account has bought or claimed.
///
/// [ADR-0010](../../docs/architecture/ADR-0010-five-rooms-one-database.md)
/// settles the ownership model: one-time products, not a subscription or tier
/// ladder. [ADR-0015](../../docs/architecture/ADR-0015-the-catalogue-is-code.md)
/// extends that same catalogue to Curios: if this binary can deliver a product,
/// it names that product here; price and checkout routing remain configuration.
///
/// **An entitlement is a fact about an account, not about a project or a
/// device.** A one-time purchase or claim has to reach the author's second
/// machine, so it is a synced record like the profile is.
///
/// **This file deliberately does not mention rooms.** What an author owns and
/// which door or surface opens are different questions, and the mapping belongs
/// at the gate that serves the feature.
library;

/// Something an author can own once.
enum PaidProduct {
  /// **Retired from sale, September 14, 2026.** The bundle that opened four
  /// doors: the map editor, styled relationship trees, cover design, and
  /// printed endpapers and ornaments. Reading maps, placing markers and
  /// exporting stay free, as they always did.
  ///
  /// Three of those four doors belong to other packs —
  /// [ADR-0020](../../docs/architecture/ADR-0020-the-create-bundle-is-unbundled.md)
  /// — so this licence is not renamed, re-pointed or revoked. It is **kept, and
  /// no longer offered**: it has no checkout variant, it is not one of the
  /// thirteen packs, and it still opens all four of its doors for every account
  /// that holds it. That is D3 — *what is bought stays open* — met by leaving
  /// the purchase alone rather than by migrating it.
  ///
  /// A value that vanished would be a purchase that could not be read.
  aosCreate,

  /// The map editor, and the half of Map Studio that is map *creation*.
  /// Reading a map, placing and moving markers, presenting and exporting are
  /// AOS Write's and free — the split is `MapStudioMode`'s.
  ///
  /// The successor to the map half of [aosCreate], and a **new id rather than
  /// a renamed one**: ADR-0015 fixes a wire id for the life of a purchase, so
  /// the way to sell a narrower thing is to sell a different thing.
  aosCartographer,

  /// Styled relationship trees and family trees — the drawn artefact over the
  /// free relationship records. The Ancestry Room's, and Worldsmith's to sell.
  ///
  /// The Knowledge Graph itself stays free and whole: every mode, every
  /// relationship edit and the saved canvas are AOS Write's, held by
  /// `graph_room_boundary_test.dart`.
  aosWorldsmith,

  /// Cover design: the front cover canvas, the full wrap, series branding and
  /// the promotional derivatives over them.
  aosCoverStudio,

  /// The ritual around the provocations — chosen and remembered sprint
  /// lengths, dare mode, the oracle decks, reading rhythm, streaks, the fade.
  aosUnblocked,

  /// The typeset book: ornamental chapter openers, drop caps, reusable
  /// publishing themes, trim and bleed presets, PDF/X, and the publishing
  /// preparation around them.
  ///
  /// **The manuscript itself never belongs to this.** A clean PDF, DOCX, EPUB,
  /// TXT and Markdown of the author's own words come out free, permanently —
  /// ADR-0010's first inherited principle, which
  /// [ADR-0017](../../docs/architecture/ADR-0017-write-is-complete-expansions-are-rooms.md)
  /// leaves standing: *a writer's way out of the application is not a feature
  /// it is entitled to sell them.* What this sells is the design over those
  /// words, which is presentation, exactly like a drawn map.
  ///
  /// Named here before anything gates on it, and deliberately: the registry
  /// cannot say who owns `press.typesetBook` without a value to name, and a
  /// product with no checkout slug withholds nothing. `CheckoutStore.sells`
  /// stays false until a build is given a slug for `aos-press`.
  aosPress,

  /// Hearts & Tensions — the Drawing Room, and the specialist romance
  /// workspace inside it: the Relationship Arc Designer, the Tension Map and
  /// Relationship Continuity.
  ///
  /// **The relationships themselves are not this, and never become it.**
  /// Characters and the canonical `partnerOf` edge belong to Character Studio
  /// and stay free — an author without this product keeps every relationship
  /// they have ever made, readable and editable, in the room that owns them.
  /// What is sold is the layer *over* them: an arc with stages, milestones
  /// anchored to chapters and scenes, seven tracked dynamics, and the map that
  /// plots them. That is presentation over records, which is the line
  /// ADR-0010 drew and [ADR-0017](../../docs/architecture/ADR-0017-write-is-complete-expansions-are-rooms.md)
  /// left standing.
  ///
  /// Unlike [aosPress] this takes nothing back: the room is new, nothing was
  /// carved out of Write to make it, and no author has ever had these surfaces
  /// for free. There is no grandfathering question to answer because there is
  /// no prior art to grandfather.
  ///
  /// The wire id is not chosen here. `HeartsAndTensionsExpansion.productWireId`
  /// stated it first, and `hearts_and_tensions_gate_test.dart` asserts the two
  /// still agree — one id, named in the manifest, honoured here.
  aosHeartsAndTensions,

  /// AOS Companion — the Fireside Room, and the specialist character
  /// intelligence inside it: the conversation, the discoveries it produces,
  /// and the continuity that keeps a character's answers inside what they
  /// could know.
  ///
  /// **This is the second product that sells something AuthorOS Write
  /// shipped.** [aosPress] made the reversal
  /// [ADR-0017](../../docs/architecture/ADR-0017-write-is-complete-expansions-are-rooms.md)
  /// permits, on surfaces kept to the beta branch. The Fireside Room was in
  /// the main build and an author was standing in it, which is what made this
  /// the harder of the two.
  ///
  /// **September 17, 2026: it is not any more, and it has no free tier.** The
  /// room moved to `AuthorOS-Expansions`, the way Hearts & Tensions and
  /// Politics & Power went before it, and [FiresideRoom] closed in the same
  /// change. The struck-through answer this comment used to give was:
  ///
  /// > ~~the door opens while nothing is for sale and never closes on a
  /// > conversation an author already had.~~
  ///
  /// What replaces it: the door is shut while nothing is for sale, and the
  /// conversations an author already had were never the door's to keep. They
  /// are rows in the one database ADR-0010 names, reached by the record layer
  /// that owns them, and no gate in this file can reach them either.
  /// `AuthorRoom.companion` therefore stays one of the eleven types — those
  /// records still name it.
  ///
  /// **September 18, 2026: the room is back in this build and still shut.**
  /// ADR-0023 settles that a DLC cannot arrive after the binary, so selling
  /// this product means compiling it in. That is a fact about the build, not
  /// about the gate: [FiresideRoom] still answers per account, still opens
  /// closed, and still has nothing to open for until `curio_products` carries
  /// an `aos-companion` row with a live Stripe price.
  ///
  /// **The provocation deck in this room is not this product.** When the
  /// pillar decision retired the *Stuck* type, AOS Unblocked's deck became a
  /// Companion mode — so the room holds a door that [aosUnblocked] sells, and
  /// `unblocked.ritual` stays that product's capability. Two purchases meet
  /// inside one room, which is legal and is exactly the case *one object per
  /// purchase* exists for. Neither gate may answer for the other.
  ///
  /// **The character is free, the conversation is bought.** Character records,
  /// identity, personality, backstory, goals and notes are Character Studio's
  /// and stay free; an account that owns none of this keeps every character it
  /// has ever written, readable, editable and exportable. What is sold is the
  /// specialist tier over them — `characters.specialist`, which was reserved
  /// for [ReservedSpecialist.companion] until this value existed and is now
  /// bought rather than awaited, exactly as `characters.lineage` was.
  ///
  /// The wire id is not chosen here. `CompanionExpansion.productWireId` stated
  /// it first, and `companion_gate_test.dart` asserts the two still agree.
  aosCompanion,

  /// The Common Room — a paid beta-reader room. A$14.95, one-time.
  ///
  /// **The author buys it; readers buy nothing.** The author publishes an
  /// immutable reading copy of a book and invites up to twenty-five readers per
  /// book, who read on the web and may comment, highlight and add notes — and
  /// acquire no entitlement by doing so. What this value names is the author's
  /// right to open the room and to let people in.
  ///
  /// Decided by ADR-0026, *a room other people enter*. Added September 25,
  /// 2026, and not on sale until a `curio_products` row says so, so its gate
  /// answers shut until then.
  aosCommonRoom,

  /// The first free Curio. A printable ownership plate rendered from project
  /// title and author profile metadata. It has no checkout slug because it is
  /// claimed for free, but ADR-0015 still requires the build to name what it
  /// can deliver.
  bookplateMaker,

  /// The Calendar Bible — the depth over a world's calendar: the lore of its
  /// months and days and the calendar itself, its astrology and the birth
  /// readings drawn from it, and its festivals and holy days. A paid Curio.
  ///
  /// **The calendar itself is not this, and never becomes it.** Months, their
  /// lengths, the week, eras, the epoch, date formats, conversion, story dates
  /// on the timeline and in the manuscript, and the continuity checks that
  /// read them stay AuthorOS Write's and free. What is sold is the lore over
  /// that structure — the line the constitution's first Curio drew, moved by
  /// the owner on October 3, 2026 from the whole builder to the depth alone.
  ///
  /// Shut until `curio_products` carries a `curio-calendar-bible` row with a
  /// live Stripe price. An author who already wrote lore keeps it: a field
  /// with a stored value is never withheld.
  calendarBible;

  /// The wire name, fixed independently of the Dart identifier.
  String get id => switch (this) {
        PaidProduct.aosCreate => 'aos-create',
        PaidProduct.aosCartographer => 'aos-cartographer',
        PaidProduct.aosWorldsmith => 'aos-worldsmith',
        PaidProduct.aosCoverStudio => 'aos-cover-studio',
        PaidProduct.aosUnblocked => 'aos-unblocked',
        PaidProduct.aosPress => 'aos-press',
        PaidProduct.aosHeartsAndTensions => 'aos-hearts-and-tensions',
        PaidProduct.aosCompanion => 'aos-companion',
        PaidProduct.aosCommonRoom => 'aos-common-room',
        PaidProduct.bookplateMaker => 'curio-bookplate-maker',
        PaidProduct.calendarBible => 'curio-calendar-bible',
      };

  /// Whether this was once sold and is not offered any more.
  ///
  /// **A third acquisition state, and it had to be one.** [isFreeClaim]
  /// answers *how was this acquired*; this answers *is it still offered*, and
  /// the two are independent axes. A retired product was bought, with money,
  /// by accounts that still hold it.
  ///
  /// The registry's conformance rule reads this. Without it, a retired product
  /// fails *a product that sells nothing cannot be bought honestly* — which is
  /// true of something on sale and meaningless for something withdrawn. The
  /// tempting fix is to invent a capability for it to sell, and that is
  /// precisely the mistake `curios.bookplateMaker` was reverted for: a
  /// conformance rule answered with a false statement is worse than no rule.
  bool get isRetired => switch (this) {
        PaidProduct.aosCreate => true,
        PaidProduct.aosCartographer ||
        PaidProduct.aosWorldsmith ||
        PaidProduct.aosCoverStudio ||
        PaidProduct.aosUnblocked ||
        PaidProduct.aosPress ||
        // Added September 15, 2026. `aosHeartsAndTensions` arrived on
        // September 14 with its wire id and its `isFreeClaim` answer, and this
        // switch was not given one — so `PaidProduct` stopped being
        // exhaustively matched and `lib/` stopped compiling. It is newly on
        // sale, which is the opposite of retired.
        PaidProduct.aosHeartsAndTensions ||
        // Added September 17, 2026, and the same lesson a second time: a new
        // value is not finished when `id` knows it. Newly on sale, which is
        // the opposite of retired.
        PaidProduct.aosCompanion ||
        // Added September 25, 2026, in the same change as the value — the
        // third time this switch has been the one to remember. Not yet on
        // sale, which is still not retired.
        PaidProduct.aosCommonRoom ||
        PaidProduct.bookplateMaker ||
        // Added October 3, 2026, with the value. On sale, not retired.
        PaidProduct.calendarBible =>
          false,
      };

  /// Whether this is claimed for nothing rather than bought.
  ///
  /// **The commercial vocabulary, stated once.** `PaidProduct` began as a list
  /// of things on sale, and ADR-0015 broke that premise when it admitted free
  /// Curios: the Bookplate Maker is a product this build can deliver, an
  /// entitlement an account owns and a gate `BookplateService.export` asks —
  /// but it has no price, no checkout variant and nothing on sale.
  ///
  /// Before this getter that fact was asserted in three places and owned by
  /// none: `CurioShelf` kept a private set of what may be claimed,
  /// `CurioCatalogue` kept a `priceKind` beside each entry, and
  /// `CapabilityRegistry.conformanceIssues` assumed every value here was on
  /// sale and failed the build because one was not. Three statements of one
  /// fact is the shape Lock 1 exists to refuse, and the one that can disagree
  /// with itself: a Curio marked free in the catalogue and absent from the
  /// shelf's set would render a claim button that returns false.
  ///
  /// Free is the *price*, never the gate. A claim is still an entitlement and
  /// still opens what it opens; D3 keeps it open exactly as a purchase stays
  /// open.
  bool get isFreeClaim => switch (this) {
        PaidProduct.aosCreate ||
        PaidProduct.aosCartographer ||
        PaidProduct.aosWorldsmith ||
        PaidProduct.aosCoverStudio ||
        PaidProduct.aosUnblocked ||
        PaidProduct.aosPress ||
        PaidProduct.aosHeartsAndTensions ||
        PaidProduct.aosCompanion ||
        PaidProduct.aosCommonRoom ||
        PaidProduct.calendarBible =>
          false,
        PaidProduct.bookplateMaker => true,
      };

  /// The product [id] names, or null when this build has never heard of it.
  ///
  /// Null rather than a throw: a newer build may contain something this one
  /// does not know about, and an unknown entitlement is not corrupt. The
  /// reader keeps it — see [Entitlements.unknown].
  static PaidProduct? byId(String id) {
    for (final product in PaidProduct.values) {
      if (product.id == id) return product;
    }
    return null;
  }
}

/// One purchase or free claim, as this device knows it.
class Entitlement {
  const Entitlement({
    required this.productId,
    required this.grantedAt,
    this.source = 'purchase',
  });

  /// The wire id, not the enum — so an entitlement for a product this build
  /// does not know can still be held, stored and synced onward.
  final String productId;

  final DateTime grantedAt;

  /// How it was granted. Free text because the answer may be a payment
  /// provider, a free Curio claim, or a migration source.
  final String source;

  PaidProduct? get product => PaidProduct.byId(productId);

  Map<String, Object?> toJson() => {
        'productId': productId,
        'grantedAt': grantedAt.toUtc().toIso8601String(),
        'source': source,
      };

  factory Entitlement.fromJson(Map<String, dynamic> json) => Entitlement(
        productId: (json['productId'] as String?)?.trim() ?? '',
        grantedAt:
            DateTime.tryParse(json['grantedAt'] as String? ?? '')?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        source: json['source'] as String? ?? 'purchase',
      );

  @override
  bool operator ==(Object other) =>
      other is Entitlement &&
      other.productId == productId &&
      other.grantedAt == grantedAt &&
      other.source == source;

  @override
  int get hashCode => Object.hash(productId, grantedAt, source);
}

/// Everything one account has bought or claimed.
class Entitlements {
  Entitlements(Iterable<Entitlement> held)
      : _byProductId = {
          for (final entitlement in held)
            if (entitlement.productId.isNotEmpty)
              entitlement.productId: entitlement,
        };

  static final Entitlements none = Entitlements(const []);

  final Map<String, Entitlement> _byProductId;

  Iterable<Entitlement> get all => _byProductId.values;

  bool get isEmpty => _byProductId.isEmpty;

  bool owns(PaidProduct product) => _byProductId.containsKey(product.id);

  /// Entitlements for products this build has never heard of.
  ///
  /// Kept rather than dropped so opening an older build cannot erase a newer
  /// purchase or claim when it syncs back out.
  Iterable<Entitlement> get unknown =>
      _byProductId.values.where((held) => held.product == null);

  Entitlements withGrant(Entitlement entitlement) =>
      Entitlements([...all, entitlement]);

  List<Map<String, Object?>> toJson() =>
      [for (final held in all) held.toJson()];

  factory Entitlements.fromJson(List<dynamic> json) => Entitlements([
        for (final entry in json)
          if (entry is Map)
            Entitlement.fromJson(Map<String, dynamic>.from(entry)),
      ]);
}