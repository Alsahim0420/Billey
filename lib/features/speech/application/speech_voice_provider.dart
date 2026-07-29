import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechVoiceOption {
  const SpeechVoiceOption({
    required this.id,
    required this.name,
    required this.isFemale,
  });

  final String id;
  final String name;
  final bool isFemale;
}

class SpeechVoiceProvider extends ChangeNotifier {
  static const _storageKey = 'billey_speech_voice_id';

  static const femaleVoice = SpeechVoiceOption(
    id: 'hpp4J3VqNfWAUOO0d1Us',
    name: 'Bella',
    isFemale: true,
  );

  static const maleVoice = SpeechVoiceOption(
    id: 'iP95p4xoKVk53GoZ742B',
    name: 'Chris',
    isFemale: false,
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
