import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:equatable/equatable.dart';

/// How far a destination card is open.
sealed class Reveal extends Equatable {
  static Reveal ceilingFor({
    required GameStep step,
    required int verseCount,
  }) => switch (step) {
    OpeningStep() || EpilogueStep() => const CardHidden(),
    PrologueStep() || BriefingStep() => const SignShowing(),
    PlayingStep() || ClearanceStep() =>
      verseCount == 0 ? const SignShowing() : VersesShowing(verseCount),
  };

  static Reveal floorFor({
    required GameStep step,
    required bool opensBlank,
  }) => switch (step) {
    OpeningStep() || EpilogueStep() => const CardHidden(),
    PrologueStep() ||
    BriefingStep() ||
    PlayingStep() ||
    ClearanceStep() => opensBlank ? const CardHidden() : const SignShowing(),
  };

  bool get showsSign;

  int get versesShown;

  const Reveal();

  /// Whether the card is on screen at all.
  ///
  /// A briefing gets the map to itself: the arrival and the line
  /// explaining it are one moment, and raising the sign underneath puts a
  /// second thing on screen to read. The card comes up on the press that
  /// leaves the briefing. The prologue is spoken over the first city and
  /// belongs to that level, but it introduces the journey rather than the
  /// letter, so it never raises the card either.
  bool showsCard({required GameStep step, required bool hasLevel}) =>
      hasLevel &&
      showsSign &&
      step is! PrologueStep &&
      step is! BriefingStep;

  bool isArriving({required bool opensBlank}) =>
      opensBlank && this is CardHidden;

  bool hasNext({required GameStep step, required int verseCount}) =>
      this != ceilingFor(step: step, verseCount: verseCount);

  Reveal next({required GameStep step, required int verseCount}) {
    final ceiling = ceilingFor(step: step, verseCount: verseCount);
    if (this == ceiling) {
      return this;
    }

    return switch (this) {
      CardHidden() => const SignShowing(),
      SignShowing() => const VersesShowing(1),
      VersesShowing(:final shown) => VersesShowing(shown + 1),
    };
  }

  Reveal previous({required Reveal floor}) {
    if (this == floor) {
      return this;
    }

    return switch (this) {
      CardHidden() => const CardHidden(),
      SignShowing() => const CardHidden(),
      VersesShowing(shown: 1) => const SignShowing(),
      VersesShowing(:final shown) => VersesShowing(shown - 1),
    };
  }

  List<String> revealedVerses({
    required List<String> carriedVerses,
    required List<String> levelVerses,
  }) => [
    ...carriedVerses,
    ...levelVerses.take(versesShown),
  ];
}

final class CardHidden extends Reveal {
  @override
  bool get showsSign => false;

  @override
  int get versesShown => 0;

  @override
  List<Object?> get props => const [];

  const CardHidden();
}

final class SignShowing extends Reveal {
  @override
  bool get showsSign => true;

  @override
  int get versesShown => 0;

  @override
  List<Object?> get props => const [];

  const SignShowing();
}

final class VersesShowing extends Reveal {
  final int shown;

  @override
  bool get showsSign => true;

  @override
  int get versesShown => shown;

  @override
  List<Object?> get props => [shown];

  const VersesShowing(this.shown);
}
