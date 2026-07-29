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
    id: 'hpp4J3VqNfWAUOO0d1Us',
    name: 'Bella',
    gender: SpeechVoiceGender.female,
    description: 'Cálida y brillante · Americana',
  );

  static const maleVoice = SpeechVoiceOption(
    id: 'iP95p4xoKVk53GoZ742B',
    name: 'Chris',
    gender: SpeechVoiceGender.male,
    description: 'Cercana y natural · Americano',
  );

  static const options = [
    femaleVoice,
    SpeechVoiceOption(
      id: 'EXAVITQu4vr4xnSDxMaL',
      name: 'Sarah',
      gender: SpeechVoiceGender.female,
      description: 'Madura y confiable · Americana',
    ),
    SpeechVoiceOption(
      id: 'FGY2WhTYpPnrIDTdsKH5',
      name: 'Laura',
      gender: SpeechVoiceGender.female,
      description: 'Expresiva y peculiar · Americana',
    ),
    SpeechVoiceOption(
      id: 'Xb7hH8MSUJpSbSDYk0k2',
      name: 'Alice',
      gender: SpeechVoiceGender.female,
      description: 'Clara y educativa · Británica',
    ),
    SpeechVoiceOption(
      id: 'XrExE9yKIg1WjnnlVkGX',
      name: 'Matilda',
      gender: SpeechVoiceGender.female,
      description: 'Profesional y clara · Americana',
    ),
    SpeechVoiceOption(
      id: 'cgSgspJ2msm6clMCkdW9',
      name: 'Jessica',
      gender: SpeechVoiceGender.female,
      description: 'Alegre y cálida · Americana',
    ),
    SpeechVoiceOption(
      id: 'pFZP5JQG7iQjIQuC4Bku',
      name: 'Lily',
      gender: SpeechVoiceGender.female,
      description: 'Suave y elegante · Británica',
    ),
    maleVoice,
    SpeechVoiceOption(
      id: 'CwhRBWXzGAHq8TQ4Fs17',
      name: 'Roger',
      gender: SpeechVoiceGender.male,
      description: 'Casual y relajado · Americano',
    ),
    SpeechVoiceOption(
      id: 'IKne3meq5aSn9XLyUdCD',
      name: 'Charlie',
      gender: SpeechVoiceGender.male,
      description: 'Profundo y enérgico · Australiano',
    ),
    SpeechVoiceOption(
      id: 'JBFqnCBsd6RMkjVDRZzb',
      name: 'George',
      gender: SpeechVoiceGender.male,
      description: 'Narrador cálido · Británico',
    ),
    SpeechVoiceOption(
      id: 'N2lVS1w4EtoT3dr4eOWO',
      name: 'Callum',
      gender: SpeechVoiceGender.male,
      description: 'Ronco y expresivo · Americano',
    ),
    SpeechVoiceOption(
      id: 'SOYHLrjzK2X1ezoPC6cr',
      name: 'Harry',
      gender: SpeechVoiceGender.male,
      description: 'Intenso y fuerte · Americano',
    ),
    SpeechVoiceOption(
      id: 'TX3LPaxmHKxFdv7VOQHJ',
      name: 'Liam',
      gender: SpeechVoiceGender.male,
      description: 'Joven y energético · Americano',
    ),
    SpeechVoiceOption(
      id: 'bIHbv24MWmeRgasZH58o',
      name: 'Will',
      gender: SpeechVoiceGender.male,
      description: 'Relajado y optimista · Americano',
    ),
    SpeechVoiceOption(
      id: 'cjVigY5qzO86Huf0OWal',
      name: 'Eric',
      gender: SpeechVoiceGender.male,
      description: 'Suave y confiable · Americano',
    ),
    SpeechVoiceOption(
      id: 'nPczCjzI2devNBz1zQrb',
      name: 'Brian',
      gender: SpeechVoiceGender.male,
      description: 'Profundo y reconfortante · Americano',
    ),
    SpeechVoiceOption(
      id: 'onwK4e9ZLuTAKqWW03F9',
      name: 'Daniel',
      gender: SpeechVoiceGender.male,
      description: 'Estable, tipo locutor · Británico',
    ),
    SpeechVoiceOption(
      id: 'pNInz6obpgDQGcFmaJgB',
      name: 'Adam',
      gender: SpeechVoiceGender.male,
      description: 'Firme y dominante · Americano',
    ),
    SpeechVoiceOption(
      id: 'pqHfZKP75CvOlQylNhV4',
      name: 'Bill',
      gender: SpeechVoiceGender.male,
      description: 'Maduro y equilibrado · Americano',
    ),
    SpeechVoiceOption(
      id: 'SAz9YHcvj6GT2YYXdXww',
      name: 'River',
      gender: SpeechVoiceGender.neutral,
      description: 'Relajada e informativa · Neutral',
    ),
  ];

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
