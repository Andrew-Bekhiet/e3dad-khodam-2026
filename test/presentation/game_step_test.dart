import 'package:e3dad_khodam_2026/src/data/game/post_office_script.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_step.dart';
import 'package:e3dad_khodam_2026/src/presentation/cubit/game_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameScript_buildsTypedStepsForEachPartOfThePlay', () {
    final script = GameScript(PostOfficeScript.script);

    expect(script.stepAt(0), isA<OpeningStep>());
    expect(script.steps.whereType<PrologueStep>(), isNotEmpty);
    expect(script.steps.whereType<BriefingStep>(), isNotEmpty);
    expect(
      script.steps.whereType<PlayingStep>(),
      hasLength(script.script.levels.length),
    );
    expect(script.steps.whereType<ClearanceStep>(), isNotEmpty);
  });
}
