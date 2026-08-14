import 'package:e3dad_khodam_2026/src/domain/game/game_character.dart';
import 'package:e3dad_khodam_2026/src/domain/game/journey_stop.dart';
import 'package:equatable/equatable.dart';

/// Where one character stands during one level.
///
/// A level lists a placement per character on the move, which is what
/// makes several travellers possible: each one's placements across the
/// levels, read in order, are their own route — and their own trail.
final class CharacterPlacement extends Equatable {
  /// Who is standing somewhere.
  final List<GameCharacter> characters;

  /// Where they are standing during this level.
  final JourneyStop stop;

  @override
  List<Object?> get props => [characters, stop];

  /// Creates a placement.
  const CharacterPlacement({required this.characters, required this.stop});
}
