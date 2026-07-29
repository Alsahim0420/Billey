import 'dart:io';

import 'result.dart';
import 'speech_entities.dart';
import 'speech_repository.dart';

class TranscribeAudioUseCase {
  const TranscribeAudioUseCase(this._repository);

  final SpeechRepository _repository;

  Future<Result<Transcript>> call(RecordedAudio audio) async {
    final file = File(audio.path);
    if (!await file.exists()) {
      return const ErrorResult(
        InvalidAudioFailure('La grabación de audio no existe.'),
      );
    }
    if (await file.length() == 0) {
      return const ErrorResult(
        InvalidAudioFailure('La grabación de audio está vacía.'),
      );
    }
    return _repository.transcribe(audio: audio);
  }
}
