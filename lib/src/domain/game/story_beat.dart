import 'package:equatable/equatable.dart';

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

/// One line of story shown as an overlay over the map, before or after a
/// level. Beats are advanced one at a time by the same forward/backward
/// controls that move between levels.
final class StoryBeat extends Equatable {
  /// Who says [text].
  final StorySpeaker speaker;

  /// The Arabic line shown in the overlay panel.
  final String text;

  /// Optional heading above [text], e.g. a level name or "أحسنتم!".
  final String? title;

  @override
  List<Object?> get props => [speaker, text, title];

  /// Creates a beat for [speaker].
  const StoryBeat({required this.speaker, required this.text, this.title});

  /// A beat spoken by the in-world guide character.
  const StoryBeat.guide(this.text, {this.title}) : speaker = StorySpeaker.guide;

  /// A beat spoken by the narrator.
  const StoryBeat.narrator(this.text, {this.title})
    : speaker = StorySpeaker.narrator;
}
