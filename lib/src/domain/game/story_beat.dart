import 'package:equatable/equatable.dart';

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

  /// How much room the guide's line is given. Read only for
  /// [StorySpeaker.guide]: the narrator is always staged as a cutscene.
  final BeatEmphasis emphasis;

  @override
  List<Object?> get props => [speaker, text, title, emphasis];

  /// Creates a beat for [speaker].
  const StoryBeat({
    required this.speaker,
    required this.text,
    this.emphasis = BeatEmphasis.callout,
    this.title,
  });

  /// A beat spoken by the in-world guide character.
  const StoryBeat.guide(
    this.text, {
    this.emphasis = BeatEmphasis.callout,
    this.title,
  }) : speaker = StorySpeaker.guide;

  /// A beat spoken by the narrator.
  const StoryBeat.narrator(this.text, {this.title})
    : speaker = StorySpeaker.narrator,
      emphasis = BeatEmphasis.panel;
}

/// How much of the screen a guide's beat takes.
///
/// Chosen per beat by whoever writes the script rather than inferred from
/// the text: Arabic character counts do not track rendered height —
/// diacritics, ligatures and a variable font all break the correlation —
/// so a measured guess would flip a line's staging on a reword.
enum BeatEmphasis {
  /// A speech bubble from the guide's portrait in the app bar. The
  /// default: she is standing right there, and most of what she says is
  /// an aside.
  callout,

  /// The full centred panel, for the lines that open and close the
  /// journey and deserve the screen.
  panel,
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
