import '../domain/speech_entities.dart';

abstract interface class AudioPlaybackService {
  Future<void> play(GeneratedAudio audio);

  Future<void> stop();

  Future<void> dispose();
}
