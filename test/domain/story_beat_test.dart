import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StoryBeat_aGuideLine_speaksFromTheAppBarUnlessToldOtherwise', () {
    const beat = StoryBeat.guide('نبدأ من تسالونيكي');

    expect(beat.emphasis, BeatEmphasis.callout);
  });

  test('StoryBeat_aGuideLineGivenThePanel_keepsIt', () {
    const beat = StoryBeat.guide('طويل', emphasis: BeatEmphasis.panel);

    expect(beat.emphasis, BeatEmphasis.panel);
  });

  test('StoryBeat_theNarrator_isAlwaysStagedAsACutscene', () {
    const beat = StoryBeat.narrator('في تلك الأيام');

    expect(beat.emphasis, BeatEmphasis.panel);
  });

  test('StoryBeat_twoLinesDifferingOnlyInEmphasis_areNotEqual', () {
    const callout = StoryBeat.guide('نفس الكلام');
    const panel = StoryBeat.guide('نفس الكلام', emphasis: BeatEmphasis.panel);

    expect(callout, isNot(panel));
  });
}
