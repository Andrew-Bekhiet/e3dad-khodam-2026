/// How a leg of the journey was travelled.
///
/// This is a fact about the journey, not about how the trail is drawn —
/// but it decides where the leg's route geometry comes from, because a
/// road service can only answer for one of them.
enum LegKind {
  /// Travelled overland. Its route geometry comes from a road service.
  land,

  /// Travelled chiefly by ship. Its route geometry is charted by hand,
  /// since no road service will route across the Aegean — and two of the
  /// journey's stops, كريت among them, cannot be reached by road at all.
  ///
  /// A sea leg's chart may still begin or end with a short overland
  /// approach: غلاطية and كولوسي are inland, and the ship stopped at the
  /// nearest port.
  sea,
}
