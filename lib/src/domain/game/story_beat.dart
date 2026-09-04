import 'package:equatable/equatable.dart';

/// One line of story shown as an overlay over the map, before or after a
/// level. Beats are advanced one at a time by the same forward/backward
/// controls that move between levels.
final class StoryBeat extends Equatable {
  /// Who says [text].
  final StorySpeaker speaker;

  /// The Arabic line shown in the overlay panel.
  ///
  /// A guide beat's line is never painted — the actor performs it live on
  /// stage — but the text stays here regardless: it is the record of the
  /// play, and this field is its only home.
  final String text;

  @override
  List<Object?> get props => [speaker, text];

  /// Creates a beat for [speaker].
  const StoryBeat({required this.speaker, required this.text});

  /// A beat spoken by the in-world guide character.
  const StoryBeat.guide(this.text) : speaker = StorySpeaker.guide;

  /// A beat spoken by the narrator.
  const StoryBeat.narrator(this.text) : speaker = StorySpeaker.narrator;
}

/// Who is talking in a [StoryBeat]. Each speaker gets its own overlay
/// treatment: the guide is an in-world character with a portrait and a
/// speech panel, the narrator is an out-of-world voice shown as a
/// letterboxed band.
enum StorySpeaker {
  /// The in-world companion who explains the game, hands out the next
  /// level, and confirms a clearance.
  guide,

  /// The off-screen voice that frames the journey itself.
  narrator,
}
