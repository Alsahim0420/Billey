import '../domain/speech_entities.dart';

abstract interface class AudioRecorderService {
  Future<bool> hasPermission();

  Future<void> start();

  Future<RecordedAudio> stop();

  Future<void> cancel();

  Future<bool> get isRecording;

  Future<double> get currentAmplitudeDb;
}
