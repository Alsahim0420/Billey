import 'package:billey/features/speech/application/speech_voice_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses Jessica by default', () async {
    final provider = SpeechVoiceProvider();

    await provider.initialize();

    expect(provider.selectedVoice, SpeechVoiceProvider.femaleVoice);
  });

  test('persists the selected voice', () async {
    final provider = SpeechVoiceProvider();
    await provider.initialize();

    await provider.selectVoice(SpeechVoiceProvider.maleVoice);

    final restoredProvider = SpeechVoiceProvider();
    await restoredProvider.initialize();
    expect(restoredProvider.selectedVoice, SpeechVoiceProvider.maleVoice);
  });

  test('migrates a removed catalog voice to Jessica', () async {
    SharedPreferences.setMockInitialValues({
      'billey_speech_voice_id': 'hpp4J3VqNfWAUOO0d1Us',
    });
    final provider = SpeechVoiceProvider();

    await provider.initialize();

    expect(provider.selectedVoice, SpeechVoiceProvider.femaleVoice);
    expect(provider.selectedVoice.name, 'Jessica');
  });
}
