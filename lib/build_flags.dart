/// Build-time switches for expansions that are not ready to be seen.
///
/// ## Why this lives in Core
///
/// It began in `lib/expansions/`, which put an edge from
/// `built_in_record_types.dart` into the expansions library and tripped
/// `core_boundary_architecture_test`: *Core may name only Core.* The test was
/// right and the first placement was wrong. A build flag is not expansion
/// logic — it is configuration the record registry has to read to decide which
/// fields it declares — and Core already names expansions in exactly this way,
/// through `ReservedSpecialist` in `capabilities.dart`.
///
/// ## Why a compile-time flag rather than an entitlement
///
/// An entitlement answers *does this account own it*. That is the right question
/// for a product on sale, and the wrong one for a room still being built: there
/// is no product, `CapabilityRegistry.conformanceIssues` refuses a `PaidProduct`
/// that sells nothing, and a gate keyed to an account still ships the room to
/// everyone and then hides it. This flag answers a different question — *is this
/// room in this build at all* — and the honest answer for unfinished work is no.
///
/// `beta.yml` already says the beta line "deliberately does not publish". This
/// is that intent made mechanical, so it survives a branch being deployed by
/// accident or a preview URL being shared.
///
/// ## It removes the code, not just the door — with two exceptions
///
/// Every flag here is a `const`, read through `bool.fromEnvironment`. A `const
/// false` condition lets the compiler drop the branch behind it, so a build
/// without the flag does not merely hide the Council Chamber: the view, the
/// Power Network, the structure model, the four field definitions and every
/// string of the room's interior are eliminated from `main.dart.js` by tree
/// shaking. Verified against the artefact rather than assumed — `beta.yml`
/// greps the built bundle.
///
/// **The name is gated too, and the router's contract survived it.** The
/// section's `label` and `slug` are switch cases on the free shell's own enum,
/// reached because `studioSectionForSlug` walks every value — so no guard
/// elsewhere can drop them, and an earlier cut of this flag left the words
/// "Council Chamber" and "council-chamber" legible in a shipped bundle. Hiding
/// a room whose name a stranger can read is not hiding it.
///
/// Both cases are now gated as well, which raised the question of what a gated
/// section's address should *be*. `authoros_route_test` asks four things of one
/// — non-empty, URL-safe, unique, and round-tripping back to its section — and a
/// blank slug fails three. So the placeholder is derived from the enum index:
/// `unavailable-25` and `Unavailable (25)`. The index is already observable and
/// says nothing about the room, it keeps slugs and labels unique however many
/// sections are gated, and every rule the router asks still holds in both
/// builds. The invariant was kept rather than renegotiated; what moved is the
/// name.
///
/// The rest only holds while the guards stay `const`-shaped. Do not route one
/// of these through a variable, a getter that takes an argument, or a runtime
/// setting: the moment the condition stops being const, the branch comes back
/// into the output and the flag degrades into a hidden feature.
///
/// ## What it must never gate
///
/// **An author's records and their stored values.** The four political fields
/// this flag withholds live on the canonical `faction` record, and a project
/// authored in a build that had them keeps every value when opened in a build
/// that does not: unknown stored keys are preserved by the tolerant readers the
/// free types already use, and `politics_and_power_gate_test.dart` holds that.
///
/// The flag decides what an author is *offered*. It never decides what they keep.
library;

/// Whether Politics & Power exists in this build.
///
/// Off by default, and deliberately: the safe build is the one without an
/// unfinished paid room in it, so shipping the room has to be an explicit act.
///
/// Turn it on for a development build, a local test run or the beta
/// verification job:
///
/// ```
/// flutter run   --dart-define=AOS_ENABLE_POLITICS=true
/// flutter test  --dart-define=AOS_ENABLE_POLITICS=true
/// flutter build web --release --dart-define=AOS_ENABLE_POLITICS=true
/// ```
///
/// When this graduates to a real product the flag does not become the
/// entitlement — it is deleted, and `world.politicalModelling` gains a
/// `soldBy`. The two mechanisms answer different questions and should never
/// both be load-bearing at once.
const politicsAndPowerEnabled =
    bool.fromEnvironment('AOS_ENABLE_POLITICS');

/// Whether Hearts & Tensions exists in this build.
///
/// Off by default, for the reason above and one of its own. **This room was
/// shipping its door without its code.** When the pack moved to
/// `AuthorOS-Expansions` under ADR-0023 the section stayed behind, ungated:
/// `AuthorRoom.heartsTensions` was in the sidebar map unconditionally, the slug
/// and label read `drawing-room` and `Drawing Room`, and the section rendered
/// `_RoomNotInThisBuild`. So every author got a HEARTS & TENSIONS heading over a
/// row that opened *"Nothing here"* — the advertisement
/// [politicsAndPowerEnabled] exists to prevent, for a room that was not merely
/// unfinished but absent.
///
/// The comment that stood there argued the entitlement gate was enough: *"gated
/// by entitlement rather than by compilation."* That was true while the room was
/// in the build and stopped being true when it left. `DrawingRoom` fails open by
/// design — `opensDrawingRoom` returns true for a product not on sale, and true
/// again before its first read — so with no code behind it the gate could only
/// ever show everybody the same dead door. **An entitlement cannot gate a room
/// that is not there**; only a build flag can, which is this file's opening
/// argument reached from the other direction.
///
/// Turn it on for a development build, a local test run or the beta
/// verification job:
///
/// ```
/// flutter run   --dart-define=AOS_ENABLE_HEARTS=true
/// flutter test  --dart-define=AOS_ENABLE_HEARTS=true
/// flutter build web --release --dart-define=AOS_ENABLE_HEARTS=true
/// ```
///
/// **Both mechanisms are load-bearing here, and that is not the thing this file
/// warns against.** The warning above is against a flag and an entitlement
/// answering the *same* question. These answer two: the flag says whether the
/// Drawing Room is compiled in at all, and `appDrawingRoom` says whether this
/// account may write arcs once it is. A flagged build still honours the gate,
/// which is what makes a flagged build worth testing — it is the shipping
/// behaviour, not a bypass of it.
///
/// When Hearts & Tensions goes on sale the flag is deleted, not repurposed, and
/// what replaces it is a checkout variant rather than a second guard: until
/// `CheckoutCatalogue` carries the product, `isOnSale` is false and the gate
/// opens for everyone by design.
const heartsAndTensionsEnabled =
    bool.fromEnvironment('AOS_ENABLE_HEARTS');
