import '../domain/speech_entities.dart';

abstract interface class AudioPlaybackService {
  Stream<Duration> get positionStream;

  Stream<Duration?> get durationStream;

  Stream<bool> get playingStream;

  Stream<bool> get completedStream;

  Future<void> load(GeneratedAudio audio);

  Future<void> resume();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> play(GeneratedAudio audio);

  Future<void> stop();

  Future<void> dispose();
}
