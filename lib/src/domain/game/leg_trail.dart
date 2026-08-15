/// Whether a leg leaves a line behind it.
///
/// Separate from `LegKind`, which says how the leg was travelled: a leg
/// can be a real sea crossing and still be left untraced, and the two
/// questions have never had the same answer.
enum LegTrail {
  /// Traced on the map, and walked by the party as the camera flies.
  drawn,

  /// Crossed without a line, and without anyone walking it: the party is
  /// simply somewhere new when the camera lands.
  ///
  /// A leg with no chart is *not* this. A missing chart is an absence
  /// nobody has filled in yet and still draws a blunt straight line; this
  /// is a deliberate silence.
  undrawn,
}
