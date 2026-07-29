import 'result.dart';
import 'speech_entities.dart';

abstract interface class SpeechRepository {
  Future<Result<Transcript>> transcribe({required RecordedAudio audio});

  Future<Result<GeneratedAudio>> synthesize({required String text});
}
