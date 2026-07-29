import 'dart:typed_data';

class Transcript {
  const Transcript({
    required this.text,
    this.languageCode,
    this.languageProbability,
  });

  final String text;
  final String? languageCode;
  final double? languageProbability;
}

class GeneratedAudio {
  const GeneratedAudio({
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
}

class RecordedAudio {
  const RecordedAudio({
    required this.path,
    required this.mimeType,
    this.duration,
  });

  final String path;
  final String mimeType;
  final Duration? duration;
}
