import 'package:http/http.dart' as http;

import 'application/speech_assistant_controller.dart';
import 'config/eleven_labs_config.dart';
import 'config/encrypted_environment_secret_provider.dart';
import 'data/eleven_labs_remote_data_source.dart';
import 'data/eleven_labs_speech_repository.dart';
import 'domain/generate_speech_use_case.dart';
import 'domain/transcribe_audio_use_case.dart';
import 'services/just_audio_playback_service.dart';
import 'services/record_audio_recorder_service.dart';

class SpeechDependencies {
  const SpeechDependencies._();

  static Future<SpeechAssistantController> initialize() async {
    final secrets = EncryptedEnvironmentSecretProvider();
    await secrets.initialize();
    final config = ElevenLabsConfig.fromSecrets(secrets);
    final remoteDataSource = HttpElevenLabsRemoteDataSource(
      config: config,
      client: http.Client(),
    );
    final repository = ElevenLabsSpeechRepository(remoteDataSource);
    return SpeechAssistantController(
      recorder: RecordAudioRecorderService(),
      playback: JustAudioPlaybackService(),
      transcribeAudio: TranscribeAudioUseCase(repository),
      generateSpeech: GenerateSpeechUseCase(repository),
    );
  }
}
