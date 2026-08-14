import 'package:e3dad_khodam_2026/src/data/game/journey_stops.dart';
import 'package:e3dad_khodam_2026/src/data/game/post_office_characters.dart';
import 'package:e3dad_khodam_2026/src/domain/game/character_placement.dart';

/// Where the cast stands in each level of the post-office game.
///
/// Today every level places exactly one character — the courier — so
/// these read as "the courier is in X". A second traveller is added by
/// appending a placement to the lists below, and nothing else in the app
/// has to change: trails, tokens and camera all follow from placements.
final class PostOfficePlacements {
  /// The courier in تسالونيكي.
  static const List<CharacterPlacement> thessalonica = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.thessalonica,
    ),
  ];

  /// The courier in كورنثوس.
  static const List<CharacterPlacement> corinth = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.corinth,
    ),
  ];

  /// The courier in غلاطية.
  static const List<CharacterPlacement> galatia = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.galatia,
    ),
  ];

  /// The courier in رومية.
  static const List<CharacterPlacement> rome = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.rome,
    ),
  ];

  /// The courier in فيلبي.
  static const List<CharacterPlacement> philippi = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.philippi,
    ),
  ];

  /// The courier in كولوسي.
  static const List<CharacterPlacement> colossae = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.colossae,
    ),
  ];

  /// The courier in أفسس.
  static const List<CharacterPlacement> ephesus = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.ephesus,
    ),
  ];

  /// The courier in كريت.
  static const List<CharacterPlacement> crete = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.crete,
    ),
  ];

  /// The courier in أورشليم.
  static const List<CharacterPlacement> jerusalem = [
    CharacterPlacement(
      character: PostOfficeCharacters.courier,
      stop: JourneyStops.jerusalem,
    ),
  ];

  const PostOfficePlacements._();
}
