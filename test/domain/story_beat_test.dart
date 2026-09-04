import 'package:e3dad_khodam_2026/src/domain/game/story_beat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StoryBeat_theGuide_keepsHerTextEvenThoughItIsNeverPainted', () {
    const beat = StoryBeat.guide('نبدأ من تسالونيكي');

    expect(beat.text, 'نبدأ من تسالونيكي');
    expect(beat.speaker, StorySpeaker.guide);
  });

  test('StoryBeat_theNarrator_keepsHerText', () {
    const beat = StoryBeat.narrator('في تلك الأيام');

    expect(beat.text, 'في تلك الأيام');
    expect(beat.speaker, StorySpeaker.narrator);
  });

  test('StoryBeat_sameSpeakerAndText_areEqual', () {
    const first = StoryBeat.guide('نفس الكلام');
    const second = StoryBeat.guide('نفس الكلام');

    expect(first, second);
  });

  test('StoryBeat_theSameLineFromDifferentSpeakers_areNotEqual', () {
    const guide = StoryBeat.guide('نفس الكلام');
    const narrator = StoryBeat.narrator('نفس الكلام');

    expect(guide, isNot(narrator));
  });
}
