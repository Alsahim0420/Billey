import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SpeechVoiceGender { female, male, neutral }

class SpeechVoiceOption {
  const SpeechVoiceOption({
    required this.id,
    required this.name,
    required this.gender,
    required this.description,
  });

  final String id;
  final String name;
  final SpeechVoiceGender gender;
  final String description;

  bool get isFemale => gender == SpeechVoiceGender.female;
}

class SpeechVoiceProvider extends ChangeNotifier {
  static const _storageKey = 'billey_speech_voice_id';

  static const femaleVoice = SpeechVoiceOption(
    id: 'cgSgspJ2msm6clMCkdW9',
    name: 'Jessica',
    gender: SpeechVoiceGender.female,
    description: 'Alegre y cálida · Americana',
  );

  static const maleVoice = SpeechVoiceOption(
    id: 'bIHbv24MWmeRgasZH58o',
    name: 'Will',
    gender: SpeechVoiceGender.male,
    description: 'Relajado y optimista · Americano',
  );

  static const options = [femaleVoice, maleVoice];

  SpeechVoiceOption _selectedVoice = femaleVoice;

  SpeechVoiceOption get selectedVoice => _selectedVoice;
  String get selectedVoiceId => _selectedVoice.id;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedId = preferences.getString(_storageKey);
    _selectedVoice = options.firstWhere(
      (voice) => voice.id == savedId,
      orElse: () => femaleVoice,
    );
  }

  Future<void> selectVoice(SpeechVoiceOption voice) async {
    if (_selectedVoice.id == voice.id) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, voice.id);
    _selectedVoice = voice;
    notifyListeners();
  }
}
