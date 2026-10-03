library;

/// The edges that can say when a scene happens.
///
/// Moved from AOS Write's `lib/core/story_clock.dart` on October 3, 2026, so
/// the Continuity Engine's calendar detector reads exactly the edges the Story
/// Clock reads. The app re-exports it.
///
/// All four are declared open in the built-in registry, carry
/// `temporalSupport`, and were reachable from a scene before this file
/// existed. **No fifth edge was invented to hold a date** — the same rule the
/// world projection followed when it read holdings.
class StoryClockLinks {
  const StoryClockLinks._();

  /// The scene happens inside the span of an event. The usual one.
  static const during = 'during';

  /// The Timeline vocabulary's own phrasing of the same relationship.
  static const occursDuring = 'occursDuring';

  /// The scene and the event run alongside each other.
  static const concurrentWith = 'concurrentWith';

  /// Written from the event: *this event is depicted in that scene*.
  ///
  /// Read in reverse, because an author working in Timeline Studio links
  /// outward from the event and an author working in the manuscript links
  /// outward from the scene. Both are the same fact and both are read.
  static const depictedIn = 'depictedIn';

  /// Edges whose **source** is the scene.
  static const fromScene = {during, occursDuring, concurrentWith};

  /// Edges whose **target** is the scene.
  static const toScene = {depictedIn};

  /// Every edge this file reads, in either direction.
  static const all = {...fromScene, ...toScene};
}
