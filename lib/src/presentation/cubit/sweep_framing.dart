/// How wide a sweep pulls out before it dives on its destination.
///
/// A phone shows the same basin in a third of the pixels, where two
/// cities at opposite ends of it are a pair of dots nobody can read. The
/// leg being walked is the part of the journey the sweep is about, so on
/// a small screen that is all it frames.
enum SweepFraming {
  /// Out to the whole Mediterranean.
  basin,

  /// Out to just the leg being walked: where the party stands, and where
  /// they are going.
  leg,
}
