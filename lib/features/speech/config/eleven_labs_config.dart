import 'secret_provider.dart';

class ElevenLabsConfig {
  const ElevenLabsConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.voiceId,
    required this.textToSpeechModelId,
    required this.speechToTextModelId,
    required this.outputFormat,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 45),
    this.sendTimeout = const Duration(seconds: 45),
  });

  factory ElevenLabsConfig.fromSecrets(SecretProvider secrets) {
    return ElevenLabsConfig(
      baseUrl: Uri.parse('https://api.elevenlabs.io'),
      apiKey: secrets.getRequired('ELEVENLABS_API_KEY'),
      // STT does not require a voice. TTS validates this value on demand.
      voiceId: secrets.getOptional('ELEVENLABS_VOICE_ID')?.trim() ?? '',
      textToSpeechModelId:
          secrets.getOptional('ELEVENLABS_TTS_MODEL_ID') ?? 'eleven_flash_v2_5',
      speechToTextModelId:
          secrets.getOptional('ELEVENLABS_STT_MODEL_ID') ?? 'scribe_v2',
      outputFormat:
          secrets.getOptional('ELEVENLABS_OUTPUT_FORMAT') ?? 'mp3_44100_128',
    );
  }

  final Uri baseUrl;
  final String apiKey;
  final String voiceId;
  final String textToSpeechModelId;
  final String speechToTextModelId;
  final String outputFormat;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
}
