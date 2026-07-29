import 'dart:typed_data';

import '../domain/speech_entities.dart';

class SpeechToTextResponseDto {
  const SpeechToTextResponseDto({
    required this.text,
    this.languageCode,
    this.languageProbability,
  });

  factory SpeechToTextResponseDto.fromJson(Map<String, dynamic> json) {
    final text = json['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const FormatException(
        'ElevenLabs devolvió una transcripción vacía.',
      );
    }
    final probability = json['language_probability'];
    return SpeechToTextResponseDto(
      text: text.trim(),
      languageCode: json['language_code'] is String
          ? json['language_code'] as String
          : null,
      languageProbability: probability is num ? probability.toDouble() : null,
    );
  }

  final String text;
  final String? languageCode;
  final double? languageProbability;

  Transcript toDomain() => Transcript(
        text: text,
        languageCode: languageCode,
        languageProbability: languageProbability,
      );
}

class GeneratedAudioDto {
  const GeneratedAudioDto({
    required this.bytes,
    required this.mimeType,
    required this.format,
    this.requestId,
    this.characterCost,
  });

  final Uint8List bytes;
  final String mimeType;
  final String format;
  final String? requestId;
  final int? characterCost;

  GeneratedAudio toDomain() => GeneratedAudio(
        bytes: bytes,
        mimeType: mimeType,
        format: format,
        requestId: requestId,
        characterCost: characterCost,
      );
}
